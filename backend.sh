#!/bin/bash

#colors
R="\e[31m"
G="\e[32m"
N="\e[0m"

#variables
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

# checking root user or not
if [ $USERID -ne 0 ]
then
    echo -e "$R please access with root user $N"
    exit 1
else
    echo -e "$G you are root user $N"
fi

# validate function
VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is...$R FAILED $N"
        exit 1
    else
        echo -e "$2 is...$G SUCCESS $N"
    fi
}

dnf module disable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Disabiling nodejs 18"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabiling nodejs 20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs 20"

useradd expense &>>$LOGFILE
VALIDATE $? "Installing nodejs 20"

mkdir /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code to tmp folder"

cd /app

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Unzipping backend zip file"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/206-expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copying backend service file to system folder"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reloading"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabiling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Loading schema"

systemctl restart backend &>>LOGFILE
VALIDATE $? "Restarting Backend"