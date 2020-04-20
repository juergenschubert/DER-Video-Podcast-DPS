# List all container and get the vSphere CSI driver and Daemonset Container


    root@tanzu-m1:/home/administrator# docker image ls
    
REPOSITORY                                          TAG                 IMAGE ID            CREATED             SIZE
gcr.io/cloud-provider-vsphere/csi/release/syncer    v1.0.2              2b11efaf3392        2 months ago        99.3MB
gcr.io/cloud-provider-vsphere/csi/release/driver    v1.0.2              34cd0ef118af        2 months ago        146MB
gcr.io/cloud-provider-vsphere/cpi/release/manager   latest              a2ff4dcbcd4e        4 months ago        56.2MB
gcr.io/cloud-provider-vsphere/csi/release/syncer    v1.0.1              61b18277656b        6 months ago        99.7MB
gcr.io/cloud-provider-vsphere/csi/release/driver    v1.0.1              4f8ebdb7decf        6 months ago        146MB
quay.io/k8scsi/csi-provisioner                      v1.2.2              37eef1e78ae2        6 months ago        50.4MB
quay.io/k8scsi/csi-node-driver-registrar            v1.2.0              c2103589e99f        7 months ago        17.1MB
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
##remove them
    root@tanzu-m1:/home/administrator# docker image rm 2b11efaf3392 34cd0ef118af a2ff4dcbcd4e 61b18277656b 4f8ebdb7decf 37eef1e78ae2 c2103589e99f e87846966350 d638ef264170
