# Services

In Kubernetes, 'services' is actually all about networking. In Docker world, when you use docker compose, all the networking is done for us. However that's not the case when it comes to kubernetes. To setup networking in Kubernetes, you need to create 'service' objects.

There are [4 main types of of services](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types).

## Nodeport Service Type

We have already created this type of service in earlier examples. The NodePort service type is specifically used for making a pod accessible externally. E.g. from another VM, or another pod from another Kubecluster. Nodeport can't be used for pod-to-pod communication where both pods are running on the same kube cluster.

Nodeport is actually rarely used in production, and is mainly used for development purposes only.

## ClusterIP Service Type

This service type is specifically designed for setting up internal pod-to-pod communications inside a kube cluster.

For example, let's say we have 2 pods, one is generic httpd pod, and the other is a generic centos pod. Let's say we want to be able to curl from the centos pod, to the httpd pod. To be able to do this, you need to create a ClusterIP service to sit in front of the httpd pod so that it can accept curl requests coming from other pods in the kubecluster. So first we build the httpd pod:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-httpd-provider
  labels:
    component: apache_webserver
spec:
  containers:
    - name: cntr-httpd
      image: httpd
      ports:
        - containerPort: 80
```

There's nothing special here, it's just a standard httpd pod. Now let's create the ClusterIP type Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-clusterip-httpd   # this is the service endpoint that has a dns entry that we can curl for.
spec:
  type: ClusterIP
  ports:
    - port: 4000       # Other pods will need to access the httpd pod via this port number
      targetPort: 80   # This service object will forward incoming 4000 port requests to this port.
  selector:
    component: apache_webserver   # this is how we link this service to our httpd pod
```

Next we create the centos pod:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-httpd-consumer
  labels:
    component: apache_webserver_consumer
spec:
  containers:
    - name: cntr-centos
      image: centos
      command: ["/bin/bash", "-c"]
      args:
        - while true ; do
            date ;
            curl -s http://svc-clusterip-httpd.default.svc.cluster.local:4000 ;
            sleep 10 ;
          done
```

The key thing to note here, is the fqdn name we used, here's its breakdown:

```text
http://{service object's metadata.name}.{namespace name}.svc.cluster.local
```

You can find the '.svc.cluster.local' in the centos container's /etc/resolv.conf file:

```bash
$ minikube ssh
                         _             _
            _         _ ( )           ( )
  ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __  
/' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
| ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
(_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)

$ docker ps | grep consumer
bf4ab9283adb        centos                                    "/bin/bash -c 'while…"   19 minutes ago      Up 19 minutes                           k8s_cntr-centos_pod-httpd-consumer_default_2ccb9a48-36c6-11e9-b8a5-080027913128_0
0578c96f59d4        k8s.gcr.io/pause:3.1                      "/pause"                 19 minutes ago      Up 19 minutes                           k8s_POD_pod-httpd-consumer_default_2ccb9a48-36c6-11e9-b8a5-080027913128_0
$ docker exec -it bf4ab9283adb /bin/bash
[root@pod-httpd-consumer /]# cat /etc/resolv.conf
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
[root@pod-httpd-consumer /]#
```

the content of the resolv.conf file is managed by whatever networking plugin is installed in the kubernetes install, e.g. flannel, weave, calico,...etc. After applying these configs we should now have:

```bash
$ kubectl get pods
NAME                 READY     STATUS    RESTARTS   AGE
pod-httpd-consumer   1/1       Running   0          23m
pod-httpd-provider   1/1       Running   0          32m
$ kubectl get service
NAME                  CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes            10.96.0.1        <none>        443/TCP    1d
svc-clusterip-httpd   10.101.183.250   <none>        4000/TCP   32m
```

The next thing to check is whether our centos is managing to successfully access the httpd pods. We can check this by simply viewing the container logs:

```bash
$ kubectl logs pod-httpd-consumer -c cntr-centos
Fri Feb 22 17:20:43 UTC 2019
<html><body><h1>It works!</h1></body></html>
Fri Feb 22 17:21:03 UTC 2019
<html><body><h1>It works!</h1></body></html>
Fri Feb 22 17:21:23 UTC 2019
.
.
...etc
```
Note, I noticed there is a lag in getting the logs for some reason. So give it a few mins before trying this command. Also notice that I also specified the -c (container) flag followed by the container name. That's only required if you have a multi-container pod, otherwise you can leave it out. 


At this point we've only provided pod-to-pod related networking. So at this point we won't be able to access the service externally (e.g. from our macbook). So to fix that, we can just create an aditional service object, but this time as a nodeport service:

```bash
---
  apiVersion: v1
kind: Service
metadata:
  name: svc-nodeport-apache-webserver
spec:
  type: NodePort
  ports:
    - port: 3050

      targetPort: 80
      nodePort: 31000
  selector:
    component: apache_webserver
```

Then it will work:

```bash
$ minikube ip
192.168.99.100
$ curl http://192.168.99.100:31000
<html><body><h1>It works!</h1></body></html>
```

So now we have to service abjects associated with the httpd pod, one (ClusterIP) service to enable pod-2-pod communication. And the second (Nodeport) service to enable external-to-pod communication.

Now let's cleanup:

```bash
$ kubectl delete -f configs/ClusterIP-example
pod "pod-httpd-consumer" deleted
pod "pod-httpd-provider" deleted
service "svc-clusterip-httpd" deleted
service "svc-nodeport-apache-webserver" deleted
```