# namespace quotas

It's common to have multiple teams using the same kubecluster. In those cases it's quite common to have a namespace for each team/project/environnment in order to keep things organised. However it's possible that some namespaces could end up using too much cpu/memory/storage and deprives the other namespaces. To solve this problem you can use [ResourceQuota](https://kubernetes.io/docs/concepts/policy/resource-quotas/) for your namespace.

Namespace quotas is a system that lets you set limits on what you can use/create under a namespace. For 