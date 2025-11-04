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
echo "$LOGFILE"

#checking root user or not
if [ $USERID -ne 0 ]
then
    echo "please access with root user"
    exit 1
else
    echo "you are root user"
fi

dnf install mysql-server -y