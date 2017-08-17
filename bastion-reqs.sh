#!/bin/bash

BLACKLIST="/dev/vda|/dev/sda"
DEV=($(sudo ls -1 /dev/vd*|egrep -v "${BLACKLIST}"|egrep -v "[0-9]$"))
sudo mkdir /managed-k8s
echo "n
p
1


w
"| sudo fdisk "${DEV}" > /dev/null 2>&1

MOUNTPOINT=/managed-k8s
PARTITION=$(sudo fdisk -l ${DEV}|grep -A 1 Device|tail -n 1|awk '{print $1}')
        echo "Creating filesystem on ${PARTITION}."
        sudo mkfs -F -j -t ext4 ${PARTITION}
        sudo mount ${PARTITION} ${MOUNTPOIN}

    read UUID FS_TYPE < <(sudo blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3" "$5}'|tr -d "\"")

add_to_fstab() {
    UUID=${1}
    MOUNTPOINT=${2}
    grep "${UUID}" /etc/fstab >/dev/null 2>&1
    if [ ${?} -eq 0 ];
    then
        echo "${UUID} already exists"
    else
        LINE="UUID=\"${UUID}\"\t${MOUNTPOINT}\text4\tnoatime,nodiratime,nodev,noexec,nosuid\t1 2"
        sudo echo -e "${LINE}" >> /etc/fstab
    fi
}

    add_to_fstab "${UUID}" "${MOUNTPOINT}"
    echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}"
    sudo mount "${MOUNTPOINT}"

# Installing pre-reqs
# Docker
sudo apt update && apt install -y docker.io
sudo usermod -aG docker ubuntu
