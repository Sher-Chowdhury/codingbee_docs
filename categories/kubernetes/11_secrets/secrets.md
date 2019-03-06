# Secrets

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
