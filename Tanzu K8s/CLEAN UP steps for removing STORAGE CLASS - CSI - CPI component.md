Sample CLEAN UP steps for removing STORAGE CLASS, CSI, CPI components.



Remove any POD's or NS that is using the PVC from VC/Cluster in question

#### SC clean up now

    administrator@k8vmware6master:~$ kubectl delete sc sc-common
    storageclass.storage.k8s.io "sc-common" deleted

####CSI driver clean up now

    administrator@k8vmware6master:~$ kubectl delete -f vsphere-csi-node-ds.yaml
    daemonset.apps "vsphere-csi-node" deleted
OR  
   
    administrator@tanzu-m1:~$ kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/v1.0.2/deploy/vsphere-csi-node-ds.yaml
    daemonset.apps "vsphere-csi-node" deleted


    administrator@k8vmware6master:~$ kubectl delete -f vsphere-csi-controller-ss.yaml
    statefulset.apps "vsphere-csi-controller" deleted
    csidriver.storage.k8s.io "csi.vsphere.vmware.com" deleted
OR
  
    administrator@tanzu-m1:~$ kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/v1.0.2/deploy/vsphere-csi-controller-ss.yaml
statefulset.apps "vsphere-csi-controller" deleted
csidriver.storage.k8s.io "csi.vsphere.vmware.com" deleted


#### Remove CSI roles

    administrator@k8vmware6master:~$ kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/1.14/rbac/vsphere-csi-controller-rbac.yaml
    serviceaccount "vsphere-csi-controller" deleted
    clusterrole.rbac.authorization.k8s.io "vsphere-csi-controller-role" deleted
    clusterrolebinding.rbac.authorization.k8s.io "vsphere-csi-controller-binding" deleted

#### Remove CSI secrets

    administrator@k8vmware6master:~$ kubectl delete secret vsphere-config-secret --namespace=kube-system
  secret "vsphere-config-secret" deleted

#### REMOVE CSI NODES

First get the "CSI NODES"

    kubectl get CSINode

    administrator@k8vmware6master:~$ kubectl delete CSINode k8vmware6worker1
    csinode.storage.k8s.io "k8vmware6worker1" deleted
    administrator@k8vmware6master:~$ kubectl delete CSINode k8vmware6worker2
    csinode.storage.k8s.io "k8vmware6worker2" deleted

####Remove secret cpi-datacenter
 
    administrator@tanzu-m1:~$ kubectl delete secret cpi-datacenter-145-secret --namespace=kube-system
secret "cpi-datacenter-145-secret" deleted

 
#### Remove CPI manifests

    administrator@k8vmware6master:~$ kubectl delete -f vsphere-cloud-controller-manager-ds.yaml
    serviceaccount "cloud-controller-manager" deleted
    daemonset.apps "vsphere-cloud-controller-manager" deleted
    service "vsphere-cloud-controller-manager" deleted


    administrator@k8vmware6master:~$ kubectl delete -f https://raw.githubusercontent.com/kubernetes/cloud-provider-    vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
    rolebinding.rbac.authorization.k8s.io "servicecatalog.k8s.io:apiserver-authentication-reader" deleted
    clusterrolebinding.rbac.authorization.k8s.io "system:cloud-controller-manager" deleted
    administrator@k8vmware6master:~$ kubectl delete -f https://raw.githubusercontent.com/kubernetes/cloud-provider-    vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
clusterrole.rbac.authorization.k8s.io "system:cloud-controller-manager" deleted


######Remove CPI SECRET

    administrator@k8vmware6master:~$ kubectl delete secret cpi-vmdm-secret --namespace=kube-system
    secret "cpi-vmdm-secret" deleted

#####Remove CPI CONFIG MAP

    administrator@k8vmware6master:~$ kubectl delete configmap cloud-config --namespace=kube-system
    configmap "cloud-config" deleted

# Login to worker nodes:
    sudo su
    root@tanzu-s1:/home/administrator# docker images
    REPOSITORY                                         TAG                 IMAGE ID            CREATED             SIZE
    gcr.io/cloud-provider-vsphere/csi/release/driver   v1.0.2              34cd0ef118af        2 months ago        146MB
    quay.io/k8scsi/csi-node-driver-registrar           v1.2.0              c2103589e99f        7 months ago        17.1MB
    k8s.gcr.io/kube-proxy                              v1.14.2             5c24210246bb        11 months ago       82.1MB
    quay.io/k8scsi/livenessprobe                       v1.1.0              d638ef264170        12 months ago       15MB
    quay.io/k8scsi/csi-node-driver-registrar           v1.1.0              a93898755322        12 months ago       15.8MB
    k8s.gcr.io/coredns                                 1.5.0               7987f0908caf        12 months ago       42.5MB
    quay.io/coreos/flannel                             v0.11.0-amd64       ff281650a721        14 months ago       52.6MB
    k8s.gcr.io/pause                                   3.1                 da86e6ba6ca1        2 years ago         742kB



remove any images relating to CPI and CSI

    gcr.io/cloud-provider-vsphere/csi/release/drive 
    quay.io/k8scsi/csi-node-driver-registrar  
    quay.io/k8scsi/csi-node-driver-registrar 

    root@tanzu-s1:/home/administrator#  sudo docker image rm 34cd0ef118af
    Untagged: gcr.io/cloud-provider-vsphere/csi/release/driver:v1.0.2
    Untagged: gcr.io/cloud-provider-vsphere/csi/release/driver@sha256:149e87faaacda614ee95ec271b54c8bfdbd2bf5825abc12d45c654036b798229
    Deleted: sha256:34cd0ef118af692c38fc9d7030d0135a43e04dbf6e228c4fb73bfbd0b6d3734e
    Deleted: sha256:fd6e09a54b3d166ff7c0df35277ab97918fc574bc16e2aa91734e114bfa2b03e
    Deleted: sha256:c026446544d907bafc7e6642c5fd1951f58a31ad460541dfaaaffd95fac2e18b
    Deleted: sha256:fc703035870768bbee0899a28a82a8827669215b93fcb53dcf170f7512d06355
    Deleted: sha256:1715251d4f57a313cd7e2b9a8af685fb1e5f384c001be72812ac97c717cbc8c9
    Deleted: sha256:aa686b5974df44460789e661f98c35feaca65c37190508cd597490029299811f
    
    root@tanzu-s1:/home/administrator# sudo docker image rm c2103589e99f
    Untagged: quay.io/k8scsi/csi-node-driver-registrar:v1.2.0
    Untagged: quay.io/k8scsi/csi-node-driver-registrar@sha256:89cdb2a20bdec89b75e2fbd82a67567ea90b719524990e772f2704b19757188d
    Deleted: sha256:c2103589e99f907333422ae78702360ad258a8f0366c20e341c9e0c53743e78a
    Deleted: sha256:f91afafce1aa4dc9674b6c4af5c319ce36e202086d15abca0bfde24d2b56a7e8
    Deleted: sha256:932da51564135c98a49a34a193d6cd363d8fa4184d957fde16c9d8527b3f3b02
    
    root@tanzu-s1:/home/administrator# sudo docker image rm a93898755322
    Untagged: quay.io/k8scsi/csi-node-driver-registrar:v1.1.0
    Untagged: quay.io/k8scsi/csi-node-driver-registrar@sha256:13daf82fb99e951a4bff8ae5fc7c17c3a8fe7130be6400990d8f6076c32d4599
    Deleted: sha256:a938987553222a925537e68c4d8d6f4912eb3fca1269ddef160beae3d202d1c8
    Deleted: sha256:9cd1590270b532153bc0e987d8dc13e287c4b169924912f20dd79a5e6f90ff17

let's check

    root@tanzu-s1:/home/administrator# docker images
    REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
    k8s.gcr.io/kube-proxy          v1.14.2             5c24210246bb        11 months ago       82.1MB
    quay.io/k8scsi/livenessprobe   v1.1.0              d638ef264170        12 months ago       15MB
    k8s.gcr.io/coredns             1.5.0               7987f0908caf        12 months ago       42.5MB
    quay.io/coreos/flannel         v0.11.0-amd64       ff281650a721        14 months ago       52.6MB
    k8s.gcr.io/pause               3.1                 da86e6ba6ca1        2 years ago         742kB
