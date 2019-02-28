# Install Kubernetes on MacOS

To run a kubecluster locally on your macbook, you need to install a software called [Minikube](https://kubernetes.io/docs/setup/minikube/). This.

There are a few steps involved in this process:

1. Install [brew](https://brew.sh/) - this is a MacOS based package installer. 
2. run: `brew install kubectl` to install kubectl
3. run: `brew cask install virtualbox` to install virtualbox
4. run: `brew cask install minikube` to install minikube

After minikube is installed, next check it's version:

```bash
$ minikube version
minikube version: v0.34.1
```

Similarly you check it's status:

```bash
$ minikube status
host:
kubelet:
apiserver:
kubectl:
```

To create a new kubecluster on your macbook, run (note this can take several minutes):

```bash
$ minikube start
😄  minikube v0.34.1 on darwin (amd64)
🔥  Creating virtualbox VM (CPUs=2, Memory=2048MB, Disk=20000MB) ...
💿  Downloading Minikube ISO ...
 184.30 MB / 184.30 MB [============================================] 100.00% 0s
📶  "minikube" IP address is 192.168.99.100
🐳  Configuring Docker as the container runtime ...
✨  Preparing Kubernetes environment ...
💾  Downloading kubeadm v1.13.3
💾  Downloading kubelet v1.13.3
🚜  Pulling images required by Kubernetes v1.13.3 ...
🚀  Launching Kubernetes v1.13.3 using kubeadm ... 
🔑  Configuring cluster permissions ...
🤔  Verifying component health .....
💗  kubectl is now configured to use "minikube"
🏄  Done! Thank you for using minikube!
```

If you open up the virtualbox gui, you should a new vm called minikube running. If you check the status again, you should now see:

```bash
$ minikube status
host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100
```

Here it says that minikube has also configured kubectl, to check if that's really the case, run:

```bash
$ kubectl cluster-info
Kubernetes master is running at https://192.168.99.100:8443
KubeDNS is running at https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/kube-dns

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

And to get more detailed info about how your kubectl cli is currently configured, run:

```bash
$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://localhost:6443
  name: docker-for-desktop-cluster
- cluster:
    insecure-skip-tls-verify: true
    server: https://kube-ops-tlg1-ipt-platform.service.ops.iptho.co.uk
  name: kubernetes
- cluster:
    certificate-authority: /Users/schowdhury/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
contexts:
- context:
    cluster: kubernetes
    user: chowdhus
  name: default
- context:
    cluster: docker-for-desktop-cluster
    user: docker-for-desktop
  name: docker-for-desktop
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: chowdhus
  user:
    token: e3d576a2-cfa3-46f1-a014-92cb50a65b75
- name: docker-for-desktop
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: minikube
  user:
    client-certificate: /Users/schowdhury/.minikube/client.crt
    client-key: /Users/schowdhury/.minikube/client.key
```

When you ran, `minikube start` earlier, what actually happened to configure kubectl cli, is that the file `~/.kube/config` was created. This shows all the configs as shown above. So our kubectl command is specifically configured to communicate with the minikube built VM. 

However our docker cli, is still configured to just interact with our macbook installed docker-daemon. But you want it also connect to the docker daemon inside the minikube built VM, then run:

```bash
eval $(minikube docker-env)
```

You might want to do this for troubleshooting/debugging purposes. However this will only last for the current bash session, and will get reset if you restart bash. 



A kubecluster is normally made up of a number of VMs (aka nodes), and these nodes functions as either master or worker nodes. To see how many nodes are minikube kubecluster is made of, run:

```bash
$ kubectl get nodes
NAME       STATUS    AGE       VERSION
minikube   Ready     14m       v1.13.3
```

By design, to stay lightweight, our kubecluster only has one node, which acts as both the master and worker node. This is fine in a development environment. But in production, you should have multiple master and worker nodes for HA. You can also monitor your kubecluster via the web browser, bu running:

```bash
$ minikube dashboard
🔌  Enabling dashboard ...
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:50387/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```


### References
https://kubernetes.io/docs/setup/minikube/
https://kubernetes.io/docs/tutorials/hello-minikube/
https://kubernetes.io/docs/reference/kubectl/cheatsheet/  (talks about getting autocomplete to work)

