# Pod Quotas

The containers pod might need a minimum amount of cpu+ram in order to work properly. If so then you can specify them with the `pod.spec.containers.resources.requests` settings. Also you can set the maximum amount of cpu+ram your pod's containers are allowed to use, with the `pod.spec.containers.resources.limits` setting, in case your container unexpected and starts using too much hardware resources which in turn could have a knock on impact on other things running on your kube cluster. To see how this works, we'll try this out in a new namespace, 'codingbee', we'll explain why later. 

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dep-httpd
  namespace: codingbee        # notice we are using a new namespace.
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpd_webserver
  template:
    metadata:
      labels:
        app: httpd_webserver
    spec:
      containers:
        - name: cntr-httpd
          image: httpd:latest
          resources:
            requests:           # requests are used for minimum requirements. 
              memory: "64Mi"
              cpu: "100m"   # 1000m = 1 cpu core. So here were requesting just 10%.
            limits:             # Apply limits in case container malfunctions and starts using too much hardware resources. 
              memory: "128Mi"
              cpu: "200m"
          ports:
            - containerPort: 80
```



Since we're using a new namespace, we need to switch over to that namespace:


```bash
$ kubectl config set-context  $(kubectl config current-context) --namespace=codingbee
Context "minikube" modified.

$ kubectl config get-contexts
CURRENT   NAME                 CLUSTER                      AUTHINFO             NAMESPACE
          default              kubernetes                   chowdhus             
          docker-for-desktop   docker-for-desktop-cluster   docker-for-desktop   
*         minikube             minikube                     minikube             codingbee
```

A








# namespace quotas

It's typical to have multiple teams using the same kubecluster. In those cases it's quite common to have a namespace for each team/project/environnment in order to keep things organised. However it's possible that one or more namespaces could end up using too much hardware resources cpu/memory/storage and deprives the other namespaces. To solve this problem you can use [ResourceQuota](https://kubernetes.io/docs/concepts/policy/resource-quotas/) for your namespace.

```yaml
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: codingbee-compute-quota
  namespace: codingbee
spec:
  hard:
    requests.cpu: 1
    limits.cpu: 2 
    requests.memory: 1Gi
    limits.memory: 2Gi
```

ResourceQuota not only sets hardware limits (i.e. cpu and ram) but can also set kubernetes objects limits, e.g. namespace isn't allowed to have more than x pods running. 




