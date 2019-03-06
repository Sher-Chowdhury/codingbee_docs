# ConfigMaps

When using images from docker hub, you'll often find yourself wanting to add additional configs (or override the default configs embeded inside the image) during a container build time. Also some images needs requires customisation configuration as part of build time, e.g. the mysql image that we saw earlier. Earlier we saw how we could provide these customisation data, through yaml configurations in the form of 'environment variables' (and 'secrets' when dealing with sensitive data).


Using Env Vars is quite crude, and doesn't scale well. That's why it's usage should be limited where necessary. To do more sophisticated container build time config changes, it's recommended to use ConfigMaps. 


ConfigMaps are Kubernetes objects for storing dictionary data, i.e. key value pairs. They value of a key/value pair can also be used to store entire config files.






There's a few ways to create configmap objects, but we'll create via kube oject yaml file approach.

# Create configmap from a file









