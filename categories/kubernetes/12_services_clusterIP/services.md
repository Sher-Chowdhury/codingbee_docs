# ClusterIP Service Type

As covered earlier, Kubernetes comes with some networking features out-of-the-box. But there are other networking that you need to setup yourself, which you do by creating Service objects. We've already covered one type of service object, the nodePort type. nodePort services are relatively easy to understand+setup, but they're not suitable for using in production environments. Instead of creating NodePort services, it's better to create **ClusterIP** and **Ingress** service objects.


This ClusterIp service objets are specifically designed for setting up inter pod-to-pod communications inside a kube cluster.

For example, let's say we have 2 pods, one is generic httpd pod, and the other is a generic centos pod. Let's say we want to be able to curl from the centos pod, to the httpd pod. To be able to do this, you need to create a ClusterIP service to sit in front of the httpd pod so that it can accept curl requests coming from other pods in the same kubecluster. So first we build the httpd pod:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: svc-clusterip-httpd   # this is the service endpoint that has a dns entry that we can curl for. 
spec:
  type: ClusterIP
  ports:
    - port: 80          # you can choose to use a different port number here if you like.
      targetPort: 80
  selector:
    component: httpd_webserver
```

From this yaml file, you'll see that ClusterIP gives us two really important features:

- ClusterIP objects ends up adding a [dns entry](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#what-things-get-dns-names) in the kube cluster's internal dns service (kube-dns/coredns).
- ClusterIP objects comes with built in loadbalancing - It forwards traffic to all pods with the matching label

This yaml file ends up creating:

```bash
$ kubectl get svc
NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kubernetes                      ClusterIP   10.96.0.1        <none>        443/TCP          3d16h
svc-clusterip-httpd             ClusterIP   10.99.76.207     <none>        80/TCP           5m8s
```

You can think of ClusterIP objects as an internal loadbalancer with a working static dns name. It's makes ClusterIP objects perfectly suited to deliver traffic to a group of pods spawnd by a Deployment object. Here's our example:


```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dep-httpd
  labels:
    component: apache_webserver
spec:
  replicas: 3 
  selector:
    matchLabels:
      component: httpd_webserver
  template:
    metadata:
      labels:
        component: httpd_webserver
    spec: 
      containers:
        - name: cntr-httpd
          image: httpd:latest
          ports:
            - containerPort: 80
          command: ["/bin/bash", "-c"]
          args:
            - |
              /bin/echo "The pod, $HOSTNAME is displaying this page." > /usr/local/apache2/htdocs/index.html
              /usr/local/bin/httpd-foreground  
```

This deployment ends up creating:

```bash
$ kubectl get pods -o wide --show-labels
NAME                         READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
dep-httpd-597fc5f696-4jt8b   1/1     Running   0          106s   172.17.0.8    minikube   <none>           <none>            component=httpd_webserver,pod-template-hash=597fc5f696
dep-httpd-597fc5f696-6ttn4   1/1     Running   0          106s   172.17.0.10   minikube   <none>           <none>            component=httpd_webserver,pod-template-hash=597fc5f696
dep-httpd-597fc5f696-qw4pf   1/1     Running   0          106s   172.17.0.9    minikube   <none>           <none>            component=httpd_webserver,pod-template-hash=597fc5f696
```

Now we have pods with labels that our ClusterIP object is allowed to send traffic to, we can confirm this in the endpoints entry:

```bash
$ kubectl describe svc svc-clusterip-httpd
Name:              svc-clusterip-httpd
Namespace:         default
Labels:            <none>
Annotations:       kubectl.kubernetes.io/last-applied-configuration:
                     {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"svc-clusterip-httpd","namespace":"default"},"spec":{"ports":[{"po...
Selector:          component=httpd_webserver
Type:              ClusterIP
IP:                10.99.76.207
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         172.17.0.10:80,172.17.0.8:80,172.17.0.9:80
Session Affinity:  None
Events:            <none>
```

Now we can test out the ClusterIP dns and loadbalancing from our centos test pod. 

```bash
$ kubectl exec pod-centos -it /bin/bash
[root@pod-centos /]# curl http://svc-clusterip-httpd.default.svc.cluster.local
The pod, dep-httpd-597fc5f696-4jt8b is displaying this page.
[root@pod-centos /]# curl http://svc-clusterip-httpd.default.svc.cluster.local
The pod, dep-httpd-597fc5f696-4jt8b is displaying this page.
[root@pod-centos /]# curl http://svc-clusterip-httpd.default.svc.cluster.local
The pod, dep-httpd-597fc5f696-6ttn4 is displaying this page.
[root@pod-centos /]# curl http://svc-clusterip-httpd.default.svc.cluster.local
The pod, dep-httpd-597fc5f696-qw4pf is displaying this page.
```

This time we managed to curl to our pods using a dns name rather than ip address. Also we didn't need to use an non-standard port either (although that option is available for use, if we need it). 

As you can see, by running curl a few times, we can also see the ClusterIP's loadbalancing feature also working. By the way we're also running this curl command inside a while loop, as part of the centos pods primary command. You can view this output in the logs:

```bash
$ kubectl logs pod-centos
Wed Mar 13 12:19:02 UTC 2019
The pod, dep-httpd-597fc5f696-qw4pf is displaying this page.
Wed Mar 13 12:19:12 UTC 2019
The pod, dep-httpd-597fc5f696-6ttn4 is displaying this page.
Wed Mar 13 12:19:22 UTC 2019
The pod, dep-httpd-597fc5f696-6ttn4 is displaying this page.
Wed Mar 13 12:19:32 UTC 2019
The pod, dep-httpd-597fc5f696-qw4pf is displaying this page.
```




## DNS Entry structure

We didn't explain how we came up with the url name. Here's the dns name breakdown:

```text
http://{service.metadata.name}.{target.pod's.namespace.name}.svc.cluster.local
```

### Some background info

To better understand how the dns lookup worked behind the scenes. We first to look at our container's dns configuration file,which is the resolv.conf file:

```bash
$ kubectl exec pod-centos -it /bin/bash
[root@pod-centos /]# cat /etc/resolv.conf 
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5

```

A pod's resolv.conf file is autogenerated by kubernetes during the pod's launch time. The nameserver's ip address points to the kubernetes internal kube-dns clusterIP service, which in turn forwards dns lookups to Kubernetes's internal coredns pods:

```bash
$ kubectl get svc -o wide --namespace=kube-system | grep dns
kube-dns               ClusterIP   10.96.0.10     <none>        53/UDP,53/TCP   3d17h   k8s-app=kube-dns

$ kubectl describe service kube-dns --namespace=kube-system | grep Endpoint
Endpoints:         172.17.0.2:53,172.17.0.3:53
Endpoints:         172.17.0.2:53,172.17.0.3:53
$ kubectl get pods -o wide --namespace=kube-system | grep 172.17.0.2
coredns-86c58d9df4-zl7j4                   1/1     Running   0          3d17h   172.17.0.2   minikube   <none>           <none>
```

The resolv.conf also gives domain's value (default.svc.cluster.local) with our currently logged container's namespace (default) hardcoded in. Therefore when we do an dns lookup from inside the centos container we get:

```bash
[root@pod-centos /]# nslookup svc-clusterip-httpd.default.svc.cluster.local
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   svc-clusterip-httpd.default.svc.cluster.local
Address: 10.99.76.207
```

Just remember, if our httpd pods were in a different namespace to our centos pods, then we would have needed to replace 'default' with the correct namespace name.



## Making Pods Externally accessible

At the moment our httpd pods are not externally accessible, which is fine if they are solely intended to be used inside the kube cluster.

However if you want the httpd pods to be externally accessible, then just setting up ClusterIP objects alone won't be enough to give you that ability. The recommended way of doing this is by creating another type of service object, the Ingress object. We'll cover that next. 


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