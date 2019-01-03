# Building Docker images with the Dockerfile

The Dockerfile is made up of 3 main sections:

1. Declaration of starting base image - you can think of this as your image's Operating System. 
2. set of base image customisation tasks which are executed during the 'docker build' command
3. Specify the command to execute during the docker startup (docker start)


## Build Docker images

You need to run the following command while inside a directory that contains a file called 'Dockerfile'

```bash
docker build . --tag {image_name}
```

This command builds several layers and stack them on top of each other in a sequence. This builds up the build process 


