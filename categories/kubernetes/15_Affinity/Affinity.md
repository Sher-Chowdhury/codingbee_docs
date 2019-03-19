# Affinity and Anti-Affinity

We came across nodeSelector as part of looking at deamonsets. [Affinity/Anti-Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) can do the same thing as a nodeSelector but also has more capabilities:

1. More versatile label selection method - e.g. instead of a simple key=value label match. You can just specify deploy/dont-deploy on nodes that has a key with a certain and ignoring what the key's value is. Or you can specify a list of valid values for a given key.  See `pod.spec.affinity.nodeAffinity`
2. Specify preference (rather than hard rules) - So if no suitable deployment target is found, kubernetes will deploy it anyway to non-mathing targets, since it's more important for the pod(s) to exist than having those pods running on non-preferred worker, see `pod.spec.affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`
3. Prevent particular pods from running on the same worker node (co-locating), based on labels. See `pod.spec.affinity.podAntiAffinity`.


## NodeAffinity Preference (eg1-node-affinity)

For this demo we'll create the following node label:


```bash
$ kubectl label nodes kube-worker2 ec2InstanceType=M3
node/kube-worker2 labeled

$ kubectl get nodes --show-labels
NAME           STATUS   ROLES    AGE   VERSION   LABELS
kube-master    Ready    master   81m   v1.13.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kube-master,node-role.kubernetes.io/master=
kube-worker1   Ready    <none>   77m   v1.13.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kube-worker1
kube-worker2   Ready    <none>   75m   v1.13.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ec2InstanceType=M3,kubernetes.io/hostname=kube-worker2

```

then our affinity setting is going to be:


```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-httpd
  labels:
    app: apache_webserver
spec:
  affinity:                # Added this section
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution: # this means decision is made at scheduling stage only, so won't self correct if rule is met in the futuer
        - weight: 10
          preference:
            matchExpressions: 
              - key: ec2InstanceType
                operator: In
                values:
                  - M1
                  - M2
  containers:
    - name: cntr-httpd
      image: httpd:latest
      ports:
        - containerPort: 80
```


Notice here that our Kube-worker1 node is the closest match with label value is M3, but yaml file will match for either M1 or M2. So no match is made. However a pod is still created, since it's more important for the pod(s) to exist on non-ideal worker nodes, than not have any pod(s) at all. 

```bash
# kubectl get pods -o wide --show-labels
NAME        READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES   LABELS
pod-httpd   1/1     Running   0          9m59s   192.168.1.3   kube-worker1   <none>           <none>            app=apache_webserver
```

If a match subsequently came to existance, e.g. matching label applied to existing worker, or new worker node is added to the cluster with matching label, then nothing will happen as implied by 'preferredDuringSchedulingIgnoredDuringExecution'.

```bash
$ kubectl label nodes kube-worker2 ec2InstanceType=M2 --overwrite
node/kube-worker2 labeled

$ kubectl get nodes -o wide --show-labels
NAME           STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME   LABELS
kube-master    Ready    master   3h51m   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1     beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kube-master,node-role.kubernetes.io/master=
kube-worker1   Ready    <none>   3h48m   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1     beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kube-worker1
kube-worker2   Ready    <none>   3h46m   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1     beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ec2InstanceType=M2,kubernetes.io/hostname=kube-worker2

$ kubectl get pods -o wide --show-labels
NAME        READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES   LABELS
pod-httpd   1/1     Running   0          24m   192.168.1.3   kube-worker1   <none>           <none>            app=apache_webserver

```


Even reapplying wont make a difference since the pod already exists:


```bash
$ kubectl apply -f configs/eg1-node-affinity/
pod/pod-httpd unchanged


$ kubectl get pods -o wide --show-labels
NAME        READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES   LABELS
pod-httpd   1/1     Running   0          25m   192.168.1.3   kube-worker1   <none>           <none>            app=apache_webserver
```

The only way to fix this is by rebuilding the pod:


```bash
# kubectl delete -f configs/eg1-node-affinity/ ; kubectl apply -f configs/eg1-node-affinity/
pod "pod-httpd" deleted
pod/pod-httpd created
# kubectl get pods -o wide --show-labels
NAME        READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES   LABELS
pod-httpd   1/1     Running   0          7s    192.168.2.4   kube-worker2   <none>           <none>            app=apache_webserver
```

If you have created a pod cluster via a controller, e.g. deployment, then you can trigger a rebuild by manually deleting one pod at a time.

We just saw a soft rule (preference) in action. If you want a hard rule then use `pod.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution` instead. This does the same job as nodeSelector but with more advanced customisation. 


## preferredDuringSchedulingIgnoredDuringExecution weights

The 'weight' setting is something specific to soft/preference rules. For each preference rule a node matches, it receives a score equal to the weight. So if a certain node matches multiple preferences then it scores higher, and is more likely to have the pods deployed to them. 


## Built-in node labels

If you take a look at the node labels again:

```bash
# kubectl get nodes --show-labels
NAME           STATUS   ROLES    AGE   VERSION   LABELS
kube-master    Ready    master   16h   v1.13.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kube-master,node-role.kubernetes.io/master=
kube-worker1   Ready    <none>   16h   v1.13.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=kube-worker1
kube-worker2   Ready    <none>   16h   v1.13.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,ec2InstanceType=M2,kubernetes.io/hostname=kube-worker2
```

You'll see that the nodes are already tagged with a few labels by default. You can use these built-in labels as part of your Affinity/Anti-Affinity definitions if they meet your needs.  



