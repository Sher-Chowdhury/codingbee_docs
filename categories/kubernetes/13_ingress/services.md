# Services

In Kubernetes, 'services' is actually all about networking. In Docker world, when you use docker-compose, all the networking is done for you automatically behind the scenes. However that's not the case when it comes to kubernetes. To setup networking in Kubernetes, you need to create 'service' objects.

There are [4 main types of of services](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types).


## Nodeport Service Type

We have already created this type of service in earlier examples. The NodePort service type is specifically used for making a pod accessible externally. E.g. from another VM, or another pod from another Kubecluster. Nodeport can't be used for pod-to-pod communication where both pods are running in the same kube cluster.

Nodeport is actually rarely used in production, and is mainly used for development purposes only.

## ClusterIP Service Type

This service type is specifically designed for setting up inter pod-to-pod communications inside a kube cluster.

For example, let's say we have 2 pods, one is generic httpd pod, and the other is a generic centos pod. Let's say we want to be able to curl from the centos pod, to the httpd pod. To be able to do this, you need to create a ClusterIP service to sit in front of the httpd pod so that it can accept curl requests coming from other pods in the same kubecluster. So first we build the httpd pod:

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



## LoadBalancer Service Type

This type of service is used for making pods externally accessible (using cloud specific technologies). E.g. if your kubecluster is running on AWS, and want to make a group of identical pods externally accessible, then you create a loadbalancer object, and that object will end up creating an AWS ELB behind the scenes to route traffic to the pods. 

LoadBalancer is slowly getting deprecated and is being replaced by the Ingress Service type. 


## Ingress Service Type

This type of service is used for making pods externally accessible. It uses nginx behind the scenes, and it has it's own github repo called [ingress-nginx](https://github.com/kubernetes/ingress-nginx). Like the LoadBalancer service type, the setup of Ingress is also dependent on which cloud platform you use.


When you create an ingress-nginx object, you are effectively creating an 'Ingress-controller'. The word 'controller' is used in Kubernetes to refer to objects that doesn't actually to any heavy-lifting low level work, e.g. it doesn't run any containers like pods do, or route traffic, like nodeport service objects do. Instead a controller object creates other objects that does all the legwork, and it ensures the state of those objects. Therefore a controller builds other objects to reach a desired state, and then constantly monitors+maintains that desired state. 

Based on that, the Ingress Service object is actually a type of controller object. So what objects does an Ingress controller build? It basically builds


 - an nginx-revproxy pod that's specifically been optimised to work really well for routing external traffic to pods in the kubecluster. In what way is it optimised, here's a couple of examples:
   - The nginx pod doesn't need a clusterIP service setup to a target group of pods, instead it can communicate/loadbalance to with these pods directly. I.e. the ngnix pod to some extent has clustIP service abilities builtin. 
   - it can setup sticky sessions to pods, where needed. 
 - Cloud specific resources, e.g. if kubecluster is running on AWS, then it builds AWS ELBs. 



### Setting up Ingress on Minikube

The [Nginx official Ingress](https://kubernetes.github.io/ingress-nginx/) Documentation covers how to set up the Ingress object. First go to the [Ingress deploy](https://kubernetes.github.io/ingress-nginx/deploy/) section. Then perform the [generic deployloyment](https://kubernetes.github.io/ingress-nginx/deploy/#prerequisite-generic-deployment-command), this part is irrespective of what cloud platform you're using. 

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
namespace/ingress-nginx created
configmap/nginx-configuration created
configmap/tcp-services created
configmap/udp-services created
serviceaccount/nginx-ingress-serviceaccount created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-role created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-role-nisa-binding created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-clusterrole-nisa-binding created
deployment.apps/nginx-ingress-controller created
```

This ends up creating a new namespace and creates objects inside that namespace.

```bash
$ kubectl get all --namespace=ingress-nginx
NAME                                            READY   STATUS    RESTARTS   AGE
pod/nginx-ingress-controller-797b884cbc-qddzz   1/1     Running   0          8m7s

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-ingress-controller   1/1     1            1           8m7s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-ingress-controller-797b884cbc   1         1         1       8m7s
$ kubectl get configmap --namespace=ingress-nginx
NAME                              DATA   AGE
ingress-controller-leader-nginx   0      7m49s
nginx-configuration               0      8m35s
tcp-services                      0      8m35s
udp-services                      0      8m35s
```

Next we following the instructions to [enable ingress for minkube](https://kubernetes.github.io/ingress-nginx/deploy/#minikube)

```bash
$ minikube addons enable ingress
✅  ingress was successfully enabled
```

Now we create our test environment.

```yaml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-service
  annotations:      # this is something specific to ingress objects. It lets you customise your ingress setup.
    kubernetes.io/ingress.class: nginx  # this is how we tell k8s to build ingress controller using the nginx project.
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
spec:
  rules:
    - http:       # this enables listening on port 80, i.e. http port
        paths:
          - path: /
            backend:
              serviceName: svc-clusterip-httpd
              servicePort: 4000
```

There are a lot of [Ingress Controller Annotation settings](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations) available that allows you to customise your Kubernetes setup. 

Applying this yaml results in:

```bash
$ kubectl apply -f configs/ingress-example/ingress-obj-def.yaml 
ingress.extensions/ingress-service created

$ kubectl get ingress
NAME              HOSTS   ADDRESS   PORTS   AGE
ingress-service   *                 80      4s
```

Now we can test it by running:

```bash
$ minikube ip
192.168.99.102

$ curl http://192.168.99.102
<html><body><h1>It works!</h1></body></html>
```

The important thing here is that we no longer need to specify a port number in the url. 


Noticed that we disabled some ssl setting annotations in the yaml file. That's just to avoid getting unwanted redirect messages, or insecure ssl certs message, which can still be suppressed using -Lk curl flags as shown below: 


```bash
$ curl http://192.168.99.102
<html>
<head><title>308 Permanent Redirect</title></head>
<body>
<center><h1>308 Permanent Redirect</h1></center>
<hr><center>nginx/1.15.6</center>
</body>
</html>


$ curl -L http://192.168.99.102
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl performs SSL certificate verification by default, using a "bundle"
 of Certificate Authority (CA) public keys (CA certs). If the default
 bundle file isnt adequate, you can specify an alternate file
 using the --cacert option.
If this HTTPS server uses a certificate signed by a CA represented in
 the bundle, the certificate verification probably failed due to a
 problem with the certificate (it might be expired, or the name might
 not match the domain name in the URL).
If you'd like to turn off curl's verification of the certificate, use
 the -k (or --insecure) option.
HTTPS-proxy has similar options --proxy-cacert and --proxy-insecure.


$ curl -Lk  http://192.168.99.102
<html><body><h1>It works!</h1></body></html>

```

## Accessing different pods based on different urls

So far we've seen how we can access one pod via ingress. However another common scenario is that you want to access a particular pod based on the url. Here's an example of a ingress file to do something like that:

```yaml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-service
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
spec: 
  rules: 
    - host: httpd-demo.com    # we specify a domain name this time. 
      http:
        paths:
          - path: /
            backend:
              serviceName: svc-clusterip-httpd
              servicePort: 4000
    - host: nginx-demo.com          # we specify a domain name this time. 
      http:
        paths:
          - path: /
            backend:
              serviceName: svc-clusterip-nginx
              servicePort: 5000
```

Here we specify to rules. One that forwards traffic to a httpd pod, and the other to an nginx pod. 

We also have to add these custom domains into our local hosts file:

```bash
$ echo "$(minikube ip)   nginx-demo.com" >> /etc/hosts
$ echo "$(minikube ip)   httpd-demo.com" >> /etc/hosts
```

Now we apply the above configs:

```bash
$ kubectl apply -f configs/ingress-example2
ingress.extensions/ingress-service created
pod/pod-httpd-provider created
pod/pod-nginx-provider created
service/svc-clusterip-httpd created
service/svc-clusterip-nginx created
```

Now notice that our nginx pod has whitelisted the following domains/hosts:

```bash
$ kubectl get ingress
NAME              HOSTS                           ADDRESS   PORTS   AGE
ingress-service   httpd-demo.com,nginx-demo.com             80      32s
```

Now we try this out:

```bash
$ curl -Lk  http://nginx-demo.com
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




$ curl -Lk  http://httpd-demo.com
<html><body><h1>It works!</h1></body></html>
```

Success!



### Further Reading

This is to do with:


https://github.com/kubernetes/ingress-nginx

https://kubernetes.github.io/ingress-nginx/


https://www.joyfulbikeshedding.com/blog/2018-03-26-studying-the-kubernetes-ingress-system.html

https://itnext.io/an-illustrated-guide-to-kubernetes-networking-part-1-d1ede3322727
https://itnext.io/an-illustrated-guide-to-kubernetes-networking-part-2-13fdc6c4e24c
https://itnext.io/an-illustrated-guide-to-kubernetes-networking-part-3-f35957784c8e

https://medium.com/@awkwardferny/getting-started-with-kubernetes-ingress-nginx-on-minikube-d75e58f52b6c

https://www.reddit.com/r/kubernetes/comments/8x1am5/get_automatic_https_with_lets_encrypt_and/

https://kubedex.com/ingress/