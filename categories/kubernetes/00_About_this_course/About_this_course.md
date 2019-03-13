## The aim of this course

This course is a follow-along hands-on guide to Kubernetes and cover as much of the kubernetes feature as possible, so that you get comfortable using kubernetes for usual day-to-day work. 

This course is also a good companion for those who are planning on taking the [Certified Kubernetes Administrator](https://www.cncf.io/certification/cka/) certification.


## Requirements

This is an intermediate level course. You need to know the following:

- docker and concept of containers
- git
- linux, bash, vim
- yaml syntax
- basic networking knowledge, e.g. subnets, netmasks, also things like http is port 80. 
- already have basic kubernetes knowledge - This isn't a kubernetes beginners course. 


## what software you need to follow along

- vscode
- brew
- git
- 



## scope

- We don't spend that much time going over concepts and theories. The hope is that you'll understand and learn kubernetes faster by seeing it in action. 
- Kubernetes installation - only focusing no minikube on macs
- docker, this won't cover a lot about docker

## Course guide

This course will be closely following the following git repo: xxxxxx

So if you want to follow along, then clone this repo. 

# Course Structure 

How to follow this course


## Notations.

Throughout this course we'll be using the kubectl command. kubectl is the main command used for performing day-to-day kubernetes work. kubectl has a lot of built in reference docs. That includes lots of man pages:

```bash
man kubectl<tab><tab>
```

Also you can access a lot more info by running:

```bash
kubectl explain xxxxx
```

In this qude, we'll refer to what to put in here, using a dot like notation e.g. 'pod.spec'. 


## Disclaimer

I have not taken my KCA exam yet. 