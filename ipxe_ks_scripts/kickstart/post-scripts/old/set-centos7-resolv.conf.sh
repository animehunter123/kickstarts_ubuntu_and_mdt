#!/bin/bash

pushd .

cd /etc
cat <<EOF > resolv.conf
search YOURDOMAIN.COM
nameserver 172.16.0.111
nameserver 172.16.0.112
EOF

popd.