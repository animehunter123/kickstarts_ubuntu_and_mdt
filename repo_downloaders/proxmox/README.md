# Description of this repo_downloader script and purpose
This is just a wget2 script to download the proxmox repository. I plan to use this to upgrade from 8.4.0 to 8.4.1 for the lab.

Additionally, below are notes of how we can integrate the official documentation for using the repository along with a tool and TOML file eventually to pxe boot a proper proxmox server and match the install team's configuration and guidance (JB etc).

Important: The final restore procedure to build a proxmox would be:
1. Install Proxmox from the ISO (USB Stick or F12 to ISO), **NOT A DEBIAN KICKSTART!**
2. After the install, add our offline proxmox repo to /etc/apt/sources.list
3. Run apt update ; apt dist-upgrade -y #Which would update to 8.4.1

Optional: We can also get the debian 12 repositories too if we want (vim, nfs-common, etc), but it's not necessary. Notice how I dont see a need to do a debian 12 kickstart at this time since we will just use the ISO as the installer just like we used ESX in the past.
Optional: We dont have access to proxmox ceph repo or enterprise, so some tools outside of the community repo are not available.

# Proxmox Repository Information from docs, and our plan/ideas
The proxmox documentation provides a upgrade repository with official support:

https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo

Per the documentation, it stated:

```bash
# Proxmox VE No-Subscription Repository #
# As the name suggests, you do not need a subscription key to access this repository. It can be used for testing and non-production use. It’s not recommended to use this on production servers, as these packages are not always as heavily tested and validated.
# We recommend to configure this repository in /etc/apt/sources.list.

# File /etc/apt/sources.list
deb http://ftp.debian.org/debian bookworm main contrib
deb http://ftp.debian.org/debian bookworm-updates main contrib
# Proxmox VE pve-no-subscription repository provided by proxmox.com (WE PLAN TO wget2 THIS URL to upgrade from 8.4.0 to 8.4.1!!!)
# deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
deb [trusted=yes] http://download.proxmox.com/debian/pve bookworm pve-no-subscription
# security updates
deb http://security.debian.org/debian-security bookworm-security main contrib
```

We can also use the ```apt install proxmox-auto-install-assistant``` to create ISO or boot images with a TOML file to specify any additional capabilities we need. (We plan to ask to buy the enterprise version very soon!)

