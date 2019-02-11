#!/bin/bash
#tag::deploy[]
#Configuration
# ${KFAPP} is the name for the kubeflow deployment
# The ksonnet app will be created in the directory ${KFAPP}/ks_app
export KFAPP=example
${KUBEFLOW_DIR}/scripts/kfctl.sh init ${KFAPP}
cd ${KFAPP}
${KUBEFLOW_DIR}/scripts/kfctl.sh generate k8s
${KUBEFLOW_DIR}/scripts/kfctl.sh apply k8s
#end::deploy[]
