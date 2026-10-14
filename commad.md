連接到您的 AKS 叢集
```bash
az login
az aks get-credentials --resource-group ResourceGroup --name AKSCluster

az aks command invoke --resource-group ResourceGroup --name AKSCluster --command "kubectl apply -f - <<EOF
$(cat pgvector-statefulSet.yaml)
EOF"
```
`az aks command invoke --resource-group ResourceGroup --name AKSCluster --command " kubectl get pod "`

k8s 
```bash 
kubectl create secret generic pgvector-secrets --from-literal=postgres-password=admin
```
```bash
az aks command invoke --resource-group ResourceGroup --name AKSCluster --command "kubectl create secret generic pgvector-secrets --from-literal=postgres-password=admin"

```bash
kubectl create secret generic langchain-gemini-service-serets --from kubectl create secret generic my-json-secret --from-file=./workspaces/muti-cloud/kubernetes /key.json
```