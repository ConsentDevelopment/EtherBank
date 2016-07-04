# My Ether Bank
## Deposit, withdraw and transfer ether with no charges!

My Ether Bank is a Ethereum contract that gives users the ability to safely and securely store ether on the blockchain (like a wallet existing on the blockchain).

This contract also has security interfaces for connecting a bank account to a different owner address (wallet account - normal or contract).  This is useful in case your local wallet / keys (stored on PC, mobile, usb or a piece of paper) is lost, stolen or destroyed as you will be able to recover you ether funds in full using the contract.

This contract with the following banking interfaces :

* OpenBankAccount() - send payment transaction (ether value will be deposited to account) or use interface method.
* GetBankAccountNumber()
* GetBankAccountBalance()
* DepositToBankAccount() - send payment transaction (ether value will be deposited to account) or use interface method.
* DepositToBankAccountFromDifferentAddress(uint32 bankAccountNumber)
* WithdrawAmountFromBankAccount(uint256 amount)
* WithdrawFullBalanceFromBankAccount()
* TransferAmountFromBankAccountToAddress(uint256 amount, address destinationAddress)

And security interfaces :

* Security_HasPasswordSha3HashBeenAddedToBankAccount()
* Security_AddPasswordSha3HashToBankAccount(bytes32 sha3Hash)
* Security_ConnectBankAccountToNewOwnerAddress(uint32 bankAccountNumber, string password)
* Security_getNumberOfAttemptsToConnectBankAccountToANewOwnerAddress()
