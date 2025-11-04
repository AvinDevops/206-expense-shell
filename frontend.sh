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

# main process

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabiling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing files in html folder"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend zip file in tmp folder"

cd /usr/share/nginx/html &>>$LOGFILE
VALIDATE $? "Changing to html dir"

unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Unzipping forntend zip file"

cp /home/ec2-user/206-expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copying expense conf file to default.d folder"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"