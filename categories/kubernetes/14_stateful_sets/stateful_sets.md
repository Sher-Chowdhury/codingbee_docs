# Stateful Sets

StatefullSets are similar to deployments, but have some differences:

- pods built with deployments follows a podname-randomstring convention. But in stateful sets it has podname-0, podname-1, podname-3,...etc namining convention
- stateful sets pods comes with builtin persistant storage. The volumes exists even after scaling down
- stateful sets pods always stays on the same worker node that originally hosted them, even if you rebuild them. 
- Each stateful set pods comes included with static dns entries, which are of the format:
  podname-number.statefulsetname.namespace.svc.cluster.local 
- pods are created in order. podname-0, podname-1, podname-2....etc. and when scaling down, it does it in reverse order. 







Stateful sets are another variation of deployments, but with the following characteristics:

- pods are awlays recreated on the same worker node. This could be useful when you pods or making use of volumes of the 'hostPath' variety, covered later. 
- have a static dns name - which is done via services. This means stateful sets pods must always has a service attached to them. That's not the case with pods created with deployments. 