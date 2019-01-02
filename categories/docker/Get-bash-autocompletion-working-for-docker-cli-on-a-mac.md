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
