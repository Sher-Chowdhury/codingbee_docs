# Kubernetes Hello World

In this walkthrough we will get an Apache web server (container) running inside our kube cluster. In Kubernetes we build objects. There are different types of objects, here are the 2 types of objects we'll be building in this walkthrough:

**Pod:** A pod is the fundamental building block in the world of Kubernetes. It is a group of one or more Containers, tied together for the purposes of administration and networking

**Deployment:** A Kubernetes Deployment checks on the health of your Pod and restarts the Pod’s Container if it terminates. Deployments are the recommended way to manage the creation and scaling of Pods.

**Service:** This is used to set up networknig in our kube cluster. If a running pod exposes a web based gui, then a Service object needs to be set up to make that pod's gui externally accessible.

At the moment, we don't have any pod of deployments objects (of any type) in our kubecluster:

```bash
$ kubectl get pods
No resources found.
$ kubectl get deployments
No resources found.
```

In kubernetes, you create an object by first creating a yaml config file, and then feeding that config file into kubectl.

So here's our pod object file's yaml content:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: client-pod
  labels:
    component: web
spec:
  containers:
    - name: client
      image: stephengrider/multi-client
      ports:
        - containerPort: 3000

```

And here's what our service object file's content:

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
    - port: 3050  # this is used by other pods to access assets that's avialable in our demo conainer

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

Refer to kubernetes docs for more info about [Service](https://kubernetes.io/docs/concepts/services-networking/service/) objects.

## Anatomy of an Kubernetes object config file

Notice, that all these config files have the following general yaml structure:

```yaml
apiVersion: xxx
kind: xxxxx
metadata:
  {blah blah blah}
spec:
  {blah blah blah}
```

The apiVersion, kind, metadata, and spec, are the [required fields](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/#required-fields), for all kubernetes object files.

**kind:** What type object that you want to make.

**apiVersion:** The kubernetes api is rapidly evolving so the api is broken down into various parts. Your version choice depends on what 'kind' of object you want to define.  For example, if the kind is 'Pod' then this field needs to be set to 'v1'.

You need to take a look at the [Kubernetes API Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/) to work out what to set this for your chosen object type (kind). This reference doc is really useful have displays example yaml content for your chosen kind.
This link is for version v1.13. But in your case you need go to the link, that's specified with the Major and Minor tag of Server Version in:

```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"6", GitVersion:"v1.6.2", GitCommit:"477efc3cbe6a7effca06bd1452fa356e2201e1ee", GitTreeState:"clean", BuildDate:"2017-04-19T20:33:11Z", GoVersion:"go1.7.5", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.3", GitCommit:"721bfa751924da8d1680787490c54b9179b1fed0", GitTreeState:"clean", BuildDate:"2019-02-01T20:00:57Z", GoVersion:"go1.11.5", Compiler:"gc", Platform:"linux/amd64"}
```

You can also run the following to list out all the supported versions:

```bash
$ kubectl api-versions
admissionregistration.k8s.io/v1beta1
apiextensions.k8s.io/v1beta1
apiregistration.k8s.io/v1
apiregistration.k8s.io/v1beta1
apps/v1
apps/v1beta1
apps/v1beta2
authentication.k8s.io/v1
authentication.k8s.io/v1beta1
authorization.k8s.io/v1
authorization.k8s.io/v1beta1
autoscaling/v1
autoscaling/v2beta1
autoscaling/v2beta2
batch/v1
batch/v1beta1
certificates.k8s.io/v1beta1
coordination.k8s.io/v1beta1
events.k8s.io/v1beta1
extensions/v1beta1
networking.k8s.io/v1
policy/v1beta1
rbac.authorization.k8s.io/v1
rbac.authorization.k8s.io/v1beta1
scheduling.k8s.io/v1beta1
storage.k8s.io/v1
storage.k8s.io/v1beta1
v1
```

**metadata:** Data that helps uniquely identify the object. metadata.name is used to assign a name to the object. It's also used to link up objects together with the help of the metadata.labels data.

**spec:** The content of this depends on the kind of object in question. Api specifies what structure+content this section should hold.

## Start creating the Kubernetes objects

First let's get the current status:

```bash
$ kubectl get pods
No resources found.
$ kubectl get services
NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   10.96.0.1    <none>        443/TCP   3h
```

Notice, we already have a service called 'kubernetes'. This came as default and is used by Kubernete for internal purposes only. Therefore you can ignore this service.

Now let's create the objects, starting with the pod object:

```bash
$ kubectl apply -f configs/pod-object-definition.yml
pod "pod-httpd" created

$ kubectl get -o wide pods
NAME        READY     STATUS    RESTARTS   AGE       IP           NODE
pod-httpd   1/1       Running   0          8s        172.17.0.5   minikube
```

Notice here that we used the '-o wide' just to get some verbose info. Next let's do the service object:

```bash
$ kubectl apply -f configs/service-object-definition.yml
service "svc-nodeport-apache-webserver" created

$ kubectl get -o wide services
NAME                            CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE       SELECTOR
kubernetes                      10.96.0.1       <none>        443/TCP          4h        <none>
svc-nodeport-apache-webserver   10.100.173.40   <nodes>       3050:31000/TCP   7s        component=apache_webserver
```

Next, you need to find the ip address of your worker node, which you can find by running:

```bash
$ minikube ip
192.168.99.100
```

Now, you can test either via a web browser, or with curl:

```bash
$ curl http://192.168.99.100:31000
<html><body><h1>It works!</h1></body></html>
```

Note, when you access a pod like this, you would normally do it via a loadbalancer that sits in front of the worker nodes.

## Deleting objects

To delete the objects we created, run:

```bash
$ kubectl delete -f configs/service-object-definition.yml
service "svc-nodeport-apache-webserver" deleted
$ kubectl delete -f configs/pod-object-definition.yml
pod "pod-httpd" deleted
```

## References

[kubernetes api concepts](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)
[kubernetes api reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/)