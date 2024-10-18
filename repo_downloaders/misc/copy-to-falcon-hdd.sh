#!/bin/bash

for i in `echo rocky ipxe_backups *list *sh *txt du-sh* mirrored-files *png *url *xlsx vscode-rpm pypi-bandersnatch pypi-morgan  epel apt_yum_config_files minirepo-3.8.6 minirepo-3.10.6 minirepo-downloader nux` ; do cp -rpv $i /volumeUSB1/usbshare1-2/repos ; done
