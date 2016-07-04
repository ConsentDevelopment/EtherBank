# My Ether Bank
## Deposit, withdraw and transfer ether with no charges!

My Ether Bank is a Ethereum contract that gives users the ability to safely and securely store ether on the blockchain (like a wallet existing on the blockchain).

This contract also has security interfaces for connecting a bank account to a different owner address (wallet account - normal or contract).  This is useful in case your local wallet / keys (stored on PC, mobile, usb or a piece of paper) is lost, stolen or destroyed as you will be able to recover you ether funds in full using the contract.

The contract with the following interfaces :

* OpenBankAccount() - send payment transaction (ether value will be deposited to account) or use interface method.
* GetBankAccountNumber() - use interface method.
* GetBankAccountBalance() - use interface method.
* DepositToBankAccount() - send payment transaction or use interface method.
* DepositToBankAccountFromDifferentAddress(uint32 bankAccountNumber) - use interface method.
* WithdrawAmountFromBankAccount(uint256 amount) - user inteface method.
* WithdrawFullBalanceFromBankAccount - use interface method.