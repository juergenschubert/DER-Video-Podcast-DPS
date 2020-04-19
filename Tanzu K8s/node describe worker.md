adminuser@k8-master:~$ kubectl describe nodes



Name:               k8-node
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=vsphere-vm.cpu-4.mem-8gb.os-ubuntu
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8-node
                    kubernetes.io/os=linux
Annotations:        csi.volume.kubernetes.io/nodeid: {"csi.vsphere.vmware.com":"k8-node"}
                    flannel.alpha.coreos.com/backend-data: {"VtepMAC":"c6:82:1e:64:0e:bf"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.1.43
                    kubeadm.alpha.kubernetes.io/cri-socket: /var/run/dockershim.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Fri, 27 Mar 2020 14:50:45 +0100
Taints:             <none>
Unschedulable:      false
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason
         Message
  ----             ------  -----------------                 ------------------                ------
         -------
  MemoryPressure   False   Sun, 19 Apr 2020 17:47:41 +0200   Sun, 19 Apr 2020 04:56:00 +0200   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Sun, 19 Apr 2020 17:47:41 +0200   Sun, 19 Apr 2020 04:56:00 +0200   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Sun, 19 Apr 2020 17:47:41 +0200   Sun, 19 Apr 2020 04:56:00 +0200   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Sun, 19 Apr 2020 17:47:41 +0200   Sun, 19 Apr 2020 04:56:00 +0200   KubeletReady
         kubelet is posting ready status. AppArmor enabled
Addresses:
  Hostname:  k8-node
Capacity:
 cpu:                4
 ephemeral-storage:  101694448Ki
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             8168408Ki
 pods:               110
Allocatable:
 cpu:                4
 ephemeral-storage:  93721603122
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             8066008Ki
 pods:               110
System Info:
 Machine ID:                 5643fefed15a4cb9bdec06d34863e897
 System UUID:                C65E0042-F127-BD8F-85D8-4D58DEA9531E
 Boot ID:                    0ca3a4ab-eca8-414d-9aa8-ff79e90fdb03
 Kernel Version:             4.15.0-20-generic
 OS Image:                   Ubuntu 18.04 LTS
 Operating System:           linux
 Architecture:               amd64
 Container Runtime Version:  docker://18.6.0
 Kubelet Version:            v1.14.2
 Kube-Proxy Version:         v1.14.2
PodCIDR:                     10.244.1.0/24
ProviderID:                  vsphere://42005ec6-27f1-8fbd-85d8-4d58dea9531e
Non-terminated Pods:         (5 in total)
  Namespace                  Name                                        CPU Requests  CPU Limits  Memory Requests
 Memory Limits  AGE
  ---------                  ----                                        ------------  ----------  ---------------
 -------------  ---
  default                    mongod-0                                    200m (5%)     0 (0%)      200Mi (2%)
 0 (0%)         23d
  kube-system                kube-flannel-ds-amd64-wqzk6                 100m (2%)     100m (2%)   50Mi (0%)
 50Mi (0%)      23d
  kube-system                kube-proxy-rw59n                            0 (0%)        0 (0%)      0 (0%)
 0 (0%)         23d
  powerprotect               powerprotect-controller-76f7559854-kcfx9    0 (0%)        0 (0%)      0 (0%)
 0 (0%)         23d
  velero-ppdm                velero-76445cd9f6-cbbj2                     500m (12%)    1 (25%)     128Mi (1%)
 256Mi (3%)     23d
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                800m (20%)  1100m (27%)
  memory             378Mi (4%)  306Mi (3%)
  ephemeral-storage  0 (0%)      0 (0%)
Events:              <none>
adminuser@k8-master:~$ kubectl describe nodes k8-master
Name:               k8-master
Roles:              master
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=vsphere-vm.cpu-4.mem-8gb.os-ubuntu
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8-master
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/master=
Annotations:        flannel.alpha.coreos.com/backend-data: {"VtepMAC":"22:b8:3d:1a:9d:bb"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.1.42
                    kubeadm.alpha.kubernetes.io/cri-socket: /var/run/dockershim.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Fri, 27 Mar 2020 14:36:09 +0100
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason
         Message
  ----             ------  -----------------                 ------------------                ------
         -------
  MemoryPressure   False   Sun, 19 Apr 2020 17:56:43 +0200   Fri, 27 Mar 2020 14:36:08 +0100   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Sun, 19 Apr 2020 17:56:43 +0200   Fri, 27 Mar 2020 14:36:08 +0100   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Sun, 19 Apr 2020 17:56:43 +0200   Fri, 27 Mar 2020 14:36:08 +0100   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Sun, 19 Apr 2020 17:56:43 +0200   Fri, 27 Mar 2020 14:38:40 +0100   KubeletReady
         kubelet is posting ready status. AppArmor enabled
Addresses:
  Hostname:    k8-master
  ExternalIP:  192.168.1.42
  InternalIP:  192.168.1.42
Capacity:
 cpu:                4
 ephemeral-storage:  101694448Ki
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             8168416Ki
 pods:               110
Allocatable:
 cpu:                4
 ephemeral-storage:  93721603122
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             8066016Ki
 pods:               110
System Info:
 Machine ID:                 663641c1390b468eb02d626afce45f7d
 System UUID:                B4890042-AFE3-B90E-45CB-D4F7654ADDB6
 Boot ID:                    00800ff4-19d0-4ea1-b441-9af9781c52fc
 Kernel Version:             4.15.0-20-generic
 OS Image:                   Ubuntu 18.04 LTS
 Operating System:           linux
 Architecture:               amd64
 Container Runtime Version:  docker://18.6.0
 Kubelet Version:            v1.14.2
 Kube-Proxy Version:         v1.14.2
PodCIDR:                     10.244.0.0/24
ProviderID:                  vsphere://420089b4-e3af-0eb9-45cb-d4f7654addb6
Non-terminated Pods:         (10 in total)
  Namespace                  Name                                      CPU Requests  CPU Limits  Memory Requests  Memory Limits  AGE
  ---------                  ----                                      ------------  ----------  ---------------  -------------  ---
  kube-system                coredns-6557d7f7d6-fggwq                  100m (2%)     0 (0%)      70Mi (0%)        170Mi (2%)     23d
  kube-system                coredns-6557d7f7d6-nz7l4                  100m (2%)     0 (0%)      70Mi (0%)        170Mi (2%)     23d
  kube-system                etcd-k8-master                            0 (0%)        0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                kube-apiserver-k8-master                  250m (6%)     0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                kube-controller-manager-k8-master         200m (5%)     0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                kube-flannel-ds-amd64-wqcwt               100m (2%)     100m (2%)   50Mi (0%)        50Mi (0%)      23d
  kube-system                kube-proxy-qhvnc                          0 (0%)        0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                kube-scheduler-k8-master                  100m (2%)     0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                vsphere-cloud-controller-manager-vxths    200m (5%)     0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                vsphere-csi-controller-0                  0 (0%)        0 (0%)      0 (0%)           0 (0%)         9m45s
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests     Limits
  --------           --------     ------
  cpu                1050m (26%)  100m (2%)
  memory             190Mi (2%)   390Mi (4%)
  ephemeral-storage  0 (0%)       0 (0%)
Events:              <none>
adminuser@k8-master:~$ clear
adminuser@k8-master:~$ kubectl describe nodes
Name:               k8-master
Roles:              master
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=vsphere-vm.cpu-4.mem-8gb.os-ubuntu
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8-master
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/master=
Annotations:        flannel.alpha.coreos.com/backend-data: {"VtepMAC":"22:b8:3d:1a:9d:bb"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.1.42
                    kubeadm.alpha.kubernetes.io/cri-socket: /var/run/dockershim.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Fri, 27 Mar 2020 14:36:09 +0100
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason
         Message
  ----             ------  -----------------                 ------------------                ------
         -------
  MemoryPressure   False   Sun, 19 Apr 2020 17:57:43 +0200   Fri, 27 Mar 2020 14:36:08 +0100   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Sun, 19 Apr 2020 17:57:43 +0200   Fri, 27 Mar 2020 14:36:08 +0100   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Sun, 19 Apr 2020 17:57:43 +0200   Fri, 27 Mar 2020 14:36:08 +0100   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Sun, 19 Apr 2020 17:57:43 +0200   Fri, 27 Mar 2020 14:38:40 +0100   KubeletReady
         kubelet is posting ready status. AppArmor enabled
Addresses:
  Hostname:    k8-master
  ExternalIP:  192.168.1.42
  InternalIP:  192.168.1.42
Capacity:
 cpu:                4
 ephemeral-storage:  101694448Ki
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             8168416Ki
 pods:               110
Allocatable:
 cpu:                4
 ephemeral-storage:  93721603122
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             8066016Ki
 pods:               110
System Info:
 Machine ID:                 663641c1390b468eb02d626afce45f7d
 System UUID:                B4890042-AFE3-B90E-45CB-D4F7654ADDB6
 Boot ID:                    00800ff4-19d0-4ea1-b441-9af9781c52fc
 Kernel Version:             4.15.0-20-generic
 OS Image:                   Ubuntu 18.04 LTS
 Operating System:           linux
 Architecture:               amd64
 Container Runtime Version:  docker://18.6.0
 Kubelet Version:            v1.14.2
 Kube-Proxy Version:         v1.14.2
PodCIDR:                     10.244.0.0/24
ProviderID:                  vsphere://420089b4-e3af-0eb9-45cb-d4f7654addb6
Non-terminated Pods:         (10 in total)
  Namespace                  Name                                      CPU Requests  CPU Limits  Memory Requests  Memory Limits  AGE
  ---------                  ----                                      ------------  ----------  ---------------  -------------  ---
  kube-system                coredns-6557d7f7d6-fggwq                  100m (2%)     0 (0%)      70Mi (0%)        170Mi (2%)     23d
  kube-system                coredns-6557d7f7d6-nz7l4                  100m (2%)     0 (0%)      70Mi (0%)        170Mi (2%)     23d
  kube-system                etcd-k8-master                            0 (0%)        0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                kube-apiserver-k8-master                  250m (6%)     0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                kube-controller-manager-k8-master         200m (5%)     0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                kube-flannel-ds-amd64-wqcwt               100m (2%)     100m (2%)   50Mi (0%)        50Mi (0%)      23d
  kube-system                kube-proxy-qhvnc                          0 (0%)        0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                kube-scheduler-k8-master                  100m (2%)     0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                vsphere-cloud-controller-manager-vxths    200m (5%)     0 (0%)      0 (0%)           0 (0%)         23d
  kube-system                vsphere-csi-controller-0                  0 (0%)        0 (0%)      0 (0%)           0 (0%)         10m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests     Limits
  --------           --------     ------
  cpu                1050m (26%)  100m (2%)
  memory             190Mi (2%)   390Mi (4%)
  ephemeral-storage  0 (0%)       0 (0%)
Events:              <none>


Name:               k8-node
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=vsphere-vm.cpu-4.mem-8gb.os-ubuntu
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8-node
                    kubernetes.io/os=linux
Annotations:        csi.volume.kubernetes.io/nodeid: {"csi.vsphere.vmware.com":"k8-node"}
                    flannel.alpha.coreos.com/backend-data: {"VtepMAC":"c6:82:1e:64:0e:bf"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.1.43
                    kubeadm.alpha.kubernetes.io/cri-socket: /var/run/dockershim.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Fri, 27 Mar 2020 14:50:45 +0100
Taints:             <none>
Unschedulable:      false
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason
         Message
  ----             ------  -----------------                 ------------------                ------
         -------
  MemoryPressure   False   Sun, 19 Apr 2020 17:57:41 +0200   Sun, 19 Apr 2020 04:56:00 +0200   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Sun, 19 Apr 2020 17:57:41 +0200   Sun, 19 Apr 2020 04:56:00 +0200   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Sun, 19 Apr 2020 17:57:41 +0200   Sun, 19 Apr 2020 04:56:00 +0200   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Sun, 19 Apr 2020 17:57:41 +0200   Sun, 19 Apr 2020 04:56:00 +0200   KubeletReady
         kubelet is posting ready status. AppArmor enabled
Addresses:
  Hostname:  k8-node
Capacity:
 cpu:                4
 ephemeral-storage:  101694448Ki
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             8168408Ki
 pods:               110
Allocatable:
 cpu:                4
 ephemeral-storage:  93721603122
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             8066008Ki
 pods:               110
System Info:
 Machine ID:                 5643fefed15a4cb9bdec06d34863e897
 System UUID:                C65E0042-F127-BD8F-85D8-4D58DEA9531E
 Boot ID:                    0ca3a4ab-eca8-414d-9aa8-ff79e90fdb03
 Kernel Version:             4.15.0-20-generic
 OS Image:                   Ubuntu 18.04 LTS
 Operating System:           linux
 Architecture:               amd64
 Container Runtime Version:  docker://18.6.0
 Kubelet Version:            v1.14.2
 Kube-Proxy Version:         v1.14.2
PodCIDR:                     10.244.1.0/24
ProviderID:                  vsphere://42005ec6-27f1-8fbd-85d8-4d58dea9531e
Non-terminated Pods:         (5 in total)
  Namespace                  Name                                        CPU Requests  CPU Limits  Memory Requests
 Memory Limits  AGE
  ---------                  ----                                        ------------  ----------  ---------------
 -------------  ---
  default                    mongod-0                                    200m (5%)     0 (0%)      200Mi (2%)
 0 (0%)         23d
  kube-system                kube-flannel-ds-amd64-wqzk6                 100m (2%)     100m (2%)   50Mi (0%)
 50Mi (0%)      23d
  kube-system                kube-proxy-rw59n                            0 (0%)        0 (0%)      0 (0%)
 0 (0%)         23d
  powerprotect               powerprotect-controller-76f7559854-kcfx9    0 (0%)        0 (0%)      0 (0%)
 0 (0%)         23d
  velero-ppdm                velero-76445cd9f6-cbbj2                     500m (12%)    1 (25%)     128Mi (1%)
 256Mi (3%)     23d
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                800m (20%)  1100m (27%)
  memory             378Mi (4%)  306Mi (3%)
  ephemeral-storage  0 (0%)      0 (0%)
Events:              <none>   
