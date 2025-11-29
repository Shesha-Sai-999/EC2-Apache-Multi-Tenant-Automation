#!/bin/bash

# Welcome to the script, i have added commands so that everybody 
# including beginners could understand the script easily

# Take input from user to delete specific student
echo "****** The Below script Delets a specific Student Account ******"
read -p "Enter the User Name: " USER
read -p "Enter the Port Number: " PORT

# Disable Port Configuration and Restart
sudo a2dissite $USER.conf
sudo systemctl reload apache2

# Remove the conf file
sudo rm /etc/apache2/sites-available/$USER.conf

# Remove Port Number from ports.conf
sudo sed -i "/Listen $PORT/d" /etc/apache2/ports.conf

# Delete user and folder
sudo userdel -r $USER

# Update log file
LOG_FILE="/var/log/user_onboarding.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
STATUS="DELETED"
ADMIN_USER=$(whoami)
PORT_STATUS="FREE"
echo "$TIMESTAMP | STATUS:$STATUS | ADMIN:$ADMIN_USER | USER:$USER | PORT:$PORT | PORT_STATUS:$PORT_STATUS | FOLDER: DELETED" | sudo tee -a $LOG_FILE > /dev/null


echo "*/*/*/ USER GOT DELETED SUCCESSFULLY */*/*/"