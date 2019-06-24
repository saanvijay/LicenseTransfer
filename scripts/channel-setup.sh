#!/bin/bash

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
echo $FABRIC_CFG_PATH

CHANNEL_NAME=lic-transfer-channel
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lictransfer.com/orderers/orderer.lictransfer.com/msp/tlscacerts/tlsca.lictransfer.com-cert.pem

# Channel creation
echo "========== Creating channel: "$CHANNEL_NAME" =========="
sleep 15
peer channel create -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile $ORDERER_CA

# peer0.Applee channel join
echo "========== Joining peer0.Applee.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/users/Admin@Applee.com/msp
export CORE_PEER_ADDRESS=peer0.Applee.com:7051
export CORE_PEER_LOCALMSPID="AppleeMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/peers/peer0.Applee.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.Applee channel join
echo "========== Joining peer1.Applee.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/users/Admin@Applee.com/msp
export CORE_PEER_ADDRESS=peer1.Applee.com:8051
export CORE_PEER_LOCALMSPID="AppleeMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/Applee.com/peers/peer1.Applee.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block

# peer0.ibmm channel join
echo "========== Joining peer0.ibmm.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/users/Admin@ibmm.com/msp
export CORE_PEER_ADDRESS=peer0.ibmm.com:7051
export CORE_PEER_LOCALMSPID="ibmmMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/peers/peer1.ibmm.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.ibmm channel join
echo "========== Joining peer1.ibmm.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/users/Admin@ibmm.com/msp
export CORE_PEER_ADDRESS=peer1.ibmm.com:8051
export CORE_PEER_LOCALMSPID="ibmmMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ibmm.com/peers/peer1.ibmm.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block

# peer0.oraclee channel join
echo "========== Joining peer0.oraclee.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/users/Admin@oraclee.com/msp
export CORE_PEER_ADDRESS=peer0.oraclee.com:7051
export CORE_PEER_LOCALMSPID="oracleeMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/peers/peer1.oraclee.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.oraclee channel join
echo "========== Joining peer1.oraclee.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/users/Admin@oraclee.com/msp
export CORE_PEER_ADDRESS=peer1.oraclee.com:8051
export CORE_PEER_LOCALMSPID="oracleeMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/oraclee.com/peers/peer1.oraclee.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block

# peer0.microsoftt channel join
echo "========== Joining peer0.microsoftt.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/users/Admin@microsoftt.com/msp
export CORE_PEER_ADDRESS=peer0.microsoftt.com:7051
export CORE_PEER_LOCALMSPID="microsofttMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/peers/peer1.microsoftt.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.microsoftt channel join
echo "========== Joining peer1.microsoftt.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/users/Admin@microsoftt.com/msp
export CORE_PEER_ADDRESS=peer1.microsoftt.com:8051
export CORE_PEER_LOCALMSPID="microsofttMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/microsoftt.com/peers/peer1.microsoftt.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block

# peer0.googlee channel join
echo "========== Joining peer0.googlee.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/users/Admin@googlee.com/msp
export CORE_PEER_ADDRESS=peer0.googlee.com:7051
export CORE_PEER_LOCALMSPID="googleeMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/peers/peer1.googlee.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block
peer channel update -o orderer.lictransfer.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

# peer1.googlee channel join
echo "========== Joining peer1.googlee.com to channel $CHANNEL_NAME =========="
sleep 15
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/users/Admin@googlee.com/msp
export CORE_PEER_ADDRESS=peer1.googlee.com:8051
export CORE_PEER_LOCALMSPID="googleeMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/googlee.com/peers/peer1.googlee.com/tls/ca.crt
peer channel join -b ${CHANNEL_NAME}.block

echo "==================================== DONE ======================================"
echo""
