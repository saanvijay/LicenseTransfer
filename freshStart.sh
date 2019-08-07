#!/bin/bash

cd license-network
./ntUp.sh restart
cd -

cd application
rm -rf hfc-key-store hfc-key-store2

echo
echo -e "\e[1;32m ========= Enroll Admin for Vodafone =========== \e[0m"
echo
node enrollAdmin.js
echo
echo -e "\e[1;32m ========= Enroll Admin for Allinq =========== \e[0m"
echo
node enrollAdmin2.js
echo
echo -e "\e[1;32m ========= Register User1 for Vodafone =========== \e[0m"
echo
node registerUser.js
echo
echo -e "\e[1;32m ========= Register User2 for Allinq =========== \e[0m"
echo
node registerUser2.js
echo
echo -e "\e[1;32m ========= Start Application Server =========== \e[0m"
echo
node server.js

cd -
