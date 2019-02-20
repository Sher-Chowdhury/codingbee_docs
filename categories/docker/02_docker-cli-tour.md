# Docker notes

## View info about your General Docker setup

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

## A simple hello-world example

This example is made up 3 steps:

1. download the hello-world image
2. create a container from the image
3. start the container

**Step 1:** we download the [hello-world](https://hub.docker.com/_/hello-world/) docker image from docker hub:

```bash
$ docker pull hello-world
Using default tag: latest
latest: Pulling from library/hello-world
1b930d010525: Pull complete
Digest: sha256:2557e3c07ed1e38f26e389462d03ed943586f744621577a99efb77324b0fe535
Status: Downloaded newer image for hello-world:latest
```

We now have the followng image available locally:

```bash
$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              fce289e99eb9        4 days ago          1.84kB
```

**Step 2:** We now create a container from this image:

```bash
$ docker container create --name cntr_hello-world hello-world
cbc947515086aceb33c46197b29b08fffc5adcb1c84ff0d5d6609788a4b632f0
```

Here we used the optional --name flag to give a name to our container. If we din't use the name flag, then docker will randomly generate a name for us. I also used a 'cntnr_' prefix in the name just to help us keep track of things.   

This creates the following container:

```bash
$ docker container ls --all
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
cbc947515086        hello-world         "/hello"            50 seconds ago      Created                                 cntr_hello-world
```

The command only lists containers that are running. That's why we used the --all flag to force this command list all running and stopped containers. Also notice that are container has a randomly generated name, 'thirsty_hopper'.

**Step 3:** So far we have created the container but haven't started it yet. So let's start it:

```bash
$ docker container start --attach cntr_hello-world 

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

The --attach flag is used to tell docker to attach our current bash session to this docker container's standard output. If we omitted it, then the container would have run, but it wouldn't have displayed the above message. 

This container only runs long enough to output the above message. It then stopped running as soon as the output was given. You can also view this output via the container's log:

```bash
$ docker logs thirsty_hopper

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

## Another hello-world example - this time using the 'run' command

So far we ran 3 commands, to get the hello-world message. However there is a shorthand 'run' command that essentially runs all three of these commands behind the scenes:

```bash
$ docker run hello-world
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

## Stopping and deleting containers

To stop and delete a container do:

```bash
docker container stop cntr_name
docker container rm cntr_name
```

The stop command tries to stop the container gracefully. If after 10 seconds it's still running then docker will issue the kill command, which stops the container by force:

```bash
docker container kill cntr_name  
```

To delete all containers and images:

```bash
docker container stop $(docker container ls --all --quiet) ; docker container rm $(docker container ls --all --quiet) ; docker image rm $(docker image ls --quiet)
```

This effectively does a factory reset of your docker server. Here's another way to delete all containers+images and start again:

```bash
docker system prune --all --volumes --force
```

## Short/Long running containers
A container is designed to run a specific workload, which is in the form of a command. The container will stay running as long as the command's underlying process is running. Here's how to view what that command/workload is (see the 'Command' column):

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

The (workload) command section of the above command is actually optional. The image usually comes with a dafault workload command built-in. So we effectively did an override. To see what the default command is, do:

```bash
$ docker container run centos:latest
$ docker container ls --all
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
8a824c21a5a9        centos:latest       "/bin/bash"         11 seconds ago      Exited (0) 10 seconds ago                       fervent_gauss
```

As you can see, it is just /bin/bash. This command is the last command on the [CentOS 7 official Dockerfile](https://hub.docker.com/_/centos/)

Once you do a command override, then that override stays intact with that container, even if you stop and start it.


Here's another example, but this time running a long running process:

```bash
docker run --detach httpd
```

This downloads the official apache web server docker image, and starts a container with it. I needed to use the --detach flag, otherwise the docker run command just hangs.

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

-i means interactive, so that you can find commands straight into the docker container
-t means tty terminal mode, which basically adds some nice formatting to the terminal running inside your docker container. -t is optional, and if you leave it out, then it just means that your terminal output is a little hard to follow, e.g.:

```bash
$ docker container run -i centos:latest /bin/bash
echo hello
hello
ls -l
total 12
-rw-r--r--.   1 root root 12076 Dec  5 01:37 anaconda-post.log
lrwxrwxrwx.   1 root root     7 Dec  5 01:36 bin -> usr/bin
drwxr-xr-x.   5 root root   340 Jan  2 23:30 dev
.
.
...etc.
```

If a container is already running and you want to access it, then you use the exec subcommand:

```bash
$ docker container run --detach centos:latest ping google.com
571edce564332dea0f81a88557c41e855fc298c1e9f750edaaaa559a13ce0994
$ docker exec -it 571edce564332 /bin/bash
[root@571edce56433 /]# ps -ef | grep ping
root         1     0  0 23:39 ?        00:00:00 ping google.com
root        21     6  0 23:40 pts/0    00:00:00 grep --color=auto ping
```

## running interactive CLIs inside docker containers

There are some cli that start up their own interactive sessions, e.g. msyql, python, irb,...etc. These can be run inside docker containers. Just make sure that the default command is the command that starts up the cli. 

