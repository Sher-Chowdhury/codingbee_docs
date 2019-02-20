# What are docker images and containers

Docker effectively manages to main types of assets, images and containers. 


## Docker Images

An image is a single binary file, which is bit like an archive file. The content of this 


 Inside this archive there is usually 2 components:

- A filesystem - this filesystem ideally contains the bare minimum folder/files needed to run a particular process. 
- Startup command - This is a command that is executed when the image is started. 

Docker images are created using Dockerfiles


## Docker Containers

This is effectively an instance of the docker image. 

E.g. in AWS you have AMIs and EC2 instances, the corresponding analogy is Docker images, and docker containers. 