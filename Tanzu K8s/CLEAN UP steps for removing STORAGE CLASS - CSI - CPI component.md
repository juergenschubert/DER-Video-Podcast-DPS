# Sample CLEAN UP steps for removing STORAGE CLASS, CSI, CPI components.



## Remove any POD's or NS that is using the PVC from VC/Cluster in question

### SC clean up now

    administrator@k8vmware6master:~$ kubectl delete sc sc-common
    storageclass.storage.k8s.io "sc-common" deleted


### remove config map
    root@tanzu-m1:/etc/kubernetes# kubectl get configmap --namespace=kube-system
    NAME                                 DATA   AGE
    cloud-config                         1      18h
    coredns                              1      19h
    extension-apiserver-authentication   6      19h
    kube-flannel-cfg                     2      19h
    kube-proxy                           2      19h
    kubeadm-config                       2      19h
    kubelet-config-1.14                  1      19h
    
    root@tanzu-m1:/etc/kubernetes# kubectl delete configmap cloud-config --namespace=kube-system
    configmap "cloud-config" deleted

##CSI driver clean up now
### remove the deamonset

    administrator@k8vmware6master:~$ kubectl delete -f vsphere-csi-node-ds.yaml
    daemonset.apps "vsphere-csi-node" deleted

### remove the statefullset and csidriver  
    administrator@k8vmware6master:~$ kubectl delete -f vsphere-csi-controller-ss.yaml
    statefulset.apps "vsphere-csi-controller" deleted
    csidriver.storage.k8s.io "csi.vsphere.vmware.com" deleted


### Remove CSI roles
#### remove serviceaccount, clusterrole and role binding

    administrator@k8vmware6master:~$ kubectl delete -f vsphere-csi-controller-rbac.yaml
    serviceaccount "vsphere-csi-controller" deleted
    clusterrole.rbac.authorization.k8s.io "vsphere-csi-controller-role" deleted
    clusterrolebinding.rbac.authorization.k8s.io "vsphere-csi-controller-binding" deleted


### Remove CSI secrets

    administrator@k8vmware6master:~$ kubectl delete secret vsphere-config-secret --namespace=kube-system
    secret "vsphere-config-secret" deleted

### REMOVE CSI NODES

First get the "CSI NODES"

    kubectl get CSINode

    administrator@k8vmware6master:~$ kubectl delete CSINode k8vmware6worker1
    csinode.storage.k8s.io "k8vmware6worker1" deleted
    administrator@k8vmware6master:~$ kubectl delete CSINode k8vmware6worker2
    csinode.storage.k8s.io "k8vmware6worker2" deleted

### Remove secret cpi-datacenter
 
    administrator@tanzu-m1:~$ kubectl delete secret cpi-datacenter-145-secret --namespace=kube-system
secret "cpi-datacenter-145-secret" deleted

##CPI 
### Remove CPI manifests
    administrator@tanzu-m1:~$ pwd
    /home/administrator
    administrator@tanzu-m1:~$ kubectl delete -f vsphere-cloud-controller-manager-ds.yaml
    serviceaccount "cloud-controller-manager" deleted
    daemonset.apps "vsphere-cloud-controller-manager" deleted
    service "vsphere-cloud-controller-manager" deleted


    administrator@k8vmware6master:~$ kubectl delete -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
    rolebinding.rbac.authorization.k8s.io "servicecatalog.k8s.io:apiserver-authentication-reader" deleted
    clusterrolebinding.rbac.authorization.k8s.io "system:cloud-controller-manager" deleted
    
    
    administrator@k8vmware6master:~$ kubectl delete -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
    clusterrole.rbac.authorization.k8s.io "system:cloud-controller-manager" deleted
 
 
###Show CPI SECRET  

    kubectl get secrets --namespace=kube-system

#####Remove CPI SECRET  

    administrator@k8vmware6master:~$ kubectl delete secret cpi-vmdm-secret --namespace=kube-system
    secret "cpi-vmdm-secret" deleted

#####Show CPI CONFIG MAP  
    kubectl get configmap --namespace=kube-system
    
#####Remove CPI CONFIG MAP

    administrator@k8vmware6master:~$ kubectl delete configmap cloud-config --namespace=kube-system
    configmap "cloud-config" deleted

# Reomove Docker Images 
Login to worker nodes!

    sudo su
    root@tanzu-s1:/home/administrator# docker image ls
    REPOSITORY                                         TAG                 IMAGE ID            CREATED             SIZE
    gcr.io/cloud-provider-vsphere/csi/release/driver   v1.0.1              4f8ebdb7decf        6 months ago        146MB  
    k8s.gcr.io/kube-proxy                              v1.14.2             5c24210246bb        11 months ago       82.1MB  
    quay.io/k8scsi/livenessprobe                       v1.1.0              d638ef264170        12 months ago       15MB  
    quay.io/k8scsi/csi-node-driver-registrar           v1.1.0              a93898755322        12 months ago       15.8MB  
    k8s.gcr.io/coredns                                 1.5.0               7987f0908caf        12 months ago       42.5MB  
    quay.io/coreos/flannel                             v0.11.0-amd64       ff281650a721        14 months ago       52.6MB
    k8s.gcr.io/pause                                   3.1                 da86e6ba6ca1        2 years ago         742kB  




## remove any images relating to CPI and CSI  
    gcr.io/cloud-provider-vsphere/csi/release/driver   v1.0.1              4f8ebdb7decf
    quay.io/k8scsi/csi-node-driver-registrar           v1.1.0              a93898755322 
    
    root@tanzu-s1:/home/administrator#  sudo docker image rm 4f8ebdb7decf a93898755322

## let's check

    root@tanzu-s1:/home/administrator# docker image ls
    REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
    k8s.gcr.io/kube-proxy          v1.14.2             5c24210246bb        11 months ago       82.1MB
    quay.io/k8scsi/livenessprobe   v1.1.0              d638ef264170        12 months ago       15MB
    k8s.gcr.io/coredns             1.5.0               7987f0908caf        12 months ago       42.5MB
    quay.io/coreos/flannel         v0.11.0-amd64       ff281650a721        14 months ago       52.6MB
    k8s.gcr.io/pause               3.1                 da86e6ba6ca1        2 years ago         742kB
  
