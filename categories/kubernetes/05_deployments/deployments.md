# Deployments

[deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) are a special type of object referred to as 'controllers'. Controllers are essentially objects that monitor+controls the state and behaviour of other objects.

In the case of deployments, they control the state of other pod objects. Deployments are a bit like the equivalent of AWS EC2 Autoscaling Scaling Groups, Where instead of autoamatically scaling ec2 instances, in kubernetes you autoscale identical pods across one or more worker nodes. 

Deployments monitors the pods by continously performng pod healthchecks and ensures that the desired state (of number of healthy active pods) is maintained. That's why it's [kubernetes best practice](https://kubernetes.io/docs/concepts/configuration/overview/#naked-pods-vs-replicasets-deployments-and-jobs) to always create pods using a controller object, such as deployments. 

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

### Deleting Deployments

```bash
kubectl delete deployments deployment-nginx
```
Notice that we run this command imperitively rather than doing it declaritevely by specifying the config file. 


