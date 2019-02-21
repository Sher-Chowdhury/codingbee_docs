# Updating objects

Kubernetes is smart enough to identify which objects have been created by a particular config file. It does so by using the configs about the kind and metadata.name info. 

That's a good thing because it means you can modify an existing object by editing it's corresponding config file and reapply it.