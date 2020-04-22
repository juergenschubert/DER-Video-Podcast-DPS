     # ip a  
[How to disable IPv6 address on Ubuntu 18.04 Bionic Beaver Linux](https://linuxconfig.org/how-to-disable-ipv6-address-on-ubuntu-18-04-bionic-beaver-linux)

Make sure DNS is working !!!

    # ping quay.io 
is working !
If not !  

    sudo apt install resolvconf
    sudo nano /etc/resolvconf/resolv.conf.d/head

add the following lines to add the DNS Server

    # Make edits to /etc/resolvconf/resolv.conf.d/head.
    nameserver 8.8.4.4
    nameserver 8.8.8.8 
    nameserver 192.168.1.1
    
    sudo service resolvconf restart
    
     sudo nano /etc/resolv.conf
----
Disable ipv6

     ip a
 
 see if you find kind like

    inet6 fe80::250:56ff:fe83:bb8a/64 scope link
    valid_lft forever preferred_lft forever

disable this with:

    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

The above IPv6 disable settings would not persist after the reboot. The usual way on how to load the above settings is to edit the /etc/sysctl.conf configuration file by adding the following lines:

    net.ipv6.conf.all.disable_ipv6=1
    net.ipv6.conf.default.disable_ipv6=117snoopy
    
 

    # sudo nano /etc/netplan/50-cloud-init.yaml

add the follwowing addresses for DNS:

    # This file is generated from information provided by the datasource.  Changes
    # to it will not persist across an instance reboot.  To disable cloud-init's
    # network configuration capabilities, write a file
    # /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
    # network: {config: disabled}
    network:
        ethernets:
            ens160:
                addresses:
                - 192.168.1.156/24
                gateway4: 192.168.1.1
                nameservers:
                    addresses:
                    - 192.168.1.1
                    - 8.8.8.8
                    - 8.8.4.4
                search:
                    - vlab.local
        version: 2

And than apply this setting with

    sudo netplan generate
    sudo netplan apply

