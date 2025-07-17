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



## Download Proxmox Community Repo (repo_downloaders method)
* Make a debian12 downloader vm, regular install of debian nothing special
* apt install -y ssh nfs-common
* mount the nas and make a folder to save everything in. i.e 
```bash
mount nas01:/data /tmp/nas/
mkdir /tmp/nas/repos/proxmox-download-in-progress
```
* add pve-no-subscription-repo to /etc/apt/sources.list ```deb [trusted=yes] http://download.proxmox.com/debian/pve bookworm pve-no-subscription```
* install the gpg key: ```sudo wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg```
* apt update so that PVE is now working and ready
* apt install -y proxmox-offline-mirror
* run this to generate a /etc/proxmox-offline-mirror.cfg file: ```proxmox-offline-mirror setup```
```
Here is how I ran mine USING THE MOUNTED NAS AS A FOLDER!!!!!:
# proxmox-offline-mirror setup
Initializing new config.
Select Action:
   0) Add new mirror entry
   1) Add new subscription key
   2) Quit
Choice ([0]): 0
Guided Setup ([yes]):
Select distro to mirror
   0) Proxmox VE
   1) Proxmox Backup Server
   2) Proxmox Mail Gateway
   3) Proxmox Ceph
   4) Debian
Choice: 0
Select release
   0) Bookworm
   1) Bullseye
   2) Buster
Choice ([0]): 0
Select repository variant
   0) Enterprise repository
   1) No-Subscription repository
   2) Test repository
Choice ([0]): 1
Should missing Debian mirrors for the selected product be auto-added ([yes]):
Configure filters for Debian mirror bookworm / main:
        Enter list of package sections to be skipped ('-' for None) ([debug,games]):
        Enter list of package names/name globs to be skipped ('-' for None): -
Configure filters for Debian mirror bookworm / updates:
        Enter list of package sections to be skipped ('-' for None) ([debug,games]):
        Enter list of package names/name globs to be skipped ('-' for None): -
Configure filters for Debian mirror bookworm / security:
        Enter list of package sections to be skipped ('-' for None) ([debug,games]):
        Enter list of package names/name globs to be skipped ('-' for None): -
Enter mirror ID ([pve_bookworm_no_subscription]):
Enter (absolute) base path where mirrored repositories will be stored ([/var/lib/proxmox-offline-mirror/mirrors/]): /tmp/nas/repos/proxmox-download-in-progress/
Should already mirrored files be re-verified when updating the mirror? (io-intensive!) ([yes]): no
Should newly written files be written using FSYNC to ensure crash-consistency? (io-intensive!) ([yes]): no
Config entry 'debian_bookworm_main' added
Run "proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'debian_bookworm_main'" to create a new mirror snapshot.
Config entry 'debian_bookworm_updates' added
Run "proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'debian_bookworm_updates'" to create a new mirror snapshot.
Config entry 'debian_bookworm_security' added
Run "proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'debian_bookworm_security'" to create a new mirror snapshot.
Config entry 'pve_bookworm_no_subscription' added
Run "proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'pve_bookworm_no_subscription'" to create a new mirror snapshot.
Existing config entries:
mirror 'debian_bookworm_updates'
mirror 'pve_bookworm_no_subscription'
mirror 'debian_bookworm_main'
mirror 'debian_bookworm_security'
```
* now we have a nas folder with stuff in it:
```powershell
# ls \\nas.blah.local\Data\repos\proxmox-download-in-progress
  Directory: \\nas.blah.local\Data\repos\proxmox-download-in-progress
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
da----         7/17/2025   2:12 PM                .pool
da----         7/17/2025   2:12 PM                debian_bookworm_main
da----         7/17/2025   2:12 PM                debian_bookworm_security
da----         7/17/2025   2:12 PM                debian_bookworm_updates
da----         7/17/2025   2:12 PM                pve_bookworm_no_subscription
```
* now, lets start the sync and run those commands for all 4 syncs. You can use `glances` and should see the Rx/sec to increase from 20-40Mbit, and it should eventually download all of them to the nas
* Finally you can make a proxmox repo file to your nas, like this:
```bash
# Modify these to point to the new final location
deb http://ftp.jp.debian.org/debian bookworm main contrib
deb http://ftp.jp.debian.org/debian bookworm-updates main contrib
deb http://security.debian.org bookworm-security main contrib
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
# I.e. http://ftp.jp.debian.org/debian => http://lm-webserver.lm.local/repos/proxmox-download-in-progress/debian_bookworm_main/dists/bookworm/ and so forth for each of the 4 folders on the nas!
``` 
* at this point you are done! You can make another fresh debian12 or proxmox server, and point apt sources to this nas repo and do things like:
```bash
apt-get install proxmox-ve  # <-- for a proxmox server
apt install -y proxmox-offline-mirror # <-- for proxmox downloader
```
* Thats it! You downloaded a Repo to the nas!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!









## Ghetto download method, do not use this anymore it is the old way
```bash
pushd .
cd ../../proxmox/
mkdir -p download.proxmox.com/debian/pve/dists 2>/dev/null 1>/dev/null
mkdir -p download.proxmox.com/debian/pve/dists/bookworm 2>/dev/null 1>/dev/null
wget2 -r -c --max-threads=8 -e robots=off --no-parent 'http://download.proxmox.com/debian/pve/dists/bookworm/' # Dont forget the trailing slash
chmod -R 777 *
popd
```