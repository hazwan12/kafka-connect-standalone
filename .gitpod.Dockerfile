# You can find the new timestamped tags here: https://hub.docker.com/r/gitpod/workspace-full/tags
FROM gitpod/workspace-full:latest

## Install Prerequisites
RUN sudo apt-get update && sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
lsb-release \
gnupg

## Install Kubectl
RUN sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
&& echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
&& sudo apt-get update && sudo apt-get install -y kubectl

## Install Helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list \
&& sudo apt-get update && sudo apt-get install -y helm

## Install Azure
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc |gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
&& AZ_REPO=$(lsb_release -cs) \
&& echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list \
&& sudo apt-get update && sudo apt-get install -y azure-cli