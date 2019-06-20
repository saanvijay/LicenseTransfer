configtxgen -profile FiveOrgsOrdererGenesis -channelID lic-transfer-channel -outputBlock ./channel-artifacts/genesis.block
configtxgen -profile FiveOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID lic-transfer-channel 

configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/AppleeMSPanchors.tx -channelID  lic-transfer-channel -asOrg AppleeMSP
configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/googleeMSPanchors.tx -channelID  lic-transfer-channel -asOrg googleeMSP
configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/ibmmMSPanchors.tx -channelID  lic-transfer-channel -asOrg ibmmMSP
configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/microsofttMSPanchors.tx -channelID  lic-transfer-channel -asOrg microsofttMSP
configtxgen -profile FiveOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/oracleeMSPanchors.tx -channelID  lic-transfer-channel -asOrg oracleeMSP

