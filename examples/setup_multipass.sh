#!/usr/bin/env bash

export KUBEFLOW_VERSION=0.4.1

# Todo check if kubeflow exists- if so delete it or abort or something
multipass launch bionic -n kubeflow -m 8G -d 40G -c 4

### MicroK8s Tools
multipass exec kubeflow -- git clone https://github.com/canonical-labs/kubernetes-tools
multipass exec kubeflow -- sudo kubernetes-tools/setup-microk8s.sh


### This doesn't work.

#### KSonnet
#multipass exec kubeflow -- wget https://github.com/ksonnet/ksonnet/releases/download/v0.13.1/ks_0.13.1_linux_amd64.tar.gz
#multipass exec kubeflow -- tar -xzf ks_0.13.1_linux_amd64.tar.gz
#multipass exec kubeflow -- rm ks_0.13.1_linux_amd64.tar.gz
#multipass exec kubeflow -- sudo cp ks_0.13.1_linux_amd64/ks /usr/local/bin

### Argo
multipass exec kubeflow -- sudo curl -sSL -o /usr/local/bin/argo https://github.com/argoproj/argo/releases/download/v2.2.1/argo-linux-amd64
multipass exec kubeflow -- sudo chmod +x /usr/local/bin/argo

multipass shell kubeflow
##########################################################################################################################################################################################
### From heer on need to be logged into VM #todo fix
export KUBEFLOW_VERSION=0.4.1
#### Kubeflow Tools
multipass exec kubeflow -- git clone https://github.com/canonical-labs/kubeflow-tools
multipass exec kubeflow -- kubeflow-tools/install-kubeflow.sh
#curl https://raw.githubusercontent.com/kubeflow/kubeflow/v${KUBEFLOW_VERSION}/scripts/download.sh | bash
export PATH=$PATH:/home/multipass/scripts
echo 'export PATH=$PATH:/home/multipass/scripts' >> /home/multipass/.bashrc
microk8s.enable registry
sudo snap alias microk8s.docker docker
export DOCKER_HOST="unix:///var/snap/microk8s/current/docker.sock"
sudo ln -s /var/snap/microk8s/current/docker.sock /var/run/docker.sock
sudo ln -s /var/snap/microk8s/common/var/lib/docker /var/lib/docker

microk8s.enable dns dashboard storage
sudo iptables -P FORWARD ACCEPT

#kubectl apply -f https://raw.githubusercontent.com/argoproj/argo/v2.2.1/manifests/install.yaml fails "namespaces 'argo' not found"



### Helm and Tiller
sudo snap install helm --classic

kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
kubectl rollout status deploy/tiller-deploy -n kube-system
