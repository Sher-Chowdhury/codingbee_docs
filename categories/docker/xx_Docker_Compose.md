# Docker Compose

Docker-Compose command is an optional tool, that you don't have to use. However it makes life a lot easier to use it. Here are some of the benefits of using docker compose:


1. The command cuts down the need to repeatedly write+run unwieldily long docker commands. Instead the docker-compose command runs them for us behind the scenes. you first have to create a docker-compose.yml file. 
2. Docker-compose can start up multiple containers
3. it can setup internal networking between containers. e..g So that an app container can communicate with db container. This is something you can set up manually just using the docker cli, but is really complicated to do. Instead docker-compose massively simplify this. If you're docker compose file defines 2 containers, one is called cntr_app and the other called cntr_db, then docker-compose automatically makes those 2 names are also available as dns names for internal container-to-container communication!

once you have created your dockercompose file, you then run:

```bash
docker-compose up --detach
```

To see containers are running as part of the docker-compose.yml file, do 

```bash
docker-compose ps
```

To delete all resources created by the above command, run:

```bash
docker-compose down --timeout 1 --volumes --rmi all
```

To delete absolutely everything:

```bash
docker container stop $(docker container ls --all --quiet)
docker container rm $(docker container ls --all --quiet)
docker image rm $(docker image ls --quiet)
docker volume rm $(docker volume ls --quiet)
docker system prune --all --volumes --force
```
