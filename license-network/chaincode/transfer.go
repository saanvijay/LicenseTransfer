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
	Validity              int  `json:",string"`
	AvailableForShare     bool   `json:",string"`
	Status                string `json:"Status"`
	SourceUserId          string `json:SourceUserId`
	SourceUserLcToken     string `json:SourceUserLcToken`
	IsValidLicense        bool   `json:",string"`
	ValidityStartsOn      time.Time `json:",string"`
	ValidityExpiriesOn    time.Time `json:",string"`
}

type License struct {
	RootLcToken           string `json:"RootLcToken"`
	TotalDaysValidity     int `json:",string"`
	NumberOfUsersShared   int `json:",string"`
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
	if function == "RequestLicense" {
		return l.RequestLicense(stub, args)
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

func GenerateToken(ProductName string, CompanyName string, Validity int) string {
	//var err error
	
	//Generate Token for shared License
	tokenString := fmt.Sprintf("%s%s%d%s", ProductName, CompanyName, Validity, time.Now().String())
	input := strings.NewReader(tokenString)
	hash := sha256.New()
	if _, err := io.Copy(hash, input); err != nil {
		fmt.Println("Unable to Generate Token in GenerateLicense : ", err)
		return string(err.Error())
	}

	return hex.EncodeToString(hash.Sum(nil))
}

func (l *License) ShareLicense(stub shim.ChaincodeStubInterface, args []string) pb.Response { 
	var err error
	var destLicense License
	var RootToken string
	var sindex,dindex int 
	var UserToUser bool
	var LcToken, SourceUserLcToken string

	if len(args) < 1 {
		fmt.Println("Invalid number of arguments")
		return shim.Error(err.Error())
	}

	var err0 error
	err0 = json.Unmarshal([]byte(args[0]), &RootToken)
	if err0 != nil {
		fmt.Println("Unable to unmarshal data in ShareLicense : ", err0)
		return shim.Error(err.Error())
	}

	var err1 error
	err1 = json.Unmarshal([]byte(args[1]), &SourceUserLcToken)
	if err1 != nil {
		fmt.Println("Unable to unmarshal data in ShareLicense : ", err1)
		return shim.Error(err.Error())
	}

	var err2 error
	err2 = json.Unmarshal([]byte(args[2]), &LcToken)
	if err2 != nil {
		fmt.Println("Unable to unmarshal data in ShareLicense : ", err2)
		return shim.Error(err.Error())
	}

	//SourceUserId = "producer"
	sindex = 0
	dindex = 0
	UserToUser = false

    var bytesread []byte
	bytesread, err = stub.GetState(RootToken)
	err = json.Unmarshal(bytesread, &destLicense)
	if err != nil {
		fmt.Println("Unable to unmarshal data in ShareLicense: ", err)
		return shim.Error(err.Error())
	}

	for index1, user := range destLicense.User {
			if user.LcToken == LcToken {
				dindex = index1
				//break
			}

			if user.LcToken == SourceUserLcToken {
				sindex = index1
				if user.SourceUserId != "producer" {
					UserToUser = true
				}
			}
			// if we get both index then come out of loop
			//if UserToUser == true && sindex != -1 && dindex != -1 {
			//	break
			//} 
	}

	fmt.Printf("chaincode ShareLicese sindex=%v dindex=%v", sindex, dindex)
	if destLicense.TotalDaysValidity >= destLicense.User[dindex].Validity  {
		destLicense.LastTransaction = time.Now().String()
		destLicense.User[dindex].AvailableForShare = true
		destLicense.User[dindex].Status = "shared"
		destLicense.User[dindex].IsValidLicense = true
    
		destLicense.User[dindex].LcToken = GenerateToken(destLicense.User[dindex].ProductName, destLicense.User[dindex].CompanyName, destLicense.User[dindex].Validity)
    
		// Sharing is successful, hence reduce the total validity
		if UserToUser == true {
			fmt.Printf("chaincode ShareLicese destLicense.User[%v].Validity=%v destLicense.User[%v].Validityx=%v", sindex, destLicense.User[sindex].Validity, dindex, destLicense.User[dindex].Validity)
			destLicense.User[sindex].Validity -= destLicense.User[dindex].Validity 
		} else {
			destLicense.TotalDaysValidity -= destLicense.User[dindex].Validity
			destLicense.User[dindex].SourceUserId = "producer"
		}
		destLicense.NumberOfUsersShared += 1
		//Validity/expire date (IST)
		destLicense.User[dindex].ValidityStartsOn   = time.Now()
		//destLicense.User[dindex].ValidityStartsOn   = destLicense.User[dindex].ValidityStartsOn.Format("2006-01-02 3:4:5 PM")
		destLicense.User[dindex].ValidityExpiriesOn = time.Now()
		destLicense.User[dindex].ValidityExpiriesOn = destLicense.User[dindex].ValidityExpiriesOn.AddDate(0,0,destLicense.User[dindex].Validity)
		//destLicense.User[dindex].ValidityExpiriesOn = destLicense.User[dindex].ValidityExpiriesOn.Format("2006-01-02 3:4:5 PM")

	} else {
		destLicense.User[dindex].Status = "rejected"
	}

	// Start - Put into Couch DB
	JSONBytes, err := json.Marshal(destLicense)
	if err != nil {
		fmt.Println("Unable to Marshal ShareLicense: ", err)
		return shim.Error(err.Error())
	}

	fmt.Printf("LcToken : %v\n", destLicense.RootLcToken)
	err = stub.PutState(destLicense.RootLcToken, JSONBytes)

	// End - Put into Couch DB
	if err != nil {
		fmt.Println("Unable to make transaction for UpdateLicense: ", err)
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (l *License) RequestLicense(stub shim.ChaincodeStubInterface, args []string) pb.Response { 
	var err, err1 error
	var oldLicEntity License
	var objUser LcUser
	var RootToken string

	if len(args) < 1 {
		fmt.Println("Invalid number of arguments")
		return shim.Error(err.Error())
	}

	err = json.Unmarshal([]byte(args[0]), &RootToken)
	if err != nil {
		fmt.Println("Unable to unmarshal data in RequestLicense : ", err)
		return shim.Error(err.Error())
	}

	err1 = json.Unmarshal([]byte(args[1]), &objUser)
	if err1 != nil {
		fmt.Println("Unable to unmarshal data in RequestLicense : ", err1)
		return shim.Error(err.Error())
	}
    
	var bytesread []byte
	bytesread, err = stub.GetState(RootToken)
	err = json.Unmarshal(bytesread, &oldLicEntity)
	if err != nil {
		fmt.Println("Unable to unmarshal data in RequestLicense: ", err)
		return shim.Error(err.Error())
	}

	objUser.LcToken = GenerateToken(objUser.ProductName, objUser.CompanyName, objUser.Validity)
	objUser.Status  = "requested"
	//oldLicEntity.RootLcToken = RootToken
	oldLicEntity.User  = append(oldLicEntity.User, objUser)

	// Start - Put into Couch DB
	JSONBytes, err := json.Marshal(oldLicEntity)
	if err != nil {
		fmt.Println("Unable to Marshal RequestLicense: ", err)
		return shim.Error(err.Error())
	}
     
	err = stub.PutState(oldLicEntity.RootLcToken, JSONBytes)
	// End - Put into Couch DB
	if err != nil {
		fmt.Println("Unable to make transaction for RequestLicense: ", err)
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
	queryString := fmt.Sprintf("{\"selector\":{\"RootLcToken\":{\"$ne\": \"%s\"}}}", "null")
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

	if len(args) < 1 {
		fmt.Println("Invalid number of arguments")
		return shim.Error(err.Error())
	}

	err = json.Unmarshal([]byte(args[0]), &objUser)
	if err != nil {
		fmt.Println("Unable to unmarshal data in GenerateLicense : ", err)
		return shim.Error(err.Error())
	}
    
	licEntity.RootLcToken = GenerateToken(objUser.ProductName, objUser.CompanyName, objUser.Validity)
	objUser.AvailableForShare = true
	objUser.IsValidLicense = true
	objUser.SourceUserLcToken = "null"
	objUser.LcToken = GenerateToken(objUser.ProductName, objUser.CompanyName, objUser.Validity)
	objUser.Status  = "generated"
	objUser.UserId  = "producer"
	objUser.ValidityStartsOn = time.Now()
	objUser.ValidityExpiriesOn = objUser.ValidityStartsOn.AddDate(0,0, objUser.Validity)
	licEntity.User  = append(licEntity.User, objUser)
	licEntity.NumberOfUsersShared += 1
	licEntity.TotalDaysValidity = objUser.Validity
	licEntity.LastTransaction = time.Now().String()


	// Start - Put into Couch DB
	JSONBytes, err := json.Marshal(licEntity)
	if err != nil {
		fmt.Println("Unable to Marshal GenerateLicense: ", err)
		return shim.Error(err.Error())
	}
     
	err = stub.PutState(licEntity.RootLcToken, JSONBytes)
	// End - Put into Couch DB
	if err != nil {
		fmt.Println("Unable to make transaction for GenerateLicense: ", err)
		return shim.Error(err.Error())
	}

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
