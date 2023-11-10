#!/bin/sh

kubectl create namespace monitoring

helm upgrade --install prometheus prometheus-community/prometheus  \
 --set alertmanager.persistentVolume.enabled=false \
 --set server.persistentVolume.enabled=false \
 --namespace monitoring

echo "Installing Grafana"
kubectl apply -f ./monitoring/grafana/grafana.yaml
helm upgrade --install grafana grafana/grafana --namespace monitoring --values ./monitoring/grafana/values.yaml

echo "Ingress rule"
kubectl apply -f ./monitoring/grafana/ingress.yaml
echo " http://monitoring.<DOMAIN>" 

echo "Get admin secret"
echo "----------------"
echo "kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode" 
echo "Import dashboards from ./grafana/dashboards"
