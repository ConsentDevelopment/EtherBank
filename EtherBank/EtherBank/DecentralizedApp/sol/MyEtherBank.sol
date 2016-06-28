contract MyEtherBank 
{
    /* -------- State data -------- */
    address _owner;
    uint256 _bankDonationsBalance;
   
    // Account               
    struct BankAccount 
    {
        bool accountSet;
        uint256 accountNumber;
        address accountOwner;
        uint256 balance;
    }

    // Account owners
    mapping(address => BankAccount) public _bankAccounts;

    // Total bank accounts
    uint256 _totalBankAccounts;


    /* -------- Constructor -------- */
    function MyEtherBank()
    {
        // Set the contract owner
        _owner = msg.sender;  
        _bankDonationsBalance = 0; 
    }


    /* -------- Modifiers -------- */
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


    /* -------- Contract owner functions -------- */

    function DonateToBank(uint256 amount)
    {
        if (amount > 0)
        {
            _bankDonationsBalance += amount;
        }
    }



    /* -------- General bank functions -------- */

    // Open bank account
    function OpenBankAccount()
        returns (uint256 accountNumber)
    {
        // Does this sender already have a bank account?
        if (_bankAccounts[msg.sender].accountSet)
        {
            // Throw
            throw;
        }

        // Assign the new bank account number
        accountNumber = _totalBankAccounts;

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






    // Default function
    function() 
    {
        // If a address just sends a value or the wrong call data then just throw    
        throw;
    }
} 