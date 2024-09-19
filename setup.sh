ln -s /var/cache/kvm/masters ~
# Home directory setup
mkdir ~/vm
ln -s ~/masters/scripts ~/vm/

mkdir ~/exam
cat > ~/exam/switch.yaml << EOF
ovs:
  switches:
    - name: SWITCH_NAME
      ports:
        - name: tapXXX
          type: OVSPort
          vlan_mode: access
          tag: VLAN_ID_X
        - name: tapYYY
          type: OVSPort
          vlan_mode: access
          tag: VLAN_ID_Y
        - name: tapZZZ
          type: OVSPort
          vlan_mode: trunk
          trunks: [VLAN_ID_X, VLAN_ID_Y]
EOF

cd ~/exam

$HOME/masters/scripts/switch-conf.py switch.yaml

cat > ~/exam/lab.yaml << EOF
kvm:
  vms:
    - vm_name: server
      master_image: debian-VERSION-amd64.qcow2 # master image to be used
      force_copy: true/false # force copy the master image to the VM image
      memory: 2048 # memory in MB
      tapnum: <tap interface number>
      devices:
        storage:
          - dev_name: second_disk.qcow2 # device name
            type: disk
            size: 32G # size of the disk
            bus: <scsi|virtio|nvme> # bus type
    - vm_name: client
      master_image: debian-VERSION-amd64.qcow2 # master image to be used
      force_copy: true/false # force copy the master image to the VM image
      memory: 2048 # memory in MB
      tapnum: <tap interface number>
EOF

$HOME/masters/scripts/lab-startup.py lab.yaml

cat > ~/exam/exam.yaml << EOF
network:
  version: 2
  ethernets:
    enp0s1:
      dhcp4: false
      dhcp6: false
      accept-ra: true
      addresses:
        - XXX.XXX.XXX.XXX/MM
        - 2001:678:3fc:VVVV::YYYY/64
      routes:
        - to: default
          via: XXX.XXX.XXX.G
        - to: "::/0"
          via: "fe80::VVVV:1"
          on-link: true
      nameservers:
        addresses:
          - 172.16.0.2
          - 2001:678:3fc:3::2
EOF