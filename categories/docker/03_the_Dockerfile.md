# Building Docker images with the Dockerfile

A Dockerfile is a simple plain text file that's used for building docker images. It's essentially a sequential list of instructions. The Dockerfile is made up of 3 parts:

1. Declaration of starting base image Instruction - you can think of this as your image's Operating System. - This is a single line declaration at the start of the Dockerfile
2. Set of customisation instruction which are executed during the 'docker build' command - This makes up the majority of the Dockerfile. 
3. Specify the default startup command to execute during the docker startup (docker start) - This is specified as the very last line of the Docker file. 

Here's an example:

```dockerfile
# Declare base image
FROM ubuntu:15.04

# Various customisations
COPY . /app
RUN make /app

# Declare startup command. 
CMD python /app/app.py
```


## Build Docker images

You need to run the following command while inside a directory that contains a file called 'Dockerfile'

```bash
docker build -tag {image_name} .
```
The image name should have the following convention:

```text
{dockerhub_username}/{image_name}:{version-tag, or the word 'latest'}
```
e.g.:

```text
codingbee/my_custom_wordpress_img:0.1
```
If you leave out the ':{tag-version}' then docker will assume you meant ':latest'. 



This command builds several layers/images and stack them on top of each other in a sequence. 

In our example, behind the scenes, docker will create a new container using the default ubuntu image, and treat the first customisation as the overriding startup comamdn. Once that container stops running, docker will create a snapshot of it store it as temporary interim image (without any default startup commands). It will then use that temp image as base image and start it up again, but this time use the next customisation command as the next overriding startup command,....and so on. As a result will have built multiple interim images as part of the image building process. Finally it will reach the actual startup command, and which point it will update the final interim command with the real startup command. So to summarise, when building a new docker image, you end up creating multiple interim docker containers+images behind the scenes. 




The first time you run this, it can take a while. But if you run it again straight then it'll be much quicker because docker caches the layers. If you change a line in the Dockerfile, then that layer gets regenerated along with all subsequent layers. That's why, from a performance perspective, it's best practice to place time consuming lines (e.g. bundle install) as close to the top as possible, to prevent them from getting regenerated too often.

Once build command has finished, you can view your new image by running:

```bash
docker image ls
```

You can also view the layers used to build this image:

```bash
docker history cntr_name
```

In case you're Dockerfile has a none standard name (e.g. you want to store multiple docker files in the same directory), then you can simply do:

```bash
docker build -f {dockerfile_name} --tag {image_name} .
```

A stopped docker container is effectively a docker image. Hence you can spin up a container straight from an official base image, start a bash terminal inside it using exec, run some commands, exit out. Then stop the container. This effectively is the manual way of creating a docker image. However it's best practice to use the Dockerfile approach so that you have a record of everything. 





## Some commonly used instructions


### WORKDIR

This is used to specify the default directory to drop contents to. Best to set this before using the COPY instructino. Otherwise you'll end up putting files in the wrong places. 