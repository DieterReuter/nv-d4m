
# Deploying NeuVector Container Firewall on Docker4Mac in Kubernetes


## Prerequisites

* [Docker for Mac](https://docs.docker.com/docker-for-mac/) 18.02.0-ce (tested with Version 18.02.0-ce-rc2-mac51 (22446))
* Kubernetes v1.9.2 musst be enabled in D4M


### Prepare Docker-for-Mac

First of all, you'll need access to the NeuVector Docker images which are available at a private Docker Hub account. 

Create `neuvector` namespace:
```bash
$ kubectl create namespace neuvector
```

Create secret to access your DockerHub account with Kubernetes:
```bash
$ export DOCKER_HUB_ID="your-docker-hub-id"
$ export DOCKER_HUB_PASSWORD="your-docker-hub-password"
$ export DOCKER_HUB_EMAIL="your-docker-hub-email"
$ kubectl create secret docker-registry regsecret -n neuvector \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=$DOCKER_HUB_ID \
  --docker-password=$DOCKER_HUB_PASSWORD \
  --docker-email=$DOCKER_HUB_EMAIL
```

Verify the secret:
```bash
$ kubectl get secret regsecret -n neuvector
NAME        TYPE                             DATA      AGE
regsecret   kubernetes.io/dockerconfigjson   1         2h
```

```bash
$ kubectl describe secret regsecret -n neuvector
Name:         regsecret
Namespace:    neuvector
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/dockerconfigjson

Data
====
.dockerconfigjson:  166 bytes
```


## Create NeuVector Deployment 

Deploy NeuVector resources:
```bash
$ kubectl apply -f neuvector-d4m.yaml
clusterrolebinding "neuvector-binding" created
service "neuvector-manager-svc" created
service "neuvector-api-svc" created
service "neuvector-cluster-svc" created
daemonset "neuvector-allinone-pod" created
```


## Verify NeuVector Deployment

Show all available NeuVector resources:
```bash
$ kubectl get all -n neuvector
NAME                        DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR     AGE
ds/neuvector-allinone-pod   1         1         1         1            0           nvallinone=true   24s
ds/neuvector-allinone-pod   1         1         1         1            0           nvallinone=true   24s

NAME                              READY     STATUS    RESTARTS   AGE
po/neuvector-allinone-pod-x9p6b   1/1       Running   0          24s

NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
svc/neuvector-api-svc       NodePort    10.108.49.188   <none>        10443:31505/TCP                 24s
svc/neuvector-cluster-svc   ClusterIP   None            <none>        18300/TCP,18301/TCP,18301/UDP   24s
svc/neuvector-manager-svc   NodePort    10.101.232.50   <none>        8443:30432/TCP                  24s
```


## Delete NeuVector Deployment

Delete deployment:
```bash
$ kubectl delete -f neuvector-d4m.yaml
clusterrolebinding "neuvector-binding" deleted
service "neuvector-manager-svc" deleted
service "neuvector-api-svc" deleted
service "neuvector-cluster-svc" deleted
daemonset "neuvector-allinone-pod" deleted
```

Verify that it's really deleted:
```bash
$ kubectl get all -n neuvector
No resources found.
```


----

Apache 2.0 License - Copyright (c) 2018 Dieter Reuter
