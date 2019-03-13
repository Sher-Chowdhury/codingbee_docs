# Stateful Sets


Stateful sets are another variation of deployments, but with the following characteristics:

- pods are awlays recreated on the same worker node. This could be useful when you pods or making use of volumes of the 'hostPath' variety, covered later. 
- have a static dns name - which is done via services. This means stateful sets pods must always has a service attached to them. That's not the case with pods created with deployments. 