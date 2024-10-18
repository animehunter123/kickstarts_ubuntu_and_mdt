# Homelab scripts for Kicking Linux and Windows...

![image](https://user-images.githubusercontent.com/42163211/231925197-c375244d-22a0-4db5-a40d-c4bbd388e13c.png)

Repository URL is: https://github.com/animehunter123/kickstarts_ubuntu_and_mdt

This repository contains all of the repository code for creating a iPXE menu which chain loads to a MDT/Ubuntu/CentOS kickstart. You may still need ISO files such as CentOS7/Ubuntu2204/Win10/WinSvr2022/Exchange/Lync. It is only a repository of code at this point, and I will need to document in more detail later.

All important fields need to be replaced after cloning this repo. Search and replace the several fields that begin with ```INSERT_YOUR_xxxxxxxxxx_HERE```. You will also need a nfs share (synology or truenas), and fully share the data via NFS/HTTP/TFTP appropriately for your environment. Lot of work required for this.

## repos_downloaders
* These are shell scripts and configs to sync from the internet into this local directory.

1. ubuntu apt rocky...
2. rhel/fedora epel...
3. others...

## ipxe
* boot-images: Has the unzipped server iso files for any iso's you have (1. ubuntu server standard iso, and 2. a special cubic live custom kubuntu iso we created which isnt required for kickstarts but rather recovery)
* ipxe: the required stage 1 binaries used in pxe boot (BCD+boot.sdi <-- used to chainload MDT; ipxe.efi+undionly.kpxe <--- we compiled these ipxe binaries from scratch per developer docs)
* kickstart: (cloud-init <-- the Ubuntu Kickstarts, ks+pre-scripts+post-scripts <--- the CentOS Kickstarts)
* menu_backup20230407.ipxe <-- a menu file sample that you can look at. Shows all the submenus you can dig through for building a ipxe menu for mdt/centos/ubuntu and even live cds like vmware/vyos/ghost/acronis.
* dhcp-gui-photos: A picture of everything you need to set up in your pxe server to get the low side kickstarts going first!

## windows_mdt
* wiki_instructions.wt - Contains Wiki Notes on the entire process for building a MDT server from scratch on the low side. (Use the VSCode addon to read with ease: RoweWilsonFrederiskHolme.wikitext)

* Scripts folder (has a subfolder called LM, this is what you paste into your C:\MDTBuildLab or similar folder's Scripts folder. There is also a custom modification to DeployWiz, ZTIUtility, and ZTI-Chocolatey-Wrapper, use `diff` on the latest versions supplied from Microsoft before merging)

