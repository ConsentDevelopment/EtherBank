# My Ether Bank
## Deposit, withdraw and transfer ether with no charges!

My Ether Bank is a Ethereum contract that gives users the ability to safely and securely store ether on the blockchain (like a wallet existing on the blockchain).

This contract also has security interface methods for connecting a bank account to a different owner address (wallet account - normal or contract).  This is useful in case your local wallet / keys (stored on PC, mobile, usb or a piece of paper) is lost, stolen or destroyed as you will be able to recover you ether funds in full using the contract.

This contract with the following banking interface methods :

* OpenBankAccount() - send payment transaction (ether sent will be deposited to your account) or use interface method.
* GetBankAccountNumber()
* GetBankAccountBalance()
* DepositToBankAccount() - send payment transaction (ether sent will be deposited to your account) or use interface method.
* DepositToBankAccountFromDifferentAddress(uint32 bankAccountNumber)
* WithdrawAmountFromBankAccount(uint256 amount)
* WithdrawFullBalanceFromBankAccount()
* TransferAmountFromBankAccountToAddress(uint256 amount, address destinationAddress)

And security interface methods :

* Security_HasPasswordSha3HashBeenAddedToBankAccount()
* Security_AddPasswordSha3HashToBankAccount(bytes32 sha3Hash)
* Security_ConnectBankAccountToNewOwnerAddress(uint32 bankAccountNumber, string password)
* Security_GetNumberOfAttemptsToConnectBankAccountToANewOwnerAddress()

Note : Only the interface methods OpenBankAccount() (used the 1st time to open a bank account), DepositToBankAccount() and DepositToBankAccountFromDifferentAddress() will accept ether value from a payment transaction. This is to prevent users accidentally sending ether when using interface methods that do not require ether to be sent.

## Securing your My Ether Bank account :

VERY IMPORTANT - please use the latest offical Ethereum wallet (if you use the Ethereum wallet client). Link - https://github.com/ethereum/mist/releases

Once you have opened a bank account then you can secure your account using the following process -

1. Call the interface method GetBankAccountNumber(). Store this number in a safe location. 

2. Call the interface method Security_AddPasswordSha3HashToBankAccount(bytes32 sha3Hash) and pass in your password sha3 hash output.
   Use the following link to convert your password to a sha3 hash output - https://emn178.github.io/online-tools/keccak_256.html (you can also use other sha3 generators as long as they use Keccak-256 encoding). VERY IMPORTANT - use a long and complex password (mixture of lowercase / uppercase characters and numbers) and ONLY pass in the sha3 hash output of your password into this interface. DO NOT pass in your actual password.

3. Keep the bank account number (see point 1. above) and password (see point 2. above) together in a safe and secure location. You will need this number and password to retrieve your full ether balance on the contract.
    
4. If your wallet / keys that you used to open a bank acount are lost, stolen or destroyed then you can create a new wallet / key address and call the interface method 
Security_ConnectBankAccountToNewOwnerAddress(uint32 bankAccountNumber, string password) and pass in your bank account number (see point 1. above) and the password you used to create a sha3 hash output (see point 2. above).  If the password hash values match then the bank account will be connected to the new caller address and you will be able to retrieve your full ether balance.

Important - You can call the interface method Security_AddPasswordSha3HashToBankAccount(bytes32 sha3Hash) as many times as you want but you cannot use a previously passed in password hash output.  Once a bank account is successfully connected to a new owner address then the stored bank account hash is reset and you will need to repeat the above process using the new owner address.

## Developer and license information :

If you have any questions or issues regarding this contract then send a email to consentdev@gmail.com 

LICENSE - This Ethereum contract uses a MIT License.

This smart contract is free to use but donations are always welcome :
* Donate Ether - 0x65850dfd9c511a5da3132461d57817f56acc1906
* Donate Bitcoin - 36XRasACPNEvd3YxbLoWWeUfSgCUyZ69z8 