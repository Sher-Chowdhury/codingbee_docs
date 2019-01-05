# Docker Compose

Docker-Compose command is an optional tool, that you don't have to use. However it makes life convenient. Here are some of the benefits of using docker compose:


1. The command cuts down the need to repeatedly write+run unwieldily long docker commands. Instead the docker-compose command runs them for us behind the scenes. you first have to create a docker-compose.yml file. 
2. Docker-compose can start up multiple containers
3. it can setup internal networking between containers. So that you can ping one container from another

once you have created your dockercompose file, you then run:

```bash
docker-compose up
```

