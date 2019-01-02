# Docker notes

To get docker version info:

```bash
$ docker version
Client:
 Version:           18.09.0
 API version:       1.39
 Go version:        go1.10.4
 Git commit:        4d60db4
 Built:             Wed Nov  7 00:48:22 2018
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.0
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.4
  Git commit:       4d60db4
  Built:            Wed Nov  7 00:19:08 2018
  OS/Arch:          linux/amd64
  Experimental:     false
```

To get more detailed info about your docker server:

```bash
docker system info
Containers: 1
 Running: 1
 Paused: 0
 Stopped: 0
Images: 27
Server Version: 18.09.0
Storage Driver: overlay2
 Backing Filesystem: xfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
 Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary: docker-init
containerd version: c4446665cb9c30056f4998ed953e6d4ff22c7c39
runc version: 4fc53a81fb7c994640722ac585fa9ca548971871
init version: fec3683
Security Options:
 seccomp
  Profile: default
Kernel Version: 3.10.0-862.3.2.el7.x86_64
Operating System: CentOS Linux 7 (Core)
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 1.794GiB
Name: PreprodWallboard.servers.castletrust.co.uk
ID: Z7I2:G4SF:HQM2:O6IX:NFZP:RGLA:OQWU:76EE:2EVJ:QSYR:KI5Q:7GOW
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
Labels:
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
Product License: Community Engine

WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled
```

To download the [hello-world](https://hub.docker.com/_/hello-world/) docker image from docker hub, and then create a container from that image, run:

```bash
docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete
Digest: sha256:2557e3c07ed1e38f26e389462d03ed943586f744621577a99efb77324b0fe535
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

To view a list of docker images currently stored locally, do:

```bash
docker image ls
```

To list running docker containers:

```bash
$ docker container ls
CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS              PORTS                  NAMES
ea2fed155c0b        dashing              "/run.sh"           4 hours ago         Up 4 hours          0.0.0.0:80->3030/tcp   wallboard
```

This only shows running containers, not stopped containers, to view all running+stopped containers do:

```bash
docker container ls --all
```

to stop and delete a container do:

```bash
docker container stop {container-name}
docker container rm {container-name}
```

To delete all containers and images:

```bash
docker container stop $(docker container ls --all --quiet)
docker container rm $(docker container ls --all --quiet)
docker image rm $(docker image ls --quiet)
```

This effectively does a factory reset of your docker server

Here's another hello world example:

```bash
$ docker run centos:latest /bin/echo "hello world"
Unable to find image 'centos:latest' locally
latest: Pulling from library/centos
a02a4930cb5d: Pull complete
Digest: sha256:184e5f35598e333bfa7de10d8fb1cebb5ee4df5bc0f970bf2b1e7c7345136426
Status: Downloaded newer image for centos:latest
hello world
```

This command did the following tasks:

1. download the latest official centos image - you can just do this step by running: "docker pull centos:latest"
2. start a container from that image to run the workload
3. run the workload, which in this example is echo command
4. stop the container, after/if it has finished running the workload

The docker run command is actually running the following 3 commands behind the scenes:

```bash
docker pull centos:latest
docker create centos        # this creates a container from the image, but doesn't start it yet
docker start -a {container_id}  # -a means show all output while the container is running
```

here's how to view the container that ran the worklaod:

```bash
$ docker container ls --all
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS               NAMES
b2ca6fc42122        centos:latest       "/bin/echo 'hello wo…"   9 minutes ago       Exited (0) 9 minutes ago                       kind_hellman
```

To view the standard output of the workload:

```bash
$ docker logs kind_hellman
hello world
```

The logs command is really useful for debugging purposes. E.g. you can use it to view the logs of a stopped container and find out why it stopped unexpectedly. 

The (workload) command section of the above command is actually optional. The image comes with a dafault workload command built-in. So we effectively did an override. To see what the default command is, do:

```bash
$ docker container run centos:latest
$ docker container ls --all
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
8a824c21a5a9        centos:latest       "/bin/bash"         11 seconds ago      Exited (0) 10 seconds ago                       fervent_gauss
```

As you can see, it is just /bin/bash. This command is the last command on the [CentOS 7 official Dockerfile](https://hub.docker.com/_/centos/)



Here's another example, but this time running a long running process:

```bash
docker run --detach httpd
```

This downloads the official apache web server docker image, and starts a container with it. I needed to use the --detach flag
otherwise the docker run command just hangs.

```bash
$ docker container ls
CONTAINER ID        IMAGE               COMMAND              CREATED              STATUS              PORTS                NAMES
2200dbbd2297        httpd               "httpd-foreground"   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp   practical_napier
$ docker ps
CONTAINER ID        IMAGE               COMMAND              CREATED              STATUS              PORTS                NAMES
2200dbbd2297        httpd               "httpd-foreground"   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp   practical_napier
```




This shows that it is listening on port 80, however that's access port 80 from inside the Docker container. To access it from the host machine, you need to setup port forwarding, which we'll cover later. To view what's happenign inside the containter run:

```bash
$ docker logs 2e6cbf5f7dd1
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
[Wed Jan 02 20:57:15.465623 2019] [mpm_event:notice] [pid 1:tid 140265675433152] AH00489: Apache/2.4.37 (Unix) configured -- resuming normal operations
[Wed Jan 02 20:57:15.465864 2019] [core:notice] [pid 1:tid 140265675433152] AH00094: Command line: 'httpd -D FOREGROUND'
```

Now let's run it with port forwarding enabled:

```bash
docker run --detach -p 80:80 httpd
```

Now portwording should now be active, as indicated in the ports column:

```bash
$ docker container ls
CONTAINER ID        IMAGE               COMMAND              CREATED              STATUS              PORTS                NAMES
2200dbbd2297        httpd               "httpd-foreground"   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp   practical_napier
```


Now you tail the logs:

```bash
docker logs --follow {container-id}
```

While following the logs, you should be able to view new entries when accessing the web server:

```bash
$ curl http://10.0.150.33
<html><body><h1>It works!</h1></body></html>
```

Here's how to access a bash terminal inside a container:

```bash
docker container run -it centos:latest /bin/bash
```

-i means interactive. and -t means tty terminal mode.




## Build Docker images

You need to run the following command while inside a directory that contains a file called 'Dockerfile'

```bash
docker build . --tag {image_name}
```