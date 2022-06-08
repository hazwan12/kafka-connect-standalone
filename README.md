# Kafka Connect On Prem

## About The Project
This repo 

## Getting Started

### Prerequisites
- kubectl
```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```
- helm
```sh
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### Installation
Below is an example on how to install the Confluent Kafka Connect and Control Center on a Kubernetes environment

1. Create a Namespace in Kubernetes
```sh
kubectl create namespace confluent
```
3. Set default Namespace to the one created in step 1
```sh
kubectl config set-context --current --namespace confluent
```
5. Install Confluent Operator
```sh
helm repo add confluentinc https://packages.confluent.io/helm
helm repo update
helm upgrade --install operator confluentinc/confluent-for-kubernetes
```
6. Generate SSL Certificates
```sh
openssl genrsa -out ca-key.pem 2048
openssl req -new -key ca-key.pem -x509 \
  -days 1000 \
  -out ca.pem \
  -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"
```
7. Create Kubernetes Secrets from SSL 
```sh
kubectl create secret tls ca-pair-sslcerts --cert=ca.pem --key=ca-key.pem
kubectl create secret generic cloud-plain --from-file=plain.txt=creds-client-kafka-sasl-user.txt
kubectl create secret generic control-center-user --from-file=basic.txt=creds-control-center-users.txt
kubectl create secret generic kafka-client-config-secure --from-file=kafka.properties -n confluent
```
8. Deploy Kafka Connect and Control Center
```sh
kubectl apply -f confluent-platform.yaml
```
9. Verify Installation


### Teardown
```
kubectl delete -f confluent-platform.yaml
kubectl delete secrets cloud-plain control-center-user kafka-client-config-secure
kubectl delete secret ca-pair-sslcerts
helm delete operator
```
