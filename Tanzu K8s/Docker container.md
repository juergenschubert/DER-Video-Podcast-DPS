#Container you should see on your Kubernetes Nodes

##Master  
adminuser@k8-master:~$ sudo docker image ls  

REPOSITORY                                          TAG                 IMAGE ID            CREATED             SIZE  
gcr.io/cloud-provider-vsphere/csi/release/syncer    v1.0.2              2b11efaf3392        2 months ago        99.3MB  
gcr.io/cloud-provider-vsphere/csi/release/driver    v1.0.2              34cd0ef118af        2 months ago        146MB  
gcr.io/cloud-provider-vsphere/cpi/release/manager   latest              a2ff4dcbcd4e        4 months ago        56.2MB  
quay.io/k8scsi/csi-provisioner                      v1.2.2              37eef1e78ae2        6 months ago        50.4MB  
k8s.gcr.io/kube-proxy                               v1.14.2             5c24210246bb        11 months ago       82.1MB  
k8s.gcr.io/kube-apiserver                           v1.14.2             5eeff402b659        11 months ago       210MB  
k8s.gcr.io/kube-controller-manager                  v1.14.2             8be94bdae139        11 months ago       158MB  
k8s.gcr.io/kube-scheduler                           v1.14.2             ee18f350636d        11 months ago       81.6MB  
quay.io/k8scsi/csi-attacher                         v1.1.1              e87846966350        11 months ago       42.8MB  
quay.io/k8scsi/livenessprobe                        v1.1.0              d638ef264170        12 months ago       15MB  
k8s.gcr.io/coredns                                  1.5.0               7987f0908caf        12 months ago       42.5MB  
quay.io/coreos/flannel                              v0.11.0-amd64       ff281650a721        14 months ago       52.6MB  
k8s.gcr.io/etcd                                     3.3.10              2c4adeb21b4f        16 months ago       258MB  
k8s.gcr.io/pause                                    3.1                 da86e6ba6ca1        2 years ago         742kB  
adminuser@k8-master:~$  

##Worker
adminuser@k8-node:~$ sudo docker image ls  
REPOSITORY                                         TAG                 IMAGE ID            CREATED             SIZE  
dellemc/powerprotect-k8s-controller                19.4.0-6            8659348c5492        4 weeks ago         257MB  
dellemc/powerprotect-velero-dd                     19.4.0-6            bb73a3645f81        4 weeks ago         188MB  
vsphereveleroplugin/velero-plugin-for-vsphere      0.9.0               5c589caba02a        7 weeks ago         294MB  
gcr.io/cloud-provider-vsphere/csi/release/driver   v1.0.2              34cd0ef118af        2 months ago        146MB  
mongo                                              3.4                 f76f959b2a49        2 months ago        431MB  
velero/velero                                      v1.2.0              255525afb00f        5 months ago        148MB  
k8s.gcr.io/kube-proxy                              v1.14.2             5c24210246bb        11 months ago       82.1MB  
quay.io/k8scsi/livenessprobe                       v1.1.0              d638ef264170        12 months ago       15MB  
quay.io/k8scsi/csi-node-driver-registrar           v1.1.0              a93898755322        12 months ago       15.8MB  
quay.io/coreos/flannel                             v0.11.0-amd64       ff281650a721        14 months ago       52.6MB  
k8s.gcr.io/pause                                   3.1                 da86e6ba6ca1        2 years ago         742kB  
adminuser@k8-node:~$  
