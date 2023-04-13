#!/bin/bash

yum groupinstall -y "MATE"

systemctl set-default graphical.target