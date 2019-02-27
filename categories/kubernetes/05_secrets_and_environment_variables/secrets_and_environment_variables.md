# Secrets and Environment Variables

Some Docker images, e.g. the [official mysql image](https://hub.docker.com/_/mysql) have options to feed [docker image environment variables](https://hub.docker.com/_/mysql#environment-variables) into the the container. These environment are usually optional, but can also be mandatory. In the case of the mysql image, only MYSQL_ROOT_PASSWORD is mandatory. These environment variables are usually used by an [entrypoint](https://github.com/docker-library/mysql/blob/master/8.0/docker-entrypoint.sh) script.

Here we're going to look at how we feed in environment variables into a container using kubernetes. We'll use the official mysql image for this walkthrough.




## Environment Variables

The [mysql docker image environment variables](https://hub.docker.com/_/mysql#environment-variables) documentation tells us what env variables are avaliable, so we now construct a pod definition yaml file with the content:


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-mysql-db
  labels:
    component: mysql_db_server
spec: 
  containers:
    - name: cntr-mysql-db
      image: mysql
      env:                       # we use 'env' section to feed in environments variables
        - name: MYSQL_DATABASE      # this is an optional environment variable
          value: dummy_db
        - name: "MYSQL_ROOT_PASSWORD"  # this is a mandatory environment variable
          value: "password123"
      ports:
        - containerPort: 3306
```

Note: We have defined MYSQL_ROOT_PASSWORD in plain text above. That's not best practice, we'll cover a better approach using secrects further down.

Environment variables must be in the form of a string. Hence any variable that is a number, must be enclosed in single quotes. 

Now lets build this:

```bash
$ kubectl apply -f configs/env_example
pod/pod-mysql-db created
service/svc-nodeport-mysql-db-server created
```

This seems to have worked:

```bash
$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
pod-mysql-db   1/1     Running   0          39s
$ kubectl get svc
NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes                     ClusterIP   10.96.0.1       <none>        443/TCP          4m46s
svc-nodeport-mysql-db-server   NodePort    10.111.211.39   <none>        3050:31306/TCP   43s
```

But the only way to know for sure is to take a look inside the pod by creating a mysql session inside it. 


### Creating a mysql session to a pod

Let's start by finding out what ip address we should be using:

```bash
$ minikube ip
192.168.99.102
```

Now let's see if we can nc/telnet to it (using the port number that's listed in our svc object as shown above):



```bash
$ nc -v 192.168.99.102 31306
found 0 associations
found 1 connections:
     1: flags=82<CONNECTED,PREFERRED>
        outif vboxnet7
        src 192.168.99.1 port 54368
        dst 192.168.99.102 port 31306
        rank info not available
        TCP aux info available

Connection to 192.168.99.102 port 31306 [tcp/*] succeeded!
```

This means our svc object is working, and our pod is listening on port 3306. Next we install mysql client, on our macbook (if we don't already have it installed):

```bash
brew install mysql-client
```


Now lets try establishing a mysql connection and see if our dummy_db exists:

```bash
$ mysql -h 192.168.99.102 -P 31306 -u root -p'password123'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.15 MySQL Community Server - GPL

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| dummy_db           |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.01 sec)

mysql> 
```

Success!






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

Now let's delete everything:

```bash
$ kubectl delete -f configs/env_example
pod "pod-mysql-db" deleted
service "svc-nodeport-mysql-db-server" deleted
```

# Using Secrets

In the previous example, our config file had a big flaw in respect to the fact that we stored passwords in plain text. Which is worse if you store your kube object files in a git repo. [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) are just another type of object. However we dont create secret object declaritively by writing out an secrets object definition file, because you would end up with the same problem as with the pod yaml file. Instead we do it imperative (i.e. manually from the command line):

```bash
$ kubectl create secret generic mysql-secrets --from-literal MysqlRootPassword=password123
secret/mysql-secrets created


$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-p5k7f   kubernetes.io/service-account-token   3      28m  # this comes included in kube cluster. 
mysql-secrets        Opaque                                1      10s
```

Here, the word 'generic' means refers to the type of secret. The 'generic' type simply meants to create a secret from the contents from local file, directory or literal value. Other options are 'docker-registry' and 'tls'. 

--from-literal means use the key=value pair specified on the same command line

The object we created is called mysql-secrets. That object can house multipe key-value pairs for storing secrets. At the moment we're only storing once key-value pair inside this secret. 

If you want to view this secret, then you do so by [decoding the kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/#decoding-a-secret):

```bash
$ kubectl get -o yaml secrets mysql-password
apiVersion: v1
data:
  MYSQL_ROOT_PASSWORD: cGFzc3dvcmQxMjM=
kind: Secret
metadata:
  creationTimestamp: "2019-02-27T12:04:14Z"
  name: mysql-password
  namespace: default
  resourceVersion: "2484"
  selfLink: /api/v1/namespaces/default/secrets/mysql-password
  uid: ccd105fa-3a87-11e9-946d-0800271ef513
type: Opaque

$ echo 'cGFzc3dvcmQxMjM=' | base64 --decode
password123
```

Now we modify our pod yaml file so that it now looks like:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-mysql-db
  labels:
    component: mysql_db_server
spec: 
  containers:
    - name: cntr-mysql-db
      image: mysql
      env:
        - name: MYSQL_DATABASE
          value: dummy_db
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secrets      # this is the name of the object that holds one or more key-value pairs. 
              key: MysqlRootPassword   # this is the name of the key, whose value we're interested in. 
      ports:
        - containerPort: 3306
```

Now let's try it out:

```bash
$ mysql -h 192.168.99.102 -P 31306 -u root -p'password123'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.15 MySQL Community Server - GPL

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

Success!

In this mysql example, everytime you delete the mysql pod, all data stored inside the mysql database get's deleted as well, which isn't good. That's why you should use Kubernetes Persistent Volumes for storing persistant data. Will cover more about Kubernetes Volumes later.
