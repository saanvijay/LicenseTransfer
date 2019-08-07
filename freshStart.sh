#!/bin/bash

#cd license-network
#./ntUp.sh 
#cd -

cd application
rm -rf key-store-Applee key-store-ibmm key-store-oraclee key-store-googlee key-store-microsoftt

echo
echo -e "\e[1;32m ========= Enroll Admin for Applee =========== \e[0m"
echo
node enrollAdminApplee.js
echo
echo -e "\e[1;32m ========= Enroll Admin for ibmm =========== \e[0m"
echo
node enrollAdminIbmm.js
echo
echo -e "\e[1;32m ========= Enroll Admin for oraclee =========== \e[0m"
echo
node enrollAdminOraclee.js
echo
echo -e "\e[1;32m ========= Enroll Admin for microsoftt =========== \e[0m"
echo
node enrollAdminMicrosoftt.js
echo
echo -e "\e[1;32m ========= Enroll Admin for googlee =========== \e[0m"
echo
node enrollAdminGooglee.js
echo
echo -e "\e[1;32m ========= Register User1 for Applee =========== \e[0m"
echo
node registerUserApplee.js
echo
echo -e "\e[1;32m ========= Register User1 for Oraclee =========== \e[0m"
echo
node registerUserOraclee.js
echo
echo -e "\e[1;32m ========= Register User1 for Microsoftt =========== \e[0m"
echo
node registerUserMicrosoftt.js
echo
echo -e "\e[1;32m ========= Register User1 for Ibmm =========== \e[0m"
echo
node registerUserIbmm.js
echo
echo -e "\e[1;32m ========= Register User1 for Googlee =========== \e[0m"
echo
node registerUserGooglee.js
echo
echo -e "\e[1;32m ========= Start Application Server =========== \e[0m"
echo
node server.js

cd -
