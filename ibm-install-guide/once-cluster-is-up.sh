#!/usr/bin/env bash

#tag::setVars[]
APP_NAME=my-kubeflow
NAMESPACE=tfworkflow
K8S_VERSION=1.10.11
#end::setVars[]

## Assumes cluster has been created and is up and running... eventually merge these scripts..

if [ -z "$CLUSTER_NAME" ]; then
    export CLUSTER_NAME=kubeflow-tutorial2
    echo "CLUSTER_NAME not set, we're gonna call this one ${CLUSTER_NAME}"
fi


#tag::kubeConfig[]
export KUBECONFIG=$(ibmcloud cs cluster-config $CLUSTER_NAME | sed -n 's/.*KUBECONFIG=//p')
#end::kubeConfig[]
echo "KUBECONFIG=$KUBECONFIG"

if [ -f ./set-aws-creds.sh ]; then
		echo "Found 'set-aws-creds.sh' , loading creds from there"
    source ./set-aws-creds.sh
fi

## Need better check on wheather that is working or not
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
	echo "Please set AWS_ACCESS_KEY_ID"
	exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
	echo "Please set AWS_SECRET_ACCESS_KEY"
	exit 1
fi


if [[ ! -d "kf-tutorial" ]]; then
	echo "Cloning MNIST Example"
	mkdir kf-tutorial
	cd kf-tutorial
	git init
	git remote add origin -f https://github.com/kubeflow/examples
	echo mnist >> .git/info/sparse-checkout
	git pull origin master
	# Rolling back to before jlewi did a big refactor of the example
	git checkout 4dda73afbfcbf023c20524a4d5dbce011d9dbf79
	cd ..
	echo "Example source code cloned"
else
	echo "kf-tutorial found, skipping fresh cloning"
fi

#tag::copyMmt[]
cp modified-model-train.yaml kf-tutorial/mnist
#end::copyMmt[]
cd kf-tutorial/mnist



if [[ $(kubectl get namespace) == *"${NAMESPACE}"* ]]; then
	echo "${NAMESPACE} namespace already exists in k8s."
else
#tag::createK8sNamespace[]
	kubectl create namespace ${NAMESPACE}
#end::createK8sNamespace[]
fi

if [[ $(ibmcloud cr namespace-list) == *"${NAMESPACE}"* ]]; then
	echo "${NAMESPACE} namespace already exists in Docker repo"
else
#tag::createDkrNamespace[]
	ibmcloud cr namespace-add $NAMESPACE
#end::createDkrNamespace[]
fi


# if directory exists, delete it.
if [ -d "$APP_NAME" ]; then
	echo "Deleting $APP_NAME"
	rm $APP_NAME -rf
fi

# todo skip if exists (or possibly not needed)
wget https://raw.githubusercontent.com/kubernetes/kubernetes/v${K8S_VERSION}/api/openapi-spec/swagger.json
echo "Initializing KS app ${APP_NAME} with api-spec version ${K8S_VERSION}"

#ks init ${APP_NAME} --api-spec=file:swagger.json  #important bc IBM wants to be creative w version name
#tag::ksWitchcraft[]
ks init ${APP_NAME} --api-spec=file:swagger.json --api-spec=version:v$K8S_VERSION
cd ${APP_NAME}

ks registry add kubeflow github.com/kubeflow/kubeflow/tree/v0.2.4/kubeflow
ks pkg install kubeflow/core@v0.2.4
ks pkg install kubeflow/argo

ks generate core kubeflow-core --name=kubeflow-core --namespace=${NAMESPACE}
ks generate argo kubeflow-argo --name=kubeflow-argo --namespace=${NAMESPACE}

ks apply default -c kubeflow-core
ks apply default -c kubeflow-argo

# Switch context for the rest of the example
kubectl config set-context $(kubectl config current-context) --namespace=${NAMESPACE}


cd -

# Create a user for our workflow
kubectl apply -f tf-user.yaml
#end::ksWitchcraft[]


echo "Building Docker Image"
#tag::configureDockerRegistry[]
export DOCKER_BASE_URL=registry.ng.bluemix.net/$NAMESPACE # Put your docker registry here
#end::configureDockerRegistry[]

#tag::buildnpushDockerRegistry[]
if [[ $(ibmcloud cr image-list) == *"${DOCKER_BASE_URL}"* ]]; then
	echo "${DOCKER_BASE_URL} already exists in registry."
else
#tag::buildnpushDockerRegistry[]
	docker build . --no-cache  -f Dockerfile.model -t ${DOCKER_BASE_URL}/mytfmodel:1.7
	docker push ${DOCKER_BASE_URL}/mytfmodel:1.7
#end::buildnpushDockerRegistry[]
	echo "Docker Image built and pushed"
fi


echo "Copying Docker Secrets"

IMAGE_PULL_SECRET_NAME=my-kf-docker-registry-secret

if [[ $(kubectl get secrets) == *"${IMAGE_PULL_SECRET_NAME}"* ]]; then
	echo "${IMAGE_PULL_SECRET_NAME} exists."
else
	echo "Creating Docker Secret Token"
#tag::createDockerSecret[]
	IMAGE_PULL_SECRET_NAME=my-kf-docker-registry-secret
	TOKEN_PASS=$(ibmcloud cr token-add --description "kf-tutorial" --non-expiring -q)
	kubectl --namespace $NAMESPACE \
	  create secret docker-registry $IMAGE_PULL_SECRET_NAME \
	  --docker-server=registry.ng.bluemix.net \
	  --docker-username=token \
	  --docker-password=$TOKEN_PASS \
	  --docker-email=a@b.com
#end::createDockerSecret[]
	echo "Done"
fi



## Create S3 Creds
#tag::configureS3[]
export S3_ENDPOINT=s3-api.us-geo.objectstorage.softlayer.net
export AWS_ENDPOINT_URL=https://${S3_ENDPOINT}
export AWS_REGION=us-geo
export BUCKET_NAME=mnist-bucket-tutorial
export S3_USE_HTTPS=1
export S3_VERIFY_SSL=1
export S3_DATA_URL=s3://${BUCKET_NAME}/
export S3_TRAIN_BASE_URL=s3://${BUCKET_NAME}
#end::configureS3[]

if [[ $(kubectl get secrets) == *"aws-creds"* ]]; then
	echo "aws-creds exists."
else
#tag::createS3Secret[]
	kubectl create secret generic aws-creds --from-literal=awsAccessKeyID=${AWS_ACCESS_KEY_ID} \
	 --from-literal=awsSecretAccessKey=${AWS_SECRET_ACCESS_KEY}
#end::createS3Secret[]
	echo "created aws-creds"
fi

#tag::setTrainingParams[]
export JOB_NAME=myjob-$(uuidgen  | cut -c -5 | tr '[:upper:]' '[:lower:]')
export TF_MODEL_IMAGE=${DOCKER_BASE_URL}/mytfmodel:1.7
export TF_WORKER=3
export MODEL_TRAIN_STEPS=200
export MODEL_BATCH_SIZE=100
#end::setTrainingParams[]

## TODO If these already exist in bucket, don't upload them...
## Upload mnist/data to S3_DATA_URL

aws --endpoint-url $AWS_ENDPOINT_URL s3 ls s3://mnist-bucket-tutorial/0.png

#tag::uploadData[]
for i in `seq 0 9`;
	do
		if [-z $(aws --endpoint-url $AWS_ENDPOINT_URL s3 ls $S3_TRAIN_BASE_URL/$i.png) ]; then
			echo "Uploading $i"
			aws --endpoint-url $AWS_ENDPOINT_URL s3 cp data/$i.png $S3_TRAIN_BASE_URL
		else
			echo "$i already exists, skipping"
		fi
	done
#end::uploadData[]

## Submit the Job

#tag::submitTraining[]
argo submit modified-model-train.yaml --serviceaccount tf-user \
    -p aws-endpoint-url=${AWS_ENDPOINT_URL} \
    -p s3-endpoint=${S3_ENDPOINT} \
    -p aws-region=${AWS_REGION} \
    -p tf-model-image=${TF_MODEL_IMAGE} \
    -p s3-data-url=${S3_DATA_URL} \
    -p s3-train-base-url=${S3_TRAIN_BASE_URL} \
    -p job-name=${JOB_NAME} \
    -p tf-worker=${TF_WORKER} \
    -p model-train-steps=${MODEL_TRAIN_STEPS} \
    -p model-batch-size=${MODEL_BATCH_SIZE} \
    -p s3-use-https=${S3_USE_HTTPS} \
    -p s3-verify-ssl=${S3_VERIFY_SSL} \
    -p namespace=${NAMESPACE} \
    -p image-pull-secret=${IMAGE_PULL_SECRET_NAME} \
    -n ${NAMESPACE}
#end::submitTraining[]
#

sleep 3

#tag::argoServer[]
PODNAME=$(kubectl get pod -l app=argo-ui -n${NAMESPACE} -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward ${PODNAME} 8001:8001
#end::argoServer[]

echo "visit http://127.0.0.1:8001 to see the status of your workflows"


