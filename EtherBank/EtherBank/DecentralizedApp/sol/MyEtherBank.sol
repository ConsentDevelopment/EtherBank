contract MyEtherBank 
{
    /* -------- State data -------- */

    // Owner
    address _owner;
    uint256 private _bankDonationsBalance;
    bool private _openNewBankAccountsEnabled;
    bool private _connectBankAccountToNewOwnerAddressEnabled;

    // Bank accounts    
    struct BankAccount
    {
        uint32 number; 
        address owner;      
        uint256 balance;
        bytes32 passwordSha3Hash;   
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

    function MyEtherBank()
    {
        // Set the contract owner
        _owner = msg.sender; 
        _openNewBankAccountsEnabled = true; 
        _connectBankAccountToNewOwnerAddressEnabled = true;
        _bankDonationsBalance = 0; 
    }


    /* -------- Modifiers -------- */

    modifier modifier_isContractOwner()
    { 
        // Value sent?
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
            uint32 accountNumber = _bankAccountAddresses[msg.sender].accountNumber;
            address accountOwner = _bankAccountsArray[accountNumber].owner;
            if (msg.sender != accountOwner) 
            {
                // This could occur if a bank account is connected to a new owner address and 
                // the previous owner address tries to access the bank account
                event_noBankAccountConnectedToAddress(msg.sender);
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

    event event_noBankAccountConnectedToAddress(address indexed senderAddress);
    event event_bankAccountOpened(address indexed bankAccountOwner, uint32 indexed bankAccountNumber);
    event event_newBankAccountsAreDisabled();
    event event_depositMadeToBankAccount(uint32 indexed bankAccountNumber, uint256 indexed depositAmount); 
    event event_depositMadeToBankAccountFromDifferentAddress(address indexed addressFrom, uint256 indexed depositAmount, uint32 indexed bankAccountNumber);
    event event_withdrawalMadeFromBankAccount(uint32 indexed bankAccountNumber, uint256 indexed withdrawalAmount); 
    event event_transferMadeFromBankAccountToAddress(uint32 indexed bankAccountNumber, uint256 indexed withdrawalAmount, address indexed destinationAddress); 
	event event_bankDonationsWithdrawn(uint256 donationsAmount);
 
    // Security
    event event_securityNewBankAccountsAreDisabled();
    event event_securityConnectingABankAccountToANewOwnerAddressIsDisabled();
	event event_securityPasswordSha3HashAddedToBankAccount(uint32 indexed bankAccountNumber);
    event event_securityBankAccountConnectedToNewAddressOwner(uint32 indexed bankAccountNumber, address indexed newAddressOwner);

     /* -------- Contract owner functions -------- */

    function Donate(uint256 amount)
    {
        if (amount > 0)
        {
            _bankDonationsBalance += amount;
        }
    }

    function BankOwner_WithdrawDonations(address destinationAddress)
        modifier_isContractOwner()
    { 
        if (_bankDonationsBalance > 0)
        {
            uint256 amount_ = _bankDonationsBalance;
            _bankDonationsBalance = 0;

            // Check if using send() is successful
            if (!msg.sender.send(amount_))
            {
                throw;
            }
            else
            {
                event_bankDonationsWithdrawn(amount_);
            }
        }
    }

    function BankOwner_EnableNewBankAccountsToBeAdded()
        modifier_isContractOwner()
    { 
        if (_openNewBankAccountsEnabled == false)
        {
            _openNewBankAccountsEnabled = true;
        }
    }

    function BankOwner_DisableNewBankAccountsToBeAdded()
        modifier_isContractOwner()
    { 
        if (_openNewBankAccountsEnabled)
        {
            _openNewBankAccountsEnabled = false;
        }
    }

    function BankOwner_EnableConnectBankAccountToNewOwnerAddress()
        modifier_isContractOwner()
    { 
        if (_connectBankAccountToNewOwnerAddressEnabled == false)
        {
            _connectBankAccountToNewOwnerAddressEnabled = true;
        }
    }

    function  BankOwner_DisableConnectBankAccountToNewOwnerAddress()
        modifier_isContractOwner()
    { 
        if (_connectBankAccountToNewOwnerAddressEnabled)
        {
            _connectBankAccountToNewOwnerAddressEnabled = false;
        }
    }


    /* -------- General bank functions -------- */

    // Open bank account
    function OpenBankAccount()
        returns (uint32 newBankAccountNumber)
    {
        // Can new bank accounts be opened?
        if ( _openNewBankAccountsEnabled == false)
        {
            event_newBankAccountsAreDisabled();
            throw;        
        }

        // Does this sender already have a bank account?
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
                number: newBankAccountNumber,
                owner: msg.sender,
                balance: 0,
                passwordSha3Hash: 0
            }
            ));

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
        event_bankAccountOpened(msg.sender, newBankAccountNumber);
        return newBankAccountNumber;
    }

    // Get account number from a existing account address
    function GetBankAccountNumber()       
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (uint32)
    {
	    return _bankAccountAddresses[msg.sender].accountNumber;
    }


    /* -------- Account functions -------- */

    function GetBankAccountBalance()
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (uint256)
    {   
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber;
        return _bankAccountsArray[accountNumber_].balance;
    }

    function DepositToBankAccount()
        modifier_doesSenderHaveABankAccount()
        returns (bool)
    {
        // Value sent?
        if (msg.value > 0)
        {
            uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 
            _bankAccountsArray[accountNumber_].balance += msg.value; 
            event_depositMadeToBankAccount(accountNumber_, msg.value);
            return true;
        }
        else
        {
            return false;
        }
    }

    function DepositToBankAccountFromDifferentAddress(uint32 accountNumber)
        returns (bool)
    {
        // Check if bank account number is valid
        if (accountNumber >= _totalBankAccounts)
        {
           return false;     
        }    
            
        // Value sent?
        if (msg.value > 0)
        {   
            _bankAccountsArray[accountNumber].balance += msg.value; 
            event_depositMadeToBankAccountFromDifferentAddress(msg.sender, msg.value, accountNumber);
            return true;
        }
        else
        {
            return false;
        }
    }
    
    function WithdrawAmountFromBankAccount(uint32 amount)
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (bool)
    {
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 

        // Bank account has value that can be withdrawn?
        if (amount > 0 &&  _bankAccountsArray[accountNumber_].balance >= amount)
        {
            // Reduce the account balance 
            _bankAccountsArray[accountNumber_].balance -= amount;

            // Check if using send() is successful
            if (!msg.sender.send(amount))
            {
                // Check if using call.value() is successful
                if (!msg.sender.call.value(amount)())
                {
                    throw;
                }
                else
                {
                    event_withdrawalMadeFromBankAccount(accountNumber_, amount); 
                    return true;
                }
            }
            else
            {
                event_withdrawalMadeFromBankAccount(accountNumber_, amount); 
                return true;
            }
        }  

        return false;
    }

    function WithdrawFullBalanceFromBankAccount()
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (bool)
    {
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 

        // Bank account has value that can be withdrawn?
        if (_bankAccountsArray[accountNumber_].balance > 0)
        {
            uint256 fullBalance = _bankAccountsArray[accountNumber_].balance;

            // Reduce the account balance 
            _bankAccountsArray[accountNumber_].balance = 0;

            // Check if using send() is successful
            if (!msg.sender.send(fullBalance))
            {
                // Check if using call.value() is successful
                if (!msg.sender.call.value(fullBalance)())
                {
                    throw;
                }
                else
                {
                    event_withdrawalMadeFromBankAccount(accountNumber_, fullBalance); 
                    return true;
                }
            }
            else
            {
                event_withdrawalMadeFromBankAccount(accountNumber_, fullBalance); 
                return true;
            }
        }  

        return false;
    }

    function TransferAmountFromBankAccountToAddress(uint256 amount, address destinationAddress)
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (bool)
    {
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 

        // Bank account has value that can be transfered?
        if (amount > 0 && _bankAccountsArray[accountNumber_].balance >= amount)
        {
            // Reduce the account balance 
            _bankAccountsArray[accountNumber_].balance -= amount;

            // Check if using send() is successful
            if (!destinationAddress.send(amount))
            {
                // Check if using call.value() is successful
                if (!destinationAddress.call.value(amount)())
                {
                    throw;
                }
                else
                {
                    event_transferMadeFromBankAccountToAddress(accountNumber_, amount, destinationAddress); 
                    return true;
                }
            }
            else
            {
                event_transferMadeFromBankAccountToAddress(accountNumber_, amount, destinationAddress); 
                return true;
            }
        }  

        return false;
    }


    /* -------- Security functions -------- */

    function Security_AddPasswordSha3HashToBankAccount(bytes32 sha3Hash)
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
    {
        uint32 accountNumber_ = _bankAccountAddresses[msg.sender].accountNumber; 

        // Set the account password sha3 hash
        _bankAccountsArray[accountNumber_].passwordSha3Hash = sha3Hash;

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

        // Check the sha3 hash password
        if (sha3(password) != _bankAccountsArray[accountNumber].passwordSha3Hash)
        {
            return false;        
        }

        // Set new bank account address owner
        _bankAccountsArray[accountNumber].owner = msg.sender;

        // Reset password sha3 hash
        _bankAccountsArray[accountNumber].passwordSha3Hash = 0;
       
        event_securityBankAccountConnectedToNewAddressOwner(accountNumber, msg.sender);
        return true;
    }


    /* -------- Default function -------- */

    function() 
    {
        // If a address just sends a value or the wrong call data then just throw    
        throw;
    }
} 