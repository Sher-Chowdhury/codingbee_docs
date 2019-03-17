# Stateful Sets

Earlier we came across deployments which are used to manage stateless pods, i.e. pods that don't need any persistant data. 
We also saw that deployments can also manage stateful pods, by taking advantage of Persistant Volumes for externally storing a pod's persistant data. However what if that persistant data relies on the pod's hostname (which in turn is the pod's name) to be static as well as the container's ip address (which in turn is the pods ip addresss) to be static too? Deployment provisioned (and rebuilt) pods have deploymentname-randomstring naming convention. They also gets randomly assigned ip address during rebuilds.



That's where Statefull Sets comes into the picture. StatefullSets are like deployments, but with a few important differences:




- pods built with deployments follows a podname-randomstring convention. But in stateful sets it has podname-0, podname-1, podname-3,...etc namining convention
- stateful sets pods comes with builtin persistant storage. The volumes exists even after scaling down
- stateful sets pods always stays on the same worker node that originally hosted them, even if you rebuild them. 
- Each stateful set pods comes included with static dns entries, which are of the format:
  podname-number.statefulsetname.namespace.svc.cluster.local 
- pods are created in order. podname-0, podname-1, podname-2....etc. and when scaling down, it does it in reverse order. 







Stateful sets are another variation of deployments, but with the following characteristics:

- pods are awlays recreated on the same worker node. This could be useful when you pods or making use of volumes of the 'hostPath' variety, covered later. 
- have a static dns name - which is done via services. This means stateful sets pods must always has a service attached to them. That's not the case with pods created with deployments. 