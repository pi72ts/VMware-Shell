#!/bin/sh

echo "echo #password" > /tmp/#dirname
chmod 500 /tmp/#dirname
export SSH_ASKPASS=/tmp/#dirname
export DISPLAY=dummy:0
user=user
host=192.168.xxx.xxx
array=("#vm-name1" "#vm-name2" "#vm-name3")

echo start
for var in ${array[@]}
do
        vmid=`exec setsid ssh -l $user $host vim-cmd vmsvc/getallvms | grep $var | awk '{print $1}'`
        ssid=`ssh -l $user $host vim-cmd vmsvc/snapshot.get $vmid | grep Id | awk '{print $4;}' | tail -1`
        state=`ssh -l $user $host vim-cmd vmsvc/get.summary $vmid  | grep powerState | awk -F'"' '{print $2}'`
        if [ $state = "poweredOn" ]; then
                ssh -l $user $host vim-cmd vmsvc/power.off $vmid
                ssh -l $user $host vim-cmd vmsvc/snapshot.revert $vmid $ssid no
                ssh -l $user $host vim-cmd vmsvc/power.on $vmid
        else
                setsid ssh -l $user $host vim-cmd vmsvc/snapshot.revert $vmid $ssid no
                ssh -l $user $host vim-cmd vmsvc/power.on $vmid
        fi
done
unset SSH_ASKPASS
unset DISPLAY
rm /tmp/sshpass
echo end
~