#!/bin/bash
# see: https://github.com/kubernetes/examples/tree/master/guestbook
set -e

kubectl create -f frontend-deployment.yaml
kubectl create -f frontend-service.yaml
kubectl create -f redis-master-deployment.yaml
kubectl create -f redis-master-service.yaml
kubectl create -f redis-slave-deployment.yaml
kubectl create -f redis-slave-service.yaml
