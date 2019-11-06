pragma solidity ^0.5.0; 
  
/**
 * @author : sagar chaurasia
 * @dev ProjectX => version: BETA (aicumen technologies specific)
 */ 
 import "./ERC20.sol";

/**
* Note : oraclize is called "provable" now
*/ 
 import "github.com/provable-things/ethereum-api/provableAPI.sol";  

contract AcuConverter is usingProvable { 

/**
 * @dev declaring global variables
 * instantiation of erc20 implemantation
 */
  address public owner; 
  address public ContractAddress; 
  uint256 public ExchangeTime;  
  ERC20 private ERC20Interface; 

/**
 * @dev modifier to restrict the access of sensitive functions to contract owner only
 */
  modifier onlyOwner() {
    require(msg.sender == owner ,"Authorization failed");
    _;
  }  

/**
 * @dev defining enum for tokens , for tracking
 */  
  enum tokenSymbol {USDT, INRT}

/**  
 * @dev Defining structs 
 */
  struct Transfer {
  string token_;
  address from_;  
  address to_;  
  uint amount_;   
  }  

/**  
 * @dev defining mappings
 * where allInTransactions , stores all the transactions in which user sends token to contract
 * and allOutTransactions , stores info regarding , user getting alternative tokens from contract
 * intransactionInfo , stores the information for IN-STATE transaction mapped with query id , to differentiate several transaction instatiation state info, for later  reconciliation in callback
 */ 
  mapping(address => Transfer[]) public allInTransactions;
  mapping(address => Transfer[]) public allOutTransactions;
  mapping(bytes32 => Transfer) internal inTransitionInfo; 
  mapping(string => address) public tokens;
  
/**  
 * @dev Defining various events thats inpacts on blockchain on their execution
 */ 
  event TransferSuccessful(string token, address indexed from_, address indexed to_, uint256 amount_);  
  event TransferFailed(string token,address indexed from_, address indexed to_, uint256 amount_);  
  event LogNewProvableQuery(string description);
  event TokenAdded(string tokenName);
  event TokenRemoved(string tokenName);
  
/**
 * @dev constructor for defining initial values of global variables
 * Note :  keeping exchange time for 60 secs in starting (quick test purpose) , but can be changed later
 */
  constructor() public {  
    owner = msg.sender;
    ContractAddress = address(this);
    ExchangeTime = 60;
 }  


/**  
 * @dev add address of supported tokens Smart contracts 
 */  
  function addNewToken(tokenSymbol symbol_, address address_) public onlyOwner  returns (bool) {  
    string memory symbol;
    if (tokenSymbol(symbol_)==tokenSymbol.USDT)
    {symbol= "USDT";}
    else if (tokenSymbol(symbol_)==tokenSymbol.INRT)
    {symbol = "INRT";}
    else {revert("Symbol Not Found");}
    tokens[symbol] = address_;  
    emit TokenAdded(symbol);
    return true;  
 }  

/**  
 * @dev remove address of token that are no more supported
 */  
  function removeToken(tokenSymbol symbol_) public onlyOwner returns (bool) {
    string memory symbol;
    if (tokenSymbol(symbol_)==tokenSymbol.USDT)
    {symbol= "USDT";}
    else if (tokenSymbol(symbol_)==tokenSymbol.INRT)
    {symbol = "INRT";}
    else {revert("Symbol Not Found");}
    delete(tokens[symbol]);  
    emit TokenRemoved(symbol);
    return true;  
  }

/**  
 * @dev method for setting the exchange time 
 */
  function setExchangeTime(uint256 time) public onlyOwner returns(bool) {
    ExchangeTime = time;
    return true;
 }

  /**  
 * @dev method that handles transfer of ERC20 tokens to other address and calls the update function for further compution 
 * and automatic resending of tokens via callback function
 * symbol defines the type of currency you are sending in contract
 * IMPORTANT => atleast 1 usdT or INRT should be send , And Amount is in CENT/PAISE 
 */
  function applyForExchange(tokenSymbol symbol_ , uint256 amount_) public payable { 
    require(amount_ >= 100 , "atleast 1 USDT/INRT (100 cents/paise)should be send"); 
    string memory symbol;
    string memory alterSymbol;
    uint256 queryCode;

    if (tokenSymbol(symbol_)==tokenSymbol.USDT){
      symbol= "USDT";
      queryCode = 0;
      alterSymbol = "INRT";
      }
    else if (tokenSymbol(symbol_)==tokenSymbol.INRT){
      symbol = "INRT";
      queryCode =1;
      alterSymbol = "USDT";
      }
    else {
      revert("Symbol Not Found");
      }

    address contract_ = tokens[symbol];  
    address from_ = msg.sender;  
    address to_ = address(this);
    
    ERC20Interface = ERC20(contract_); 
    uint256 myBal = ERC20Interface.balanceOf(from_);

    if(amount_ > myBal){
      emit TransferFailed(symbol,from_,to_,amount_);
      revert("insufficient balance");
    }
    ERC20Interface.transferFrom(from_,to_, amount_); 
    Transfer memory transferInfo; 
      transferInfo.token_ = symbol;
      transferInfo.from_ = from_;
      transferInfo.to_ = to_;
      transferInfo.amount_ = amount_;
      allInTransactions[from_].push(transferInfo);
    
    emit TransferSuccessful(symbol, from_, to_, amount_);  

    update(queryCode,alterSymbol,to_,from_,amount_);
    //here , altering the values , since we need to send alternative currency to msg.sender , For update function
 }  


/**
* @dev query using oraclize service fetches the current rate of usd/inr pair or vice-versa
* function needs to be payable since oraclize is paid service
* using free api for getting concurrent data from internet about current rate of currencies
* To support multiple transaction at a time , using query id to descriminate between various transactions
*/
    function update(uint256 queryCode, string memory alternativeSymbol, address newFrom , address newTo, uint256 amount) public payable
    {
      bytes32 queryId;
      Transfer memory transferInfo;
      transferInfo.token_ = alternativeSymbol;
      transferInfo.from_ = newFrom;
      transferInfo.to_ = newTo;
      transferInfo.amount_ = amount;
        if (provable_getPrice("URL") > address(this).balance) {
            emit LogNewProvableQuery("query was NOT sent, try adding some ETH to the Contract ");
        } else {
          if(queryCode == 0) {
            emit LogNewProvableQuery("query was sent, wating for exchange time");
            queryId = provable_query(ExchangeTime, "URL", "json(https://free.currconv.com/api/v7/convert?q=USD_INR&compact=ultra&apiKey=969ee6cd3dfec2260f72).USD_INR");
            inTransitionInfo[queryId]= transferInfo;
          }
          else if(queryCode == 1) {
           
            emit LogNewProvableQuery("query was sent, wating for exchange time");
            queryId = provable_query(ExchangeTime, "URL", "json(https://free.currconv.com/api/v7/convert?q=INR_USD&compact=ultra&apiKey=969ee6cd3dfec2260f72).INR_USD"); 
            inTransitionInfo[queryId]= transferInfo;
          }
        }
    }

/**
* @dev call back function is called after the oraclize has worked and reverted with result
 * logic used for conversion
   * since fetched resulted from oraclize is in string format and is for 1 USD to INR or 1 INR to USD
   * 1) convert string to int type
   * 2) using 2 deciml precision to convert usd/inr to eqivalent cent/paise
   * REMEMBER , though the oraclize result is converted to paise/cents but still it is 1 usd/inr equivalent 
   * 3) now calculating actual amount to send
   * since amount user transferred to contract was in cent/usd
   * a) Divide the amount send by user by 100 to get cents/paise equivalent to usd/inr
   * b) now multiply the above resultant to orcalize per uint result to get the correct amount to send 
   * NOTE : FOr better understanding , check the mathematical example in file ""
  
*/
 function __callback(bytes32 _myid,string memory _result) public {
   string memory symbol = inTransitionInfo[_myid].token_;
   address from_ = inTransitionInfo[_myid].from_;
   address to = inTransitionInfo[_myid].to_; 

   uint256 unitPrice = parseInt(_result, 2); // converting oraclize result to int , and in cents/paise
   uint256 amount = (inTransitionInfo[_myid].amount_ * unitPrice)/100;
   address contract_ = tokens[symbol]; 
   ERC20Interface = ERC20(contract_);
   uint256 myBal = ERC20Interface.balanceOf(from_);
    if(amount > myBal){
      emit TransferFailed(symbol,from_,to,amount);
      revert("contract does not have sufficient balance");
    }
    ERC20Interface.transferFrom(from_,to, amount); 
    Transfer memory transferInfo; 
      transferInfo.token_ = symbol;
      transferInfo.from_ = from_;
      transferInfo.to_ = to;
      transferInfo.amount_ = amount;
      allOutTransactions[to].push(transferInfo);
    
    emit TransferSuccessful(symbol, from_, to, amount);
  }
  
 }


