# Affinity and Anti-Affinity

We came across nodeSelector as part of looking at deamonsets. [Affinity/Anti-Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) can do the same thing as nodeSelector but also has a lot more features and customisations:

1. More versatile label selection method - e.g. instead of key=value label match. You can just specify deploy/dont-deploy on nodes that has a key called 'xxx'. See `pod.spec.affinity.nodeAffinity`
2. Specify preference (rather than hard rules) - So if no suitable deployment target is found, kubernetes will deploy it anyway to non-mathing targets, since it's more to have pods to exist on not existing in the first place. e.g. see `pod.spec.affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`
3. Prevent particular pods from running on the same worker node (co-locating), based on labels. See `pod.spec.affinity.podAntiAffinity`.





