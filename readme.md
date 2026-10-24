# Multi-Cloud Kubernetes Platform
### Azure AKS + GCP GKE, provisioned with Terraform, fronted by Cloudflare global load balancing

> **My role:** architecture and implementation of the entire stack — Azure and GCP infrastructure,
> the Kubernetes platform, and the application deployment. Coursework, built and demoed end-to-end
> on both clouds, then torn down.

Two private Kubernetes clusters — one per cloud — run the same LangChain + Gemini service over a
`pgvector` PostgreSQL StatefulSet. Cloudflare health-checks both origins and steers traffic between
them. No node in either cluster has a public IP.

**Stack:** Terraform · Azure (AKS, VNet, NAT Gateway, Log Analytics) · GCP (GKE, Cloud NAT, Cloud
Logging) · Kubernetes 1.31 · Cloudflare DNS / GSLB / TLS · PostgreSQL + pgvector · LangChain ·
Gemini · Bash

## What the brief fixed

At least two cloud providers, Kubernetes inside a private VPC, a stateful database, credentials in
Kubernetes `Secret`s, a cloud-native load balancer behind an `Ingress`, TLS, application logs shipped
to each cloud's logging service, and a global DNS layer for cross-cloud availability. Everything in
the next section is what I decided inside those lines.

## Architecture

```mermaid
flowchart LR
    C([Client]) --> CF["Cloudflare<br/>DNS · TLS · Global LB<br/>dynamic latency steering"]

    subgraph AZ["Azure · East Asia"]
        A1["AKS private cluster<br/>2 node pools"]
        A2["langchain-gemini-service ×2"]
        A3[("pgvector<br/>StatefulSet")]
        A4[("Log Analytics")]
        A1 --> A2 --> A3
        A2 -.-> A4
    end

    subgraph GCP["GCP · asia-east2"]
        G1["GKE private node pool"]
        G2["langchain-gemini-service ×2"]
        G3[("pgvector<br/>StatefulSet")]
        G4[("Cloud Logging")]
        G1 --> G2 --> G3
        G2 -.-> G4
    end

    CF --> A1
    CF --> G1
```

Azure runs two node pools, one in each of two private subnets, spread across two availability zones;
GKE runs a single private node pool across two zones. Node pools autoscale (AKS 1–2 per pool, GKE
1–3) and egress through managed NAT. Azure's API server is private; GKE's control-plane endpoint is
public but restricted by authorised networks.

## Design decisions

**Private workers were required; a private API server was my call.** The brief asked for workers in
private subnets. On Azure I also made the control plane private, which is why `kubectl` never runs
from the laptop and every command goes through `az aks command invoke`. The alternative is a bastion
host; `command invoke` needs no extra infrastructure and leaves the topology untouched. Every call
pays a pod-start delay, and that is the part I would revisit first.

**Ingress in front of ClusterIP services.** The brief asked for a cloud-native load balancer via
`Ingress`. Keeping every service `ClusterIP` was mine: one entry point per cluster holds TLS and
routing in a single place, and a service cannot accidentally become public.

**Postgres with pgvector, initialised by a ConfigMap.** A stateful database was required; choosing
`pgvector` was driven by the workload, which needs similarity search next to the data. The `vector`
extension is created by an init script mounted from a ConfigMap, so a fresh volume initialises
itself. The cost is that backups and failover are mine to own — flagged below rather than hidden.

**Two-phase apply across three providers.** Cloudflare's DNS and pool config need ingress addresses
that only exist after the clusters are built, so the rollout scripts write the real address back to
`terraform.tfvars` and a second `apply` publishes it. I considered a polling `null_resource`; it
would have been fewer lines and much harder to debug when it timed out.

**TCP health checks at the edge.** Cloudflare's HTTP monitor marked healthy origins down: the
origins terminate TLS at the cloud load balancer, and the edge probes on 443. A TCP monitor measures
reachability without unwinding the TLS chain, which is the property I actually needed.

## Problems hit

| Problem | Resolution |
|---|---|
| The upstream multi-cloud reference stopped applying — module APIs had moved | `terraform init -upgrade`, then rewrote the deprecated arguments |
| GKE apply failed on disabled APIs | `google_project_service` with `for_each`, sequenced behind Cloud Resource Manager |
| Private clusters had no public endpoint to point DNS at | captured ingress addresses post-rollout; second apply configures DNS |
| Pods in private subnets could not pull images | NAT Gateway (Azure) / Cloud NAT (GCP) with explicit subnet associations |
| PVC initialisation failed on the mounted volume | `PGDATA` moved to a subdirectory so `lost+found` did not block `initdb` |

## Known limitations

- **Coursework scope, not production.** One workload, one region per cloud, no backup or disaster
  recovery story, and no automated tests — verification was manual.
- **GKE's control-plane endpoint is open to `0.0.0.0/0`.** The cluster has private nodes, but
  `master_authorized_networks` was left wide to keep `kubectl` usable; it should be narrowed to the
  operator's address range.
- **Terraform state is local** — no remote backend or locking.
- **Ingress addresses are ephemeral.** Both clouds hand out a new IP on rebuild, which is what forces
  the second apply; reserved static IPs would remove it.
- **AKS ingress needs the Application Gateway controller enabled.** The manifest declares the class;
  AGIC has to be on the cluster to reconcile it.
- **`local-exec` paths are absolute** (`/workspaces/...`) — `path.module` would make them portable.
- **Static service-account key.** Workload Identity (GKE) / Workload Identity Federation (AKS) would
  remove the JSON key entirely.
