# My Ether Bank
## Deposit, withdraw and transfer ether with no charges!

My Ether Bank is a Ethereum contract that gives users the ability to safely and securely store ether on the blockchain (like a wallet existing on the blockchain).

This contract also has security interfaces for connecting a bank account to a different owner address (wallet account - normal or contract).  This is useful in case your local wallet / keys (stored on PC, mobile, usb or a piece of paper) is lost, stolen or destroyed as you will be able to recover you ether funds in full using the contract.

This contract with the following banking interfaces :

* OpenBankAccount() - send payment transaction (ether sent will be deposited to account) or use interface method.
* GetBankAccountNumber()
* GetBankAccountBalance()
* DepositToBankAccount() - send payment transaction (ether sent will be deposited to account) or use interface method.
* DepositToBankAccountFromDifferentAddress(uint32 bankAccountNumber)
* WithdrawAmountFromBankAccount(uint256 amount)
* WithdrawFullBalanceFromBankAccount()
* TransferAmountFromBankAccountToAddress(uint256 amount, address destinationAddress)

And security interfaces :

* Security_HasPasswordSha3HashBeenAddedToBankAccount()
* Security_AddPasswordSha3HashToBankAccount(bytes32 sha3Hash)
* Security_ConnectBankAccountToNewOwnerAddress(uint32 bankAccountNumber, string password)
* Security_GetNumberOfAttemptsToConnectBankAccountToANewOwnerAddress()

Note : Only the interface methods OpenBankAccount() (used the 1st time to open a bank account), DepositToBankAccount() and DepositToBankAccountFromDifferentAddress() will accept ether value from a payment transaction. This is to prevent users accidentally sending ether when using interfaces that do not require ether to be sent.

## Securing your My Ether Bank account :




## Developer and license information :

If you have any questions or issues regarding this contract then send a email to consentdev@gmail.com 

LICENSE - This Ethereum contract uses a MIT License.

This smart contract is free to use but donations are always welcome :
* Donate Ether - 0x65850dfd9c511a5da3132461d57817f56acc1906
* Donate Bitcoin - 36XRasACPNEvd3YxbLoWWeUfSgCUyZ69z8 