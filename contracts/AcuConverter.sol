pragma solidity ^0.5.0; 
  
 /**
  @author : sagar chaurasia
  @dev ProjectX => version: BETA (aicumen technologies specific)
  */ 
import "./ERC20.sol";

// Note : oraclize is called provable now
import "github.com/provable-things/ethereum-api/provableAPI.sol";  

contract AcuConverter is usingProvable {  
  
  string public priceETHXBT;

    event LogNewProvableQuery(string description);
 /**  
  * @dev Details of each transfer 
  */
  struct Transfer {  
  address contract_;  
  address to_;  
  uint amount_;  
  bool failed_;  
  }  

/**
 *@dev modifier to restrict the access of sensitive functions to contract owner only
 */
  modifier onlyOwner() {
    require(msg.sender == owner ,"Authorization failed");
    _;
  }

  /**  
 * @dev a mapping from transaction ID's to the sender address 
 */ 

 mapping(address => uint[]) public transactionIndexesToSender;  
  
  
  /**  
 * @dev a list of all transfers successful or unsuccessful 
 * ExchangeTime is the the amount of time in which automatic converion of tokens is done and send
 */  
 Transfer[] public transactions;  
  
  address public owner;  

  uint256 public ExchangeTime;
  
  /**  
 * @dev list of all supported tokens for transfer 
 * @param string token symbol 
 * @param address contract address of token 
 */  
  mapping(string => address) public tokens;  
  
  ERC20 private ERC20Interface;  
  
/**  
 * @dev Event to notify if transfer successful or failed 
 */ 
  event TransferSuccessful(address indexed from_, address indexed to_, uint256 amount_);  

  //failing event can be added once the security check is added at the time of transfer
  //event TransferFailed(address indexed from_, address indexed to_, uint256 amount_);  
  
  constructor() public {  
  owner = msg.sender;
  // note we are  keeping exchange time for 60 secs in starting (quick test purpose) , but can be changed later  
  ExchangeTime = 60;
 }  

/**  
 * @dev add address of token to list of supported tokens using 
 * token symbol as identifier in mapping 
 */  
 function addNewToken(string memory symbol_, address address_) public  returns (bool) {  
  tokens[symbol_] = address_;  
  return true;  
 }  

  /**  
  * @dev remove address of token we no more support
  */  
 function removeToken(string memory symbol_) public  returns (bool) {  
  delete(tokens[symbol_]);  
  return true;  
  }

  /**  
 * @dev method that handles transfer of ERC20 tokens to other address
 * symbol defines the type of currency you are sending in contract 
 */

 function applyForExchange(string memory symbol_, uint256 amount_) public {  
 
   // TODO :security check 1) add the balance revert call and retireve the current balance and add if & revert back , if failing 
  //2) check if legit symbol or not , if not =>revert
  uint256 code ;
  if (symbol_ == "USDT")
  {code=0;} else {code=1;}
  address contract_ = tokens[symbol_];  
  address from_ = msg.sender;  
  address to_ = address(this);
  
  ERC20Interface = ERC20(contract_);  
  
  // TODO , manage the ledger in more sensible and task specific way
  uint256 transactionId = transactions.push(  
  Transfer({  
  contract_:  contract_,  
            to_: to_,  
            amount_: amount_,  
            failed_: true  
  })  
 );  
  transactionIndexesToSender[from_].push(transactionId - 1);  

  ERC20Interface.transfer( to_, amount_);  
  
  transactions[transactionId - 1].failed_ = false;  
  
  emit TransferSuccessful(from_, to_, amount_);  
  update(code);
 }  

  /**  
 * @dev method that can set the exchange time 
 * TODO : only owner can call this function 
 */
 function setExchangeTime(uint256 time) public oinlyOwner returns(bool) {
   ExchangeTime = time;
   return true;
 }


/**
* @dev query using oraclize service fetches the current rate of usd/inr pair or vice-versa
* function needs to be payable since oraclize is paid service
*/
 
    function update(uint256 queryCode) public payable
    {
        if (provable_getPrice("URL") > address(this).balance) {
            emit LogNewProvableQuery("query was NOT sent, try adding some ETH ");
        } else {
          if(queryCode == 0) {

            emit LogNewProvableQuery("query was sent, wating for exchange time");
            // using free api for getting concurrent data from internet about curent rate of currencies
            provable_query(ExchangeTime, "URL", "json(https://free.currconv.com/api/v7/convert?q=USD_INR&compact=ultra&apiKey=969ee6cd3dfec2260f72).USD_INR");
          }
          else if(queryCode == 1) {
           
            emit LogNewProvableQuery("query was sent, wating for exchange time");
            // using free api for getting concurrent data from internet about curent rate of currencies
            provable_query(ExchangeTime, "URL", "json(https://free.currconv.com/api/v7/convert?q=INR_USD&compact=ultra&apiKey=969ee6cd3dfec2260f72).INR_USD"); 
          }
        }
    }

    /**
* @dev call back function is called after the oraclize has worked and reverted with result
* NOTE : COMPLETLY REWORK ON CALLBACK FUNCTION , currently multiple trnasaction from existing user not supported and 
* and maintain a ledger entry for this "OUT" transaction also
*/
 function __callback(bytes32 _myid,string memory _result,bytes memory _proof) public {
        require(msg.sender == provable_cbAddress());
  ERC20Interface.transfer( msg.sender, _result);

    }

 
 }


 //query returns the bytes32 value , i.e, id , id can be used as mapping 
 
  
  
