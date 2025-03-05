# Before you begin
* Make sure to use a expendable VM for this process, as it will be ruined afterwards. Ensure lots of CPU/MEM for the VM.
* Before running script number 3 as root you need run a cronjob to remove this folder, so: 
```bash
crontab -e
```
* And, make a entry like this:
```bash
# Force Pip Cleanup to ensure that your hard drive doesnt fill up
*/30 * * * * rm -rf /root/.cache/pip/*
# Force a cleanup so that the /tmp filesystem doesnt fill up:
* * * * * rm -rf /tmp/pip*
```

