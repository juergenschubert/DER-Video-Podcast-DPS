
# Agenda 
little overview what you'll find below  

```
Voraussetzunge von VMware  
   Requirement - vSphere 6.7 U3 
   Create TWO VM (master/worker)  
     Enabling disk UUID
     enable CBT
   Install Ubuntu
   Setting up VMs in the Guest OS  
     Disable Swap
   Install Docker CE
   Install Kubelet, Kubectl, Kubeadm
   Pod Networking - flanel
   Install Kubernetes
     on master node
       Install flannel pod overlay networking for master
     on worker node
   Install the vSphere Cloud Provider Interface CPI
     Create a CPI configMap
     Create a CPI secret
     Check that all nodes are tainted
     Deploy the CPI manifests
     Verify that the CPI has been successfully deployed
     Check that all worker nodes are untainted
   Install vSphere Container Storage Interface CSI Driver
     Create a CSI secret
     Create Roles, ServiceAccount and ClusterRoleBinding
     Install the vSphere CSI driver
     Verify that CSI has been successfully deployed

```

# Tanzu Kubernetes Space

trying to explaing what's needed and how to setup a k8s Clustern withing a VMWare vSphere environment. We wanna use the First Cals Disks (FCD) of VMWare for a persistent Volume. This PV should contain data which we will backu with PowerProtect. So we wanna install and configure a k8s Cluster to be backedup with DELL PowerProtect.

## Voraussetzung von VMware     
What we need are two VM with UBUNTU and on HW Version 15 for some K8s features. Therefore we need vSphere 6.7 U2 vSphere or above and the 2 Ubuntu Server, tanzu-m1 and tanzu.s1. mit k8s zu versehen. Wie das geht, was es zu beachten gibt sowie die einzelnen Schrite versuche ich hier zu beschreiben. Stand 15-Apr.2020 !

## Step 1 vSphere 6.7 U3
get vSphere 6.7 U3 running (check Hardware 15). Hardware 15 is the version we are using to install Ubuntu on.

## Step 2 Create both VM
I do name them **tanzu-m1** und **tanzu-s1**, m1 for master and s1 for the first worker. Logins are administrator and root on all server :-)  Just in case you do see, my password are **Password123!**.

### Create a new VM with the following properties :
Compatibility : ESXi 6.7 Update 2 and later (HW version 15)
* CPU 4 CPU(s),  
* Memory 8 GB  
* Hard disk 1 100GB  
* SCSI controller 0 VMware Paravirtual    
* Change Type VMware Paravirtual     
* SCSI Bus Sharing None  

I have used smaller with 1 CPU and 10GB of disk. So fare no issues.   

### Enabling disk UUID on virtual machines  

disk.EnableUUID=1  
    - Power off the guest.  
    - Select the guest and select Edit Settings.  
    - Select the Options tab on top.  
    - Select General under the Advanced section.  
    - Select the Configuration Parameters... on right hand side.  

Check to see if the parameter disk.EnableUUID is set, if it is there then make sure it is set to TRUE. If the parameter is not there, select Add Row and add it.  
Power on the guest. 


### To enable CBT in a virtual machine:  
    - Power off the virtual machine.    
    - Right-click the virtual machine and click Edit Settings.  
    - Click the Options tab.  
    - Click General under the Advanced section and then click Configuration Parameters.         
    - The Configuration Parameters dialog opens.  
    - Click Add Row.  
    - Add the ctkEnabled parameter and then set its value to true.  
    - Click Add Row, add scsi0:0.ctkEnabled, and set its value to true.  

Note: scsi0:0 in scsi0:0.ctkEnabled indicates the SCSI device assigned to the hard disk that is added to the virtual machine. Every hard disk added to the virtual machine is given a SCSI device that appears similar to scsi0:0, scsi0:1, or scsi 1:1. CBT is enabled (or disabled) individually on each disk.  
Power on the virtual machine.  
In the home directory of the virtual machine, verify that each disk having CBT enabled has also a vmname-ctk.vmdk file  

**Hardware 15** for both VMs. You can change that version later and upgrade so never mind upfrotn. Change Block tracking, and UUID need to be enabled on both VMs.  

Either config the VM in vcenter and change the HW Version, enable CBT and enable UUID or use a commandline tool within the Ubuntu VM to change it afterwards. I will use **govc** and install it on Ubuntu to get the VM config done.  

Tools I am talking about and I am using are:  
**govc** is a vSphere CLI built on top of govmomi and can be downloaded here: [GitHub download location for govc](https://github.com/vmware/govmomi/releases)  
  
[Using the govc CLI to automate vCenter commands](https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/)  

[My GitHub article on the govc usage and config](https://github.com/juergenschubert/DER-Video-Podcast-DPS/blob/master/Tanzu%20K8s/govc%20howto.md)   

## Install Ubuntu 18.04.4 LTS (Bionic Beaver) 
Before we can start with the Ubuntu install I prefer to download a ISO file [http://releases.ubuntu.com/18.04.4/](download)  I can mount in the VM as a CD so it starts off that iso. So I am booting from this ISO file which does contain the latest Ubuntu Bionic Beaver version.   
Duing install I will make sure that I can use a fixed IP and DNS entry from both systems.  
**tanzu-m1.vlab.local** und **tanzu-s1.vlab.local**  
Just you are running into issues on the network conig with netplan or/ and a DNS resolution topic. The below mentioned articles helped me to fix these issues.  

[Netzwerkconfig Hilfe und Troubleshooting -_Netplan](https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan)   
[Ubuntu DNS Server nslookup Hilfe](https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan)

## Setting up VMs in the Guest OS
After Ubuntu install and conig k8s components on the Ubuntu OS virtual machines are next. Some components must be installed on all of the nodes. In other cases, some of the components need only be installed on the master, and in other cases, only the workers. In each case, where the components are installed is highlighted. All installation and configuration commands should be executed with root privilege. You can switch to the root environment using the "sudo su" command. But before we can start with k8s componentes we need to prepare Ubuntu a bit.  

### Disable Swap (Both master and worker)
SSH into all K8s worker nodes and disable swap on all nodes including master node. This is a prerequisite for kubeadm.    

    # sudo su  
    # swapoff -a  
    # vi /etc/fstab ... remove any swap entry from   this file ...

and get ready for Docker installation. As we will use Docker as a container Service in our K8s environment.

## Install Docker CE (Both master and worker )
    # sudo su
    # apt update
    # apt install ca-certificates software-properties-common apt-transport-https curl -y  

    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    OK
    # add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    # apt update
    # apt install docker-ce=18.06.0~ce~3-0~ubuntu -y  

*The yaml file below is also part of this github repository. See for download*  
    
    # tee /etc/docker/daemon.json >/dev/null <<EOF
    {
     "exec-opts": ["native.cgroupdriver=systemd"], "log-driver": "json-file",
     "log-opts": {
     "max-size": "100m" },
     "storage-driver": "overlay2" }
    EOF  
    # mkdir -p /etc/systemd/system/docker.service.d
    # systemctl daemon-reload
    # systemctl restart docker
    # systemctl status docker
    docker.service - Docker Application Container Engine
    Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)    
    Active: active (running) since Fri 2019-09-06 12:37:27 UTC; 4min 15s ago13. 
    # docker info | egrep "Server Version|Cgroup Driver" 
    Server Version: 18.06.0-ce
    Cgroup Driver: systemd  
## Install Kubelet, Kubectl, Kubeadm
On both tanzu-m1 and tanzu-s1, on master and worker  
  
    # sudo su
    # curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    OK
    # cat <<EOF >/etc/apt/sources.list.d/kubernetes.list 
    deb https://apt.kubernetes.io/   kubernetes-xenial main   
    EOF
    # apt update
    # apt install -qy kubeadm=1.14.2-00 kubelet=1.14.2-00 kubectl=1.14.2-00
    # apt-mark hold kubelet kubeadm kubectl
    kubelet set on hold.  
    kubeadm set on hold.  
    kubectl set on hold.  

## Pod Networking - Setup flannel 
(Pod Networking for both master and worker )  
  
    # sudo su
    # sysctl net.bridge.bridge-nf-call-iptables=1  
    net.bridge.bridge-nf-call-iptables = 1  


## Installing the Kubernetes on your tanzu-m1 (master node)  

    #sudo su  
    
***Where serviceSubnet: "10.98.48.0/21" is the CIDR/subnet mask and podSubnet: "10.244.0.0/16" is the default value. Note the "token:" in below as this will be RE-USED in Subsequent steps.***  

*The yaml file below is also part of this github repository. See for download*  


    # tee /etc/kubernetes/kubeadminit.yaml >/dev/null <<EOF
    apiVersion: kubeadm.k8s.io/v1beta1  
    kind: InitConfiguration  
    bootstrapTokens:  
           - groups:  
            - system:bootstrappers:kubeadm:default-node-token  
            token: y7yaev.9dvwxx6ny4ef8vlq  
            ttl: 0s  
            usages:  
            - signing  
            - authentication  
    nodeRegistration:  
      kubeletExtraArgs:  
        cloud-provider: external  
    ---  
    apiVersion: kubeadm.k8s.io/v1beta1  
    kind: ClusterConfiguration  
    useHyperKubeImage: false  
    kubernetesVersion: v1.14.2  
    networking:  
      serviceSubnet: "10.96.0.0/12"  
      podSubnet: "10.244.0.0/16"  
    etcd:  
      local:  
        imageRepository: "k8s.gcr.io"  
        imageTag: "3.3.10"  
    dns:  
      type: "CoreDNS"  
      imageRepository: "k8s.gcr.io"  
      imageTag: "1.5.0"  
    EOF

Preserve the output the of below command, Note that the last part of the output provides the command to join the worker nodes to the master in this Kubernetes cluster. 

    # kubeadm init --config /etc/kubernetes/kubeadminit.yaml  
 
    Your Kubernetes control-plane has initialized successfully!  
    
 
To start using your cluster, you need to run the following as a regular user (**administrator**):

      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.  
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:  
https://kubernetes.io/docs/concepts/cluster-administration/addons/    
I prefer flannel as the pod overlay networking and you see the config further down  

Then you can join any number of worker nodes by running the following on each as **root**:

    # kubeadm join 192.168.1.155:6443 --token y7yaev.9dvwxx6ny4ef8vlq \
    --discovery-token-ca-cert-hash sha256:a40ed74295afe9514b36d3c389b4b803fe8f633c65928282c813746b57945d63

Before we do this we'll have some more configs. You'll see the **join** later in this document.  
    
*At this stage, you may notice coredns pods remain in the pending state with FailedScheduling status. This is because the master node has taints that the coredns pods cannot tolerate. This is expected, as we have started kubelet with cloud-provider: external. Once the vSph ere Cloud Provider Interface is installed, and the nodes are initialized, the taints will be automatically removed from node, and that will allow scheduling of the coreDNS pods.*

    # kubectl get pods --namespace=kube-system
    NAME                                    READY   STATUS    RESTARTS   AGE
    coredns-fb8b8dccf-q57f9                  0/1    Pending   0          87s
    coredns-fb8b8dccf-scgp2                  0/1    Pending   0          87s 
    etcd-k8s-master                          1/1    Pending   0          54s 
    kube-apiserver-k8s-master                1/1    Running   0          39s
    kube-controller-manager-k8s-master       1/1    Running   0          54s  
    kube-proxy-rljk8                         1/1    Running   0          87s 
    kube-scheduler-k8s-master                1/1    Running   0          37s
    
    
    # kubectl describe pod coredns-fb8b8dccf-q57f9 --namespace=kube-system
    .
    .
    Events:
    Type     Reason          Age                  From             Message
    ----     ------          ----                 ----             -------
    Warning  FailedScheduling 7s (x21 over 2m1s) default-scheduler 0/1 nodes are available: 1 node(s) had taints that the pod didn't tolerate
    
    This will take a while !  

## Install flannel pod overlay networking
The next step that needs to be carried out on the master node is that the flannel pod overlay network must be installed so the pods can communicate with
each other. ( ON MASTER AS administrator USER )  

    # administrator@tanzu-m1:~$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml  
    
    podsecuritypolicy.extensions/psp.flannel.unprivileged created
    clusterrole.rbac.authorization.k8s.io/flannel created
    clusterrolebinding.rbac.authorization.k8s.io/flannel created
    serviceaccount/flannel created
    configmap/kube-flannel-cfg created
    daemonset.extensions/kube-flannel-ds-amd64 created
    daemonset.extensions/kube-flannel-ds-arm64 created
    daemonset.extensions/kube-flannel-ds-arm created
    daemonset.extensions/kube-flannel-ds-ppc64le created
    daemonset.extensions/kube-flannel-ds-s390x created

At this point, you can check if the overlay network is deployed.  

    # kubectl get pods --namespace=kube-system  

    NAME                             READY  STATUS RESTARTS AGE
    coredns-6557d7f7d6-9s7sm          0/1  Pending   0      107s
    coredns-6557d7f7d6-wgxtq          0/1  Pending   0      107s
    etcd-k8s-mstr                     1/1  Running   0      70s
    kube-apiserver-k8s-mstr           1/1  Running   0      54s
    kube-controller-manager-k8s-mstr  1/1  Running   0      53s
    -> kube-flannel-ds-amd64-pm9m9    1/1  Running   0      11s
    kube-proxy-8dfm9                  1/1  Running   0      107s
    kube-scheduler-k8s-mstr           1/1  Running   0      49s

## Export the master node configuration to worker nodes
Finally, the master node configuration needs to be exported as it is used by the tanzu-s1 wishing to join to the master.  

     # kubectl -n kube-public get configmap cluster-info -o jsonpath='{.data.kubeconfig}' > discovery.yaml

The discovery.yaml file will need to be copied to /etc/kubernetes/discovery.yaml on your tanzu-s1 node and all other worker nodes.

## Installing the Kubernetes worker node(tanzu-s1)

    # sudo su
    # tee /etc/kubernetes/kubeadminitworker.yaml >/dev/null <<EOF
    apiVersion: kubeadm.k8s.io/v1beta1 caCertPath: /etc/kubernetes/pki/ca.crt discovery:
    file:
    kubeConfigPath: /etc/kubernetes/discovery.yaml
             timeout: 5m0s
    tlsBootstrapToken: y7yaev.9dvwxx6ny4ef8vlq kind: JoinConfiguration
    nodeRegistration:
    criSocket: /var/run/dockershim.sock kubeletExtraArgs: 
    cloud-provider: external EOF
    
**copy the discovery.yaml to your local machine with scp. to /etc/kubernetes/discovery.yaml**

    # kubeadm join --config /etc/kubernetes/kubeadminitworker.yaml
    
        
**Go to your tanzu-m1 master node**
 
    # administrator@tanzu-m1:~$ kubectl get nodes -o wide
    NAME       STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
    tanzu-m1   Ready    master   20h   v1.14.2   <none>        <none>        Ubuntu 18.04.4 LTS   4.15.0-96-generic   docker://18.6.0
    tanzu-s1   Ready    <none>   19h   v1.14.2   <none>        <none>        Ubuntu 18.04.4 LTS   4.15.0-96-generic   docker://18.6.0


    # root@tanzu-m1:/home/administrator# kubectl get nodes
    NAME       STATUS   ROLES    AGE     VERSION
    tanzu-m1   Ready    master   65m     v1.14.2
    tanzu-s1   Ready    <none>   3m28s   v1.14.2

## Install the vSphere Cloud Provider Interface
(on the tanzu-m1 Master )
Note that the CSI driver requires the presence of the Cloud Provider Interface (CPI), so the step of installing the CPI is mandatory.
### Create a CPI configMap 
( Ensure to give "secret-name" argument as **lowercase** value )  

We are also working on some environment specific variables we need to clarfiy before we use them. I my case I have used these values:  
secret-name = "cpi-global-secret"    
secret-namespace = "kube-system"    
VirtualCenter "192.168.1.108"  
datacenters = "Datacenter-145"  
secret-name = "cpi-datacenter-145-secret"  
secret-namespace = "kube-system"  

let's go 

    # tee /etc/kubernetes/vsphere.conf >/dev/null <<EOF 
    [Global]
    port = "443"
    insecure-flag = "true"
    secret-name = "cpi-global-secret" 
    secret-namespace = "kube-system"
    
    [VirtualCenter "192.168.1.108"] 
    datacenters = "Datacenter-145" 
    secret-name = "cpi-datacenter-145-secret" 
    secret-namespace = "kube-system"
    EOF
    

**insecure-flag** should be set to true to use self-signed certificate for login  
**VirtualCenter** section is defined to hold property of vcenter. IP address and FQDN should be specified here.   
**secret-name** holds the credential(s) for a single or list of vCenter Servers.  
**secret-namespace** is set to the namespace where the secret has been created.  
**port** is the vCenter Server Port. The default is 443 if not specified.  
**datacenters** should be the list of all comma separated datacenters where kubernetes node VMs are present.  

    # cd /etc/kubernetes
    # kubectl create configmap cloud-config --from-file=vsphere.conf --namespace=kube-system
    configmap/cloud-config created
    
    # kubectl get configmap cloud-config --namespace=kube-system
    NAME           DATA   AGE
    cloud-config   1      65s


### Create a CPI secret  
The CPI supports storing vCenter credentials either in:  
a shared global secret containing all vCenter credentials, or  
a secret dedicated for a particular vCenter configuration which takes precedence over anything that might be configured within the global secret  

(metadata: name: should not contain uppercase letters )  

    # tee cpi-datacenter-145-secret.yml  >/dev/null <<EOF 
    apiVersion: v1
    kind: Secret
    metadata:
      name: cpi-datacenter-145-secret
      namespace: kube-system 
    stringData:
      192.168.1.108.username: "administrator@vsphere.local"  
      192.168.1.108.password: "Password123!"  
    EOF 
   .

    # kubectl create -f cpi-datacenter-145-secret.yml
    secret/cpi-datacenter-145-secret created
    # kubectl get secret cpi-datacenter-145-secret --namespace=kube-system
     NAME                       TYPE   DATA  AGE 
     cpi-datacenter-145-secret Opaque  2     22s
    # kubectl describe secret cpi-datacenter-145-secret --namespace=kube-system
     NAME                       TYPE   DATA  AGE 
     cpi-datacenter-145-secret Opaque  2     65s
     
for multiple VCenters refer : https://cloud-provider-vsphere.sigs.k8s.io/tutorials/kubernetes-on-vsphere-with-kubeadm.html



### Check that all nodes are tainted 
( THIS IS IMP. IF NODES ARE NOT TAINTED THE CPI, CSI STEPS WILL HAVE ISSUES )

    # kubectl describe nodes | egrep "Taints:|Name:"  
    Name:               tanzu-m1
    Taints:             node-role.kubernetes.io/master:NoSchedule
    Name:               tanzu-s1
    Taints:             node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule

    
** IF NODES NEED TO BE TAINTED , USE BELOW**

    # administrator@k8vmware1master:/etc/kubernetes$ kubectl taint nodes k8vmware1worker1 node.cloudprovider.kubernetes. io/uninitialized=true:NoSchedule

### Deploy the CPI manifests  

    # kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml  
    clusterrole.rbac.authorization.k8s.io/system:cloud-controller-manager created

    # kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml   
    clusterrolebinding.rbac.authorization.k8s.io/system:cloud-controller-manager created

    # wget https://github.com/kubernetes/cloud-provider-vsphere/raw/master/manifests/controller-manager/vsphere-cloud-controller-manager-ds.yaml  
    Resolving github.com (github.com)... 140.82.112.3
    Connecting to github.com (github.com)|140.82.112.3|:443... connected.
    HTTP request sent, awaiting response... 302 Found
    Location: https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/vsphere-cloud-controller-manager-ds.yaml [following]
    --2020-04-17 13:36:45--  https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/vsphere-cloud-controller-manager-ds.yaml
    Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 151.101.116.133
    Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.116.133|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 1757 (1.7K) [text/plain]
    Saving to: âvsphere-cloud-controller-manager-ds.yamlâ

    vsphere-cloud-controller-manager-ds.yaml                   100%[========================================================================================================================================>]   1.72K  --.-KB/s    in 0s

    2020-04-17 13:36:46 (134 MB/s) - âvsphere-cloud-controller-manager-ds.yamlâ saved [1757/1757]

  
    # nano vsphere-cloud-controller-manager-ds.yaml
     - Change - --cloud-config=/etc/cloud/vsphere.conf To - --cloud-config=/etc/kubernetes/vsphere.conf
     - Change - mountPath: /etc/cloud To - mountPath: /etc/kubernetes
     - Finding string is with Ctrl-W and than enter cloud-config and hit enter. Now you are in the line you wanna edit
    
    # kubectl apply -f vsphere-cloud-controller-manager-ds.yaml
    serviceaccount/cloud-controller-manager created 
    daemonset.extensions/vsphere-cloud-controller-manager created 
    service/vsphere-cloud-controller-manager created

### Verify that the CPI has been successfully deployed
    # kubectl get pods --namespace=kube-system
    NAME                                   READY    STATUS    RESTARTS     AGE  
    coredns-fb8b8dccf-bq7qq                 1/1     Pending     0          71m  
    coredns-fb8b8dccf-r47q2                 1/1     Pending     0          71m   
    etcd-k8s-master                         1/1     Running     0          69m  
    kube-apiserver-k8s-master               1/1     Running     0          70m  
    kube-controller-manager-k8s-master      1/1     Running     0          69m  
    kube-flannel-ds-amd64-7kmk9             1/1     Running     0          38m  
    kube-proxy-6jcng                        1/1     Running     0          30m  
    kube-scheduler-k8s-master               1/1     Running     0          70m  
    vsphere-cloud-controller-manager-549hb  1/1     Running     0          25s  
    
be patient while the coredns pods are still **Pending** and do the next step  

*Check that all worker nodes are untainted step*    

and come back here. With my install it took 10 minutes until it changed to  

    # kubectl get pods --namespace=kube-system
    NAME                                   READY    STATUS    RESTARTS     AGE  
    coredns-fb8b8dccf-bq7qq                 1/1     Running     0          71m  
    coredns-fb8b8dccf-r47q2                 1/1     Running     0          71m   
    etcd-k8s-master                         1/1     Running     0          69m  
    kube-apiserver-k8s-master               1/1     Running     0          70m  
    kube-controller-manager-k8s-master      1/1     Running     0          69m  
    kube-flannel-ds-amd64-7kmk9             1/1     Running     0          38m  
    kube-proxy-6jcng                        1/1     Running     0          30m  
    kube-scheduler-k8s-master               1/1     Running     0          70m  
    vsphere-cloud-controller-manager-549hb  1/1     Running     0          25s 

### Check that all worker nodes are untainted
    root@tanzu-m1:/etc/kubernetes# kubectl describe nodes | egrep "Taints:|Name:"
    Name:               tanzu-m1
    Taints:             node-role.kubernetes.io/master:NoSchedule
    Name:               tanzu-s1
    Taints:             <none>  

**IN CASE ANY NODES are TAINTED, USE BELOW TO REMOVE TAINTS ON WORKER NODES**  

To Remove taints from nodes  
  
    root@tanzu-m1:/etc/kubernetes# kubectl describe nodes | egrep "Taints:|Name:"
                                   Name:    tanzu-m1
                                   Taints:  node-role.kubernetes.io/master:NoSchedule
                                   Name:    tanzu-s1
                                   Taints:  node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule
    
-
    
    root@tanzu-m1:/etc/kubernetes# kubectl patch node tanzu-s1 -p '{"spec":{"taints":[]}}' node/tanzu-s1 patched
    error: there is no need to specify a resource type as a separate argument when passing arguments in resource/name form (e.g. 'kubectl get resource/<resource_name>' instead of 'kubectl get resource resource/<resource_name>'
    
    root@tanzu-m1:/etc/kubernetes# kubectl patch node tanzu-s1 -p '{"spec":{"taints":[]}}' tanzu-s1 patched
    node/tanzu-s1 patched
    node/tanzu-s1 patched (no change)
    Error from server (NotFound): nodes "patched" not found
    
    root@tanzu-m1:/etc/kubernetes# kubectl describe nodes | egrep "Taints:|Name:"
    Name:               tanzu-m1
    Taints:             node-role.kubernetes.io/master:NoSchedule
    Name:               tanzu-s1
    Taints:             <none>


## Install vSphere Container Storage Interface csi Driver
( tanzu.m1 Master )  

    root@tanzu-m1:/etc/kubernetes# kubectl describe nodes | egrep "Taints:|Name:"
                                   Name:   tanzu-m1
                                   Taints: node-role.kubernetes.io/master:NoSchedule
                                   Name:   tanzu-s1
                                   Taints: <none>
    
The node-role.kubernetes.io/master=:NoSchedule taint is required to be present on the master nodes to prevent scheduling of the node plugin pods for vsphere-csi-node daemonset on the master nodes. Should you need to read the taint, you can use the following command:

    # kubectl taint nodes tanzu-m1 node-role.kubernetes.io/master=:NoSchedule

### Create a CSI secret  
    # tee /etc/kubernetes/csi-vsphere.conf >/dev/null <<EOF 
    [Global]
    cluster-id = "demo-cluster-id" 
    [VirtualCenter "192.168.108"] 
    insecure-flag = "true"
    user = "administrator@vsphere.local" 
    password = "Password123!"
    port = "443"
    datacenters = "Datacenter-145" 
    EOF
-
  
**cluster-id** represents the unique cluster identifier. Each kubernetes cluster should have it's own unique cluster-id set in the csi-vsphere.conf file.  
**VirtualCenter** section defines vCenter IP address / FQDN.   
**insecure-flag** should be set to true to use self-signed certificate for login   
**user** is the vCenter username for vSphere Cloud Provider.  
**password** is the password for vCenter user specified with user.  
**port** is the vCenter Server Port. The default is 443 if not specified.  
**datacenters** should be the list of all comma separated datacenters where kubernetes node VMs are present.  
    
  --
    
     # cd /etc/kubernetes  
     # kubectl create secret generic vsphere-config-secret --from-file=csi-vsphere.conf --namespace=kube-system
     secret/vsphere-config-secret created

     # kubectl get secret vsphere-config-secret --namespace=kube-system
    NAME                    TYPE     DATA   AGE
    vsphere-config-secret   Opaque   1      20s
   
    # rm /etc/kubernetes/csi-vsphere.conf

### Create Roles, ServiceAccount and ClusterRoleBinding  
(Master)

Check the Version on GitHub  
[https://github.com/kubernetes-sigs/vsphere-csi-driver/tree/master/manifests]()
Here we also do find different manifest for different vSphere Version  

My version was: 
[https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/vsphere-67u3/vanilla/rbac/vsphere-csi-controller-rbac.yaml]()

    $ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/vsphere-67u3/vanilla/rbac/vsphere-csi-controller-rbac.yaml  
    serviceaccount/vsphere-csi-controller created
    clusterrole.rbac.authorization.k8s.io/vsphere-csi-controller-role created
    clusterrolebinding.rbac.authorization.k8s.io/vsphere-csi-controller-binding created

### Install the vSphere CSI driver
But where to find? As of Apr 17 2020 I do search at  
[https://github.com/kubernetes-sigs/vsphere-csi-driver/tree/master/manifests/vsphere-67u3/vanilla/deploy]()
You do see a branch for vsphere-67u3 adn there is one for vsphere 7 as well. As I have vsphere-67u3 I do use this  
I do see   
vsphere-csi-controller-deployment.yaml     addressed review comments  
vsphere-csi-node-ds.yaml                   removed mounting vsphere csi conf secret in vsphere-csi-node daemonset   

Config the deployment  

    root@tanzu-m1:/etc/kubernetes# wget https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/vsphere-67u3/vanilla/deploy/vsphere-csi-controller-deployment.yaml  
    
    --2020-04-17 14:43:28--  https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/vsphere-67u3/vanilla/deploy/vsphere-csi-controller-deployment.yaml
    Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 199.232.36.133
    Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|199.232.36.133|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 4281 (4.2K) [text/plain]
    Saving to: âvsphere-csi-controller-deployment.yamlâ

    vsphere-csi-controller-deployment.yaml                     100%[========================================================================================================================================>]   4.18K  --.-KB/s    in 0.03s

    2020-04-17 14:43:29 (130 KB/s) - âvsphere-csi-controller-deployment.yamlâ saved [4281/4281]

    root@tanzu-m1:/etc/kubernetes# kubectl apply -f vsphere-csi-controller-deployment.yaml
    deployment.apps/vsphere-csi-controller created
    csidriver.storage.k8s.io/csi.vsphere.vmware.com created


Config the daemonset 

     root@tanzu-m1:/etc/kubernetes# wget https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/vsphere-67u3/vanilla/deploy/vsphere-csi-node-ds.yaml

    --2020-04-17 14:45:28--  https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/vsphere-67u3/vanilla/deploy/vsphere-csi-node-ds.yaml
    Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 151.101.116.133
    Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.116.133|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 4124 (4.0K) [text/plain]
    Saving to: âvsphere-csi-node-ds.yamlâ

    vsphere-csi-node-ds.yaml                                   100%[========================================================================================================================================>]   4.03K  --.-KB/s    in 0.03s

    2020-04-17 14:45:40 (125 KB/s) - âvsphere-csi-node-ds.yamlâ saved [4124/4124]

   
    root@tanzu-m1:/etc/kubernetes# kubectl apply -f vsphere-csi-node-ds.yaml
    daemonset.apps/vsphere-csi-node created

NOW we need some time. It took 10 Minutes until I saw a result !!!  


### Verify that CSI has been successfully deployed


    # kubectl get statefulset --namespace=kube-system 
    # kubectl get daemonsets vsphere-csi-node --namespace=kube-system 

The number of csi-nodes depends on the size of the cluster. There is one per Kubernetes worker node. 

     # kubectl get pods --namespace=kube-system
     # kubectl get CSINode



 ---
**yaml files are alos included into this repository. Look for the "yaml repositoy" folder in the github reprository.**  
The yaml I am providing are these you can find above in the text starting with # tee...  
Just to avoid typos is the reson to provide them.
 
     location                           name  
     -------                            -------
     /etc/docker/daemon.json           daemon.json  
     /etc/kubernetes/kubeadminit.yaml  kubeadminit.yaml

 ---
  
  
  WORK in PROGRESS - Hier kommt noch was ! WANN? Sei geduldig!!!  
  
  
 ---


This documentation was created from the follwing VMWare article which does contain more information as I have used [hDeploying a Kubernetes Cluster on vSphere with CSI and CPI](https://cloud-provider-vsphere.sigs.k8s.io/tutorials/kubernetes-on-vsphere-with-kubeadm.html)  
 
 
**Weitere Tools die wir brauchen können findet ihr hier:**

kubectl for other Operating Systems [https://kubernetes.io/docs/tasks/tools/install-kubectl/]()   
tmux for other Operating Systems [https://github.com/tmux/tmux]()    