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
    
    DELETE the deployment
    kubectl delete -f vsphere-csi-controller-deployment.yaml


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
    
        DELETE the deployment
    kubectl delete -f vsphere-csi-node-ds.yaml

NOW we need some time. It took 10 Minutes until I saw a result !!!  


### Verify that CSI has been successfully deployed


    # kubectl get statefulset --namespace=kube-system  
    No resources found.

    # kubectl get daemonsets vsphere-csi-node --namespace=kube-system  
    NAME               DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
    vsphere-csi-node   2         2         0       2            0           <none>          3h37m

The number of csi-nodes depends on the size of the cluster. There is one per Kubernetes worker node. 

     # kubectl get pods --namespace=kube-system
     NAME                                      READY   STATUS             RESTARTS   AGE
     coredns-6557d7f7d6-cwh2w                  1/1     Running            0          3d3h
     coredns-6557d7f7d6-lkmgj                  1/1     Running            0          3d3h
     etcd-tanzu-m1                             1/1     Running            1          3d3h
     kube-apiserver-tanzu-m1                   1/1     Running            1          3d3h
     kube-controller-manager-tanzu-m1          1/1     Running            3          3d3h
     kube-flannel-ds-amd64-nq84d               1/1     Running            1          3d3h  
     kube-flannel-ds-amd64-wddlj               1/1     Running            2          3d2h 
     kube-proxy-qj46g                          1/1     Running            1          3d2h
     kube-proxy-vhfmg                          1/1     Running            1          3d3h
     kube-scheduler-tanzu-m1                   1/1     Running            2          3d3h
     vsphere-cloud-controller-manager-wjg2t    1/1     Running            0          4h39m
     vsphere-csi-controller-7db6d7dc88-gk5z5   3/5     InvalidImageName   0          3h39m
     vsphere-csi-node-88bp7                    2/3     InvalidImageName   0          3h37m
     vsphere-csi-node-8z2b9                    2/3     InvalidImageName   0          3h37m

     # kubctl describe pods vsphere-csi-controller-7db6d7dc88-gk5z5 --namespace=kube-system 

     # kubectl get CSINode
     No resources found.

gcr.io/cloud-provider-vsphere/csi/release/driver:v1.0.2
gcr.io/cloud-provider-vsphere/csi/release/syncer:v1.0.2

manifests/archives/driver-v1.0.2/deploy/vsphere-csi-controller-ss.yaml
manifests/archives/driver-v1.0.2/deploy/vsphere-csi-node-ds.yaml 
 ---
 
 get back the old one
 https://github.com/kubernetes-sigs/vsphere-csi-driver/pull/179/commits/f60041e1e1eb3252069420312356dd77a25ad746