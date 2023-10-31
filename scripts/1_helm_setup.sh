#!/bin/sh 

#Create the namespace for the confluent workloads
echo "Creating the namespace for the confluent workloads"
kubectl create namespace confluent

# Setup the CFK Operator - Kraft enabled
echo "Installing the CFK Operator"
helm repo add confluentinc https://packages.confluent.io/helm 
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update  
helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes --namespace confluent --set kRaftEnabled=true 

## Setup NGINX
helm upgrade  --install ingress-nginx ingress-nginx/ingress-nginx --set controller.extraArgs.enable-ssl-passthrough="true" 

 