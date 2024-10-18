#!/bin/bash

echo "Installing wget and morgan..."
apt install -y wget python3-pip 2>/dev/null

echo "Starting wget..."
rm -f 1-wget-result.html 2>/dev/null
wget https://pypi.org/simple/

echo "Renaming index.html to... 1-wget-result.html"
mv index.html result_01_wget.html
