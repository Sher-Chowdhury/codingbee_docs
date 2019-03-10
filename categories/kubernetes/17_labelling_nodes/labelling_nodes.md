# Labelling nodes

We've already seen how the concept of labelling objects with key/value pairs are used extensively in Kubernetes. However you can also label your worker nodes. One reason you might want to do this is if have pods you only want to deploy to certain worker nodes. 

It's not that easy to demo this on minikube, since minikube is just a single node cluster:

```bash
$ kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
minikube   Ready    master   25h   v1.13.3
```

However the way you label nodes is by running the label command:

```bash
kubectl label nodes nodename ec2InstanceType=M3
```

Then for all pods that you want to deploy to nodes with this tag, in the pod's yaml definition, add the 'spec.nodeSelector' setting, and set it to, 

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-httpd
  labels:
    component: apache_webserver
spec:
  nodeSelector:              # add this section
    ec2InstanceType: M3      # add this line
  containers:
    - name: cntr-httpd
      image: httpd:latest
      ports:
        - containerPort: 80
```