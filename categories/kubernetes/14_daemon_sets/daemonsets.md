# Daemonsets

This is a variation of deployment object, but in the case of daeamonsets, it ensures exactly one pod is runnnig per worker node. This means:

replicas = no of worker nodes in the kubecluster.

This means that the number of deamonset pods goes up/down every time you add/remove worker nodes.

There are a few use-cases for these:

- log aggregators - Have one filebeat pod per worker node, to collect logs of all other pods
- monitor - a pod that monitors the worker node itself. 
- loadbalancers/Rev proxies/API Gateways



Daemonsets are also used by the kubecluster internally:


```bash
root@kube-master:~# kubectl get nodes -o wide
NAME           STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
kube-master    Ready    master   6m50s   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1
kube-worker1   Ready    <none>   4m24s   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1
kube-worker2   Ready    <none>   2m56s   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1

root@kube-master:~# kubectl get daemonsets --namespace=kube-system
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
calico-node   3         3         3       3            3           beta.kubernetes.io/os=linux   4m
kube-proxy    3         3         3       3            3           <none>                        4m45s



root@kube-master:~# kubectl get pods -o wide --namespace=kube-system | grep proxy
kube-proxy-bnzr6                      1/1     Running   0          9m48s   10.0.2.15     kube-master    <none>           <none>
kube-proxy-hcs4t                      1/1     Running   0          6m13s   10.0.2.15     kube-worker2   <none>           <none>
kube-proxy-p7kpl                      1/1     Running   0          7m40s   10.0.2.15     kube-worker1   <none>           <none>
root@kube-master:~# kubectl get pods -o wide --namespace=kube-system | grep calico
calico-node-8q45b                     2/2     Running   0          6m15s   10.0.2.15     kube-worker2   <none>           <none>
calico-node-skhmr                     2/2     Running   0          7m42s   10.0.2.15     kube-worker1   <none>           <none>
calico-node-xrptm                     2/2     Running   0          9m19s   10.0.2.15     kube-master    <none>           <none>
```

Since minikube is only a single node cluster, I have created a [kubernetes vagrant project](https://github.com/Sher-Chowdhury/kubernetes-the-kubeadm-way-vagrant) that spins up a 3-node kube cluster, 1 master and 2 workers: 


```bash
root@kube-master:~# kubectl get nodes -o wide
NAME           STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
kube-master    Ready    master   8m10s   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1
kube-worker1   Ready    <none>   4m28s   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1
kube-worker2   Ready    <none>   2m59s   v1.13.4   10.0.2.15     <none>        Ubuntu 16.04.5 LTS   4.4.0-131-generic   docker://18.6.1
```


