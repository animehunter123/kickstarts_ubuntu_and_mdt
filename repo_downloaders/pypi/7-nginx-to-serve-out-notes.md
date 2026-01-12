So now you finished downloading pypi.

You can use a docker nginx, or manually install it on a dedicated nginx host (NOTE WE ALREADY HAVE ORWEBSERVER SO THERE IS NO NEED TO DO THIS ON THE HIGH SIDE!!!!!!!!!!!!! THIS IS JUST FOR REFERENCE WITH HORRIBLE METHODS!!!)

# Install and configure nginx to serve the PyPI mirror
sudo dnf install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx



USE THIS NGINX: /etc/nginx/conf.d/pypi-mirror.conf


# Configure nginx
cat <<EOF | sudo tee /etc/nginx/conf.d/pypi-mirror.conf
server {
    listen 80;
    server_name pypi.yourdomain.com;  # Replace with your domain or IP

    root /mnt/OrioleNAS-Data/repos/pypi-pipdownloaded;

    location / {
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
        index index.html;

        # Ensure URLs end with a trailing slash
        rewrite ^([^.]*[^/])$ $1/ permanent;

        # Correctly serve .whl and .tar.gz files
        location ~* \.(whl|tar\.gz)$ {
            add_header Content-Disposition "attachment";
            default_type application/octet-stream;
        }
    }

    # Serve the PEP 503 simple API
    location /simple/ {
        alias /mnt/OrioleNAS-Data/repos/pypi-pipdownloaded/simple/;
        autoindex on;
        index index.html;

        # Ensure URLs end with a trailing slash
        rewrite ^([^.]*[^/])$ $1/ permanent;
    }
}
EOF

# EXTREMELY HORRIBLE BECAUSE IT ALLOWS ROOOOOOOOOOOOOOOOOOOOOOOTTTTTTTTTTTTTT!!!!!!! BAD!!!!!!!!!
vim /etc/nginx/nginx.conf >> change "user nginx" to "user root"

# Restart nginx to apply changes
sudo systemctl restart nginx


Now, the webserver is up! Lets create a pip.conf for Rocky93 for example to get it ready (and if perfect dont forget to add to all rocky kickstarts)


# At this point its all sitting in 1 big fat folder
# Now use number 5 setup nginx with autoindex on
AND IT SHOULD BE SUPER FAST:
pip install --index-url http://lm-webserver.lm.local/repos/pypi-pipdownloaded/ requests --trusted-host lm-webserver.lm.local
pip install --index-url http://192.168.0.63/simple/ 021 --trusted-host 192.168.0.63
pip install --index-url http://lm-webserver.lm.local/repos/pypi-DOWNLOAD_IN_PROGRESS requests --trusted-host lm-webserver.lm.local       

THESE WORKED 100% (python -m http.server was run from ../simple (the level below with wheels))
pip install --index-url http://localhost:8000/simple  --trusted-host localhost  requests


echo "Finally, here setting up the pip.conf into your ETC NOW"
cat <<EOF | sudo tee /etc/pip.conf
[global]
no-index = false
find-links = http://192.168.0.63/
trusted-host = 192.168.0.63

[install]
no-index = false
find-links = http://192.168.0.63/
trusted-host = 192.168.0.63
EOF


echo "PyPI mirror setup complete. Access it at http://pypi.yourdomain.com"
echo "You can also just manually try a test like this..."
echo 'pip install --index-url http://192.168.2.42:82/nas/ahm/rocky9-pypi/pypi_rocky93/pypi/web/simple/ requests   --trusted-host 192.168.2.42'

