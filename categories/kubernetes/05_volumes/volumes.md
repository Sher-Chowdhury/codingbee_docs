# Volumes

There are different types of storage options available in Kubernetes, they are:

1. [Volumes](https://kubernetes.io/docs/concepts/storage/volumes) - This is used for storing pod-level non-persistant (ephemeral) data. If container inside pod dies and gets rebuilt, then the data persists. But if whole pod dies, then the data in the volume gets wiped out. You can think of these volumes as living inside a pod.
2. [Persistent Volumes - aka PV](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) - this is a volume that is persistent even if/when the pod that's using it dies. Persistent Volumes lives outside the pod.
3. [Persistent Volume Claims - aka PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#lifecycle-of-a-volume-and-claim). - This is a oject, but unlike a PV which ends up ringfencing actual storage space, a PVC is actually a bit more like a wishlist. If a Pod needs a PV, then it makes a request to a PVC, and the PVC ringfences that storage space upon request, by creating the appropriately speced PVC.

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

Earlier we saw that, with non-persistent volumes, we had defined them as part of the the pod yaml config file. Therefore since they are a part of the pod's definition, these volumes gets deleted when the pod is deleted. However PVCs can exist as a standalone from a pod. So they have their own [PVC api config](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaim-v1-core).

Here's an example of what a PVC yaml config looks like:

```bash
---
# apiVersion: v1   # had to comment this out for now because of https://github.com/kubernetes/kubernetes/issues/74597
kind: PersistentVolumeClaim 
metadata:
  name: pvc-db
spec:
  accessModes:
    - ReadWriteOnce   # this means that corresponding PV can only be used by a single node. Also see: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
  resources:
    requests:
      storage: 100Mi
# storaegeClassName: # Here you can make refrence to a storageclass object, kubernetes comes with a default
                     # storage class called 'standard'. This get's used if this line isn't used. If you want to use
                     # something else, e.g. nfs, then first create a NFS based storage object. For more info, see:
                     # https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource
```

So let's apply this:

```bash
$ kubectl apply -f configs/pvc-example/pvc-obj-def.yml
persistentvolumeclaim "pvc-db" created
$ kubectl get pvc
NAME      STATUS    VOLUME    CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc-db    Pending                                      standard       3s


$ kubectl get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc-db    Bound     pvc-553bf7c3-39cc-11e9-8b76-080027635baa   100Mi      RWO           standard       5s
```

You will also notice that a PV has also been created behind the scenes:

```bash
$ kubectl get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM            STORAGECLASS   REASON    AGE
pvc-553bf7c3-39cc-11e9-8b76-080027635baa   100Mi      RWO           Delete          Bound     default/pvc-db   standard                 9s
```

Basically the PVC created and ringfenced this pv because it anticipates it will be needed in the near future. This PV objectively has essentially been pre-emptively created by the PVC. 

Now let's build a pod that will make use of this PVC, here's what we're going to build:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-mysql-db
  labels:
    component: mysql_db_server
spec: 
  volumes: 
    - name: db-data-storage 
      persistentVolumeClaim:
        claimName: pvc-db  # nee
  containers:
    - name: cntr-mysql-db
      image: mysql
      env:
        - name: "MYSQL_ROOT_PASSWORD" # This is something that's needed by the mysql image in particular.
          value: "password123"
      volumeMounts:
        - name: db-data-storage      # this needs to match the volume name given above.
          mountPath: /var/lib/mysql
      ports:
        - containerPort: 3306

```




Now lets test this, first we install mysql client on our macbook:

```bash
brew install mysql-client
```