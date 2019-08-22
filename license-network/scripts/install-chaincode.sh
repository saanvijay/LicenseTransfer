#!/bin/bash

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
echo $FABRIC_CFG_PATH

CC_NAME=p2p
VER=6
CHANNEL_NAME=lic-transfer-channel
DELAY=5
COUNTER=1
MAX_RETRY=20

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lictransfer.com/orderers/orderer.lictransfer.com/msp/tlscacerts/tlsca.lictransfer.com-cert.pem

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute current Scenario ==========="
    echo
    exit 1
  fi
}

# peer0.Applee Installing chaincode in
echo "========== Installing chaincode in peer0.Applee.com to channel $CHANNEL_NAME =========="
sleep 20
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/users/Admin@Applee.com/msp
CORE_PEER_ADDRESS=peer0.Applee.com:7051
CORE_PEER_LOCALMSPID=AppleeMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/peers/peer0.Applee.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

# peer1.Applee Installing chaincode in
echo "========== Installing chaincode in peer1.Applee.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/users/Admin@Applee.com/msp
CORE_PEER_ADDRESS=peer1.Applee.com:8051
CORE_PEER_LOCALMSPID=AppleeMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/peers/peer1.Applee.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode

# peer0.ibmm Installing chaincode in
echo "========== Installing chaincode in peer0.ibmm.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/users/Admin@ibmm.com/msp
CORE_PEER_ADDRESS=peer0.ibmm.com:7351
CORE_PEER_LOCALMSPID=ibmmMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/peers/peer0.ibmm.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

# peer1.ibmm Installing chaincode in
echo "========== Installing chaincode in peer1.ibmm.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/users/Admin@ibmm.com/msp
CORE_PEER_ADDRESS=peer1.ibmm.com:8351
CORE_PEER_LOCALMSPID=ibmmMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/peers/peer1.ibmm.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

# peer0.oraclee Installing chaincode in
echo "========== Installing chaincode in peer0.oraclee.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/users/Admin@oraclee.com/msp
CORE_PEER_ADDRESS=peer0.oraclee.com:7151
CORE_PEER_LOCALMSPID=oracleeMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/peers/peer1.oraclee.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

# peer1.oraclee Installing chaincode in
echo "========== Installing chaincode in peer1.oraclee.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/users/Admin@oraclee.com/msp
CORE_PEER_ADDRESS=peer1.oraclee.com:8151
CORE_PEER_LOCALMSPID=oracleeMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/peers/peer1.oraclee.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

# peer0.microsoftt Installing chaincode in
echo "========== Installing chaincode in peer0.microsoftt.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/users/Admin@microsoftt.com/msp
CORE_PEER_ADDRESS=peer0.microsoftt.com:7251
CORE_PEER_LOCALMSPID=microsofttMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/peers/peer1.microsoftt.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

# peer1.microsoftt Installing chaincode in
echo "========== Installing chaincode in peer1.microsoftt.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/users/Admin@microsoftt.com/msp
CORE_PEER_ADDRESS=peer1.microsoftt.com:8251
CORE_PEER_LOCALMSPID=microsofttMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/peers/peer1.microsoftt.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

# peer0.googlee Installing chaincode in
echo "========== Installing chaincode in peer0.googlee.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/users/Admin@googlee.com/msp
CORE_PEER_ADDRESS=peer0.googlee.com:7451
CORE_PEER_LOCALMSPID=googleeMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/peers/peer1.googlee.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

# peer1.googlee Installing chaincode in
echo "========== Installing chaincode in peer1.googlee.com to channel $CHANNEL_NAME =========="
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/users/Admin@googlee.com/msp
CORE_PEER_ADDRESS=peer1.googlee.com:8451
CORE_PEER_LOCALMSPID=googleeMSP
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/peers/peer1.googlee.com/tls/ca.crt
echo "CORE_PEER_ADDRESS=$CORE_PEER_ADDRESS"
peer chaincode install -n $CC_NAME -v $VER -l golang -p github.com/chaincode 

echo""
echo "==================================== DONE ======================================"
echo""

