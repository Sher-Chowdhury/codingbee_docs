# Install Docker for mac using homebrew

Here's the command I ran:

```bash
brew install bash-completion
brew cask install docker
brew install kubectl
brew cask install minikube
```

Then go to the gui launcher and start up docker, and follow the prompts.

Then open a terminal and you should fine the following cli tools installed.

```bash
$ docker version
Docker version 17.09.0-ce, build afdb6d4

$ docker-compose version
docker-compose version 1.16.1, build 6d1ac21

$ docker-machine --version
docker-machine version 0.12.2, build 9371605

$ kubectl version --client
Client Version: version.Info{Major:"1", Minor:"6", GitVersion:"v1.6.2", GitCommit:"477efc3cbe6a7effca06bd1452fa356e2201e1ee", GitTreeState:"clean", BuildDate:"2017-04-19T20:33:11Z", GoVersion:"go1.7.5", Compiler:"gc", Platform:"darwin/amd64"}
```

#### Reference

[Docker for Mac install](https://docs.docker.com/docker-for-mac/install)


# Get bash autocompletion working for docker cli on a mac

First install the following formulas:

```bash
brew install bash-completion
brew cask install docker

```

Next via the gui launcher, find the docker icon and launch it, then follow the prompts. Then restart your bash terminal. Now run the following command to create a few symbolic links:

```bash
ln -s /Applications/Docker.app/Contents/Resources/etc/docker.bash-completion /usr/local/etc/bash_completion.d/docker
ln -s /Applications/Docker.app/Contents/Resources/etc/docker-machine.bash-completion /usr/local/etc/bash_completion.d/docker-machine
ln -s /Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion /usr/local/etc/bash_completion.d/docker-compose
```

Then restart the bash terminal. Therefore running the above ln commands resulted in the following files being created:

```bash
$ pwd
/usr/local/etc/bash_completion.d
$ cd /usr/local/etc/bash_completion.d/
$ ll | grep docker
-rw-r--r--  1 schowdhury  admin     15 19 Oct 11:18 docker
-rw-r--r--  1 schowdhury  admin     15 19 Oct 11:18 docker-compose
-rw-r--r--  1 schowdhury  admin  10347 19 Oct 11:18 docker-machine
-rw-r--r--  1 schowdhury  admin   1469 19 Oct 11:19 docker-machine-prompt
-rw-r--r--  1 schowdhury  admin   1525 19 Oct 11:18 docker-machine-wrapper

```

### References

[Add Docker autocompletion in your shell](https://webascrazy.net/2017/02/02/add-docker-autocompletion-in-your-shell/)
[Installing Docker Bash completion](https://docs.docker.com/docker-for-mac/#installing-bash-completion)
