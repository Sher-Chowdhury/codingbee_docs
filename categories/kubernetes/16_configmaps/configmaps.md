# ConfigMaps

When using images from docker hub, you'll often find yourself wanting to add additional configs (or override the default configs embeded inside the image) during a container launch time. Also some images needs requires customisation configuration as part of launch time, e.g. the mysql image that we saw earlier. where we used 'environment variables' (and 'secrets' when dealing with sensitive data) to feed that data during launch time.

Using Env Vars is quite crude, and doesn't scale well. That's why you should avoid overusing it. Another approach for adding your configs into a container is to use official docker hub images to create intermediary images with your custom configs baked in. This again isn't that elegant and doesn't scale very well.


To do more sophisticated container build time config changes, it's recommended to use ConfigMaps. 

ConfigMaps are Kubernetes objects for storing dictionary data, i.e. key value pairs. They value of a key/value pair can also be used to store entire config files. However you shouldn't use configmaps for storing secrets.

First we'll take a look at how to create configmaps and then we'll look at how to use them. 




##  Create configmaps

There's a few ways to configmap objects, but we'll create via kube oject yaml file approach.


```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fav-fruit
data:
  fruit.name: banana
  fruit.color: yellow
```


