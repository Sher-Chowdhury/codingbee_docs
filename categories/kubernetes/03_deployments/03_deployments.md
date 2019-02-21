# Deployments

## Updating objects

Kubernetes is smart enough to identify which objects have been created by a particular config file. It does so by using the configs about the 'kind' and metadata.name info. 

That's a good thing because it means you can modify an existing object by editing it's corresponding config file and reapply it. However, since the 'kind' and 'metadata.name' are used for mapping yaml configs to their respective objects it means that changing these will make kubernetes think that they are new objects. In my example I'm going to change the pod's image name from httpd to nginx:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-httpd
  labels:
    component: apache_webserver
spec: 
  containers:
    - name: cntr-httpd
      image: nginx       # this was httpd back when this object was created. 
      ports:
        - containerPort: 80

```

Now we reapply the changes:

```bash
$ kubectl apply -f configs/pod-object-definition.yml 
pod "pod-httpd" configured
```

This time we get a configured message. This means that kubernetes hasn't created anything new, just updated one or more existing objects. Now we can retest:

```bash
$ curl http://192.168.99.100:31000
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Another way to if this has worked is by running:

```bash
$ kubectl describe pod pod-http
Name:           pod-httpd
Namespace:      default
Node:           minikube/10.0.2.15
Start Time:     Thu, 21 Feb 2019 15:24:35 +0000
Labels:         component=apache_webserver
Annotations:    kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"component":"apache_webserver"},"name":"pod-httpd","namespace":"default"},"spec"...
Status:         Running
IP:             172.17.0.5
Controllers:    <none>
Containers:
  cntr-httpd:
    Container ID:       docker://ba1cc2ac63f53c813a3a7f9d77045c222f380e34a333378876b011d7ae8eaa73
    Image:              nginx
    Image ID:           docker-pullable://nginx@sha256:dd2d0ac3fff2f007d99e033b64854be0941e19a2ad51f174d9240dda20d9f534
    Port:               80/TCP
    State:              Running
      Started:          Thu, 21 Feb 2019 15:24:43 +0000
    Ready:              True
    Restart Count:      0
    Environment:        <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-hgw5b (ro)
Conditions:
  Type                  Status
  Initialized           True 
  Ready                 True 
  ContainersReady       True 
  PodScheduled          True 
Volumes:
  default-token-hgw5b:
    Type:       Secret (a volume populated by a Secret)
    SecretName: default-token-hgw5b
    Optional:   false
QoS Class:      BestEffort
Node-Selectors: <none>
Tolerations:    node.kubernetes.io/not-ready=:Exists:NoExecute for 300s
                node.kubernetes.io/unreachable=:Exists:NoExecute for 300s
Events:
  FirstSeen     LastSeen        Count   From                    SubObjectPath                   Type            Reason          Message
  ---------     --------        -----   ----                    -------------                   --------        ------          -------
  6m            6m              1       default-scheduler                                       Normal          Scheduled       Successfully assigned default/pod-httpd to minikube
  6m            6m              1       kubelet, minikube       spec.containers{cntr-httpd}     Normal          Pulling         pulling image "nginx"
  6m            6m              1       kubelet, minikube       spec.containers{cntr-httpd}     Normal          Pulled          Successfully pulled image "nginx"
  6m            6m              1       kubelet, minikube       spec.containers{cntr-httpd}     Normal          Created         Created container
  6m            6m              1       kubelet, minikube       spec.containers{cntr-httpd}     Normal          Started         Started container
```

However, like 'kind' and metadata.name, there are other fields that you can't change, e.g. for a pod object, you can't change the containerPort. If you do then you'll get a forbidden error message.

This problem gets solved by making use of another type of object called [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

Deployments are a bit like the equivalent of AWS EC2 Autoscaling Scaling Groups, Where instead of autoamatically scaling ec2 instances, in kubernetes you autoscale identical pods across one or more worker nodes. 

Deployments also does pod healthchecks and ensures that the desired state (of number of healthy active pods) is maintained. That's why it's recommended to create deployment objects rather than pod objects in a production environment. In fact it's also a good idea to create deployments objects in a dev environment too. 

Here's our example deployment yaml file:

```bash
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-httpd
  labels:
    component: apache_webserver
spec:
  replicas: 1   # This sets the number of pods that needs to exist. 
                # This is a bit like the ASG equivalent of min/desired/max, but as a single value. 
  selector:
    matchLabels:
      component: apache_webserver  # this is used by a deployment object to keep track of which pods it's configuration created.

  template:  # the content nested in this section is pretty much what was in the pod-definition yaml file. 
             # I.e. it's the aws equivalent of the EC2 Launch Configuration. 
    metadata:
      labels:
        component: apache_webserver  # this needs to be match up with the matchLabels setting above, otherwise the deployment
                                     # object will lose track of which pods it instructed kubemaster to create. 
    spec: 
      containers:
        - name: cntr-httpd
          image: httpd
          ports:
            - containerPort: 80
```

Before we apply this object, let's first check we don't have currently active deployments:

```bash
$ kubectl get deployments
No resources found.
```


Now lets apply this object:

```bash
$ kubectl apply -f configs/deployment-object-definition.yml 
deployment "deployment-httpd" created
```

Now let's check again:

```bash
$ kubectl get -o wide deployments
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE       CONTAINER(S)   IMAGE(S)   SELECTOR
deployment-httpd   1         1         1            1           28s       cntr-httpd     httpd      component=apache_webserver
```

This ended up creating:

```bash
$ kubectl get -o wide pods
NAME                                READY     STATUS    RESTARTS   AGE       IP           NODE
deployment-httpd-648756c8dd-hcc7f   1/1       Running   0          1m        172.17.0.5   minikube
```

Now if you want to increase the number of pods running under this deployment, then just update the replicas setting in the deployments config file then reapply. 

You can change port numbers too, however what deployments will end up doing is create new pods (with the correct port number) and use them to replace the existing pods that have the old port numbers.


## Refreshing deployments with new images

One of the most common changes that you're likely to want to do with a deployment is to update the pods in a deployment as soon as a newer image version becomes available in the docker hub. There's mainly three ways to do this, but none of them are that great:

1. rebuilding the deployment - not recommended in a prod environment since it would lead to downtime.
2. manually update version specified in the deployment config file - Doable, but not ideal since it involves making regular changes to your config file. Also unfortunately you can't parameterize the config files.
3. Specify the image version on the kubectl command line, effectively overriding/deviating from the config file. - Not great since it results in configuration drift. 

If you decide to take option 3, then here's what the command will look like, if we were to replace the official nginx image with the official apache image:

```bash
$ kubectl describe deployment deployment-nginx | grep Image
    Image:              nginx:latest

$ kubectl set image deployment/deployment-nginx cntr-nginx=httpd
deployment "deployment-nginx" image updated

$ kubectl describe deployment deployment-nginx | grep Image
    Image:              httpd

$ curl http://192.168.99.100:31000
<html><body><h1>It works!</h1></body></html>
```

So the syntax is:

```text
kubectl set image {object kind}/{object-name} {container-name}={image-name}
```


