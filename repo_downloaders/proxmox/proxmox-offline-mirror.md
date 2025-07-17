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
* now, lets start the sync and run those commands for all 4 syncs. You can use `glances` and should see the Rx/sec to increase from 20-40Mbit, and it should eventually download all of them to the nas. Note: Its good to only run 1 at a time, if not you will get a "Error: Unable to acquire lock ./.local" error.
* after the sync is done, make sure the folders have completed and are named like below, and resync again if they are not.
```yaml
Check INSIDE Each of the 4 folders, for example /repos/proxmox-download-in-progress/pve_bookworm_no_subscription/

If the download completed, it wont have .tmp in the name!!!
OK: 2025-07-17T05:18:50Z/      
NOT OK: 2025-07-17T05:19:24Z.tmp/  
```
* Finally you can make a proxmox repo file to your nas, like this:
```bash
# Modify these to point to the new final location, FOR EXAMPLE I DID:
# Orig
#deb http://ftp.jp.debian.org/debian bookworm main contrib
#deb http://ftp.jp.debian.org/debian bookworm-updates main contrib
#deb http://security.debian.org bookworm-security main contrib
#deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

# New (lm-nas)
deb http://lm-webserver.lm.local/repos/proxmox-download-in-progress/debian_bookworm_main/2025-07-17T05%3A18%3A50Z/ bookworm main contrib
deb http://lm-webserver.lm.local/repos/proxmox-download-in-progress/debian_bookworm_updates/2025-07-17T05%3A19%3A02Z/ bookworm-updates main contrib
deb http://lm-webserver.lm.local/repos/proxmox-download-in-progress/debian_bookworm_security/2025-07-17T05%3A19%3A24Z.tmp/ bookworm-security main contrib
deb http://lm-webserver.lm.local/repos/proxmox-download-in-progress/pve_bookworm_no_subscription/2025-07-17T05%3A19%3A39Z.tmp/ bookworm pve-no-subscription

``` 
* at this point you are done! You can make another fresh debian12 or proxmox server, and point apt sources to this nas repo and do things like:
```bash
apt-get install proxmox-ve  # <-- for a proxmox server
apt install -y proxmox-offline-mirror # <-- for proxmox downloader
```
* Thats it! You downloaded a Repo to the nas!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!







