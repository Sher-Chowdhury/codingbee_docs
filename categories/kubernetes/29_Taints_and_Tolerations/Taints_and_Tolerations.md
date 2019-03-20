# Taints and Tolerations (eg1-taints)

Earlier we saw how we can use nodeSelector, and Pod/Node Affinity to attract new pod deployments to certain worker nodes. 

We also looked at `podAntiAffinity` which is a mechanism to deploy new pod deployments away from a group of other existing pods, i.e. it repels them. Taints and Tolerations are other mechanisms for repelling pods from being deployed to certain kube nodes.


## Taints 

Taint is setting you can enable on a kube node, to tell Kubernetes not to deploy any further pods to the node in the future.


ku

For example, as part of provisioning a kubecluster using kubeadm, a number of Kubernetes internal pods are deployed on the master node itself, in the kube-system namespace. As soon as that's done, the kubeadmin init process taints so the kube master that no further pods get's deployed to them. Here's an example of what a taint looks like:

```bash
root@kube-master:~# kubectl describe nodes kube-master | grep Taints
Taints:             node-role.kubernetes.io/master:NoSchedule
```






