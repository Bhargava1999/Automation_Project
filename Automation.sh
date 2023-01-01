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

# Check inventory.html exists in the "/var/www/html folder", if it is not found creates inventory file

cd /var/www/html
inventory_file="inventory.html"

if test -f "$inventory_file"; then
    echo "$inventory_file exist"
else
touch "$inventory_file"
    if [ -s "$inventory_file" ]; then
        echo "========================================="
        echo "Headers already present"
        echo "========================================="
    else
        # Adding headers for the inventory file
        echo "Adding Headers : "
        echo "======================================================================="
        echo "Log Type	Time Created	Type	Size" > "$inventory_file"
        echo "======================================================================="
    fi
fi

cd /tmp/ # Creation of Entry in inventory file
# Get the tar files by Date created from the tmp folder after each run of the script

column_2=`ls -lrth /tmp | tail -1 | awk -F ' ' '{print $9}' | cut -d '-' -f 4,5 | cut -f1 -d '.'`
# Get the size from tmp folder of all the tar files

column_4=`ls -lrth /tmp | tail -1 | awk -F ' ' '{print $5}'`

file_path="/var/www/html"
file_name="inventory.html"
echo "================================================================="
echo "httpd-logs $column_2 tar $column_4" >> $file_path/$file_name
echo "================================================================="

# Crontab for scheduling jobs

if (( $(crontab -l | grep "automation" | wc -l) >0 ))
then
echo "======================================="
echo "Cron has already setup in the System."
echo "======================================="
else
echo "Setting cronjob for every day"
echo "====================================================================================="
cat <(crontab -l) <(echo "55 23 * * * /root/Automation_Project/automation.sh") | crontab -
echo "====================================================================================="
fi
echo "Thankyou !!! Execution Completed"
