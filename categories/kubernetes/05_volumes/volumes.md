# Volumes

There are different types of storage options available in Kubernetes, they are:

1. [Volumes](https://kubernetes.io/docs/concepts/storage/volumes) - This is used for storing pod-level non-persistant (ephemeral) data. If container inside pod dies and gets rebuilt, then the data persists. But if whole pod dies, then the data in the volume gets wiped out. You can think of these volumes as living inside a pod.
2. [Persistent Volumes - aka PV](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) - this is a volume that is persistent even if/when the pod that's using it dies. Persistent Volumes lives outside the pod.
3. [Persistent Volume Claims - aka PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#lifecycle-of-a-volume-and-claim). - This is a oject, but unlike a PV which ends up ringfencing actual storage space, a PVC is actually a bit more like a wishlist. If a Pod needs a PV, then it makes a request to a PVC, and the PVC ringfences that storage space upon request.

We've already coverer Volumes, so will cover PVs and PVCs.

## Storage option

When you create a PV, you can optionally specify what type of storage is used to host the PV, i.e. you can specify the [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/#aws-ebs).

There are a lot storage classes available. However with minikube only provides one out-of-the-box:

```bash
$ kubectl get storageclass
NAME                 TYPE
standard (default)   k8s.io/minikube-hostpath   

$ kubectl describe storageclass standard
Name:           standard
IsDefaultClass: Yes
Annotations:    storageclass.beta.kubernetes.io/is-default-class=true
Provisioner:    k8s.io/minikube-hostpath
Parameters:     <none>
Events:         <none>
```

This basically means that any volumes created will end up using the local disk space that's available inside your minikube vm, which in turn means it will use your local workstation/macbook hard drive. Also when your create a volume object file, you can specify what 'StorageClassName' however if omit mentioning that it will just end up using the (default) is labeled above. If you install your kubecluster somewhere else, e.g. AWS, then you can take advantage other storage classes, e.g. [AWS EBS Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/#aws-ebs). In fact the kubernetes will automatically set AWS EBS as the default for you.



## PVCs

PVs and PVCs are ideally suited on occasions where you want to retain your data after your pod. E.g. a database pod, which runs mysql, postrgres,..etc. In those scenarios when a pod dies, you would want a replacement pod to connect to the existing data store and carry on where the previous pod left off. 

When it comes to non-persistent volumes, we had defined them inside the pod yaml config file. Since they are a part of the pod's definition, these volumes gets deleted when the pod is deleted. However PVCs can exist as a standalone from a pod. So they have their own [PVC api config](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaim-v1-core).


