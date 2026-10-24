# Deploy and manage Multi Cloud Kubernetes with Terraform (ITP4121  assignment)

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

**A private API server on Azure.** Workers are private on both clouds, but Azure's control plane is
private too, which is why `kubectl` never runs from the laptop — every command goes through
`az aks command invoke`. The alternative is a bastion host; `command invoke` needs no extra
infrastructure and leaves the topology untouched. Every call pays a pod-start delay, and that is the
part I would revisit first.

**Ingress in front of ClusterIP services.** The API is reached only through an `Ingress`, and every
service — including the database — stays `ClusterIP`. One entry point per cluster keeps TLS and
routing in a single place, and no service can accidentally become public.

**Postgres with pgvector, initialised by a ConfigMap.** The database choice follows the workload,
which needs similarity search next to the data. The `vector` extension is created by an init script
mounted from a ConfigMap, so a fresh volume initialises itself. The cost is that backups and failover
are mine to own — flagged below rather than hidden.

**Two-phase apply across three providers.** Cloudflare's DNS and pool config need ingress addresses
that only exist after the clusters are built, so the rollout scripts write the real address back to
`terraform.tfvars` and a second `apply` publishes it. I considered a polling `null_resource`; it
would have been fewer lines and much harder to debug when it timed out.

**TCP health checks at the edge.** Cloudflare's HTTP monitor marked healthy origins down: the
origins terminate TLS at the cloud load balancer, and the edge probes on 443. A TCP monitor measures
reachability without unwinding the TLS chain, which is the property I actually needed.

