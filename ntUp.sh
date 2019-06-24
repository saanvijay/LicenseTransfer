#!/bin/bash
export IMAGE_TAG=latest
export PATH=${PWD}/../bin:${PWD}:$PATH

#cryptogen generate --config=./crypto-config.yaml

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
