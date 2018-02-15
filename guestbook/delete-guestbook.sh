#!/bin/bash
# see: https://github.com/kubernetes/examples/tree/master/guestbook
set -e

kubectl delete -f frontend-deployment.yaml
kubectl delete -f frontend-service.yaml
kubectl delete -f redis-master-deployment.yaml
kubectl delete -f redis-master-service.yaml
kubectl delete -f redis-slave-deployment.yaml
kubectl delete -f redis-slave-service.yaml
