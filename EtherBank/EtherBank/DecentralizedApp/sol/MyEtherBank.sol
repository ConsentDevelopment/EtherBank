contract MyEtherBank 
{
    /* -------- State data -------- */

    address _owner;
    bool private _openNewBankAccountsEnabled;
    uint256 private _bankDonationsBalance;
   
    // Account      
    struct BankAccountAddress
    {
        uint32 accountNumber;
        address accountOwner;        
    }   

    struct BankAccount 
    {
        bool accountSet;
        uint32 accountNumber;
            address accountOwner;
        uint256 balance;
        bytes32 passwordSha3Hash;
    }

    // Account owners
    mapping(address => BankAccount) private _bankAccounts;
    BankAccountAddress[] private _bankAccountsAddressArray; 

    // Total bank accounts
    uint32 private _totalBankAccounts;


    /* -------- Constructor -------- */

    function MyEtherBank()
    {
        // Set the contract owner
        _owner = msg.sender; 
        _openNewBankAccountsEnabled = true; 
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
        if (_bankAccounts[msg.sender].accountSet == false)
        {
            throw;
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

    event event_bankAccountOpened(address indexed bankAccountOwner, uint256 indexed bankAccountNumber);
    event event_depositMadeToBankAccount(uint256 indexed bankAccountNumber, uint256 indexed depositAmount); 
    event event_withdrawalMadeFromBankAccount(uint256 indexed bankAccountNumber, uint256 indexed withdrawalAmount); 
    event event_transferMadeFromBankAccountToAddress(uint256 indexed bankAccountNumber, uint256 indexed withdrawalAmount, address indexed destinationAddress); 
	event event_bankDonationsWithdrawn(uint256 donationsAmount);
	event event_securityPasswordHashAddedToBankAccount(uint256 indexed bankAccountNumber);


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






    /* -------- General bank functions -------- */

    // Open bank account
    function OpenBankAccount()
        returns (uint32 accountNumber)
    {
        // Can new bankaccounts be openned?
        if ( _openNewBankAccountsEnabled == false)
        {
            throw;        
        }

        // Does this sender already have a bank account?
        if (_bankAccounts[msg.sender].accountSet)
        {
            throw;
        }

        // Assign the new bank account number
        accountNumber = _totalBankAccounts;

        // Add new account to the array
        _bankAccountsAddressArray.push( BankAccountAddress(
            {
                accountNumber: accountNumber,
                accountOwner: msg.sender
            }
            ));

        // Add the new account
        _bankAccounts[msg.sender].accountNumber = accountNumber;
        _bankAccounts[msg.sender].accountSet = true;
        _bankAccounts[msg.sender].accountOwner = msg.sender;

        // Move to the next bank account
        _totalBankAccounts++;

        // Value sent?
        if (msg.value > 0)
        {
            _bankAccounts[msg.sender].balance += msg.value;
        }

        // Event
        event_bankAccountOpened(msg.sender, accountNumber);

        return accountNumber;
    }

    // Get account number from a existing account address
    function GetBankAccountNumber()       
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (uint256)
    {
	    return _bankAccounts[msg.sender].accountNumber;
    }


    /* -------- Account functions -------- */

    function GetBankAccountBalance()
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (uint256)
    {   
        return _bankAccounts[msg.sender].balance;
    }

    function DepositToBankAccount()
        modifier_doesSenderHaveABankAccount()
        returns (bool depositSuccessful)
    {
        // Value sent?
        if (msg.value > 0)
        {
            _bankAccounts[msg.sender].balance += msg.value; 
            depositSuccessful = true;
        }
            
        // Event
        if (depositSuccessful)
        { 
            event_depositMadeToBankAccount(_bankAccounts[msg.sender].accountNumber, msg.value);
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
        // Bank account has value that can be withdrawn?
        if (amount > 0 && _bankAccounts[msg.sender].balance >= amount)
        {
            // Reduce the account balance 
            _bankAccounts[msg.sender].balance -= amount;

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
                    event_withdrawalMadeFromBankAccount(_bankAccounts[msg.sender].accountNumber, amount); 
                    return true;
                }
            }
            else
            {
                event_withdrawalMadeFromBankAccount(_bankAccounts[msg.sender].accountNumber, amount); 
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
        // Bank account has value that can be withdrawn?
        if (_bankAccounts[msg.sender].balance > 0)
        {
            uint256 fullBalance = _bankAccounts[msg.sender].balance;

            // Reduce the account balance 
            _bankAccounts[msg.sender].balance = 0;

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
                    event_withdrawalMadeFromBankAccount(_bankAccounts[msg.sender].accountNumber, fullBalance); 
                    return true;
                }
            }
            else
            {
                event_withdrawalMadeFromBankAccount(_bankAccounts[msg.sender].accountNumber, fullBalance); 
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
        // Bank account has value that can be transfered?
        if (amount > 0 && _bankAccounts[msg.sender].balance >= amount)
        {
            // Reduce the account balance 
            _bankAccounts[msg.sender].balance -= amount;

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
                    event_transferMadeFromBankAccountToAddress(_bankAccounts[msg.sender].accountNumber, amount, destinationAddress); 
                    return true;
                }
            }
            else
            {
                event_transferMadeFromBankAccountToAddress(_bankAccounts[msg.sender].accountNumber, amount, destinationAddress); 
                return true;
            }
        }  

        return false;
    }


    /* -------- security functions -------- */

    function Security_AddPasswordSha3HashToAccount(bytes32 hash)
        modifier_doesSenderHaveABankAccount()
        modifier_wasValueSent()
        returns (bool)
    {
        



        // Set the account password hash
        _bankAccounts[msg.sender].passwordSha3Hash = hash;

        event_securityPasswordHashAddedToBankAccount(_bankAccounts[msg.sender].accountNumber);
        return true;
    }





    // Default function
    function() 
    {
        // If a address just sends a value or the wrong call data then just throw    
        throw;
    }
} 