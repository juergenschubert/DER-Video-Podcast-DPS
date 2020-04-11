# Tanzu Kubernetes Space

wir wollen hier ein K8s Cluster aufbauen, welches mit vSphere Tanzu diese FCD disken benutzt und als Kubernetes ein PVC hat.  
Ziel ist es das k8s Clusten nach Aubau, dann mit DELL PowerProtect zu sichern

## Voraussetzunge von VMware     
Wir brauchen ein 6.7 U3 vSphere um dann 2 Ubuntu Server, k8s.master1 und k8s.slave1 mit k8s zu versehen

## Step 1
get vSphere 6.7 U3 running (check Hardware 15) die wir brauchen um die Ubuntu Server zu verwenden

## Step 2
Install 2 Ubuntu 18.04.4 LTS (Bionic Beaver)  
Download des iso unter http://releases.ubuntu.com/18.04.4/  
Feste IP Adresse und hostname im DNS  

- Hardware 15 für die VMs, CBT und more auf beide Ubuntus anwenden. Mehr findet ihr in
VMWare FCD uuid and CBT enable.pdf.  Diese Änderungen und Hardware Versionen brauchen wir und die FCD zu verwenden und dann auch einen PVC anlegen zu können .... 
