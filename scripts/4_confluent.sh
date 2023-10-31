#!/bin/sh  

echo "Deploy the cluster"
# Deploy the cluster
kubectl apply -f ./crds/kraftcontroller.yaml
kubectl apply -f ./crds/kafka.yaml
kubectl apply -f ./crds/kafkarest.yaml
kubectl apply -f ./crds/schemaregistry.yaml
kubectl apply -f ./crds/controlcenter.yaml
kubectl apply -f ./crds/topic.yaml  

#HTTPS + Basic Auth  
kubectl apply -f ./crds/c3-ingress.yaml

## mTLS external
kubectl apply -f ./crds/kafkaingress.yaml
kubectl apply -f ./crds/kafkabootstrap.yaml   

echo "Wait for the cluster to be ready"
echo "openssl s_client -connect kafka.$DOMAIN:443"
 
 
 