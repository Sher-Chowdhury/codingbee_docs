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

This command builds several layers and stack them on top of each other in a sequence. 

The first time you run this, it can take a while. But if you run it again straight then it'll be much quicker because docker caches the layers. If you change a line in the Dockerfile, then that layer gets regenerated along with all subsequent layers. That's why, from a performance perspective, it's best practice to place time consuming lines (e.g. bundle install) as close to the top as possible, to prevent them from getting regenerated too often.

Once build command has finished, you can view your new image by running:

```bash
docker image ls
```

You can also view the layers used to build this image:

```bash
docker history wallboard_smashing
```

In case you're Dockerfile has a none standard name (e.g. you want to store multiple docker files in the same directory), then you can simply do:

```bash
docker build . -f {dockerfile_name} --tag {image_name}
```