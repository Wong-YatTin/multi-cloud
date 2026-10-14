# Define commands in an array
commands=(
    "kubectl create secret generic pgvector-secrets --from-literal=postgres-password=admin"
    "kubectl create secret generic langchain-gemini-service-secrets --from-file=key.json=/workspaces/muti-cloud/kubernetes/key.json"
    "kubectl apply -f /workspaces/muti-cloud/kubernetes/pgvector-statefulSet.yaml"
    "kubectl apply -f /workspaces/muti-cloud/kubernetes/langchain-gemini-service-deployment.yaml"
    "kubectl apply -f /workspaces/muti-cloud/kubernetes/langchain-gemini-service-svc.yaml"
    "kubectl apply -f /workspaces/muti-cloud/kubernetes/gke-langchain-gemini-ingress.yaml"
)

# 設置 GKE 連線
echo "連接到 GKE 叢集..."
gcloud container clusters get-credentials gke-private-cluster --region asia-east2 --project vtc-project-427316

# Loop through each command
for cmd in "${commands[@]}"; do
    echo "執行: $cmd"
    eval "$cmd"
done

# 等待 Ingress 獲得外部 IP
echo "等待 Ingress 獲得 IP..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress[0].ip}' ingress/langchain-gemini-ingress --timeout=300s

# 獲取 Ingress 的外部 IP
echo "獲取 Ingress 外部 IP..."
GKE_IP=$(kubectl get ingress langchain-gemini-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "GKE Ingress IP: $GKE_IP"


if [ -f /workspaces/muti-cloud/terraform/terraform.tfvars ]; then
    echo "gke_ip = \"$GKE_IP\"" >> /workspaces/muti-cloud/terraform/terraform.tfvars
else
    echo "gke_ip = \"$GKE_IP\"" > /workspaces/muti-cloud/terraform/terraform.tfvars
fi

echo "GKE 部署完成，Cloudflare 設定完成後，API 將可通過 https://api.hkiit-assistant.me 訪問"
