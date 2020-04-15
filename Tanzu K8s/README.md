
# Agenda 
little overview what you'll find below  

```
Voraussetzunge von VMware  
   Step 1 vSphere 6.7 U3 
   Step 2 Create both VM  
     Enabling disk UUID
     enable CBT
   Install Ubuntu
   Setting up VMs in the Guest OS  
     Disable Swap
   Install Docker CE
   Install Kubelet, Kubectl, Kubeadm
   Pod Networking - flanel
   Installing the Kubernetes
     master node
       Install flannel pod overlay networking
     worker node
     

```

# Tanzu Kubernetes Space

wir wollen hier ein K8s Cluster aufbauen, welches mit vSphere Tanzu diese FCD disken benutzt und als Kubernetes ein PVC hat.  
Ziel ist es das k8s Clusten nach Aufbau, dann mit DELL PowerProtect zu sichern

## Voraussetzunge von VMware     
Wir brauchen ein 6.7 U2 vSphere um dann 2 Ubuntu Server, tanzu-m1 und tanzu.s1 mit k8s zu versehen

## Step 1 vSphere 6.7 U3
get vSphere 6.7 U3 running (check Hardware 15) die wir brauchen um die Ubuntu Server zu verwenden

## Step 2 Create both VM
I do name them **tanzu-m1** und **tanzu-s1**, m1 for master and s1 for the first worker. Logins are administrator and root on all server :-)  Just in case you do see, my passwords all all Password123!.

### Create a new VM with the following properties :
Compatibility : ESXi 6.7 Update 2 and later (VM version 15)
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

**Hardware 15** für die VMs, CBT und more auf beide Ubuntus anwenden. Mehr findet ihr in VMWare FCD uuid and CBT enable.pdf.  Diese Änderungen und Hardware Versionen brauchen wir und die FCD zu verwenden und dann auch einen PVC anlegen zu können ....

Natürlich können wir das auch von innerhalb der VM aus machen das cbt enablen usw. Wir arbeiten hier mit **govc**.

Tools die wir brauchen können findet ihr hier:  
**govc** is a vSphere CLI built on top of govmomi and can be downloaded here: [GitHub download location for govc](https://github.com/vmware/govmomi/releases)  
  
[Using the govc CLI to automate vCenter commands](https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/)  

[Detailed documentation on deployment of govc](https://github.com/juergenschubert/DER-Video-Podcast-DPS/blob/master/Tanzu%20K8s/govc%20howto.md)   

##Install Ubuntu 18.04.4 LTS (Bionic Beaver) 
Download des iso unter [http://releases.ubuntu.com/18.04.4/](download)  
Von CD booten und Config durchspielen  
Feste IP Adresse und hostname im DNS  
**tanzu-m1.vlab.local** und **tanzu-s1.vlab.local**  

[Netzwerkconfig Hilfe und Troubleshooting -_Netplan](https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan)   
[Ubuntu DNS Server nslookup Hilfe](https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan)

## Setting up VMs in the Guest OS
The next step is to install the necessary Kubernetes components on the Ubuntu OS virtual machines. Some components must be installed on all of the nodes. In other cases, some of the components need only be installed on the master, and in other cases, only the workers. In each case, where the components are installed is highlighted. All installation and configuration commands should be executed with root privilege. You can switch to the root environment using the "sudo su" command. 

### Disable Swap (Both master and worker)
SSH into all K8s worker nodes and disable swap on all nodes including master node. This is a prerequisite for kubeadm.    

    # sudo su  
    # swapoff -a  
    # vi /etc/fstab ... remove any swap entry from   this file ...


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
(Both master and worker )  
  
    # sudo su
    # curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    OK
    # cat <<EOF >/etc/apt/sources.list.d/kubernetes.list 
    deb https://apt.kubernetes.io/   kubernetes-xenial main   
    EOF
    # apt update
    # apt install -qy kubeadm=1.14.2-00 kubelet=1.14.2-00 kubectl=1.14.2-00
    # apt-mark hold kubelet kubeadm kubectl
## Pod Networking - Setup flannel 
(Pod Networking for both master and worker )  
  
    # sudo su
    # sysctl net.bridge.bridge-nf-call-iptables=1

## Installing the Kubernetes master node(s)  

    #sudo su
***Where serviceSubnet: "10.98.48.0/21" is the CIDR/subnet mask and podSubnet: "10.244.0.0/16" is the default value. Note the "token:"in below as this will be RE-USED in Subsequent steps.***  


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

Then you can join any number of worker nodes by running the following on each as **root**:

    # kubeadm join 192.168.1.155:6443 --token y7yaev.9dvwxx6ny4ef8vlq \
    --discovery-token-ca-cert-hash sha256:a40ed74295afe9514b36d3c389b4b803fe8f633c65928282c813746b57945d63
 
    
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
    
    End your day or just take a break as this will take some minutes otherwise your follow on step will fail. Taking a while

## Install flannel pod overlay networking
The next step that needs to be carried out on the master node is that the flannel pod overlay network must be installed so the pods can communicate with
each other. ( ON MASTER AS REGULAR USER )  

    # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml
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

    NAME READY STATUS RESTARTS AGE
    coredns-6557d7f7d6-9s7sm 0/1 Pending 0 107s
    coredns-6557d7f7d6-wgxtq 0/1 Pending 0 107s
    etcd-k8s-mstr 1/1 Running 0 70s
    kube-apiserver-k8s-mstr 1/1 Running 0 54s
    kube-controller-manager-k8s-mstr 1/1 Running 0 53s
    kube-flannel-ds-amd64-pm9m9 1/1 Running 0 11s
    kube-proxy-8dfm9 1/1 Running 0 107s
    kube-scheduler-k8s-mstr 1/1 Running 0 49s

##Export the master node configuration to worker nodes
Finally, the master node configuration needs to be exported as it is used by the worker nodes wishing to join to the master.  

     # kubectl -n kube-public get configmap cluster-info -o jsonpath='{.data.kubeconfig}' > discovery.yaml

The discovery.yaml file will need to be copied to /etc/kubernetes/discovery.yaml on each of the worker nodes.

##Installing the Kubernetes worker node(s)

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
    
        
**Go to your Master Server**
 
    # kubectl get nodes -o wide ( In Master )

    # root@tanzu-m1:/home/administrator# kubectl get nodes
    NAME       STATUS   ROLES    AGE     VERSION
    tanzu-m1   Ready    master   65m     v1.14.2
    tanzu-s1   Ready    <none>   3m28s   v1.14.2
     
 ---
**yaml files are alos included into this repository. Look for the "yaml repositoy" folder in the github reprository.**  
The yaml I am providing are these you can find above in the text starting with # tee...  
Just to avoid typos is the reson to provide them.
 
     location                           name  
     -------                            -------
     /etc/docker/daemon.json           daemon.json  
     /etc/kubernetes/kubeadminit.yaml  kubeadminit.yaml

 ---
  
**Weitere Tools die wir brauchen können findet ihr hier:**

kubectl for other Operating Systems [https://kubernetes.io/docs/tasks/tools/install-kubectl/]()   
tmux for other Operating Systems [https://github.com/tmux/tmux]()    