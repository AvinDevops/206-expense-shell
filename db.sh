#!/bin/bash

# colors
R="\e[31m"
G="\e[32m"
N="\e[33m"

# variables
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

#prompt for root password
echo "please enter password"
read mysql_root_password

#checking root user or not
if [ $USERID -ne 0 ]
then
    echo -e "$R please access with root user $N"
    exit 1
else
    echo -e "$G you are root user $N"
fi

# function validation
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N"
        exit 1
    else
        echo -e "$2 is...$G SUCCESS $N"
    fi
}

# installing mysql server
dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql"

#enabling mysql
systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabiling mysql"

# starting mysql server
systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysql server"

# setting password for root
mysql_secure_installation --set-root-pass $mysql_root_password &>>$LOGFILE
VALIDATE $? "Setting root password"
