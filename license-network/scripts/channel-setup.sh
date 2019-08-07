#!/bin/bash

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
echo $FABRIC_CFG_PATH

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

joinChannelWithRetry() {
  PEER=$1
  ORG=$2
  . .config.core.txt

  set -x
  peer channel join -b $CHANNEL_NAME.block >&log.txt
  res=$?
  set +x
  cat log.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "${PEER}.${ORG}.com failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORG
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, ${PEER}.${ORG}.com has failed to join channel '$CHANNEL_NAME' "
}

# Channel creation
echo "========== Creating channel: "$CHANNEL_NAME" =========="
#sleep 20
peer channel create -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile $ORDERER_CA

# peer0.Applee channel join
echo "========== Joining peer0.Applee.com to channel $CHANNEL_NAME =========="
sleep 20
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/users/Admin@Applee.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer0.Applee.com:7051" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=AppleeMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/peers/peer0.Applee.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer0" "Applee" 
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.Applee channel join
echo "========== Joining peer1.Applee.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/users/Admin@Applee.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer1.Applee.com:8051" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=AppleeMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/peers/peer1.Applee.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer1" "Applee"

# peer0.ibmm channel join
echo "========== Joining peer0.ibmm.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/users/Admin@ibmm.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer0.ibmm.com:7351" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=ibmmMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/peers/peer0.ibmm.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer0" "ibmm"
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.ibmm channel join
echo "========== Joining peer1.ibmm.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/users/Admin@ibmm.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer1.ibmm.com:8351" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=ibmmMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/peers/peer1.ibmm.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer1" "ibmm"

# peer0.oraclee channel join
echo "========== Joining peer0.oraclee.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/users/Admin@oraclee.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer0.oraclee.com:7151">> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=oracleeMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/peers/peer1.oraclee.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer0" "oraclee"
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.oraclee channel join
echo "========== Joining peer1.oraclee.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/users/Admin@oraclee.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer1.oraclee.com:8151" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=oracleeMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/peers/peer1.oraclee.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer1" "oraclee"

# peer0.microsoftt channel join
echo "========== Joining peer0.microsoftt.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/users/Admin@microsoftt.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer0.microsoftt.com:7251" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=microsofttMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/peers/peer1.microsoftt.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer0" "microsoftt"
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.microsoftt channel join
echo "========== Joining peer1.microsoftt.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/users/Admin@microsoftt.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer1.microsoftt.com:8251" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=microsofttMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/peers/peer1.microsoftt.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer1" "microsoftt"

# peer0.googlee channel join
echo "========== Joining peer0.googlee.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/users/Admin@googlee.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer0.googlee.com:7451" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=googleeMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/peers/peer1.googlee.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer0" "googlee"
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.googlee channel join
echo "========== Joining peer1.googlee.com to channel $CHANNEL_NAME =========="
echo "export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/users/Admin@googlee.com/msp" > .config.core.txt
echo "export CORE_PEER_ADDRESS=peer1.googlee.com:8451" >> .config.core.txt
echo "export CORE_PEER_LOCALMSPID=googleeMSP" >> .config.core.txt
echo "export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/peers/peer1.googlee.com/tls/ca.crt" >> .config.core.txt
joinChannelWithRetry "peer1" "googlee"

echo""
echo "==================================== DONE ======================================"
echo""

