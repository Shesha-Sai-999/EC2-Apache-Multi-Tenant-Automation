#!/bin/bash

# Welcome to the script, i have added commands so that everybody 
# including beginners could understand the script easily
 

# Get input details from user

read -p "Enter new username: " NEW_USER
read -s -p "Enter passward: " PASSWD
echo "" # for new line
read -p "Enter the Port number (eg: 8082):" PORT

sudo useradd -m -d /var/www/$NEW_USER -s /bin/bash $NEW_USER # creates user without explicitly asking for passwd

echo "$NEW_USER:$PASSWD" | sudo chpasswd # passwd is not written in output

sudo chmod 755 /var/www/$NEW_USER # change user permissions

sudo echo "<h1>Welcome to $NEW_USER's page</h1>" | sudo tee /var/www/$NEW_USER/index.html # sample page for testing

ADDED=0

while [ $ADDED -eq 0 ]; do # loop to continuely ask for correct unused port

if ! grep -q "Listen $PORT" /etc/apache2/ports.conf; then
   echo "Listen $PORT" | sudo tee -a /etc/apache2/ports.conf
   echo "PORT: $PORT added to conf"
   ADDED=1
else
   echo "Port: $PORT is already in use"
   read -p "Enter the another Port number (eg: 8082):" PORT
fi

done

# Establish the connection between port and user directory
sudo tee /etc/apache2/sites-available/$NEW_USER.conf > /dev/null <<EOF
<VirtualHost *:$PORT>
    DocumentRoot /var/www/$NEW_USER
    <Directory /var/www/$NEW_USER>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Enable port configuration and restart the apache
sudo a2ensite $NEW_USER.conf
sudo systemctl reload apache2

# Update the log file
LOG_FILE="/var/log/user_onboarding.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
STATUS="CREATED"
ADMIN_USER=$(whoami)
PORT_STATUS="INUSE"
echo "$TIMESTAMP | STATUS:$STATUS | ADMIN:$ADMIN_USER | USER:$NEW_USER | PORT:$PORT | PORT_STATUS:$PORT_STATUS | FOLDER:/var/www/$NEW_USER" | sudo tee -a $LOG_FILE > /dev/null

if [ $ADDED -eq 1 ]; then
echo "---- SUCCESSFULLY ADDED $NEW_USER WITH PORT: $PORT ----"
else
echo "User Not Created****"
fi