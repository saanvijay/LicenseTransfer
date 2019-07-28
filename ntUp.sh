#!/bin/bash
export IMAGE_TAG=latest
export PATH=${PWD}/../bin:${PWD}:$PATH

rm -rf crypto-config
cryptogen generate --config=./crypto-config.yaml

for Org  in Applee googlee microsoftt oraclee ibmm ;
do
cp $Org.yaml.tmp $Org.yaml 
done

ARCH=$(uname -s | grep Darwin)
if [ "$ARCH" == "Darwin" ]; then
  OPTS="-it"
echo $OPTS
else
  OPTS="-i"
fi

CURRENT_DIR=$PWD
cd crypto-config/peerOrganizations/Applee.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed $OPTS "s/CA_APPLEE_KEY/${PRIV_KEY}/g" Applee.yaml

CURRENT_DIR=$PWD
cd crypto-config/peerOrganizations/oraclee.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed $OPTS "s/CA_ORACLEE_KEY/${PRIV_KEY}/g" oraclee.yaml

CURRENT_DIR=$PWD
cd crypto-config/peerOrganizations/microsoftt.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed $OPTS "s/CA_MICROSOFTT_KEY/${PRIV_KEY}/g" microsoftt.yaml

CURRENT_DIR=$PWD
cd crypto-config/peerOrganizations/googlee.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed $OPTS "s/CA_GOOGLEE_KEY/${PRIV_KEY}/g" googlee.yaml

CURRENT_DIR=$PWD
cd crypto-config/peerOrganizations/ibmm.com/ca/
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed $OPTS "s/CA_IBMM_KEY/${PRIV_KEY}/g" ibmm.yaml

sleep 10 
echo "=========================== Network down ============================="
docker-compose -f Applee.yaml -f googlee.yaml -f microsoftt.yaml -f oraclee.yaml -f ibmm.yaml -f common.yaml down --volumes --remove-orphans
echo "=========================== DONE ============================="
echo""
echo "=========================== Removing docker containers ============================="
docker rm -f $(docker ps -aq)
echo "=========================== DONE ============================="
echo""

rm -rf channel-artifacts

mkdir channel-artifacts

configtxgen -profile FiveOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
configtxgen -profile FiveOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID lic-transfer-channel 

configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/AppleeMSPanchors.tx -channelID  lic-transfer-channel -asOrg AppleeMSP
configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/googleeMSPanchors.tx -channelID  lic-transfer-channel -asOrg googleeMSP
configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/ibmmMSPanchors.tx -channelID  lic-transfer-channel -asOrg ibmmMSP
configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/microsofttMSPanchors.tx -channelID  lic-transfer-channel -asOrg microsofttMSP
configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/oracleeMSPanchors.tx -channelID  lic-transfer-channel -asOrg oracleeMSP

echo "=========================== Bringup Network ============================="
docker-compose -f Applee.yaml -f googlee.yaml -f microsoftt.yaml -f oraclee.yaml -f ibmm.yaml -f common.yaml up -d
echo "=========================== DONE ============================="
echo""

docker exec cli ./scripts/channel-setup.sh

docker exec cli ./scripts/install-chaincode.sh

docker exec cli ./scripts/instantiate-chaincode.sh

