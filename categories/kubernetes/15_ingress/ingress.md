# Ingress

Earlier we covered service objects which sets up networking between pods in the same kubecluster, by creating a ClusterIP service, and also how we can make a pod externally accessible by creating a NodePort service. 

However nodeport service isn't recommended in a production environment, and should only be used in dev kubecluster environments. Theres a few reasons for this:

- You end up using a lot of non-standard pods to make externally facing pods accessible. Also keeping track of which port is which can be a nightmare. 
- You end up with worker nodes listening on lots of ports, at the VM machine level. This isn't a neat solution and it also means that you end up meaning extra work in terms of updating AWS Security Groups to whitelist all these ports.

The ideal solution would be to have your worker nodes only listening to standard ports, e.g. port 443 for https. That's possible by Ingress objects. Ingress objects, like services objects is used for setting up networking. Ingress is actually a service type object, but since it's such a big part, it's been spun out into it's own object kind. 

Ingress ojects are specifically for setting up networking to make pods externally accessible. It uses nginx behind the scenes, and it has it's own github repo called [ingress-nginx](https://github.com/kubernetes/ingress-nginx). Like LoadBalancer Service objects, the setup of Ingress is also dependent on which cloud platform you use.


When you create an ingress-nginx object, you are effectively creating an 'Ingress-controller'. So what objects does an Ingress controller build? It basically builds


 - an nginx-revproxy pod that's specifically been optimised to work really well for routing external traffic to pods in the kubecluster. In what way is it optimised, here's a couple of examples:
   - The nginx pod doesn't need a clusterIP service setup to a target group of pods, instead it can communicate/loadbalance to with these pods directly. I.e. the ngnix pod to some extent has clustIP service abilities builtin. 
   - it can setup sticky sessions to pods, where needed. 
 - Cloud specific resources, e.g. if kubecluster is running on AWS, then it builds AWS ELBs. 



## Setting up Ingress on Minikube

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