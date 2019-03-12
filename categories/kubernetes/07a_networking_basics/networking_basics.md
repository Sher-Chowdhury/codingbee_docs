# Networking Basics

In Kubernetes, 'services' is actually all about networking. In Docker world, when you use docker-compose, all the networking is done for you automatically behind the scenes. With Kubernetes on the other hand, you will need to set up a lot of the networking. However there are some basic networking features that comes out-of-the-box with Kubernetes:

- A pod's internal networking
- IP based Pod-to-pod networking


  
  
## A pod's internal networking

If you have 2+ containers inside a single pod, then these containers can reach each other via localhost.


## IP based Pod-to-pod networking




To setup networking in Kubernetes, you need to create 'service' objects.