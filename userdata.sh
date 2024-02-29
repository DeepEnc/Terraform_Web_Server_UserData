#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2
echo "Deploy a web server on aws" | sudo tee /var/www/html/index.html
#bash -c 'Deploy a web server on AWS > /var/www/html/index.html'