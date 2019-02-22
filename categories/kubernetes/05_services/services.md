# Services

In Kubernetes, 'services' is actually all about networking. In Docker world, when you use docker compose, all the networking is done for us. However that's not the case when it comes to kubernetes. To setup networking in Kubernetes, you need to create 'service' objects.

There are [4 main types of of services](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types).


## Nodeport Service Type

We have already created this type of service in earlier examples. The NodePort service type is specifically used for making a pod accessible externally. E.g. from another VM, or another pod from another Kubecluster. Nodeport can't be used for pod-to-pod communication where both pods are running on the same kube cluster.

Nodeport is actually rarely used in production, and is mainly used for development purposes only.


## ClusterIP Service Type

This service type is specifically designed for setting up internal pod-to-pod communications inside a kube cluster.





