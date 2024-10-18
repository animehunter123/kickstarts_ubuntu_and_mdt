#!/bin/bash

pushd .

cd /etc
cat <<EOF > resolv.conf
search lm.local
nameserver 192.168.0.111
nameserver 192.168.0.112
EOF

popd.