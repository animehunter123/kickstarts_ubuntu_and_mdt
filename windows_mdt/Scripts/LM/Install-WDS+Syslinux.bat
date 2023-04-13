DEFAULT menu.c32

MENU TITLE WDS PXE Server (Some options take 5 min to load!!!)
 menu color screen	37;40      #80ffffff #00000000 std
 menu color border	30;31      #40000000 #00000000 std
 menu color title	1;36;44      #c00090f0 #00000000 std
 menu color unsel	37;44        #90ffffff #00000000 std
 menu color hotkey	1;37;44    #ffffffff #00000000 std
 menu color sel  	7;37;40      #e0000000 #20ff8000 all
 menu color hotsel	1;7;37;40  #e0400000 #20ff8000 all
 menu color disabled	1;30;44  #60cccccc #00000000 std
 menu color scrollbar	30;44    #40000000 #00000000 std
 menu color tabmsg	31;40      #90ffff00 #00000000 std
 menu color cmdmark	1;36;40    #c000ffff #00000000 std
 menu color cmdline	37;40      #c0ffffff #00000000 std
 menu color pwdborder	30;47    #80ffffff #20ffffff std
 menu color pwdheader	31;47    #80ff8080 #20ffffff std
 menu color pwdentry	30;47    #80ffffff #20ffffff std
 menu color timeout_msg	37;40  #80ffffff #00000000 std
 menu color timeout	1;37;40    #c0ffffff #00000000 std
 menu color help 	37;40        #c0ffffff #00000000 std
 menu color msg07	37;40        #90ffffff #00000000 std 

LABEL mdt
  MENU DEFAULT
  MENU LABEL ^MDT (REMEMBER TO PRESS F12!)
  KERNEL pxeboot.0

LABEL livecd-linux-kubuntu2004
  MENU LABEL Linux (^Kubuntu 20.04)
  KERNEL /lm_iso/lm_20-04-Kubuntu/casper/vmlinuz
  INITRD /lm_iso/lm_20-04-Kubuntu/casper/initrd
  APPEND toram root=/dev/nfs boot=casper ip=dhcp netboot=nfs nfsroot=192.168.0.215:/lm_iso/lm_20-04-Kubuntu/
  splash

LABEL livecd-linux-fedora32
  MENU LABEL Linux (^Fedora 32 KDE; Require >=4GB RAM)
  KERNEL /lm_iso/lm_Fedora-32-KDE/isolinux/vmlinuz
  INITRD /lm_iso/lm_Fedora-32-KDE/isolinux/initrd.img
  APPEND nfsrootdebug selinux=0 rd.live.image root=/dev/nfs  ip=dhcp root=live:http://lm-nas.lm.local:8083/Fedora/Fedora-KDE-Live-x86_64-32-1.6.iso

LABEL Linux (^Boot Repair ISO)
  KERNEL /lm_iso/lm_boot-repair-disk/casper/vmlinuz.efi
  INITRD /lm_iso/lm_boot-repair-disk/casper/initrd.lz
  APPEND toram root=/dev/nfs boot=casper ip=dhcp netboot=nfs nfsroot=192.168.0.215:/lm_iso/lm_boot-repair-disk/
  splash

LABEL Spacewalk
MENU LABEL ^Spacewalk
COM32 pxechn.c32
APPEND 192.168.0.138::pxelinux.0

LABEL Acronis
MENU LABEL ^Acronis
LINUX memdisk
INITRD /lm_iso/AcronisBackup_12.5_Boot_media.iso
APPEND iso

LABEL Ghost
MENU LABEL ^Ghost
LINUX memdisk
INITRD /lm_iso/Norton_GhostBootCd.iso
APPEND iso raw

LABEL ESX55
MENU LABEL ESXi ^5.5
LINUX memdisk
INITRD /lm_iso/VMware-VMvisor-Installer-5.5.0.update03-3029944.x86_64-Dell_Customized-A00.iso
APPEND iso

LABEL ESX67
MENU LABEL ESXi ^6.7
LINUX memdisk
INITRD /lm_iso/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64_M16AL-6U296-38280-0R184-1X34L.iso
APPEND iso

LABEL abort
  MENU LABEL ^Abort PXE
  Kernel abortpxe.0

LABEL local
  MENU LABEL Boot from ^Local Computer
  LOCALBOOT 0




#LABEL linuxlivecd
#  MENU LABEL ^Linux Live CD 
#  KERNEL /lm_iso/lm_19-3/vmlinuz
#  INITRD /lm_iso/lm_19-3/initrd.lz
#SPACEWALK:  APPEND root=/dev/nfs boot=casper netboot=nfs nfsroot=192.168.0.141:/var/nfs/lm_19-3/
#LM-NAS  APPEND root=/dev/nfs boot=casper netboot=nfs nfsroot=192.168.0.5:/volume1/INSERT_YOUR_NASNFSSHARE_HERE/temp/TEST_DELETEME_/lm_19-3/
#  APPEND toram root=/dev/nfs boot=casper netboot=nfs nfsroot=192.168.0.215:/lm_iso/lm_19-3/
#  splash

##LABEL linuxlivecd3
##  MENU LABEL ^Linux Live CD (Fedora 32 KDE)
##  KERNEL /lm_iso/lm_Fedora-32-KDE/isolinux/vmlinuz
##  INITRD /lm_iso/lm_Fedora-32-KDE/isolinux/initrd.img
##  APPEND nfsrootdebug selinux=0 rd.live.image root=/dev/nfs  ip=dhcp root=live:http://lm-nas.lm.local:8082/kubuntu-20.04-desktop-amd64.iso
##  APPEND nfsrootdebug selinux=0 rd.live.image root=/dev/nfs  ip=dhcp root=live:http://lm-nas.lm.local:8082/Fedora-KDE-Live-x86_64-32-1.6.iso

#got it working via http via;   https://bugzilla.redhat.com/show_bug.cgi?id=1154670
##  APPEND nfsrootdebug selinux=0 rd.live.image root=/dev/nfs  ip=dhcp nfsroot=192.168.0.215:/lm_iso/lm_Fedora-32-KDE/LiveOS/squashfs.img
##  APPEND selinux=0  inst.selinux=0 root=/dev/nfs boot=casper netboot=nfs nfsroot=192.168.0.215:/lm_iso/lm_Fedora-32-KDE/LiveOS/ nosplash nfsrootdebug  --  
##  APPEND root=/dev/nfs boot=casper netboot=nfs nfsroot=live:nfs:,nfsvers=3:192.168.0.215:/lm_iso/lm_Fedora-32-KDE/LiveOS/ nosplash nfsrootdebug selinux=0  inst.selinux=0 --  

#FROM: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/chap-anaconda-boot-options
#APPEND boot=casper netboot=nfs root=live:nfs://192.168.0.215:/lm_iso/lm_Fedora-32-KDE/LiveOS/squashfs.img ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 vga=794 -- vconsole.font=latarcyrheb-sun16 
#LINUX memdisk
#INITRD /lm_iso/Fedora-KDE-Live-x86_64-32-1.6.img
#APPEND iso  

#http://lm-nas.lm.local:8082/Chocolatey-Repo/software/packages/microsoft-windows-terminal/CascadiaPackage_1.0.1401.0_x64.msix.zip'
#kernel tftp://${fog-ip}/os/fedora/W27/vmlinuz
#initrd tftp://${fog-ip}/os/fedora/W27/initrd.img
#imgargs vmlinuz initrd=initrd.img root=live:nfs://${fog-ip}/images/os/fedora/W27/LiveOS/squashfs.img ip=dhcp repo=nfs://${fog-ip}/images/os/fedora/W27 splash quiet
