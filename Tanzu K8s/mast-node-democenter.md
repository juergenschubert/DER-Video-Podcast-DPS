##Commands from the democenter

MASTER Node

    1  sudo su
    2  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    3  sudo chown $(id -u):$(id -g) $HOME/.kube/config
    4  kubectl get pods --namespace=kube-system
    5  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml
    6  kubectl -n kube-public get configmap cluster-info -o jsonpath='{.data.kubeconfig}' > discovery.yaml
    7  ls
    8  cat discovery.yaml
    9  kubectl get nodes -o wide
   10  tee /etc/kubernetes/vsphere.conf >/dev/null <<EOF
   11  [Global]
   12  port = "443"
   13  insecure-flag = "true"
   14  secret-name = "cpi-global-secret"
   15  secret-namespace = "kube-system"
   16  [VirtualCenter "192.168.1.3"]
   17  datacenters = "Datacenter"
   18  secret-name = "cpi-datacenter-secret"
   19  secret-namespace = "kube-system"
   20  EOF
   21  sudo su
   22  cd /etc/kubernetes/
   23  kubectl create configmap cloud-config --from-file=vsphere.conf --namespace=kube-system
   24  kubectl get configmap cloud-config --namespace=kube-system
   25  cd ..
   26  apiVersion: v1
   27  kind: Secret
   28  metadata:
   29  stringData:
   30  vi cpi-datacenter-secret.yml
   31  sudo vi cpi-datacenter-secret.yml
   32  kubectl create -f cpi-datacenter-secret.yml
   33  kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
   34  kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
   35  sudo wget https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/vsphere-cloud-controller-manager-ds.yaml
   36  sudo vi vsphere-cloud-controller-manager-ds.yaml
   37  sudo vi vsphere-cloud-controller-manager-ds.yaml
   38  kubectl apply -f vsphere-cloud-controller-manager-ds.yaml
   39  kubectl get pods --namespace=kube-system
   40  tee /etc/kubernetes/csi-vsphere.conf >/dev/null <<EOF
   41  [Global]
   42  cluster-id = "demo-cluster-id"    
   43  [VirtualCenter "192.168.1.3"]
   44  insecure-flag = "true"
   45  user = "administrator@vsphere.local"
   46  password = "Password123!"
   47  port = "443"
   48  datacenters = "Datacenter"
   49  EOF
   50  sudo su
   51  cd /etc/kubernetes/
   52  kubectl create secret generic vsphere-config-secret --from-file=csi-vsphere.conf --namespace=kube-system
   53  kubectl get secret vsphere-config-secret --namespace=kube-system
   54  rm /etc/kubernetes/csi-vsphere.conf
   55  sudo rm  /etc/kubernetes/csi-vsphere.conf
   56  cd ..
   57  kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/1.14/rbac/vsphere-csi-controller-rbac.yaml
   58  sudo wget https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/1.14/deploy/vsphere-csi-controller-ss.yaml
   59  kubectl apply -f vsphere-csi-controller-ss.yaml
   60  sudo wget https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/1.14/deploy/vsphere-csi-node-ds.yaml
   61  kubectl apply -f vsphere-csi-node-ds.yaml
   62  kubectl get statefulset --namespace=kube-system
   63  kubectl describe nodes | grep "ProviderID"
   64  sudo vi global-storageclass.yml
   65  kubectl create -f global-storageclass.yml
   66  sudo vi mongodb-storageclass.yaml
   67  kubectl create -f mongodb-storageclass.yaml
   68  sudo vi mongodb-service.yaml
   69  kubectl create -f mongodb-service.yaml
   70  sudo openssl rand -base64 741 > key.txt
   71  sudo su
   72  kubectl create secret generic shared-bootstrap-data --from-file=internal-auth-mongodb-keyfile=key.txt
   73  sudo vi mongodb-statefulset.yaml
   74  kubectl create -f mongodb-statefulset.yaml
   75  sudo vi mongodb-statefulset.yaml
   76  kubectl create -f mongodb-statefulset.yaml
   77  kubectl get statefulset mongod
   78  kubectl -n kube-system get secret
   79  kubectl -n kube-system describe secret clusterrole-aggregation-controller-token-9grg4
   80  exit
   81  sudo shutdwon
   82  sudo shutdown
   83  kubectl describe nodes | grep "ProviderID"
   84  kubectl describe nodes | egrep "Taints:|Name:"
   85  kubectl get pods --namespace=kube-system
   86  kubectl get secret vsphere-config-secret --namespace=kube-system
