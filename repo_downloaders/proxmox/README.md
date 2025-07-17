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
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
# security updates
deb http://security.debian.org/debian-security bookworm-security main contrib
```

We can also use the ```apt install proxmox-auto-install-assistant``` to create ISO or boot images with a TOML file to specify any additional capabilities we need. (We plan to ask to buy the enterprise version very soon!)

