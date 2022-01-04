#!/bin/bash

yum update -y
yum install python3 -y
pip3 install flask
pip3 install flask-mysql
pip3 install sqlalchemy
pip3 install Flask-SQLAlchemy
cd /home/ec2-user
echo "${rds_endpoint}" > dbserver.endpoint
chmod 777 dbserver.endpoint
wget https://raw.githubusercontent.com/skoc10/my_projects/main/aws/Project3-Phonebook-Application/phonebook-app.py
mkdir templates
cd templates
wget https://raw.githubusercontent.com/skoc10/my_projects/main/aws/Project3-Phonebook-Application/templates/index.html
wget https://raw.githubusercontent.com/skoc10/my_projects/main/aws/Project3-Phonebook-Application/templates/delete.html  
wget https://raw.githubusercontent.com/skoc10/my_projects/main/aws/Project3-Phonebook-Application/templates/add-update.html
cd ..
python3 phonebook-app.py