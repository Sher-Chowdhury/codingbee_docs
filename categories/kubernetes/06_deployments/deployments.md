# Deployments

[deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) are a special type of object referred to as 'controllers'. Controllers are objects that monitor+controls the state and behaviour of other objects.

In the case of deployments, they control the state of other pod objects. Deployments are a bit like the equivalent of AWS EC2 Autoscaling Scaling Groups, Where instead of autoamatically scaling ec2 instances, in kubernetes you autoscale identical pods across one or more worker nodes.

Deployments monitors the pods by continously performing pod healthchecks and ensures that the desired state (of number of healthy active pods) is maintained. That's why it's [kubernetes best practice](https://kubernetes.io/docs/concepts/configuration/overview/#naked-pods-vs-replicasets-deployments-and-jobs) to always create pods using a controller object, such as deployments.

Deployments are effectively a wrapper for replicasets behind the scenes (with a few extra bells and wistles). Here's our example deployment yaml file:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dep-httpd
  labels:
    component: httpd_webserver
spec:
  replicas: 2
  minReadySeconds: 60 # This is one of the bells and whistle feature that deployment objects provides,
                      # but replica sets doesn't.
                      # it's how many seconds to wait after pod is created, before deployment
                      # will allow the pod to start receiving traffic.
  selector:
    matchLabels:
      component: httpd_webserver
  template:
    metadata:
      labels:
        component: httpd_webserver
    spec:
      containers:
        - name: cntr-nginx
          image: httpd:latest
          ports:
            - containerPort: 80
```

applying this yaml file ends up creating the following deployment object:

```bash
$ kubectl get deployments
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
dep-httpd   2/2     2            2           12s
```

 This deployment object created the following replicaset:

```bash
$ kubectl get rs
NAME                   DESIRED   CURRENT   READY   AGE
dep-httpd-6b84f9fd8c   2         2         2       16s
```

This replicaset in turn created the following pods:

```bash
$ kubectl get -o wide pods
NAME                                READY     STATUS    RESTARTS   AGE       IP           NODE
deployment-httpd-648756c8dd-hcc7f   1/1       Running   0          1m        172.17.0.5   minikube
```

So a deployment object created another controller object (replicaset), which in turn created the pod objects. That means if we manually delete the RS then the deployment would automatically recreate it again, which in turn will recreate the pods.

Going back to the yaml file, you'll notice that it's content is essentially 3 object definitions in a nested fashion. At the top we have the deploymnet, followed by the replicaset, and finally the pod definition

Now if you want to increase the number of pods running under this deployment, then just update the replicas setting in the deployments config file then reapply.

You can change port numbers too, however what deployments will end up doing is create new pods (with the correct port number) and use them to replace the existing pods that have the old port numbers.

## Refreshing deployments with new images

One of the most common changes that you're likely to want to do with a deployment is to update the pods in a deployment as soon as a newer image version becomes available in the docker hub. There's mainly three ways to do this, but none of them are that great:

1. rebuilding the deployment - not recommended in a prod environment since it would lead to downtime.
2. manually update version specified in the deployment config file - Doable, but not ideal since it involves making regular changes to your config file. Also unfortunately you can't parameterize the config files.
3. Specify the image version on the kubectl command line, effectively overriding/deviating from the config file. - Not great since it results in configuration drift.
4. Use third party solutions, e.g. [gitkube](https://github.com/hasura/gitkube)

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