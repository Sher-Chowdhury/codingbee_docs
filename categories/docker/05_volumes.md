# Docker Volumes

Docker volumes have a number of useful use cases. 


## Scenario 1: I want to uplaod a file into a docker container form my workstation. 

This is done by doing a hardlink like approach between a folder on your local workstation, and a folder inside your container. 

```bash
mkdir ./test
echo 'hello' > ./test/index.html
```

Now we start a new container which is mapped to this folder:

```bash
$ docker run --detach --volume $(pwd)/test:/usr/local/apache2/htdocs --publish 8000:80 httpd1ba872ddbdab3f05c9a865c4f9f5a50bbaf610eb58d8c121be1d940baa7c5310
```

Now lets check this is working:

```bash
$ curl http://localhost:8000
hello
```

Now lets edit our local copy of the index.html file, and retest:

```bash
$ curl http://localhost:8000
hello
$ echo 'hello CODINGBEE!' > ./test/index.html
$ curl http://localhost:8000
hello CODINGBEE!
```


## Scnenario 2: I want to share a folder between 2 or more containers

This is done by createing a resource called volume:

```bash
$ docker volume create codingbee_volume
codingbee_volume
$ docker volume ls
DRIVER              VOLUME NAME
local               codingbee_volume
```

Next we make use of this volume:

```bash
docker run --detach --volume codingbee_volume:/usr/local/apache2/htdocs --publish 8000:80 httpd
```

Note, if this volume didn't exist before hand, then docker would have automatically create this for you. next we spin up a new container and mount the same volume, then make a change:

```bash
$ docker run -it --volume codingbee_volume:/tmp busybox
/ # cd /tmp/
/tmp # ls
index.html
/tmp # cat index.html 
<html><body><h1>It works!</h1></body></html>
/tmp # echo 'edited whilst inside busybox container' > /tmp/index.html 
/tmp # exit
$ curl http://localhost:8000
edited whilst inside busybox container
```
Note: if testing with a web browser instead of curl, then make sure to open in new private windows to view the changes. 



