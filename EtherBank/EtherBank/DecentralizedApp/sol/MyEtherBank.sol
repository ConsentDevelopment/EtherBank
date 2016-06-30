contract MyEtherBank 
{
    // Version : 1.0 - initial release

    /* -------- State data -------- */

    // Owner
    address private _owner;
    uint256 private _bankDonationsBalance;
    bool private _connectBankAccountToNewOwnerAddressEnabled;

    // Bank accounts    
    struct BankAccount
    {
        // Members placed in order for optimization, not readability
        bool passwordSha3HashSet;
        uint32 number; 
        uint256 balance;
        address owner;       
        bytes32 passwordSha3Hash;   
        mapping(bytes32 => bool) passwordSha3HashesUsed;
    }   

    struct BankAccountAddress
    {
        bool accountSet;
        uint32 accountNumber; // accountNumber member is used to index the bank accounts array
    }
 
    uint32 private _totalBankAccounts;
    BankAccount[] private _bankAccountsArray; 
    mapping(address => BankAccountAddress) private _bankAccountAddresses;  


    /* -------- Constructor -------- */

    function MyEtherBank() public
    {
        // Set the contract owner
        _owner = msg.sender; 
        _connectBankAccountToNewOwnerAddressEnabled = true;
        _bankDonationsBalance = 0; 
    }


    /* -------- Modifiers -------- */

    modifier modifier_isContractOwner()
    { 
        // Contact owner?
        if (msg.sender != _owner)
        {
            throw;       
        }
        _ 
    }

    modifier modifier_doesSenderHaveABankAccount() 
    { 
        // Does this sender have a bank account?
        if (_bankAccountAddresses[msg.sender].accountSet == false)
        {
            throw;
        }
        else
        {
            // Does the bank account owner address match the sender address?
            uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber;
            address accountOwner_ = _bankAccountsArray[accountNumber_].owner;
            if (msg.sender != accountOwner_) 
            {
                throw;        
            }
        }
        _ 
    }

    modifier modifier_wasValueSent()
    { 
        // Value sent?
        if (msg.value > 0)
        {
            // Prevent users from sending value accidentally
            throw;        
        }
        _ 
    }


    /* -------- Events -------- */

    event event_bankAccountOpened_Successful(address indexed bankAccountOwner, uint32 indexed bankAccountNumber);
    event event_depositMadeToBankAccount_Successful(uint256 indexed depositAmount, uint32 indexed bankAccountNumber); 
    event event_depositMadeToBankAccount_Failed(uint256 indexed depositAmount, uint32 indexed bankAccountNumber); 
    event event_depositMadeToBankAccountFromDifferentAddress_Successful(address indexed addressFrom, uint256 indexed depositAmount, uint32 indexed bankAccountNumber);
    event event_depositMadeToBankAccountFromDifferentAddress_Failed(address indexed addressFrom, uint256 indexed depositAmount, uint32 indexed bankAccountNumber);
    event event_withdrawalMadeFromBankAccount_Successful(uint32 indexed bankAccountNumber, uint256 indexed withdrawalAmount); 
    event event_withdrawalMadeFromBankAccount_Failed(uint32 indexed bankAccountNumber, uint256 indexed withdrawalAmount); 
    event event_transferMadeFromBankAccountToAddress_Successful(uint32 indexed bankAccountNumber, uint256 indexed withdrawalAmount, address indexed destinationAddress); 
    event event_transferMadeFromBankAccountToAddress_Failed(uint32 indexed bankAccountNumber, uint256 indexed withdrawalAmount, address indexed destinationAddress); 
	event event_bankDonationsWithdrawn(uint256 donationsAmount);
 
    // Security
    event event_securityConnectingABankAccountToANewOwnerAddressIsDisabled();
	event event_securityPasswordSha3HashAddedToBankAccount(uint32 indexed bankAccountNumber);
    event event_securityBankAccountConnectedToNewAddressOwner(uint32 indexed bankAccountNumber, address indexed newAddressOwner);


    /* -------- Contract owner functions -------- */

    function Donate() public
    {
        if (msg.value > 0)
        {
            _bankDonationsBalance += msg.value;
        }
    }

    function BankOwner_WithdrawDonations(address destinationAddress) public
        modifier_isContractOwner()
        modifier_wasValueSent()
    { 
        if (_bankDonationsBalance > 0)
        {
            uint256 amount_ = _bankDonationsBalance;
            _bankDonationsBalance = 0;

            // Check if using send() is successful
            if (msg.sender.send(amount_))
            {
                event_bankDonationsWithdrawn(amount_);
            }
            // Check if using call.value() is successful
            else if (msg.sender.call.value(amount_)())
            {  
                event_bankDonationsWithdrawn(amount_);
            }
            else
            {
                // Set the previous balance
                _bankDonationsBalance = amount_;
            }
        }
    }

    function BankOwner_EnableConnectBankAccountToNewOwnerAddress() public
        modifier_isContractOwner()
    { 
        if (_connectBankAccountToNewOwnerAddressEnabled == false)
        {
            _connectBankAccountToNewOwnerAddressEnabled = true;
        }
    }

    function  BankOwner_DisableConnectBankAccountToNewOwnerAddress() public
        modifier_isContractOwner()
    { 
        if (_connectBankAccountToNewOwnerAddressEnabled)
        {
            _connectBankAccountToNewOwnerAddressEnabled = false;
        }
    }


    /* -------- General bank functions -------- */

    // Open bank account
    function OpenBankAccount() public
        returns (uint32 newBankAccountNumber) 
    {
        // Does this sender already have a bank account or a previously used address for a bank account?
        if (_bankAccountAddresses[msg.sender].accountSet)
        {
            throw;
        }

        // Assign the new bank account number
        newBankAccountNumber = _totalBankAccounts;

        // Add new bank account to the array
        _bankAccountsArray.push( 
            BankAccount(
            {
                passwordSha3HashSet: false,
                number: newBankAccountNumber,
                balance: 0,
                owner: msg.sender,
                passwordSha3Hash: "0",
            }
            ));

        // Prevent people using "password" or "Password" sha3 hash for the Security_AddPasswordSha3HashToBankAccount() function
        bytes32 passwordHash_ = sha3("password");
        _bankAccountsArray[newBankAccountNumber].passwordSha3HashesUsed[passwordHash_] = true;
        passwordHash_ = sha3("Password");
        _bankAccountsArray[newBankAccountNumber].passwordSha3HashesUsed[passwordHash_] = true;

        // Add the new account
        _bankAccountAddresses[msg.sender].accountSet = true;
        _bankAccountAddresses[msg.sender].accountNumber = newBankAccountNumber;

        // Value sent?
        if (msg.value > 0)
        {    
            _bankAccountsArray[newBankAccountNumber].balance += msg.value;
        }

        // Move to the next bank account
        _totalBankAccounts++;

        // Event
        event_bankAccountOpened_Successful(msg.sender, newBankAccountNumber);
        return newBankAccountNumber;
    }

    // Get account number from a owner address
    function GetBankAccountNumber() public      
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (uint32)
    {
	    return _bankAccountAddresses[msg.sender].accountNumber;
    }


    /* -------- Account functions -------- */

    function GetBankAccountBalance() public
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (uint256)
    {   
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber;
        return _bankAccountsArray[accountNumber_].balance;
    }

    function DepositToBankAccount() public
        modifier_doesSenderHaveABankAccount()
        returns (bool)
    {
        // Value sent?
        if (msg.value > 0)
        {
            uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 
            _bankAccountsArray[accountNumber_].balance += msg.value; 
            event_depositMadeToBankAccount_Successful(msg.value, accountNumber_);
            return true;
        }
        else
        {
            event_depositMadeToBankAccount_Failed(msg.value, accountNumber_);
            return false;
        }
    }

    function DepositToBankAccountFromDifferentAddress(uint32 accountNumber) public
        returns (bool)
    {
        // Check if bank account number is valid
        if (accountNumber >= _totalBankAccounts)
        {
           event_depositMadeToBankAccountFromDifferentAddress_Failed(msg.sender, msg.value, accountNumber);
           return false;     
        }    
            
        // Value sent?
        if (msg.value > 0)
        {   
            _bankAccountsArray[accountNumber].balance += msg.value; 
            event_depositMadeToBankAccountFromDifferentAddress_Successful(msg.sender, msg.value, accountNumber);
            return true;
        }
        else
        {
            event_depositMadeToBankAccountFromDifferentAddress_Failed(msg.sender, msg.value, accountNumber);
            return false;
        }
    }
    
    function WithdrawAmountFromBankAccount(uint256 amount) public
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (bool)
    {
        bool withdrawalSuccessful_ = false;
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 

        // Bank account has value that can be withdrawn?
        if (amount > 0 && _bankAccountsArray[accountNumber_].balance >= amount)
        {
            // Reduce the account balance 
            _bankAccountsArray[accountNumber_].balance -= amount;

            // Check if using send() is successful
            if (msg.sender.send(amount))
            {
 	            withdrawalSuccessful_ = true;
            }
            // Check if using call.value() is successful
            else if (msg.sender.call.value(amount)())
            {  
                withdrawalSuccessful_ = true;
            }  
            else
            {
                // Set the previous balance
                _bankAccountsArray[accountNumber_].balance += amount;
            }
        }

        if (withdrawalSuccessful_)
        {
            event_withdrawalMadeFromBankAccount_Successful(accountNumber_, amount); 
            return true;
        }
        else
        {
            event_withdrawalMadeFromBankAccount_Failed(accountNumber_, amount); 
            return false;
        }
    }

    function WithdrawFullBalanceFromBankAccount() public
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (bool)
    {
        bool withdrawalSuccessful_ = false;
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 

        // Bank account has value that can be withdrawn?
        if (_bankAccountsArray[accountNumber_].balance > 0)
        {
            uint256 fullBalance_ = _bankAccountsArray[accountNumber_].balance;

            // Reduce the account balance 
            _bankAccountsArray[accountNumber_].balance = 0;

            // Check if using send() is successful
            if (msg.sender.send(fullBalance_))
            {
 	            withdrawalSuccessful_ = true;
            }
            // Check if using call.value() is successful
            else if (msg.sender.call.value(fullBalance_)())
            {  
                withdrawalSuccessful_ = true;
            }  
            else
            {
                // Set the previous balance
                _bankAccountsArray[accountNumber_].balance = fullBalance_;
            }
        }  

        if (withdrawalSuccessful_)
        {
            event_withdrawalMadeFromBankAccount_Successful(accountNumber_, fullBalance_); 
            return true;
        }
        else
        {
            event_withdrawalMadeFromBankAccount_Failed(accountNumber_, fullBalance_); 
            return false;
        }
    }

    function TransferAmountFromBankAccountToAddress(uint256 amount, address destinationAddress) public
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (bool)
    {
        bool transferSuccessful_ = false; 
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 

        // Bank account has value that can be transfered?
        if (amount > 0 && _bankAccountsArray[accountNumber_].balance >= amount)
        {
            // Reduce the account balance 
            _bankAccountsArray[accountNumber_].balance -= amount; 

            // Check if using send() is successful
            if (destinationAddress.send(amount))
            {
 	            transferSuccessful_ = true;
            }
            // Check if using call.value() is successful
            else if (destinationAddress.call.value(amount)())
            {  
                transferSuccessful_ = true;
            }  
            else
            {
                // Set the previous balance
                _bankAccountsArray[accountNumber_].balance += amount;
            }
        }  

        if (transferSuccessful_)
        {
            event_transferMadeFromBankAccountToAddress_Successful(accountNumber_, amount, destinationAddress); 
            return true;
        }
        else
        {
            event_transferMadeFromBankAccountToAddress_Failed(accountNumber_, amount, destinationAddress); 
            return false;
        }
    }


    /* -------- Security functions -------- */

    function Security_AddPasswordSha3HashToBankAccount(bytes32 sha3Hash) public
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
    {
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 

        // Has this password hash been used before for this account?
        if (_bankAccountsArray[accountNumber_].passwordSha3HashesUsed[sha3Hash] == true)
        {
            return;        
        }

        // Set the account password sha3 hash
        _bankAccountsArray[accountNumber_].passwordSha3HashSet = true;
        _bankAccountsArray[accountNumber_].passwordSha3Hash = sha3Hash;
        _bankAccountsArray[accountNumber_].passwordSha3HashesUsed[sha3Hash] = true;

        event_securityPasswordSha3HashAddedToBankAccount(accountNumber_);
    }

    function Security_ConnectBankAccountToNewOwnerAddress(uint32 accountNumber, bytes32 password)
        modifier_wasValueSent()
        returns (bool)
    {
        // Can bank accounts be connected to a new owner address?
        if (_connectBankAccountToNewOwnerAddressEnabled == false)
        {
            event_securityConnectingABankAccountToANewOwnerAddressIsDisabled();
            return false;        
        }

        // Check if bank account number is valid
        if (accountNumber >= _totalBankAccounts)
        {
           return false;     
        }    

        // Has password sha3 hash been set?
        if (_bankAccountsArray[accountNumber].passwordSha3HashSet == false)
        {
            return false;           
        }

        // Check the password sha3 hash matches.
        // VERY IMPORTANT -
        // 
        // Ethereum uses KECCAK-256. It should be noted that it does not follow the FIPS-202 based standard (a.k.a SHA-3), 
        // which was finalized in August 2015.
        // 
        // Keccak-256 generator link (produces same output as solidity sha3()) - http://emn178.github.io/online-tools/keccak_256.html
        if (sha3(password) != _bankAccountsArray[accountNumber].passwordSha3Hash)
        {
            return false;        
        }

        // Set new bank account address owner and the update the owner address details 
        _bankAccountsArray[accountNumber].owner = msg.sender;
        _bankAccountAddresses[msg.sender].accountSet = true;
        _bankAccountAddresses[msg.sender].accountNumber = accountNumber;

        // Reset password sha3 hash
        _bankAccountsArray[accountNumber].passwordSha3HashSet = false;
        _bankAccountsArray[accountNumber].passwordSha3Hash = "0";
       
        event_securityBankAccountConnectedToNewAddressOwner(accountNumber, msg.sender);
        return true;
    }


    /* -------- Default function -------- */

    function() 
    {    
        // Does this sender have a bank account?
        if (_bankAccountAddresses[msg.sender].accountSet)
        {
            // Does the bank account owner address match the sender address?
            uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber;
            address accountOwner_ = _bankAccountsArray[accountNumber_].owner;
            if (msg.sender == accountOwner_) 
            {
                // Value sent?
                if (msg.value > 0)
                {    
                    // Update the bank account balance
                    _bankAccountsArray[accountNumber_].balance += msg.value;
                    event_depositMadeToBankAccount_Successful(msg.value, accountNumber_);
                }
            }
        }
        else
        {
            // Open a new bank account for the sender address - this function will also add any value sent to the bank account balance
            OpenBankAccount();
        }
    }
} 