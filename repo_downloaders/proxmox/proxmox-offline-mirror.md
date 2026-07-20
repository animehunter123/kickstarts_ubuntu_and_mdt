## Download Proxmox Community Repo (repo_downloaders method)
* Make a debian12/13 downloader vm, regular install of debian nothing special
* apt install -y ssh nfs-common
* mount the nas manually!!!!!!!
```bash
mkdir /tmp/nas
mount 192.168.0.5:/volume1/OrioleNAS-Data /tmp/nas
mkdir /tmp/nas/repos/proxmox-download-in-progress
```
* add pve-no-subscription-repo to /etc/apt/sources.list: 
```bash
# Proxomox Repositories (trixie = Debian13 but bookworm = Debian12).
deb [trusted=yes] http://download.proxmox.com/debian/pve trixie pve-no-subscription
```
* Update, Install gpg key, install pom: 
```bash
# Run these 3 commands carefully
sudo wget https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg
apt update
apt install -y proxmox-offline-mirror
```
* run this to generate a /etc/proxmox-offline-mirror.cfg file: 
```bash
mv /etc/proxmox-offline-mirror.cfg /etc/proxmox-offline-mirror.cfg.oldddddddddddddddddddd
proxmox-offline-mirror setup
```
```

#######################################################################################
# Here is how I ran mine USING THE MOUNTED NAS AS A FOLDER!!!!! (READ THESE CAREFULLY!)
#######################################################################################
root@ah-debian13 ~# rm -f /etc/proxmox-offline-mirror.cfg
root@ah-debian13 ~# proxmox-offline-mirror setup
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
   0) Trixie
   1) Bookworm
   2) Bullseye
Choice ([0]): 0
Select repository variant
   0) Enterprise repository
   1) No-Subscription repository
   2) Test repository
Choice ([0]): 1
Should missing Debian mirrors for the selected product be auto-added ([yes]):
Configure filters for Debian mirror trixie / main:
        Enter list of package sections to be skipped ('-' for None) ([debug,games]):
        Enter list of package names/name globs to be skipped ('-' for None): -
Configure filters for Debian mirror trixie / updates:
        Enter list of package sections to be skipped ('-' for None) ([debug,games]):
        Enter list of package names/name globs to be skipped ('-' for None): -
Configure filters for Debian mirror trixie / security:
        Enter list of package sections to be skipped ('-' for None) ([debug,games]):
        Enter list of package names/name globs to be skipped ('-' for None): -
Enter mirror ID ([pve_trixie_no-subscription]):
Enter (absolute) base path where mirrored repositories will be stored ([/var/lib/proxmox-offline-mirror/mirrors/]): /tmp/nas/repos/proxmox-download-in-progress/
Should already mirrored files be re-verified when updating the mirror? (io-intensive!) ([yes]): no
Should newly written files be written using FSYNC to ensure crash-consistency? (io-intensive!) ([yes]): no
Config entry 'debian_trixie_main' added
Run "proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'debian_trixie_main'" to create a new mirror snapshot.
Config entry 'debian_trixie_updates' added
Run "proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'debian_trixie_updates'" to create a new mirror snapshot.
Config entry 'debian_trixie_security' added
Run "proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'debian_trixie_security'" to create a new mirror snapshot.
Config entry 'pve_trixie_no-subscription' added
Run "proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'pve_trixie_no-subscription'" to create a new mirror snapshot.

Existing config entries:
mirror 'debian_trixie_main'
mirror 'debian_trixie_security'
mirror 'pve_trixie_no-subscription'
mirror 'debian_trixie_updates'

Select Action:
   0) Add new mirror entry
   1) Add new medium entry
   2) Add new subscription key
   3) Quit
Choice ([0]): 3 >>> OK WE ARE BACK AT THE BASH SHELL.

```
* now we have a nas folder with EMPTY FOLDERS CREATED IN THEM:
```powershell
# ls \\nas.blah.local\Data\repos\proxmox-download-in-progress
  Directory: \\nas.blah.local\Data\repos\proxmox-download-in-progress
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
da----         7/17/2025   2:12 PM                .pool
da----         7/17/2025   2:12 PM                debian_trixie_main   <--- NOTHING IS INSIDE
da----         7/17/2025   2:12 PM                debian_trixie_security   <--- NOTHING IS INSIDE
da----         7/17/2025   2:12 PM                debian_trixie_updates   <--- NOTHING IS INSIDE
da----         7/17/2025   2:12 PM                pve_trixie_no_subscription   <--- NOTHING IS INSIDE
```

* You will notice 4 folders (3 for debian, one for pve, but NO folder yet for ceph-squid-trixie so lets add it now).
```bash
proxmox-offline-mirror config mirror add \
  --id ceph_squid_trixie \
  --architectures amd64 \
  --repository 'deb http://download.proxmox.com/debian/ceph-squid trixie no-subscription' \
  --key-path /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg \
  --sync true \
  --verify false \
  --base-dir /tmp/nas/repos/proxmox-download-in-progress/ceph_squid_trixie
# TODO im not sure but I noticed we needed to mkdir this to work:
mkdir -p /tmp/nas/repos/proxmox-download-in-progress/ceph_squid_trixie/ceph_squid_trixie/.pool ; 
mkdir -p /tmp/nas/repos/proxmox-download-in-progress/ceph_squid_trixie/.pool ; 
```

* now, lets start the sync and run those commands for all 4 syncs. You can use `glances` and should see the Rx/sec to increase from 20-40Mbit, and it should eventually download all of them to the nas. Note: Its good to only run 1 at a time, if not you will get a "Error: Unable to acquire lock ./.local" error.

Thus, I SPLIT THESE BELOW SCRIPT INTO 5 SEPARATE FILES BUT RAN ONE AT A TIME until it actually FINISHED CORRECTLY.
```bash
# MAKE THIS FILE: vim  /tmp/nas/repos/proxmox-download-in-progress/dl-proxmox+debian13+ceph.sh

#!/usr/bin/env bash
set -euo pipefail
mkdir debian_trixie_main 2>/dev/null
mkdir debian_trixie_security 2>/dev/null
mkdir debian_trixie_updates 2>/dev/null
mkdir pve_trixie_no-subscription 2>/dev/null
mkdir ceph_squid_trixie 2>/dev/null

# Download Debian13 repos...
proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'debian_trixie_main'
proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg'  'debian_trixie_security'
proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg'  'debian_trixie_updates'

# Download Proxmox9 repos...
proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'pve_trixie_no-subscription'

# Download Ceph repos...
proxmox-offline-mirror mirror snapshot create --config '/etc/proxmox-offline-mirror.cfg' 'ceph_squid_trixie'

echo "Script complete."
```

* after the sync is done, make sure the folders have completed and are named like below, and resync again if they are not.
```yaml
Check INSIDE Each of the 4 folders, for example /repos/proxmox-download-in-progress/pve_trixie_no_subscription/

If the download completed, it wont have .tmp in the name!!!
OK: 2025-07-17T05:18:50Z/      
NOT OK: 2025-07-17T05:19:24Z.tmp/  
```



* Finally you can make a proxmox repo file to your nas, like this:
```bash
# /etc/apt/sources.list >> Modify these to point to the new final location, FOR EXAMPLE I DID:
# Orig
#deb http://ftp.jp.debian.org/debian trixie main contrib
#deb http://ftp.jp.debian.org/debian trixie-updates main contrib
#deb http://security.debian.org trixie-security main contrib
#deb http://download.proxmox.com/debian/pve trixie pve-no-subscription

# New (lm-nas)
deb [trusted=yes] http://lm-webserver.lm.local/repos/proxmox-download-in-progress/debian_trixie_main/2026-07-19T05%3A18%3A50Z/ trixie main contrib
deb [trusted=yes] http://lm-webserver.lm.local/repos/proxmox-download-in-progress/debian_trixie_updates/2026-07-16T05%3A19%3A02Z/ trixie-updates main contrib
deb [trusted=yes] http://lm-webserver.lm.local/repos/proxmox-download-in-progress/debian_trixie_security/2026-07-16T01%3A38%3A00Z/ trixie-security main contrib
deb [trusted=yes] http://lm-webserver.lm.local/repos/proxmox-download-in-progress/pve_trixie_no_subscription/2026-07-16T23%3A10%3A51Z/ trixie pve-no-subscription
deb [trusted=yes] http://lm-webserver.lm.local/repos/proxmox-download-in-progress/ceph-squid-trixie trixie no-subscription #.... something for ceph!!!!!!!!!!!!!!!!!!!!!!!!!!

``` 

### Example #1: Upgrading PVE from 8.4.0 to 8.4.1 (while already being joined to cluster!!!)
### With the workaround for hanging install at "Setting up pve-manager (8.4.1) ..."
apt update ; 
### Start pmxcfs in local mode (disables cluster):
systemctl stop pve-cluster
systemctl stop corosync
pmxcfs -l
apt-get dist-upgrade -y ; reboot # Updates from `pveversion` of 8.4.0 to 8.4.1

### Example #2: Installing proxmox-ve on standalone debian
apt-get install proxmox-ve  
### Example #3: Installing pom proxmox downloader for offline mirror'ing
apt install -y proxmox-offline-mirror 
```

* Thats it! You downloaded a Repo to the nas!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* Bobl also reccomended reading this strictly before doing in-place-upgrades >> https://pve.proxmox.com/wiki/Upgrade_from_8_to_9



