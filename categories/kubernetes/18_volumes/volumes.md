# Volumes

There are different types of storage options available in Kubernetes, they are:

1. [Persistent Volumes - aka PV](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) - this is a volume that is persistent even if/when the pod that's using it dies. Persistent Volumes lives outside the pod.
2. [Persistent Volume Claims - aka PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#lifecycle-of-a-volume-and-claim). - https://rancher.com/blog/2018/2018-09-20-unexpected-kubernetes-part-1/ 

We've already coverer Volumes, so will cover PVs and PVCs.

## Storage option

When you create a PV, you can optionally specify what type of storage is used to host the PV, i.e. you can specify the [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/#aws-ebs). These 'storageclass' are yet another type of object, like pods, services, etc. So you can create your own storageclass objects, by writing out the the corresponding yaml file. 

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

This basically means that any volumes created will end up using the local disk space that's available inside your minikube vm by default, which in turn means it will use your local workstation/macbook hard drive. However if you don't want to use the default, 'standard', you can create your own storageClass object files, apply them, then in your volume object files you can specify what 'StorageClassName'. If you install your kubecluster somewhere else, e.g. AWS, then you can take advantage other storage classes, e.g. [AWS EBS Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/#aws-ebs). In fact the kubernetes will automatically set AWS EBS as the default for you.



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

At this point we have created our pod, which is now using the pv that's been provisioned by the PVC:


```bash
$ kubectl get pods
NAME           READY     STATUS    RESTARTS   AGE
pod-mysql-db   1/1       Running   0          15m
$ kubectl get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc-db    Bound     pvc-bb37f1b4-39d8-11e9-8b76-080027635baa   100Mi      RWO           standard       13m
$ kubectl get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM            STORAGECLASS   REASON    AGE
pvc-bb37f1b4-39d8-11e9-8b76-080027635baa   100Mi      RWO           Delete          Bound     default/pvc-db   standard                 13m
```


## Testing our Persistant Volume. 

On the surface it looks like our mysql data will now be persistant. Let's now try to test this. We'll test this by creating a mysql session, create a new dummy db, then exit out, rebuild the pod, then see if that dummy db still exists. 

Now lets test this, first we install mysql client on our macbook:

```bash
brew install mysql-client
```

Now set up networking so that we can reach the pod's exposed mysql port:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: svc-nodeport-mysql-db-server
spec:
  type: NodePort
  ports:
    - port: 3050     # only used for pod-2-pod communication. 
      targetPort: 3306
      nodePort: 31306
  selector:
    component: mysql_db_server
```

Now check if we can reach that port using nc or telnet:

```bash
$ nc -v  192.168.99.101 31306
found 0 associations
found 1 connections:
     1: flags=82<CONNECTED,PREFERRED>
        outif vboxnet7
        src 192.168.99.1 port 51493
        dst 192.168.99.101 port 31306
        rank info not available
        TCP aux info available

Connection to 192.168.99.101 port 31306 [tcp/*] succeeded!
```

Now try establishing a mysql connection:

```bash
$ mysql -h 192.168.99.101 -P 31306 -u root -p'password123'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 16
Server version: 8.0.15 MySQL Community Server - GPL

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

Now lets create a dummy db:

```bash
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

mysql> CREATE DATABASE dummy_db;
Query OK, 1 row affected (0.02 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| dummy_db           |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> exit
Bye
```

Now let's rebuild our pod, and then see if our dummy db still exists:


```bash
$ kubectl delete -f configs/pvc-example/pod-mysql-obj-def.yml 
pod "pod-mysql-db" deleted

$ kubectl apply -f configs/pvc-example/pod-mysql-obj-def.yml 
pod "pod-mysql-db" created

$ kubectl get pods
NAME           READY     STATUS              RESTARTS   AGE
pod-mysql-db   0/1       ContainerCreating   0          3s
$ kubectl get pods
NAME           READY     STATUS    RESTARTS   AGE
pod-mysql-db   1/1       Running   0          5s

$ mysql -h 192.168.99.101 -P 31306 -u root -p'password123'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.15 MySQL Community Server - GPL

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| dummy_db           |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql>

```



