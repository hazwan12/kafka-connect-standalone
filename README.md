# Kafka Connect Standalone

## About The Project
This repo guides 

## Getting Started

### Prerequisites
- kubectl
```sh
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubectl
```

- helm
```sh
sudo apt-get update && sudo apt-get install apt-transport-https --yes
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update && sudo apt-get install helm
```
- [Confluent Cluster](https://docs.confluent.io/cloud/current/clusters/create-cluster.html)

- [Confluent Cluster API Key](https://docs.confluent.io/cloud/current/access-management/authenticate/api-keys/api-keys.html#create-a-resource-specific-api-key)

### Installation
Below steps on installing the Confluent Kafka Connect and Control Center on a Kubernetes environment

1. Create a Namespace in Kubernetes
```sh
kubectl create namespace confluent
```

2. Set default Namespace to the one created in step 1
```sh
kubectl config set-context --current --namespace confluent
```

3. Install Confluent Operator
```sh
helm repo add confluentinc https://packages.confluent.io/helm
helm repo update
helm upgrade --install operator confluentinc/confluent-for-kubernetes
```

4. Generate SSL Certificates
```sh
openssl genrsa -out ca-key.pem 2048
openssl req -new -key ca-key.pem -x509 \
  -days 1000 \
  -out ca.pem \
  -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"
```

5. Replace the API Key and Secret in the `creds-client-kafka-sasl-user.txt` file
```
username=<api-key>
password=<api-secret>
```

6. Replace the API Key, Secret and Cloud Cluster URL in the `kafka.properties`
```
      bootstrap.servers=<cloudKafka_url>:9092
      security.protocol=SASL_SSL
      sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule   required username="<api-key>"   password="<api-secret>";
      ssl.endpoint.identification.algorithm=https
      sasl.mechanism=PLAIN
```

7. Create Kubernetes Secrets from SSL 
```sh
kubectl create secret tls ca-pair-sslcerts --cert=ca.pem --key=ca-key.pem
kubectl create secret generic cloud-plain --from-file=plain.txt=creds-client-kafka-sasl-user.txt
kubectl create secret generic control-center-user --from-file=basic.txt=creds-control-center-users.txt
kubectl create secret generic kafka-client-config-secure --from-file=kafka.properties -n confluent
```

8. Replace the `<cloudKafka_url>` in the `confluent-platform.yaml` file with the Cloud Cluster URL for both Connect and Control Center
```
  dependencies:
    kafka:
      bootstrapEndpoint: <cloudKafka_url>:9092
      authentication:
        type: plain
        jaasConfig:
          secretRef: cloud-plain
      tls:
        enabled: true
        ignoreTrustStoreConfig: true 
```

9. Deploy Kafka Connect and Control Center
```sh
kubectl apply -f confluent-platform.yaml
```

10. Port Forward the Control Centre Pod
```sh
kubectl port-forward controlcenter-0 9021:9021
```

11. Validate the Control Centre by navigating to the below link. Login using username `admin` and password `Developer1` 
```sh
https://localhost:9021
```

### Teardown
```
kubectl delete -f confluent-platform.yaml
kubectl delete secrets cloud-plain control-center-user kafka-client-config-secure
kubectl delete secret ca-pair-sslcerts
helm delete operator
```
