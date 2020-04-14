# Tanzu Kubernetes Space

wir wollen hier ein K8s Cluster aufbauen, welches mit vSphere Tanzu diese FCD disken benutzt und als Kubernetes ein PVC hat.  
Ziel ist es das k8s Clusten nach Aubau, dann mit DELL PowerProtect zu sichern

## Voraussetzunge von VMware     
Wir brauchen ein 6.7 U2 vSphere um dann 2 Ubuntu Server, k8s.master1 und k8s.slave1 mit k8s zu versehen

## Step 1 vSphere 6.7 U3
get vSphere 6.7 U3 running (check Hardware 15) die wir brauchen um die Ubuntu Server zu verwenden

## Step 2 Create both VM

### Create a new VM with the following properties :
Compatibility : ESXi 6.7 Update 2 and later (VM version 15)
* CPU 4 CPU(s),  
* Memory 8 GB  
* Hard disk 1 100GB  
* SCSI controller 0 VMware Paravirtual    
* Change Type VMware Paravirtual     
* SCSI Bus Sharing None  

### disk.EnableUUID=1  
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
**Install 2 Ubuntu 18.04.4 LTS (Bionic Beaver)**  
Download des iso unter [http://releases.ubuntu.com/18.04.4/](download)  
Von CD booten und Config durchspielen  
Feste IP Adresse und hostname im DNS  
**tanzu-m1.vlab.local** und **tanzu-s1.vlab.local**  

[Netzwerkconfig Hilfe und Troubleshooting -_Netplan](https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan)   
[Ubuntu DNS Server nslookup  ](https://www.thomas-krenn.com/de/wiki/Netzwerk-Konfiguration_Ubuntu_-_Netplan)
  

- **Hardware 15** für die VMs, CBT und more auf beide Ubuntus anwenden. Mehr findet ihr in VMWare FCD uuid and CBT enable.pdf.  Diese Änderungen und Hardware Versionen brauchen wir und die FCD zu verwenden und dann auch einen PVC anlegen zu können ....

Natürlich können wir das auch von innerhalb der VM aus machen das cbt enablen usw. Wir arbeiten hier mit **govc**.

Tools die wir brauchen können findet ihr hier:  
**govc** is a vSphere CLI built on top of govmomi and can be downloaded here: [GitHub download location for govc](https://github.com/vmware/govmomi/releases)  
  
[Using the govc CLI to automate vCenter commands](https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/)  

[Detailed documentation on deployment of govc](https://github.com/juergenschubert/DER-Video-Podcast-DPS/blob/master/Tanzu%20K8s/govc%20howto.md)  
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
## Setup step for flannel 
(Pod Networking for both master and worker )  
  
    # sudo su
    # sysctl net.bridge.bridge-nf-call-iptables=1

## Installing the Kubernetes master node(s)  

    #sudo su
***Where serviceSubnet: "10.98.48.0/21" is the CIDR/subnet mask and podSubnet: "10.244.0.0/16" is the default value. Note the "token:"in below as this will be RE-USED in Subsequent steps.***  

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
  serviceSubnet: "10.125.12.0/22"
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
    
    SAMPLE O/P:1.

To start using your cluster, you need to run the following as a regular user:  

    # mkdir -p $HOME/.kube
    # sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
    # sudo chown $(id -u):$(id -g) $HOME/.kube/config  
    
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




  
**Weitere Tools die wir brauchen können findet ihr hier:**

kubectl for other Operating Systems [https://kubernetes.io/docs/tasks/tools/install-kubectl/]()   
tmux for other Operating Systems [https://github.com/tmux/tmux]()    