# What are docker images and containers

Docker effectively manages to main types of assets, images and containers. 


## Docker Images

An image is a single binary file, which is bit like an archive file. The content of this 


 Inside this archive there is usually 2 components:

- A filesystem - this filesystem ideally contains the bare minimum folder/files needed to run a particular process. You can think of it as a hard drive. 
- Startup command - This is a primary command that is executed when a container is created+started from this container. The startup command is usually a single command but can be in the form of a shell script too, for more sophisticated use cases.

```text
       Docker Image
+---------------------------+
|                           |
|Filesystem (aka hard drive)|
|                           |
+---------------------------+
|     Startup command       |
+---------------------------+
```

Some things to note:
- Docker images are created using Dockerfile.
- Images are built conceptually as layers
- You can override the Startup command with a command of your own. 


## Docker Containers

Docker uses docker images to create a stripped down micro-vm where the images's Filesystem is the container's primary hard drive, and the primary root process, is the Startup command:



```text
        Container

+------------------------------+
|  Startup Command             |   <---  Provided by Docker image
|                              |
+------------------------------+
|                              |
|  Kernel                      |
|                              |
+------------------------------+
|                              |
|  RAM/CPU/Networking/...etc   |
|                              |
+------------------------------+
|                              |
| Root filesystem              |   <---- Provided by Docker image
+------------------------------+

```text

This isn't a full fledged VM, meaning that:

- A linux VM has a primary process that is Systemd or init, However with a container it is a a particular process, e.g. httpd start
- A linux VM has it's own dedicated kernel, but with docker containers it makes use of the host machine's Linux kernel
- A linux VM's root filesystem contains far more OS related files/folders, compared to a docker images's container. 

Consequently docker images file size footprint is often tiny compared to an actual VMs. 


E.g. in AWS you have AMIs and EC2 instances, the corresponding analogy is Docker images, and docker containers. 