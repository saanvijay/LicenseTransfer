#!/bin/bash

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
echo $FABRIC_CFG_PATH

CC_NAME=p2p
VER=6
CHANNEL_NAME=lic-transfer-channel

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/lictransfer.com/orderers/orderer.lictransfer.com/msp/tlscacerts/tlsca.lictransfer.com-cert.pem

echo "========== Upgrading chaincode v$VER =========="
peer chaincode upgrade -o orderer.lictransfer.com:7050  \
                           --tls $CORE_PEER_TLS_ENABLED     \
                           --cafile $ORDERER_CA             \
                           -C $CHANNEL_NAME -n $CC_NAME     \
                           -c '{"Args": ["Init"]}' -v $VER  \
                           -P "OR ('AppleeMSP.member', 'ibmmMSP.member', 'oracleeMSP.member', 'microsofttMSP.member', 'googleeMSP.member')"

