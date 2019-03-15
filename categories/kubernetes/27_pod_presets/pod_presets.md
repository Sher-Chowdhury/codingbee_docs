# Pod Presets

You might find yourself writing a lot of pod yaml files that have sections that are identical. You can actually removed all these commonality and centralise them in a single place, by making use of pod preset objects. You can take out the common parts of a pod yaml file and create a new pod preset object. Then you reference that pod preset via labels. 

Pod Presets is still quite new, so you need to enable it by starting minikube with the following:

However there are only a few things you can centralise with PodPresets:

- env
- volumeMounts
- volumes



```bash
minikube start --extra-config=apiserver.runtime-config=settings.k8s.io/v1alpha1=true --extra-config=apiserver.enable-admission-plugins=Initializers,NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,PodPreset
```

then you apply. Note, I didnt get this to work. Maybe because it is still in alpha. 

