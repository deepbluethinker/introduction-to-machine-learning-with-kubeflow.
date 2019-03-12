#!/usr/bin/env bash

#tag::createTrainingWorkflow[]
cd $EXAMPLE_SELDON/workflows
argo submit training-sk-mnist-workflow.yaml -n kubeflow
#end::createTrainingWorkflow[]

#tag::cliTrainingCheck[]
kubectl get pods -n kubeflow | grep sk-train
#Should yeild something like this:
#kubeflow-sk-train-wnbgj-1046465934                        0/1     Completed   0          5m11s
#sk-train-kmpcr                                            0/1     Completed   0          4m31s
#
# Or
argo list -n kubeflow
# Should yield something like:
# kubeflow-sk-train-wnbgj   Succeeded   18h   4m
#
#end::cliTrainingCheck[]

#tag::getAmbassadorPort[]
kubectl get svc -n kubeflow | grep "ambassador "
# Should yield:
# ambassador                                           NodePort    10.152.183.112   <none>        80:30134/TCP
#end::getAmbassadorPort[]