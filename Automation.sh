#!/bin/bash

# Download's package information from all configured sources
sudo apt update -y

# Installing aws cli in ubuntu
sudo apt install awscli

# Created a S3 Bucket "upgrad-bhargvateja"
s3_bucket="upgrad-bhargavateja"
name="bhargava"
timestamp=$(date '+%d%m%Y-%H%M%S')

# Below For Loop Install's the apache package if it is already not installed
for package in apache2; do
    dpkg -s "$package" >/dev/null 2>&1 && {
        echo "========================================="
        echo "$package Found, It is already installed."
        echo "========================================="
    } || {
        sudo apt-get install $package
    }
done

# Below Script is used for checking whether apache service is running if not apache service is started
process=apache
if (( $(ps -ef | grep -v grep | grep $process | wc -l) > 0 ))
then
echo "========================================="
echo "$process is Running"
echo "========================================="
else
systemctl start apache2
echo "========================================="
echo "$process has Started Successfully"
echo "========================================="
fi

# Creating Tar File and Copying these files into tmp Folder
cd /var/log/apache2
tar cvf $name-httpd-logs-$timestamp.tar *.log
cp *.tar /tmp/

# Copy the tar files to the S3 Bucket
aws s3 \
cp /tmp/${name}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
