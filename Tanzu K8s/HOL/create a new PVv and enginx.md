**Voraussetzung:** HOL-0419-01 PowerProtect Data Manager  && Fix non-ANSI US keyboard layouts

Putty auf k8-master@demo.local  
adminuser@Password123!  

Check the environment
    adminuser@k8-master:~$ kubectl cluster-info 
     
    adminuser@k8-master:~$ kubectl get storageclass

	adminuser@k8-master:~$ kubectl describe storageclass mongodb-sc
	Name:                  mongodb-sc
	IsDefaultClass:        Yes
	Annotations:           storageclass.kubernetes.io/is-default-class=true
	Provisioner:           csi.vsphere.vmware.com
	Parameters:            fstype=ext4,storagepolicyname=Space-Efficient
	AllowVolumeExpansion:  <unset>
	MountOptions:          <none>
	ReclaimPolicy:         Delete
	VolumeBindingMode:     Immediate
	Events:                <none>

	adminuser@k8-master:~$ kubectl get pv
	
	adminuser@k8-master:~$ kubectl get pvc
	
	adminuser@k8-master:~$ kubectl describe pv -n=default  
	
**note the pvc ID**
See what you need for a new pvc

    kubectl describe pv pvc-9595a735-7038-11ea-b17e-00505680c6b4
# create a new PV
let’s see what we need

	kubectl get pv pvc-9595a735-7038-11ea-b17e-00505680c6b4 -o yaml  

##create a new one

	adminuser@k8-master:~$tee new-pvc.yaml >/dev/null <<EOF
	apiVersion: v1
	kind: PersistentVolumeClaim
	metadata:
	  name: new-pvc
	spec:
	  storageClassName: mongodb-sc
	  accessModes:
	    - ReadWriteOnce
	  resources:
	    requests:
	      storage: 1Gi
	EOF

apply the yaml file

	adminuser@k8-master:~$ kubectl apply -f new-pvc.yaml
	persistentvolumeclaim/new-pvc created

check what you did  

	adminuser@k8-master:~$ kubectl get pvc
	NAME                                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
	mongodb-persistent-storage-claim-mongod-0   Bound    pvc-9595a735-7038-11ea-b17e-00505680c6b4   1Gi        RWO            mongodb-sc     34d
	new-pvc                                     Bound    pvc-a5769ea4-8b92-11ea-bc80-00505680c6b4   1Gi        RWO            mongodb-sc     2m1s 
	

## mount new-pv into a pod - deployment !
let's find an example we can use

	kubectl get namespaces

have a look at default
and get the pods. Why? we'll see!

	kubectl get pods -n=default
	
Let’s explore a pod and find the mount. mongod-0 is the pod we will look into

special look here for mounts:
      /data/db from mongodb-persistent-storage-claim (rw)  
      
     kubectl describe pod mongod-0 -n=default  

finding: the mount point   
 Mounts:  
      /data/db from mongodb-persistent-storage-claim (rw)  
    
	kubectl describe pod mongod-0 -n=default | grep /data/db

let’s see how it looks like into the pod .. the shell

	kubectl exec -it mongod-0 bash -n=default

	df -h | grep /data/db
	mount | grep /data/db
	
Finding: the pod does describe the mount let’s use this for our new deployement.

	kubectl get pod mongod-0 -n=default -o yaml

## We deploy a webserver - nginx !
let's create a yaml file with nginx and the mount of the the pvc we created above.

	adminuser@k8-master:~$tee nginx-deployment.yaml >/dev/null <<EOF
	apiVersion: apps/v1 
	kind: Deployment 
	metadata:
	  name: nginx
	  namespace: default
	  labels: 
	    app: nginx-demo 
	spec:
	  replicas: 3
	  selector: 
	    matchLabels: 
	      app: nginx 
	  template: 
	    metadata: 
	      labels: 
	        app: nginx 
	    spec: 
	      containers: 
	      - name: nginx 
	        image: nginx:1.7.9 
	        ports: 
	        - containerPort: 80 
	        name: nginx
	        volumeMounts: 
	        - name: nginx-persistent-storage 
	          mountPath: /usr/share/nginx/html
	      volumes: 
	      - name: nginx-persistent-storage 
	        persistentVolumeClaim:
	          claimName: new-pvc 
	EOF

Fire - apply the yaml

	adminuser@k8-master:~$ kubectl deploy -f nginx-deployment.yaml

check

	kubectl get pods -n=default

You do see it more running more than once?

!!! Reduce Replica SET to 1 !!!

	adminuser@k8-master:~$tee nginx-deployment.yaml >/dev/null <<EOF
	apiVersion: apps/v1 
	kind: Deployment 
	metadata:
	  name: nginx
	  namespace: default
	  labels: 
	    app: nginx-demo 
	spec:
	  replicas: 1
	  selector: 
	    matchLabels: 
	      app: nginx 
	  template: 
	    metadata: 
	      labels: 
	        app: nginx 
	    spec: 
	      containers: 
	      - name: nginx 
	        image: nginx:1.7.9 
	        ports: 
	        - containerPort: 80 
	        name: nginx
	        volumeMounts: 
	        - name: nginx-persistent-storage 
	          mountPath: /usr/share/nginx/html
	      volumes: 
	      - name: nginx-persistent-storage 
	        persistentVolumeClaim:
	          claimName: new-pvc 
	EOF

	adminuser@k8-master:~$ kubectl deploy -f nginx-deployment.yaml
	kubectl get pods -n=default

## Let’s create a webpage 
Let's go into the nginx pod  

	adminuser@k8-master:~$ kubectl exec -it nginx-bfbf546c5-9v54l bash
	root@nginx-bfbf546c5-9v54l:/# df -h | grep /usr/share/nginx/html
	Filesystem                     Size  Used Avail Use% Mounted on
	overlay                         97G  4.1G   88G   5% /
	tmpfs                           64M     0   64M   0% /dev
	tmpfs                          3.9G     0  3.9G   0% /sys/fs/cgroup
	/dev/mapper/k8--node--vg-root   97G  4.1G   88G   5% /dev/termination-log
	shm                             64M     0   64M   0% /dev/shm
	/dev/mapper/k8--node--vg-root   97G  4.1G   88G   5% /etc/resolv.conf
	/dev/mapper/k8--node--vg-root   97G  4.1G   88G   5% /etc/hostname
	/dev/mapper/k8--node--vg-root   97G  4.1G   88G   5% /etc/hosts
	/dev/sdc                       976M  2.6M  907M   1% /usr/share/nginx/html
	/dev/mapper/k8--node--vg-root   97G  4.1G   88G   5% /var/cache/nginx
	tmpfs                          3.9G   12K  3.9G   1% /run/secrets/kubernetes.io/serviceaccount
	tmpfs                          3.9G     0  3.9G   0% /proc/acpi
	tmpfs                           64M     0   64M   0% /proc/kcore
	tmpfs                           64M     0   64M   0% /proc/keys
	tmpfs                           64M     0   64M   0% /proc/timer_list
	tmpfs                           64M     0   64M   0% /proc/sched_debug
	tmpfs                          3.9G     0  3.9G   0% /proc/scsi
	tmpfs                          3.9G     0  3.9G   0% /sys/firmware
	root@nginx-bfbf546c5-9v54l:/# cd /usr/share/nginx/html
	root@nginx-bfbf546c5-9v54l:/var/www/defaultl# ls
	lost+found
	
Create the webpage

	root@nginx-bfbf546c5-9v54l:/var/www/default#tee /usr/share/nginx/html/index.html>/dev/null <<EOF
	<html>
	<header><title>This is title</title></header>
	<body>
	Hello world Version 2
	</body>
	</html>
	EOF
leave the pod  

    root@nginx-bfbf546c5-9v54l:/var/www/defaultl#exit
    
### Things to know but not to use here
Where is the nginx config file we need to change ?  
Why ? Because we wanna change the html root directory!  

	adminuser@k8-master:~$ kubectl exec -it nginx-bfbf546c5-9v54l bash
	root@nginx-6d6d8bbb5c-qq4cg:/# cat /etc/nginx/conf.d/default.conf
	root@nginx-6d6d8bbb5c-qq4cg:/# cat /etc/nginx/conf.d/default.conf | grep root
	        root   /usr/share/nginx/html;
	        root   /usr/share/nginx/html;
	    #    root           html;
	    # deny access to .htaccess files, if Apache's document root

    root@nginx-bfbf546c5-9v54l:/var/www/defaultl#exit
      
### restart your nginx instance

	adminuser@k8-master:~$ kubectl exec -it nginx-bfbf546c5-9v54l bash
	root@nginx-bfbf546c5-9v54l:/var/www/defaultl#service nginx reload
	root@nginx-bfbf546c5-9v54l:/var/www/defaultl#exit
	
## Let’s get the webserver up and running
check the pvc  

	adminuser@k8-master:~$ kubectl get pvc
	NAME                                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
	mongodb-persistent-storage-claim-mongod-0   Bound    pvc-9595a735-7038-11ea-b17e-00505680c6b4   1Gi        RWO            mongodb-sc     34d
	new-pvc                                     Bound    pvc-a5769ea4-8b92-11ea-bc80-00505680c6b4   1Gi        RWO            mongodb-sc     57m

... and the deplyoment
	
	adminuser@k8-master:~$ kubectl get deployments
	NAME    READY   UP-TO-DATE   AVAILABLE   AGE
	nginx   1/1     1            1           42m

... and exposed it

	adminuser@k8-master:~$ kubectl expose deployment nginx --port=80 --type=NodePort
	service/nginx exposed

**What port is nginx using**
	
	adminuser@k8-master:~$ kubectl get services
	NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
	kubernetes        ClusterIP   198.168.1.1    <none>        443/TCP        35d
	mongodb-service   ClusterIP   None           <none>        27017/TCP      35d
	nginx             NodePort    198.168.1.41   <none>        80:31936/TCP   158m

**Port: 31936**

On which node is the pod running?
	adminuser@k8-master:~$ kubectl get pods -o wide
	NAME                     READY   STATUS    RESTARTS   AGE     IP            NODE      NOMINATED NODE   READINESS GATES
	mongod-0                 1/1     Running   13         35d     10.244.1.57   k8-node   <none>           <none>
	nginx-6d6d8bbb5c-qq4cg   1/1     Running   0          3h12m   10.244.1.59   k8-node   <none>           <none>

**node: k8-node**

Go to your webbrowser and enter: **http://k8-node:31936**    

Backup with Kubernetes and do not forget to discover the new pvc and pod

# Change the webpage before backup  

	adminuser@k8-master:~$ kubectl exec -it nginx-bfbf546c5-9v54l bash

create the new webpage

    #tee /usr/share/nginx/html/index.html>/dev/null <<EOF
	<html>
	<header><title>This is title</title></header>
	<body>
	Hello world Version 3
	</body>
	</html>
	EOF
    root@nginx-bfbf546c5-9v54l:/var/www/defaultl#exit

