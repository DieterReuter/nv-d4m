
# Deploying NeuVector Container Firewall on Docker4Mac in Kubernetes

**DISCLAMER:** NeuVector is not supported on D4M right now, but most of the features are working quite well. This is a personal repo.

Take this just as a technology preview of NeuVector!

For detailed information about the NeuVector Container Firewall solutions, please visit our website at https://neuvector.com.

And if you're dead serious about running Containers securely in production - no matter if it's on Docker CE, Docker EE, Kubernetes or OpenShift - you can easily reach out to me via at dieter@neuvector.com or [@Quintus23M](https://twitter.com/Quintus23M) and we could chat about Run-Time Container Security!


## Prerequisites

* [Docker for Mac](https://docs.docker.com/docker-for-mac/) 18.02.0-ce (tested with Version 18.02.0-ce-rc2-mac51 (22446) from edge channel)
* Kubernetes v1.9.2 musst be enabled in D4M


### Prepare Docker-for-Mac

First of all, you'll need access to the NeuVector Docker images which are available at a private Docker Hub account. In order to test NeuVector you should first apply for a trial license at https://neuvector.com/try-neuvector/.


### Create `"neuvector"` namespace

```bash
$ kubectl create namespace neuvector
```


### Create secret for DockerHub access

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


### Label the Kubernetes node

List all available Kubernetes nodes, of course we'll get only one for Docker4Mac which is named `docker-for-desktop`.
```bash
$ kubectl get nodes
NAME                 STATUS    ROLES     AGE       VERSION
docker-for-desktop   Ready     master    20h       v1.9.2
```

Finally we have to label the node, so we can deploy the NeuVector Allinone DaemonSet on it.
```bash
$ kubectl label nodes docker-for-desktop nvallinone=true
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

**EXPERT TIP:**
It's also possible to create the deployment directly from an URL:
```bash
$ kubectl create -f \
   https://raw.githubusercontent.com/DieterReuter/nv-d4m/master/neuvector-d4m.yaml
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

![login-page](/images/neuvector-manager-ui-login-page.png)
Now, login with the default admin account credentials: `username=admin`, `password=admin`.


## Displaying the Container Vulnerability Scan Results

Here is at least a sneak preview of the Container Vulnerability Scanning feature.
![container-vulnerabilities](/images/neuvector-manager-ui-container-vulnerabilities.png)

SUCCESS !!!


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
$ curl -sk https://localhost:30558/ | jq .
{
  "code": 1,
  "error": "URL not found",
  "message": "URL not found"
}
```

As soon as we are getting a JSON answer, we know the API is accessible!

----

Apache 2.0 License - Copyright (c) 2018 Dieter Reuter
