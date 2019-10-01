// call the packages we need
var express       = require('express');        // call express
var app           = express();                 // define our app using express
var bodyParser    = require('body-parser');
var http          = require('http')
var fs            = require('fs');
var Fabric_Client = require('fabric-client');
var path          = require('path');
var util          = require('util');
var os            = require('os');
var multer        = require('multer');
var crypto        = require('crypto');

module.exports = (function() {
return{
	
	GetAllLicenses: function(req, res){
		console.log("Get All the available licenses to be shared: ");

		var fabric_client = new Fabric_Client();

		// setup the fabric network
                let serverCert = fs.readFileSync('../license-network/crypto-config/peerOrganizations/Applee.com/msp/tlscacerts/tlsca.Applee.com-cert.pem');
		var channel = fabric_client.newChannel('lic-transfer-channel');
		var peer = fabric_client.newPeer('grpcs://localhost:7051',{'pem': Buffer.from(serverCert).toString(),'ssl-target-name-override': 'peer0.Applee.com'});
		//var peer = fabric_client.newPeer('grpc://localhost:7051');
		channel.addPeer(peer);

		//
		var member_user = null;
                var store_path = path.join(__dirname, 'key-store-Applee');
		console.log('Store path:'+store_path);
		var tx_id = null;

		// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
		Fabric_Client.newDefaultKeyValueStore({ path: store_path
		}).then((state_store) => {
		    // assign the store to the fabric client
		    fabric_client.setStateStore(state_store);
		    var crypto_suite = Fabric_Client.newCryptoSuite();
		    // use the same location for the state store (where the users' certificate are kept)
		    // and the crypto store (where the users' keys are kept)
		    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
		    crypto_suite.setCryptoKeyStore(crypto_store);
		    fabric_client.setCryptoSuite(crypto_suite);

		    // get the enrolled user from persistence, this user will sign all requests
		    return fabric_client.getUserContext('user1', true);
		}).then((user_from_store) => {
		    if (user_from_store && user_from_store.isEnrolled()) {
		        console.log('Successfully loaded user1 from persistence');
		        member_user = user_from_store;
		    } else {
		        throw new Error('Failed to get user1.... run registerUser.js');
		    }

		// Get all Overall planning
		    const request = {
		        chaincodeId: 'p2p',
                        channel_id: 'lic-transfer-channel',
		        txId: tx_id,
		        fcn: 'GetAllLicenses',
		        args: ['']
		    };

		    // send the query proposal to the peer
		    return channel.queryByChaincode(request);
		}).then((query_responses) => {
		    console.log("Query has completed, checking results");
		    // query_responses could have more than one  results if there multiple peers were used as targets
		    if (query_responses && query_responses.length == 1) {
		        if (query_responses[0] instanceof Error) {
		            console.error("error from query = ", query_responses[0]);
		        } else {
		            console.log("Response is ", query_responses[0].toString());
		            res.json(JSON.parse(query_responses[0].toString()));
		        }
		    } else {
		        console.log("No payloads were returned from query");
		    }
		}).catch((err) => {
		    console.error('Failed to query successfully :: ' + err);
		});
	},
	GetLicensePrice: function(req, res){
		console.log("Get License Price: ");

		var lcToken = req.body.lcToken;
		var CompanyName = req.body.companyName;
		var fabric_client = new Fabric_Client();
		var privateRule = "";

		// setup the fabric network
                let serverCert = fs.readFileSync('../license-network/crypto-config/peerOrganizations/Applee.com/msp/tlscacerts/tlsca.Applee.com-cert.pem');
		var channel = fabric_client.newChannel('lic-transfer-channel');
		var peer = fabric_client.newPeer('grpcs://localhost:7051',{'pem': Buffer.from(serverCert).toString(),'ssl-target-name-override': 'peer0.Applee.com'});
		//var peer = fabric_client.newPeer('grpc://localhost:7051');
		channel.addPeer(peer);

		//
		var member_user = null;
        var store_path = path.join(__dirname, 'key-store-Applee');
		console.log('Store path:'+store_path);
		const collectionsConfigPath = path.join(__dirname, '../license-network/chaincode/collections_config.json');
		var tx_id = null;

		// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
		Fabric_Client.newDefaultKeyValueStore({ path: store_path
		}).then((state_store) => {
		    // assign the store to the fabric client
		    fabric_client.setStateStore(state_store);
		    var crypto_suite = Fabric_Client.newCryptoSuite();
		    // use the same location for the state store (where the users' certificate are kept)
		    // and the crypto store (where the users' keys are kept)
		    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
		    crypto_suite.setCryptoKeyStore(crypto_store);
		    fabric_client.setCryptoSuite(crypto_suite);

		    // get the enrolled user from persistence, this user will sign all requests
		    return fabric_client.getUserContext('user1', true);
		}).then((user_from_store) => {
		    if (user_from_store && user_from_store.isEnrolled()) {
		        console.log('Successfully loaded user1 from persistence');
		        member_user = user_from_store;
		    } else {
		        throw new Error('Failed to get user1.... run registerUser.js');
		    }

			switch (CompanyName) {
				case "Applee":
					privateRule = "AppleePrivate";
					break;
				case "microsoftt":
					privateRule = "microsofttPrivate";
					break;
				case "oraclee":
					privateRule = "oracleePrivate";
					break;
				case "ibmm":
					privateRule = "ibmmPrivate";
					break;
				case "googlee":
					privateRule = "googleePrivate";
					break;
			}

			let tmap = new Map();
			tmap.set("lcToken", lcToken);
			tmap.set("collection", privateRule);

		console.log("collection name ", privateRule);
		console.log("Company Name ", CompanyName);
		// Get all Overall planning
		    const request = {
		        chaincodeId: 'p2p',
                channel_id: 'lic-transfer-channel',
		        txId: tx_id,
		        fcn: 'GetLicensePrice',
				args: [lcToken],
				transientMap: tmap,
				'collections-config': collectionsConfigPath
		    };

		    // send the query proposal to the peer
		    return channel.queryByChaincode(request);
		}).then((query_responses) => {
		    console.log("Query has completed, checking results");
		    // query_responses could have more than one  results if there multiple peers were used as targets
		    if (query_responses && query_responses.length == 1) {
		        if (query_responses[0] instanceof Error) {
		            console.error("error from query = ", query_responses[0]);
		        } else {
		            console.log("Response is ", query_responses[0].toString());
		            res.json(JSON.parse(query_responses[0].toString()));
		        }
		    } else {
		        console.log("No payloads were returned from query");
		    }
		}).catch((err) => {
		    console.error('Failed to query successfully :: ' + err);
		});
	},
	ShareLicense: function(req, res){
		console.log("Share License...: ");

		var rootToken = JSON.stringify(req.body.rootToken);
		var UserId = JSON.stringify(req.body.UserId);
		var SourceUserId = JSON.stringify(req.body.SourceUserId);
		var LcToken = JSON.stringify(req.body.LcToken);
		var SourceUserLcToken = JSON.stringify(req.body.SourceUserLcToken);
		var fabric_client = new Fabric_Client();

		// setup the fabric network
        let peerCert = fs.readFileSync('../license-network/crypto-config/peerOrganizations/Applee.com/msp/tlscacerts/tlsca.Applee.com-cert.pem');
        let ordererCert = fs.readFileSync('../license-network/crypto-config/ordererOrganizations/lictransfer.com/tlsca/tlsca.lictransfer.com-cert.pem');
		var channel = fabric_client.newChannel('lic-transfer-channel');
		var peer = fabric_client.newPeer('grpcs://localhost:7051',{'pem': Buffer.from(peerCert).toString(),'ssl-target-name-override': 'peer0.Applee.com'});
		var orderer = fabric_client.newOrderer('grpcs://localhost:7050',{'pem':Buffer.from(ordererCert).toString(),'ssl-target-name-override': 'orderer.lictransfer.com'})
		//var peer = fabric_client.newPeer('grpc://localhost:7051');
		channel.addPeer(peer);
		channel.addOrderer(orderer);

		//var orderer = fabric_client.newOrderer('grpc://localhost:7050');

		var member_user = null;
                var store_path = path.join(__dirname, 'key-store-Applee');
		console.log('Store path:'+store_path);
		var tx_id = null;

		// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
		Fabric_Client.newDefaultKeyValueStore({ path: store_path
		}).then((state_store) => {
		    // assign the store to the fabric client
		    fabric_client.setStateStore(state_store);
		    var crypto_suite = Fabric_Client.newCryptoSuite();
		    // use the same location for the state store (where the users' certificate are kept)
		    // and the crypto store (where the users' keys are kept)
		    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
		    crypto_suite.setCryptoKeyStore(crypto_store);
		    fabric_client.setCryptoSuite(crypto_suite);

		    // get the enrolled user from persistence, this user will sign all requests
		    return  fabric_client.getUserContext('user1', true);
		}).then((user_from_store) => {
		    if (user_from_store && user_from_store.isEnrolled()) {
		        console.log('successfully loaded user1 from persistence');
		        member_user = user_from_store;
		    } else {
		        throw new error('failed to get user1.... run registeruser.js');
		    }

		    // get a transaction id object based on the current user assigned to fabric client
		    tx_id = fabric_client.newTransactionID();
		    console.log("assigning transaction_id: ", tx_id._transaction_id);

		    // send proposal to endorser
		    const request = {
		        //targets : --- letting this default to the peers assigned to the channel
		        chaincodeId: 'p2p',
                chainId: 'lic-transfer-channel',
		        txId: tx_id,
		        fcn: 'ShareLicense',
		        args: [rootToken, SourceUserLcToken, LcToken]
		    };
		    // send the transaction proposal to the peers
		    return channel.sendTransactionProposal(request);
		}).then((results) => {
		    var proposalResponses = results[0];
		    var proposal = results[1];
		    let isProposalGood = false;
		    if (proposalResponses && proposalResponses[0].response &&
		        proposalResponses[0].response.status === 200) {
		            isProposalGood = true;
		            console.log('Transaction proposal was good');
		        } else {
		            console.error('Transaction proposal was bad');
		        }
		    if (isProposalGood) {
		        console.log(util.format(
		            'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s"',
		            proposalResponses[0].response.status, proposalResponses[0].response.message));

		        // build up the request for the orderer to have the transaction committed
		        var request = {
		            proposalResponses: proposalResponses,
		            proposal: proposal
		        };

		        // set the transaction listener and set a timeout of 30 sec
		        // if the transaction did not get committed within the timeout period,
		        // report a TIMEOUT status
		        var transaction_id_string = tx_id.getTransactionID(); //Get the transaction ID string to be used by the event processing
		        var promises = [];

		        var sendPromise = channel.sendTransaction(request);
		        promises.push(sendPromise); //we want the send transaction first, so that we know where to check status

		        // get an eventhub once the fabric client has a user assigned. The user
		        // is required bacause the event registration must be signed
		        //let event_hub = fabric_client.newEventHub();
		        let event_hub = channel.newChannelEventHub('localhost:7051');
		        //event_hub.setPeerAddr('grpcs://localhost:7053');
                        headerStatus = proposalResponses[0].response.payload; 
		        console.log("headerStatus %s",headerStatus);

		        // using resolve the promise so that result status may be processed
		        // under the then clause rather than having the catch clause process
		        // the status
		        let txPromise = new Promise((resolve, reject) => {
		            let handle = setTimeout(() => {
                                event_hub.unregisterTxEvent(transaction_id_string);
		                event_hub.disconnect();
		                resolve({event_status : 'TIMEOUT'}); //we could use reject(new Error('Trnasaction did not complete within 30 seconds'));
		            }, 15000);
		            //event_hub.connect();
		            event_hub.registerTxEvent(transaction_id_string, (tx, code) => {
		                // this is the callback for transaction event status
		                // first some clean up of event listener
		                clearTimeout(handle);
		               // event_hub.unregisterTxEvent(transaction_id_string);
		                //event_hub.disconnect();

		                // now let the application know what happened
		                var return_status = {event_status : code, tx_id : transaction_id_string};
		                if (code !== 'VALID') {
		                    console.error('The transaction was invalid, code = ' + code);
		                    resolve(return_status); // we could use reject(new Error('Problem with the tranaction, event status ::'+code));
		                } else {
		                    console.log('The transaction has been committed on peer ' + event_hub.getPeerAddr());
		                    resolve(return_status);
		                }
		            }, (err) => {
		                //this is the callback if something goes wrong with the event registration or processing
		                reject(new Error('There was a problem with the eventhub ::'+err));
		            });
		                event_hub.connect();
		        }).catch(() => { console.log ('=====================') });;
		        promises.push(txPromise);

		        return Promise.all(promises);
		    } else {
		        console.error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		        res.send("Error: no record found");
		        // throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		    }
		}).then((results) => {
		    console.log('Send transaction promise and event listener promise have completed');
		    // check the results in the order the promises were added to the promise all list
		    if (results && results[0] && results[0].status === 'SUCCESS') {
		        console.log('Successfully sent transaction to the orderer.');
		        res.json(tx_id.getTransactionID())
		    } else {
		        console.error('Failed to order the transaction. Error code: ' + response.status);
		        res.send("Error: no record found");
		    }

		    if(results && results[1] && results[1].event_status === 'VALID') {
		        console.log('Successfully committed the change to the ledger by the peer');
		        res.json(tx_id.getTransactionID())
		    } else {
		        console.log('Transaction failed to be committed to the ledger due to ::'+results[1].event_status);
                        console.log(results)
		    }
		}).catch((err) => {
		    //console.error('Failed to invoke successfully :: ' + err);
		    //res.send("Error: no record found");
		});

	},
	SetLicensePrice: function(req, res){
		console.log("Set License Price...: ");

		var LcToken = req.body.lcToken;
		var Price = req.body.Price;
		var CompanyName = req.body.CompanyName;
		var privateRule;

		var fabric_client = new Fabric_Client();

		// setup the fabric network
        let peerCert = fs.readFileSync('../license-network/crypto-config/peerOrganizations/Applee.com/msp/tlscacerts/tlsca.Applee.com-cert.pem');
        let ordererCert = fs.readFileSync('../license-network/crypto-config/ordererOrganizations/lictransfer.com/tlsca/tlsca.lictransfer.com-cert.pem');
		var channel = fabric_client.newChannel('lic-transfer-channel');
		var peer = fabric_client.newPeer('grpcs://localhost:7051',{'pem': Buffer.from(peerCert).toString(),'ssl-target-name-override': 'peer0.Applee.com'});
		var orderer = fabric_client.newOrderer('grpcs://localhost:7050',{'pem':Buffer.from(ordererCert).toString(),'ssl-target-name-override': 'orderer.lictransfer.com'})
		//var peer = fabric_client.newPeer('grpc://localhost:7051');
		channel.addPeer(peer);
		channel.addOrderer(orderer);

		//var orderer = fabric_client.newOrderer('grpc://localhost:7050');
		const collectionsConfigPath = path.join(__dirname, '../license-network/chaincode/collections_config.json');

		var member_user = null;
                var store_path = path.join(__dirname, 'key-store-Applee');
		console.log('Store path:'+store_path);
		var tx_id = null;

		// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
		Fabric_Client.newDefaultKeyValueStore({ path: store_path
		}).then((state_store) => {
		    // assign the store to the fabric client
		    fabric_client.setStateStore(state_store);
		    var crypto_suite = Fabric_Client.newCryptoSuite();
		    // use the same location for the state store (where the users' certificate are kept)
		    // and the crypto store (where the users' keys are kept)
		    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
		    crypto_suite.setCryptoKeyStore(crypto_store);
		    fabric_client.setCryptoSuite(crypto_suite);

		    // get the enrolled user from persistence, this user will sign all requests
		    return  fabric_client.getUserContext('user1', true);
		}).then((user_from_store) => {
		    if (user_from_store && user_from_store.isEnrolled()) {
		        console.log('successfully loaded user1 from persistence');
		        member_user = user_from_store;
		    } else {
		        throw new error('failed to get user1.... run registeruser.js');
		    }

		    // get a transaction id object based on the current user assigned to fabric client
		    tx_id = fabric_client.newTransactionID();
		    console.log("assigning transaction_id: ", tx_id._transaction_id);

			console.log("Company Name ", CompanyName);

			switch (CompanyName) {
				case "Applee":
					privateRule = "AppleePrivate";
					break;
				case "microsoftt":
					privateRule = "microsofttPrivate";
					break;
				case "oraclee":
					privateRule = "oracleePrivate";
					break;
				case "ibmm":
					privateRule = "ibmmPrivate";
					break;
				case "googlee":
					privateRule = "googleePrivate";
					break;
				default:
					privateRule = "no private rule";
			}

			console.log("collection name ", privateRule);

			/*let tmap = new Map();
			tmap.set("lcToken", lcToken);
			tmap.set("collection", privateRule);
			tmap.set("Price", Price);
			*/
			console.log("collection name 1", privateRule);

		
		// Get all Overall planning
		    const request = {
		        chaincodeId: 'p2p',
                channel_id: 'lic-transfer-channel',
		        txId: tx_id,
		        fcn: 'SetLicensePrice',
				args: [lcToken, privateRule, Price],
				transientMap: {'lcToken': lcToken, 'collection': privateRule, 'price': Price}
			};
			
		    // send the transaction proposal to the peers
		    return channel.sendTransactionProposal(request);
		}).then((results) => {
		    var proposalResponses = results[0];
		    var proposal = results[1];
		    let isProposalGood = false;
		    if (proposalResponses && proposalResponses[0].response &&
		        proposalResponses[0].response.status === 200) {
		            isProposalGood = true;
		            console.log('Transaction proposal was good');
		        } else {
		            console.error('Transaction proposal was bad');
		        }
		    if (isProposalGood) {
		        console.log(util.format(
		            'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s"',
		            proposalResponses[0].response.status, proposalResponses[0].response.message));

		        // build up the request for the orderer to have the transaction committed
		        var request = {
		            proposalResponses: proposalResponses,
		            proposal: proposal
		        };

		        // set the transaction listener and set a timeout of 30 sec
		        // if the transaction did not get committed within the timeout period,
		        // report a TIMEOUT status
		        var transaction_id_string = tx_id.getTransactionID(); //Get the transaction ID string to be used by the event processing
		        var promises = [];

		        var sendPromise = channel.sendTransaction(request);
		        promises.push(sendPromise); //we want the send transaction first, so that we know where to check status

		        // get an eventhub once the fabric client has a user assigned. The user
		        // is required bacause the event registration must be signed
		        //let event_hub = fabric_client.newEventHub();
		        let event_hub = channel.newChannelEventHub('localhost:7051');
		        //event_hub.setPeerAddr('grpcs://localhost:7053');
                        headerStatus = proposalResponses[0].response.payload; 
		        console.log("headerStatus %s",headerStatus);

		        // using resolve the promise so that result status may be processed
		        // under the then clause rather than having the catch clause process
		        // the status
		        let txPromise = new Promise((resolve, reject) => {
		            let handle = setTimeout(() => {
                                event_hub.unregisterTxEvent(transaction_id_string);
		                event_hub.disconnect();
		                resolve({event_status : 'TIMEOUT'}); //we could use reject(new Error('Trnasaction did not complete within 30 seconds'));
		            }, 15000);
		            //event_hub.connect();
		            event_hub.registerTxEvent(transaction_id_string, (tx, code) => {
		                // this is the callback for transaction event status
		                // first some clean up of event listener
		                clearTimeout(handle);
		               // event_hub.unregisterTxEvent(transaction_id_string);
		                //event_hub.disconnect();

		                // now let the application know what happened
		                var return_status = {event_status : code, tx_id : transaction_id_string};
		                if (code !== 'VALID') {
		                    console.error('The transaction was invalid, code = ' + code);
		                    resolve(return_status); // we could use reject(new Error('Problem with the tranaction, event status ::'+code));
		                } else {
		                    console.log('The transaction has been committed on peer ' + event_hub.getPeerAddr());
		                    resolve(return_status);
		                }
		            }, (err) => {
		                //this is the callback if something goes wrong with the event registration or processing
		                reject(new Error('There was a problem with the eventhub ::'+err));
		            });
		                event_hub.connect();
		        }).catch(() => { console.log ('=====================') });;
		        promises.push(txPromise);

		        return Promise.all(promises);
		    } else {
		        console.error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		        res.send("Error: no record found");
		        // throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		    }
		}).then((results) => {
		    console.log('Send transaction promise and event listener promise have completed');
		    // check the results in the order the promises were added to the promise all list
		    if (results && results[0] && results[0].status === 'SUCCESS') {
		        console.log('Successfully sent transaction to the orderer.');
		        res.json(tx_id.getTransactionID())
		    } else {
		        console.error('Failed to order the transaction. Error code: ' + response.status);
		        res.send("Error: no record found");
		    }

		    if(results && results[1] && results[1].event_status === 'VALID') {
		        console.log('Successfully committed the change to the ledger by the peer');
		        res.json(tx_id.getTransactionID())
		    } else {
		        console.log('Transaction failed to be committed to the ledger due to ::'+results[1].event_status);
                        console.log(results)
		    }
		}).catch((err) => {
		    //console.error('Failed to invoke successfully :: ' + err);
		    //res.send("Error: no record found");
		});

	},
	RequestLicense: function(req, res){
		console.log("Request License...: ");

		var rootToken = JSON.stringify(req.body.rootToken);
        var jsonargs = JSON.stringify(req.body.jsonblob);
		var fabric_client = new Fabric_Client();

		// setup the fabric network
        let peerCert = fs.readFileSync('../license-network/crypto-config/peerOrganizations/Applee.com/msp/tlscacerts/tlsca.Applee.com-cert.pem');
        let ordererCert = fs.readFileSync('../license-network/crypto-config/ordererOrganizations/lictransfer.com/tlsca/tlsca.lictransfer.com-cert.pem');
		var channel = fabric_client.newChannel('lic-transfer-channel');
		var peer = fabric_client.newPeer('grpcs://localhost:7051',{'pem': Buffer.from(peerCert).toString(),'ssl-target-name-override': 'peer0.Applee.com'});
		var orderer = fabric_client.newOrderer('grpcs://localhost:7050',{'pem':Buffer.from(ordererCert).toString(),'ssl-target-name-override': 'orderer.lictransfer.com'})
		//var peer = fabric_client.newPeer('grpc://localhost:7051');
		channel.addPeer(peer);
		channel.addOrderer(orderer);

		//var orderer = fabric_client.newOrderer('grpc://localhost:7050');

		var member_user = null;
                var store_path = path.join(__dirname, 'key-store-Applee');
		console.log('Store path:'+store_path);
		var tx_id = null;

		// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
		Fabric_Client.newDefaultKeyValueStore({ path: store_path
		}).then((state_store) => {
		    // assign the store to the fabric client
		    fabric_client.setStateStore(state_store);
		    var crypto_suite = Fabric_Client.newCryptoSuite();
		    // use the same location for the state store (where the users' certificate are kept)
		    // and the crypto store (where the users' keys are kept)
		    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
		    crypto_suite.setCryptoKeyStore(crypto_store);
		    fabric_client.setCryptoSuite(crypto_suite);

		    // get the enrolled user from persistence, this user will sign all requests
		    return  fabric_client.getUserContext('user1', true);
		}).then((user_from_store) => {
		    if (user_from_store && user_from_store.isEnrolled()) {
		        console.log('successfully loaded user1 from persistence');
		        member_user = user_from_store;
		    } else {
		        throw new error('failed to get user1.... run registeruser.js');
		    }

		    // get a transaction id object based on the current user assigned to fabric client
		    tx_id = fabric_client.newTransactionID();
		    console.log("assigning transaction_id: ", tx_id._transaction_id);

		    // send proposal to endorser
		    const request = {
		        //targets : --- letting this default to the peers assigned to the channel
		        chaincodeId: 'p2p',
                        chainId: 'lic-transfer-channel',
		        txId: tx_id,
		        fcn: 'RequestLicense',
		        args: [rootToken, jsonargs]
		    };
		    // send the transaction proposal to the peers
		    return channel.sendTransactionProposal(request);
		}).then((results) => {
		    var proposalResponses = results[0];
		    var proposal = results[1];
		    let isProposalGood = false;
		    if (proposalResponses && proposalResponses[0].response &&
		        proposalResponses[0].response.status === 200) {
		            isProposalGood = true;
		            console.log('Transaction proposal was good');
		        } else {
		            console.error('Transaction proposal was bad');
		        }
		    if (isProposalGood) {
		        console.log(util.format(
		            'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s"',
		            proposalResponses[0].response.status, proposalResponses[0].response.message));

		        // build up the request for the orderer to have the transaction committed
		        var request = {
		            proposalResponses: proposalResponses,
		            proposal: proposal
		        };

		        // set the transaction listener and set a timeout of 30 sec
		        // if the transaction did not get committed within the timeout period,
		        // report a TIMEOUT status
		        var transaction_id_string = tx_id.getTransactionID(); //Get the transaction ID string to be used by the event processing
		        var promises = [];

		        var sendPromise = channel.sendTransaction(request);
		        promises.push(sendPromise); //we want the send transaction first, so that we know where to check status

		        // get an eventhub once the fabric client has a user assigned. The user
		        // is required bacause the event registration must be signed
		        //let event_hub = fabric_client.newEventHub();
		        let event_hub = channel.newChannelEventHub('localhost:7051');
		        //event_hub.setPeerAddr('grpcs://localhost:7053');
                        headerStatus = proposalResponses[0].response.payload; 
		        console.log("headerStatus %s",headerStatus);

		        // using resolve the promise so that result status may be processed
		        // under the then clause rather than having the catch clause process
		        // the status
		        let txPromise = new Promise((resolve, reject) => {
		            let handle = setTimeout(() => {
                                event_hub.unregisterTxEvent(transaction_id_string);
		                event_hub.disconnect();
		                resolve({event_status : 'TIMEOUT'}); //we could use reject(new Error('Trnasaction did not complete within 30 seconds'));
		            }, 15000);
		            //event_hub.connect();
		            event_hub.registerTxEvent(transaction_id_string, (tx, code) => {
		                // this is the callback for transaction event status
		                // first some clean up of event listener
		                clearTimeout(handle);
		               // event_hub.unregisterTxEvent(transaction_id_string);
		                //event_hub.disconnect();

		                // now let the application know what happened
		                var return_status = {event_status : code, tx_id : transaction_id_string};
		                if (code !== 'VALID') {
		                    console.error('The transaction was invalid, code = ' + code);
		                    resolve(return_status); // we could use reject(new Error('Problem with the tranaction, event status ::'+code));
		                } else {
		                    console.log('The transaction has been committed on peer ' + event_hub.getPeerAddr());
		                    resolve(return_status);
		                }
		            }, (err) => {
		                //this is the callback if something goes wrong with the event registration or processing
		                reject(new Error('There was a problem with the eventhub ::'+err));
		            });
		                event_hub.connect();
		        }).catch(() => { console.log ('=====================') });;
		        promises.push(txPromise);

		        return Promise.all(promises);
		    } else {
		        console.error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		        res.send("Error: no record found");
		        // throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		    }
		}).then((results) => {
		    console.log('Send transaction promise and event listener promise have completed');
		    // check the results in the order the promises were added to the promise all list
		    if (results && results[0] && results[0].status === 'SUCCESS') {
		        console.log('Successfully sent transaction to the orderer.');
		        res.json(tx_id.getTransactionID())
		    } else {
		        console.error('Failed to order the transaction. Error code: ' + response.status);
		        res.send("Error: no record found");
		    }

		    if(results && results[1] && results[1].event_status === 'VALID') {
		        console.log('Successfully committed the change to the ledger by the peer');
		        res.json(tx_id.getTransactionID())
		    } else {
		        console.log('Transaction failed to be committed to the ledger due to ::'+results[1].event_status);
                        console.log(results)
		    }
		}).catch((err) => {
		    //console.error('Failed to invoke successfully :: ' + err);
		    //res.send("Error: no record found");
		});

	},
	GenerateLicense: function(req, res){
		console.log("Generate License...: ");


		var jsonargs = JSON.stringify(req.body.jsonblob);
		var fabric_client = new Fabric_Client();

		// setup the fabric network
        let peerCert = fs.readFileSync('../license-network/crypto-config/peerOrganizations/Applee.com/msp/tlscacerts/tlsca.Applee.com-cert.pem');
        let ordererCert = fs.readFileSync('../license-network/crypto-config/ordererOrganizations/lictransfer.com/tlsca/tlsca.lictransfer.com-cert.pem');
		var channel = fabric_client.newChannel('lic-transfer-channel');
		var peer = fabric_client.newPeer('grpcs://localhost:7051',{'pem': Buffer.from(peerCert).toString(),'ssl-target-name-override': 'peer0.Applee.com'});
		var orderer = fabric_client.newOrderer('grpcs://localhost:7050',{'pem':Buffer.from(ordererCert).toString(),'ssl-target-name-override': 'orderer.lictransfer.com'})
		//var peer = fabric_client.newPeer('grpc://localhost:7051');
		channel.addPeer(peer);
		channel.addOrderer(orderer);

		//var orderer = fabric_client.newOrderer('grpc://localhost:7050');

		var member_user = null;
        var store_path = path.join(__dirname, 'key-store-Applee');
		console.log('Store path:'+store_path);

		
		var tx_id = null;

		// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
		Fabric_Client.newDefaultKeyValueStore({ path: store_path
		}).then((state_store) => {
		    // assign the store to the fabric client
		    fabric_client.setStateStore(state_store);
		    var crypto_suite = Fabric_Client.newCryptoSuite();
		    // use the same location for the state store (where the users' certificate are kept)
		    // and the crypto store (where the users' keys are kept)
		    var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
		    crypto_suite.setCryptoKeyStore(crypto_store);
		    fabric_client.setCryptoSuite(crypto_suite);

		    // get the enrolled user from persistence, this user will sign all requests
		    return  fabric_client.getUserContext('user1', true);
		}).then((user_from_store) => {
		    if (user_from_store && user_from_store.isEnrolled()) {
		        console.log('successfully loaded user1 from persistence');
		        member_user = user_from_store;
		    } else {
		        throw new error('failed to get user1.... run registeruser.js');
		    }

		    // get a transaction id object based on the current user assigned to fabric client
		    tx_id = fabric_client.newTransactionID();
		    console.log("assigning transaction_id: ", tx_id._transaction_id);

		    // send proposal to endorser
		    const request = {
		        //targets : --- letting this default to the peers assigned to the channel
		        chaincodeId: 'p2p',
                        chainId: 'lic-transfer-channel',
		        txId: tx_id,
		        fcn: 'GenerateLicense',
				args: [jsonargs]
		    };
		    // send the transaction proposal to the peers
		    return channel.sendTransactionProposal(request);
		}).then((results) => {
		    var proposalResponses = results[0];
		    var proposal = results[1];
		    let isProposalGood = false;
		    if (proposalResponses && proposalResponses[0].response &&
		        proposalResponses[0].response.status === 200) {
		            isProposalGood = true;
		            console.log('Transaction proposal was good');
		        } else {
		            console.error('Transaction proposal was bad');
		        }
		    if (isProposalGood) {
		        console.log(util.format(
		            'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s"',
		            proposalResponses[0].response.status, proposalResponses[0].response.message));

		        // build up the request for the orderer to have the transaction committed
		        var request = {
		            proposalResponses: proposalResponses,
		            proposal: proposal
		        };

		        // set the transaction listener and set a timeout of 30 sec
		        // if the transaction did not get committed within the timeout period,
		        // report a TIMEOUT status
		        var transaction_id_string = tx_id.getTransactionID(); //Get the transaction ID string to be used by the event processing
		        var promises = [];

		        var sendPromise = channel.sendTransaction(request);
		        promises.push(sendPromise); //we want the send transaction first, so that we know where to check status

		        // get an eventhub once the fabric client has a user assigned. The user
		        // is required bacause the event registration must be signed
		        //let event_hub = fabric_client.newEventHub();
		        let event_hub = channel.newChannelEventHub('localhost:7051');
		        //event_hub.setPeerAddr('grpcs://localhost:7053');
                        headerStatus = proposalResponses[0].response.payload; 
		        console.log("headerStatus %s",headerStatus);

		        // using resolve the promise so that result status may be processed
		        // under the then clause rather than having the catch clause process
		        // the status
		        let txPromise = new Promise((resolve, reject) => {
		            let handle = setTimeout(() => {
                                event_hub.unregisterTxEvent(transaction_id_string);
		                event_hub.disconnect();
		                resolve({event_status : 'TIMEOUT'}); //we could use reject(new Error('Trnasaction did not complete within 30 seconds'));
		            }, 15000);
		            //event_hub.connect();
		            event_hub.registerTxEvent(transaction_id_string, (tx, code) => {
		                // this is the callback for transaction event status
		                // first some clean up of event listener
		                clearTimeout(handle);
		               // event_hub.unregisterTxEvent(transaction_id_string);
		                //event_hub.disconnect();

		                // now let the application know what happened
		                var return_status = {event_status : code, tx_id : transaction_id_string};
		                if (code !== 'VALID') {
		                    console.error('The transaction was invalid, code = ' + code);
		                    resolve(return_status); // we could use reject(new Error('Problem with the tranaction, event status ::'+code));
		                } else {
		                    console.log('The transaction has been committed on peer ' + event_hub.getPeerAddr());
		                    resolve(return_status);
		                }
		            }, (err) => {
		                //this is the callback if something goes wrong with the event registration or processing
		                reject(new Error('There was a problem with the eventhub ::'+err));
		            });
		                event_hub.connect();
		        }).catch(() => { console.log ('=====================') });;
		        promises.push(txPromise);

		        return Promise.all(promises);
		    } else {
		        console.error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		        res.send("Error: no record found");
		        // throw new Error('Failed to send Proposal or receive valid response. Response null or status is not 200. exiting...');
		    }
		}).then((results) => {
		    console.log('Send transaction promise and event listener promise have completed');
		    // check the results in the order the promises were added to the promise all list
		    if (results && results[0] && results[0].status === 'SUCCESS') {
		        console.log('Successfully sent transaction to the orderer.');
		        res.json(tx_id.getTransactionID())
		    } else {
		        console.error('Failed to order the transaction. Error code: ' + response.status);
		        res.send("Error: no record found");
		    }

		    if(results && results[1] && results[1].event_status === 'VALID') {
		        console.log('Successfully committed the change to the ledger by the peer');
		        res.json(tx_id.getTransactionID())
		    } else {
		        console.log('Transaction failed to be committed to the ledger due to ::'+results[1].event_status);
                        console.log(results)
		    }
		}).catch((err) => {
		    //console.error('Failed to invoke successfully :: ' + err);
		    //res.send("Error: no record found");
		});

	}


}
})();
