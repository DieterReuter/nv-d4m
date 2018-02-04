
# Deploying NeuVector Container Firewall on Docker4Mac in Kubernetes

For detailed information about the NeuVector Container Firewall solutions, please visit our website at https://neuvector.com.


## Prerequisites

* [Docker for Mac](https://docs.docker.com/docker-for-mac/) 18.02.0-ce (tested with Version 18.02.0-ce-rc2-mac51 (22446))
* Kubernetes v1.9.2 musst be enabled in D4M


### Prepare Docker-for-Mac

First of all, you'll need access to the NeuVector Docker images which are available at a private Docker Hub account. In order to test NeuVector you should first apply for a trial license at https://neuvector.com/try-neuvector/.

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
ds/neuvector-allinone-pod   1         1         1         1            1           nvallinone=true   11m
ds/neuvector-allinone-pod   1         1         1         1            1           nvallinone=true   11m

NAME                              READY     STATUS    RESTARTS   AGE
po/neuvector-allinone-pod-lp92w   1/1       Running   0          11m

NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
svc/neuvector-api-svc       NodePort    10.110.37.68    <none>        10443:30558/TCP                 11m
svc/neuvector-cluster-svc   ClusterIP   None            <none>        18300/TCP,18301/TCP,18301/UDP   11m
svc/neuvector-manager-svc   NodePort    10.98.124.158   <none>        8443:31733/TCP                  11m
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

## Access the NeuVector Manager WebUI

Detect the TCP port number of the NeuVector Manager:
```bash
$ kubectl get svc/neuvector-manager-svc -n neuvector
NAME                    TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
neuvector-manager-svc   NodePort   10.98.124.158   <none>        8443:31733/TCP   5m
```

Open your favorite web browser:
```bash
$ open https://localhost:31733
```

Now, login with the default account: `username=admin`, `password=admin`.


## Access the NeuVector API

Detect the TCP port number of the NeuVector API:
```bash
$ kubectl get svc/neuvector-api-svc -n neuvector
NAME                TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
neuvector-api-svc   NodePort   10.110.37.68   <none>        10443:30558/TCP   7m
```

Try to access the API:
```bash
$ curl -k https://localhost:30558/
{"code":1,"error":"URL not found","message":"URL not found"}
```

```bash
$ curl -sk https://localhost:30558/api/health | jq .
{
  "code": 1,
  "error": "URL not found",
  "message": "URL not found"
}
```

As soon as we are getting a JSON answer, we know the API is accessible!

----

Apache 2.0 License - Copyright (c) 2018 Dieter Reuter
