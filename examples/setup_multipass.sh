#!/usr/bin/env bash

export KUBEFLOW_VERSION=0.4.1

# Todo check if kubeflow exists- if so delete it or abort or something
multipass launch bionic -n kubeflow -m 8G -d 40G -c 4

### MicroK8s Tools
multipass exec kubeflow -- git clone https://github.com/canonical-labs/kubernetes-tools
multipass exec kubeflow -- sudo kubernetes-tools/setup-microk8s.sh

multipass exec kubeflow -- microk8s.enable registry
multipass exec kubeflow -- sudo snap alias microk8s.docker docker

### This doesn't work.
#### Kubeflow Tools
#multipass exec kubeflow -- git clone https://github.com/canonical-labs/kubeflow-tools
#multipass exec kubeflow -- kubeflow-tools/install-kubeflow.sh

### KSonnet
multipass exec kubeflow -- wget https://github.com/ksonnet/ksonnet/releases/download/v0.13.1/ks_0.13.1_linux_amd64.tar.gz
multipass exec kubeflow -- tar -xzf ks_0.13.1_linux_amd64.tar.gz
multipass exec kubeflow -- rm ks_0.13.1_linux_amd64.tar.gz
multipass exec kubeflow -- sudo cp ks_0.13.1_linux_amd64/ks /usr/local/bin

### Argo
multipass exec kubeflow -- sudo curl -sSL -o /usr/local/bin/argo https://github.com/argoproj/argo/releases/download/v2.2.1/argo-linux-amd64
multipass exec kubeflow -- sudo chmod +x /usr/local/bin/argo

### Download/install kubeflow
curl https://raw.githubusercontent.com/kubeflow/kubeflow/v${KUBEFLOW_VERSION}/scripts/download.sh | bash

multipass exec kubeflow


### From heer on need to be logged into VM #todo fix
export KUBEFLOW_VERSION=0.4.1
echo 'export PATH=$PATH:/home/multipass/kubeflow/${KUBEFLOW_VERSION}/scripts' >> /home/multipass/.bashrc

#kubectl apply -f https://raw.githubusercontent.com/argoproj/argo/v2.2.1/manifests/install.yaml fails "namespaces 'argo' not found"

### Helm and Tiller
sudo snap install helm --classic
kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
kubectl rollout status deploy/tiller-deploy -n kube-system
