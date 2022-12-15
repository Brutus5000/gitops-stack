echo "Bootstrapping up ArgoCD"
echo "based on https://www.arthurkoziel.com/setting-up-argocd-with-helm/"

kubectl create namespace argocd
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm dep update charts/argo-cd/
helm install argo-cd charts/argo-cd/ --wait

helm template apps/ | kubectl apply -f -

PASSWORD=$(kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "The admin password is: ${PASSWORD}"
echo "We urge to change it immediately and write down the new one!"
echo "Once synced please run:"
echo "    kubectl delete secret -l owner=helm,name=argo-cd"
echo "This frees argocd from helm management"
echo
echo "We are now portforwarding the ui to https://localhost:8443"
kubectl port-forward svc/argo-cd-argocd-server 8443:443
