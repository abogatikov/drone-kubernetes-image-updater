#!/bin/bash

if [ -z ${PLUGIN_NAMESPACE} ]; then
  PLUGIN_NAMESPACE="default"
fi

if [ -z ${PLUGIN_KUBERNETES_USER} ]; then
  PLUGIN_KUBERNETES_USER="default"
fi

if [ -z ${PLUGIN_KUBERNETES_CLUSTER} ]; then
  PLUGIN_KUBERNETES_CLUSTER="default"
fi

if [ ! -z ${PLUGIN_KUBERNETES_TOKEN} ]; then
  KUBERNETES_TOKEN=$PLUGIN_KUBERNETES_TOKEN
else
  echo "Option kubernetes_token is required!"
  exit 1
fi

if [ ! -z ${PLUGIN_KUBERNETES_SERVER} ]; then
  KUBERNETES_SERVER=$PLUGIN_KUBERNETES_SERVER
else
  echo "Option kubernetes_server is required!"
  exit 1
fi

if [ ! -z ${PLUGIN_KUBERNETES_CERT} ]; then
  KUBERNETES_CERT=${PLUGIN_KUBERNETES_CERT}
else
  echo "Option kubernetes_cert is required!"
  exit 1
fi

if [ -z ${PLUGIN_DEPLOYMENT} ]; then
  echo "Option deployment is required!"
  exit 1
fi

if [ -z ${PLUGIN_CONTAINER} ]; then
  echo "Option container is required!"
  exit 1
fi

if [ -z ${PLUGIN_REPO} ]; then
  echo "Option repo is required!"
  exit 1
fi

if [ -z ${PLUGIN_TAG} ]; then
  echo "Option tag is required!"
  exit 1
fi

kubectl config set-credentials ${PLUGIN_KUBERNETES_USER} --token=${KUBERNETES_TOKEN}
echo ${KUBERNETES_CERT} | base64 -d > ca.crt
#echo ${KUBERNETES_CERT} > ca.crt
kubectl config set-cluster ${PLUGIN_KUBERNETES_CLUSTER} --server=${KUBERNETES_SERVER} --certificate-authority=./ca.crt --embed-certs=true

kubectl config set-context ${PLUGIN_KUBERNETES_USER}@${PLUGIN_KUBERNETES_CLUSTER} --cluster=${PLUGIN_KUBERNETES_CLUSTER} --user=${PLUGIN_KUBERNETES_USER}
kubectl config use-context ${PLUGIN_KUBERNETES_USER}@${PLUGIN_KUBERNETES_CLUSTER}

IFS=',' read -r -a DEPLOYMENTS <<< "${PLUGIN_DEPLOYMENT}"
IFS=',' read -r -a CONTAINERS <<< "${PLUGIN_CONTAINER}"
for DEPLOY in ${DEPLOYMENTS[@]}; do
  echo Deploying to $KUBERNETES_SERVER
  for CONTAINER in ${CONTAINERS[@]}; do
    kubectl -n ${PLUGIN_NAMESPACE} set image deployment/${DEPLOY} \
      ${CONTAINER}=${PLUGIN_REPO}:${PLUGIN_TAG} --record
  done
done
