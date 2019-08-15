/* ============================================================================**
 License as a Token smart contract
** ============================================================================ */

package main

import (
	"bytes"
        "strings"
	"fmt"
	"time"
	"io"
	"crypto/sha256"
	"encoding/json"
	"encoding/hex"
    "github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type LcUser struct {
	LcToken		      string `json:"LcToken"`
	UserId                string `json:"UserId"`
	CompanyName           string `json:"CompanyName"`
	ProductName           string `json:"ProductName"`
	Validity              int64  `json:",string"`
	AvailableForShare     bool   `json:",string"`
	Status                string `json:"Status"`
}

type License struct {
	RootLcToken           string `json:"RootLcToken"`
	TotalDaysValidity     int64 `json:",string"`
	NumberOfUsersShared   int64 `json:",string"`
	LastTransaction       string `json:"LastTransaction"`
	User                  []LcUser `json:"LUser"`
}

// Init chaincode
func (l *License) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("Initiate the chaincode")
	return shim.Success(nil)
}

// Invoke the functions
func (l *License) Invoke(stub shim.ChaincodeStubInterface) pb.Response { 

	function, args := stub.GetFunctionAndParameters()

	fmt.Println("Recieved function in chaincode: ", function)

	if function == "GenerateLicense" {
		return l.GenerateLicense(stub, args)
	}
	if function == "ShareLicense" {
		return l.ShareLicense(stub, args)
	}
	if function == "UpdateLicense" {
		return l.UpdateLicense(stub, args)
	}
	if function == "GetLicense" {
		return l.GetLicense(stub, args)
	}
	if function == "GetAllLicenses" {
		return l.GetAllLicenses(stub, args)
	}
	if function == "GetTransactionHistoryForKey" {
		return l.GetTransactionHistoryForKey(stub, args)
	}

	fmt.Println("Function not found!")
	return shim.Error("Recieved unknown function invocation!")
}


func (l *License) ShareLicense(stub shim.ChaincodeStubInterface, args []string) pb.Response { 
	var err error
	var sourceLicense License
	var destLicense License

	if len(args) < 1 {
		fmt.Println("Invalid number of arguments")
		return shim.Error(err.Error())
	}

	err = json.Unmarshal([]byte(args[0]), &sourceLicense)
	if err != nil {
		fmt.Println("Unable to unmarshal data in UpdatLicense : ", err)
		return shim.Error(err.Error())
	}

    var bytesread []byte
	bytesread, err = stub.GetState(sourceLicense.RootLcToken)
	err = json.Unmarshal(bytesread, &destLicense)
	if err != nil {
		fmt.Println("Unable to unmarshal data in UpdateLicense: ", err)
		return shim.Error(err.Error())
	}

	destLicense.LastTransaction = time.Now().String()
	if destLicense.NumberOfUsersShared != 0 {
		destLicense.TotalDaysValidity -= 1
                for _, usr := range destLicense.User {
			usr.Validity -= 1
		}
	}
    
	// Start - Put into Couch DB
	JSONBytes, err := json.Marshal(destLicense)
	if err != nil {
		fmt.Println("Unable to Marshal UpdateLicense: ", err)
		return shim.Error(err.Error())
	}

    fmt.Printf("objplanentiyqueryResults : %v\n", destLicense)
    fmt.Printf("LcToken : %v\n", destLicense.RootLcToken)
	err = stub.PutState(destLicense.RootLcToken, JSONBytes)

	// End - Put into Couch DB
	if err != nil {
		fmt.Println("Unable to make transaction for UpdateLicense: ", err)
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (l *License) UpdateLicense(stub shim.ChaincodeStubInterface, args []string) pb.Response { 
	var err error
	var sourceLicense License
	var destLicense License

	if len(args) < 1 {
		fmt.Println("Invalid number of arguments")
		return shim.Error(err.Error())
	}

	err = json.Unmarshal([]byte(args[0]), &sourceLicense)
	if err != nil {
		fmt.Println("Unable to unmarshal data in UpdatLicense : ", err)
		return shim.Error(err.Error())
	}

    var bytesread []byte
	bytesread, err = stub.GetState(sourceLicense.RootLcToken)
	err = json.Unmarshal(bytesread, &destLicense)
	if err != nil {
		fmt.Println("Unable to unmarshal data in UpdateLicense: ", err)
		return shim.Error(err.Error())
	}

	destLicense.LastTransaction = time.Now().String()
	if destLicense.NumberOfUsersShared != 0 {
		destLicense.TotalDaysValidity -= 1
                for _, usr := range destLicense.User {
			usr.Validity -= 1
		}
	}
    
	// Start - Put into Couch DB
	JSONBytes, err := json.Marshal(destLicense)
	if err != nil {
		fmt.Println("Unable to Marshal UpdateLicense: ", err)
		return shim.Error(err.Error())
	}

    fmt.Printf("objplanentiyqueryResults : %v\n", destLicense)
    fmt.Printf("LcToken : %v\n", destLicense.RootLcToken)
	err = stub.PutState(destLicense.RootLcToken, JSONBytes)

	// End - Put into Couch DB
	if err != nil {
		fmt.Println("Unable to make transaction for UpdateLicense: ", err)
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (l *License) GetLicense(stub shim.ChaincodeStubInterface, args []string) pb.Response { 
	var err error

	if len(args) < 1 {
		fmt.Println("Invalid number of arguments")
		return shim.Error(err.Error())
	}

	//fetch data from couch db starts here
	var TokenId = args[0]
	queryString := fmt.Sprintf("{\"selector\":{\"RootLcToken\":{\"$eq\": \"%s\"}}}", TokenId)
	queryResults, err := getQueryResultForQueryString(stub, queryString)
	//fetch data from couch db ends here
	if err != nil {
		fmt.Printf("Unable to get Token details: %s\n", err)
		return shim.Error(err.Error())
	}
	fmt.Printf("License Details : %v\n", queryResults)

	return shim.Success(queryResults)
}

func (l *License) GetAllLicenses(stub shim.ChaincodeStubInterface, args []string) pb.Response { 
	var err error

//	if len(args) < 1 {
//		fmt.Println("Invalid number of arguments")
//		return shim.Error(err.Error())
//	}

	//fetch data from couch db starts here
	queryString := fmt.Sprintf("{\"selector\":{\"RootLcToken\":{\"$gt\": \"%s\"}}}", "null")
	queryResults, err := getQueryResultForQueryString(stub, queryString)
	//fetch data from couch db ends here
	if err != nil {
		fmt.Printf("Unable to get All License details: %s\n", err)
		return shim.Error(err.Error())
	}
	fmt.Printf("License Details : %v\n", queryResults)

	return shim.Success(queryResults)
}
func (l *License) GetTransactionHistoryForKey(stub shim.ChaincodeStubInterface, args []string) pb.Response { 
	var err error

	queryResults, err := getTransHistory(stub, args[0])
	if err != nil {
		fmt.Printf("Unable to get all Transactions : %s\n", err)
		return shim.Error(err.Error())
	}
	fmt.Printf("Transaction History: %v\n", queryResults)

	return shim.Success(queryResults)
}

func (l *License) GenerateLicense(stub shim.ChaincodeStubInterface, args []string) pb.Response { 
	var err error
	var licEntity License
	var objUser LcUser

        fmt.Printf("licEntity : 1\n")
	if len(args) < 1 {
		fmt.Println("Invalid number of arguments")
		return shim.Error(err.Error())
	}

        fmt.Printf("licEntity : %s\n", args[0])
	err = json.Unmarshal([]byte(args[0]), &objUser)
	if err != nil {
		fmt.Println("Unable to unmarshal data in GenerateLicense : ", err)
		return shim.Error(err.Error())
	}
        fmt.Printf("licEntity : 3\n")

	// Token Generation
        tokenString := fmt.Sprintf("%s%s%d%s", objUser.ProductName, objUser.CompanyName, objUser.Validity, time.Now().String())
	input := strings.NewReader(tokenString)
	hash := sha256.New()
	if _, err := io.Copy(hash, input); err != nil {
		fmt.Println("Unable to Generate Token in GenerateLicense : ", err)
		return shim.Error(err.Error())
	}
    
        fmt.Printf("licEntity : 4\n")
	licEntity.RootLcToken = hex.EncodeToString(hash.Sum(nil))
	objUser.AvailableForShare = true
	objUser.LcToken = "null"
	licEntity.User = append(licEntity.User, objUser)
	licEntity.NumberOfUsersShared = 0
	licEntity.LastTransaction = time.Now().String()

        fmt.Printf("licEntity : 5\n")
	// Start - Put into Couch DB
	JSONBytes, err := json.Marshal(licEntity)
	if err != nil {
		fmt.Println("Unable to Marshal GenerateLicense: ", err)
		return shim.Error(err.Error())
	}
        fmt.Printf("licEntity : 6\n")
        fmt.Printf("licEntity : %v\n", licEntity.RootLcToken)
	err = stub.PutState(licEntity.RootLcToken, JSONBytes)
	// End - Put into Couch DB
	if err != nil {
		fmt.Println("Unable to make transaction for GenerateLicense: ", err)
		return shim.Error(err.Error())
	}

        fmt.Printf("licEntity : 7\n")
	return shim.Success(nil)
}

// getQueryResultForQueryString
func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	fmt.Printf("***getQueryResultForQueryString queryString:\n%s\n", queryString)

        resultsIterator, err := stub.GetQueryResult(queryString)

	if err != nil {
		fmt.Println("Error from getQueryResultForQueryString:  ", err)
		return nil, err
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryRecords
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("***getQueryResultForQueryString queryResult:\n%s\n", buffer.String())

	return buffer.Bytes(), nil
}// getQueryResultForQueryString

func getTransHistory(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	fmt.Printf("***GetTransactionHistory for Key :\n%s\n", queryString)

       resultsIterator, err := stub.GetHistoryForKey(queryString)

	if err != nil {
		fmt.Println("Error from GetHistoryForKey:  ", err)
		return nil, err
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryRecords
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("*** GetTransactionHistory:\n%s\n", buffer.String())

	return buffer.Bytes(), nil
}

// Starting point of the chaincode
func main() {
	err := shim.Start(new(License))
	if err != nil {
		fmt.Println("Could not start Chaincode")
	} else {
		fmt.Println("Chaincode successfully started")
	}

}
