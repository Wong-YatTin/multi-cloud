# Define commands in an array
commands=(
    "kubectl create secret generic pgvector-secrets --from-literal=postgres-password=admin"
    "kubectl create secret generic langchain-gemini-service-secrets --from-file=key.json=/dev/stdin <<EOF
$(cat /workspaces/muti-cloud/kubernetes/key.json)
EOF"
    "kubectl apply -f - <<EOF
$(cat /workspaces/muti-cloud/kubernetes/pgvector-statefulSet.yaml)
EOF"
    "kubectl apply -f - <<EOF
$(cat /workspaces/muti-cloud/kubernetes/langchain-gemini-service-deployment.yaml)
EOF"
    "kubectl apply -f - <<EOF
$(cat /workspaces/muti-cloud/kubernetes/langchain-gemini-service-svc.yaml)
EOF"
    "kubectl apply -f - <<EOF
$(cat /workspaces/muti-cloud/kubernetes/aks-langchain-gemini-ingress.yaml)
EOF"
)

# Loop through each command
for cmd in "${commands[@]}"; do
    az aks command invoke \
        --resource-group ResourceGroup \
        --name AKSCluster \
        --command "$cmd"
done

# 等待 Ingress 獲得外部 IP
echo "等待 Ingress 獲得 IP..."
az aks command invoke \
    --resource-group ResourceGroup \
    --name AKSCluster \
    --command "kubectl wait --for=jsonpath='{.status.loadBalancer.ingress[0].ip}' ingress/langchain-gemini-ingress --timeout=300s"

# 獲取 Ingress 的外部 IP
echo "獲取 Ingress 外部 IP..."
az aks command invoke \
    --resource-group ResourceGroup \
    --name AKSCluster \
    --command "kubectl get ingress langchain-gemini-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'" \
    --output json > /workspaces/muti-cloud/terraform/azure/lb_ip.json

# 從 JSON 輸出中提取 IP
AKS_IP=$(jq -r '.value.result' /workspaces/muti-cloud/terraform/azure/lb_ip.json)
echo "AKS Ingress IP: $AKS_IP"

# 將 IP 輸出到共用的 variable.tfvars 檔案（使用絕對路徑）
if [ -f /workspaces/muti-cloud/terraform/terraform.tfvars ]; then
    echo "aks_ip = \"$AKS_IP\"" >> /workspaces/muti-cloud/terraform/terraform.tfvars
else
    echo "aks_ip = \"$AKS_IP\"" > /workspaces/muti-cloud/terraform/terraform.tfvars
fi

echo "AKS 部署完成，Cloudflare 設定完成後，API 將可通過 https://api-azure.hkiit-assistant.me 訪問"
echo "請執行 terraform apply -var-file=variable.tfvars 完成 Cloudflare 配置"

