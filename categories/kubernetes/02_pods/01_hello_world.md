# Kubernetes Hello World


## Hello world - Part 1
In this walkthrough we will get an Apache web server (container) running inside our kube cluster. In Kubernetes we build objects. There are different types (aka kind) of objects, Pods, Services, Deployments,....etc. In our hello-world example we'll start by building a Pod object. 

**Pod:** A pod is the fundamental building block in Kubernetes. A pod main purpose is to house one or more containers. At the moment, we don't have any pods in our kubecluster:

```bash
$ kubectl get pods
No resources found.
```



In kubernetes, you create an object by first writing a yaml config file, and then feeding that config file into kubectl. So here's our pod object file's yaml content:

```yaml
---
apiVersion: v1      # see https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/
kind: Pod           # type of object that's defined in this file
metadata:
  name: pod-httpd # name of the pod to be created. 
  labels:
    component: apache_webserver  # this tag is added to help this object to link to the service object.
spec:
  containers:
    - name: cntr-httpd  # name of the container that will reside in the pod
      image: httpd    # using the official apache image from docker hub
      ports:
        - containerPort: 80  # what port the container will be listening on
```

We'll cover how to construct these yaml files from scratch in the anatomy tutorial later on. For now all you need to know is that this yaml file will instruct kubectl to:

1. create a pod object that consists of a single container.
2. Build this container using the official docker hub [httpd](https://hub.docker.com/_/httpd) image.
3. name the container 'cntr-httpd',
4. and name the pod itself, 'pod-httpd'.
5. note that the container will be listening on port 80
6. Assign an arbitrary key/value label to the pod of key=component and value=apache_webserver. This label will come in useful later on.

We wrote this yaml content into a file called, pod-httpd-obj-def.yml. It doesn't matter what you call the file, as long as it's meaningful to you. and ends with the yml/yaml suffix. Now let's create the object, using the apply command:


```bash
$ kubectl apply -f configs/pod-httpd-obj-def.yml
pod "pod-httpd" created

$ kubectl get -o wide pods
NAME        READY     STATUS    RESTARTS   AGE       IP           NODE
pod-httpd   1/1       Running   0          8s        172.17.0.5   minikube
```

Here we can see tha ta new pod has been created. The pod's name is 'pod-httpd' which is exactly the name we asked for in our yaml file's metadata.name setting. Tto get more detailed info about our pod, we can use the 'describe' subcommand:

```bash
kubectl describe pods pod-httpd
Name:               pod-httpd
Namespace:          default
Priority:           0
PriorityClassName:  <none>
.
.
...etc
```

So far we've created a single pod with a single container inside that pod. This container is supposed to have the apache webserver running inside it. But how to do we verify that container's web service is definitely working? To properly verify this, we need to do a 2-step verification process:

1. Verify that our container (and consequently our pod) is listening on port 80. E.g. by running something like:
```bash
nc -v http://localhost
```
2. Try and access our containers homepage, by running something like:
```bash
curl http://localhost
```

However if you open up a bash terminal on your macbook and tried these steps you'll find that neither of these commands will work at this stage. That's because you need to setup some networking inside your kubecluster to make your pod accessible by other pods in the kubecluster and/or make your pod externally accessible (e.g. from your macbook). We'll cover how to setup some quick-and-dirty networking in the next lesson.


In the meantime there are some more limited tests that you can still perform, that is that you still perform the nc+curl tests but from inside the container itself. To do that, you need to access your container's bash terminal. You can do that by using the exec command:

```bash
$ kubectl exec -it pod-httpd -c cntr-httpd /bin/bash
root@pod-httpd:/usr/local/apache2#
```

This command is quite similar to the docker command. In case you want to access the bash terminal using the docker approach, then you can do that too, by ssh'ing into the minikube vm:

```bash
$ minikube ssh
                         _             _
            _         _ ( )           ( )
  ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __
/' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
| ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
(_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)

$
```

Then find the container name and login:

```bash

$ docker exec -it cntr-httpd /bin/bash
Error: No such container: cntr-httpd
$ docker container ls | grep cntr-httpd
ea800e6dec23        httpd                                                            "httpd-foreground"       5 hours ago         Up 5 hours                                                                               k8s_cntr-httpd_pod-httpd_default_742bd105-3c4c-11e9-946d-0800271ef513_0
$ docker exec -it ea800e6dec23 /bin/bash
root@pod-httpd:/usr/local/apache2#
```

Once you're inside the container, you then need to install the nc and curl packages. The command you need to run various depending on the image you use, but in our case, we run:

```bash
apt-get update
apt-get install netcat
apt-get install curl
```

Now we run the verifation tests:

```bash
# nc -v localhost 80
localhost [127.0.0.1] 80 (?) open


root@pod-httpd:/usr/local/apache2# curl http://localhost
<html><body><h1>It works!</h1></body></html>
```

Success!







## Hello World - Part 2

We're now going to improve on our existing hello-world example by making our pod accessible directly from our macbook's web browser. That's done by creating a 'service' object.

**Service:** A service object is used to setup networking in our kube cluster. E.g. if a running pod exposes a web based gui, then a service object needs to be set up to make that pod's gui externally accessible. 

So in our hello-world example, we've created a new yaml file with the content:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-nodeport-apache-webserver
spec:
  type: NodePort   # there are 4 types of Services. ClusterIP, NodePort, LoadBalancer, Ingress.
                   # https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
                   # NodePort should only be used for dev environments.
  ports:
    - port: 3050  # this is used by other pods to access assets that's available in our demo conainer

      targetPort: 80 # port number of the pod's primary container is listening on. So
                       # needs to mirror containerPort setting as defined in the object config file.

      nodePort: 31000  # this ranges between 30000-32767. Our worker node VM will be listening on this port.
                       # It's actually the kube-proxy compoenent on worker nodes that will start listening on this port.
                       # this is the port number we need to enter into our web browser. That's one of the drawbacks
                       # in using nodePort service type, i.e. have to explicitly specify ugly port numbers in the url
  selector:
    component: apache_webserver  # this says it will forward traffic to object that has metadata.label entry
                                 # with key/value pair of 'component: web'
                                 # that's how this object and the pod object links together.
```

There are different types of service objects, in our case we are creating a NodePort type service. NodePort services are quite crude and isn't recommended for production, but we're using it here because it's the easiest service type to understand for a beginner. Before we create our service object, let's first let's first see what services we currently have:

```bash
$ kubectl get services
NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   10.96.0.1    <none>        443/TCP   3h
```

The 'kubernetes' service comes as default in an Kubernete install and is used for internal purposes only. Therefore you can ignore this service. Now let's create the service object:

```bash
$ kubectl apply -f configs/svc-nodeport-obj-def.yml
service "svc-nodeport-apache-webserver" created

$ kubectl get -o wide services
NAME                            CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE       SELECTOR
kubernetes                      10.96.0.1       <none>        443/TCP          4h        <none>
svc-nodeport-apache-webserver   10.100.173.40   <nodes>       3050:31000/TCP   7s        component=apache_webserver
```

**Handy Tip**: Notice that we had to run the apply command twice so far, once for each yaml file. Luckily there's a way to apply all the configs in one command by simply specifying the directory that houses all your configs, e.g.:

```bash
$ kubectl apply -f ./configs
pod "pod-httpd" created
service "svc-nodeport-apache-webserver" created
```

Next, you need to find the ip address of your worker node, which you can find by running:

```bash
$ minikube ip
192.168.99.100
```

Now you know the ip number and port number you should be using, So you can test the endpoint either via a web browser, or with curl:

```bash
$ curl http://192.168.99.100:31000
<html><body><h1>It works!</h1></body></html>
```





## Deleting objects

You can delete objects individually, or collectively. Here's how to do it collectively:

```bash
$ kubectl delete -f ./configs
pod "pod-httpd" deleted
service "svc-nodeport-apache-webserver" deleted
```

## Defining multiple objects in a single config file

In this walkthrough we ended up with 2 config files. However you can store 2 or more objects in a single config file. All you need to do is to copy all the definitions into a single file, and seperate them out using by inserting the yaml-new-document-syntax '---' between them. It's really a preference on whether or not to use this approach.


## Updating objects

Kubernetes is smart enough to identify which objects have been created by a particular config file. It does so by using the configs about the 'kind' and metadata.name info. Config's filename itself doesn't matter, as long as it ends with the .yml/.yaml extension. You can make changes to the yaml files (as long as it isn't changing the kind or metadata.name fields) and just apply them again for the changes to take affect.

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

However, like 'kind' and metadata.name, there are other fields that you can't change, e.g. for a pod object, you can't change the containerPort. If you do then you'll get a forbidden error message.


## Troubleshooting pods

If a pod is failing to enter running mode, then there's a few ways to investigate that:


```bash

kubectl logs podname

kubectl describe pods podname   # this has a history session, which could give more info

kubectl get pods podname -o yaml   # this has a state message which gives more info too.

kubectl get events    # this give more general historical info about tasks performed by kubernetes


```


## References

[kubernetes api concepts](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)
[kubernetes api reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/)