# Confluent For Kubernetes (CFK) - KRAFT playground

This is a playground for [KRAFT](https://developer.confluent.io/learn/kraft/) running with [CFK](https://docs.confluent.io/operator/current/overview.html)

## Prerequisites

- A Kubernetes cluster.
  
- [Kubectl](https://kubernetes.io/docs/reference/kubectl/), with cluster context configured.
  
- [Helm](https://helm.sh/)

- [OpenSSL](https://www.openssl.org/): `openssl` command line tool.

- [CFSSL](https://github.com/cloudflare/cfssl) command: `cfssl`

## Confluent For Kubernetes

Confluent For Kubernetes

Resoources:

- KraftControllers
- Kafka
- Schema Registry
- Control Center

Networking:

- Internal communication (TLS): Autogenerated Certificates by the Operator.
- External communication (Ingress. TLS Host based routing): Custom Certificates.

External Listener:

- Authentication: mTLS

### Generate certificates

### 1. Deploy

- `scripts/1_helm_setup.sh`

Confluent For Kubernetes Operator with KRAFT enabled, Namespace: `confluent`, and NGINX Ingress Controller.

### 2. Create Certificates

**Replace** `$DOMAIN` with your domain name in the certificates configuration.

Example of using a fake DNS Domain like [nip.io](https://nip.io/).

Use: `kubectl get svc ingress-nginx-controller -o json | jq .status.loadBalancer.ingress` to get the IP address of the ingress controller.

Using a fake DNS Domain: $DOMAIN = `<load_balancer_ip>.nip.io`

`sed -i '' -e 's/$DOMAIN/<load_balancer_ip>.nip.io/g' FILENAME`

Generate certificates: `scripts/2_certs.sh`

All files will be created under the `certs/generated` directory.

### 3. Secrets

Create Kubernetes Secrets: `scripts/3_secrets.sh`

### 4. Deploy Confluent Platform

- Kraft Controllers
- Brokers
- Schema Registry
- Control Center
- Demo Topic

**Update** the `$DOMAIN` variable in the `crds` files:

- Control Center ingress: `controlcenter.$DOMAIN` - `./scripts/crds/c3-ingress.yaml`
  
- Kafka ingress: `kafka.$DOMAIN:433`, `b0.$DOMAIN`, `b1.$DOMAIN`, `b2.$DOMAIN` - `./scripts/crds/kafkaingress.yaml`
  
- Kafka external access: `domain: $DOMAIN` - `./scripts/crds/kafka.yaml`

**Deploy**: `scripts/4_confluent.sh`

Control center: Open Browser `https://controlcenter.$DOMAIN`

### Kafka Clients

#### Internal clients

- Use the autogenerated certificates.

`scripts/config/internal.properties`

```properties
bootstrap.servers=kafka.confluent.svc.cluster.local:9071
security.protocol=SSL
ssl.truststore.location=/mnt/sslcerts/truststore.jks
ssl.truststore.password=mystorepassword
```

- Demo producer (`kafka-producer-perf-test`) to topic `demo.topic`, it uses internal listener with SSL.

```sh
kubectl apply -f ./crds/producer.yaml
```

it uses `kafka-client-config-secure` secret created previously.

```yaml
   ...
      volumes:
        # This application pod will mount a volume for Kafka client properties from 
        # the secret `kafka-client-config-secure`
        - name: kafka-properties
          secret:
            secretName: kafka-client-config-secure
        # Confluent for Kubernetes, when configured with autogenerated certs, will create a
        # JKS keystore and truststore and store that in a Kubernetes secret named `kafka-generated-jks`.
        # Here, this client appliation will mount a volume from this secret so that it can use the JKS files.
        - name: kafka-ssl-autogenerated
          secret:
            secretName: kafka-generated-jks
```

#### External clients (mTLS authentication)

Client certificates: `script/5_clients.sh`

Use custom certificates. `scripts/config/external.properties`

```properties
security.protocol=SSL

ssl.truststore.type=PEM
ssl.truststore.location=<FULL_PATH>/certs/generated/cacerts.pem
security.protocol=SSL

ssl.keystore.type=PKCS12
ssl.keystore.location=<FULL_PATH>/certs/generated/user.p12
ssl.keystore.password=changeme
```

Test client:

```sh
kafka-topics --bootstrap-server kafka.$DOMAIN:443 \
--command-config ./scripts/config/external.properties \ 
--topic demo.topic \
--describe
```

**librdkafka** client:

```yml
security.protocol: SSL 
ssl.ca.location: "<FULL_PATH>/certs/generated/cacerts.pem"
ssl.certificate.location: "<FULL_PATH>/certs/generated/user.pem"
ssl.key.location: "<FULL_PATH>/certs/generated/user-key.pem"
ssl.key.password: "mystorepassword" 
```

## Extra - GKE

- Create GKE (example):

```sh
gcloud beta container --project <PROJECT_ID> clusters create "cluster-gke-1" \
--zone "<ZONE>" --no-enable-basic-auth --cluster-version "1.27.3-gke.100" \
--release-channel "regular" --machine-type "e2-standard-4" --image-type "COS_CONTAINERD" \
--disk-type "pd-balanced" --disk-size "500" --metadata disable-legacy-endpoints=true \
--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write", \
"https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol", \
"https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
--max-pods-per-node "110" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias \ 
--network "projects/<PROJECT_ID>/global/networks/<NETWORK_ID>" \ 
--subnetwork "projects/<PROJECT_ID>/regions/<REGION>/subnetworks/<SUBNETID>" \
--no-enable-intra-node-visibility --default-max-pods-per-node "110" \ 
--no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
--enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 \
--enable-shielded-nodes --node-locations "<ZONE>"
```

- Get GKE credentials (example):
  
```sh
gcloud container clusters get-credentials cluster-gke-1 --zone <ZONE> --project <PROJECT_ID>
```
