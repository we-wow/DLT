"""
This is a python implementation for interacting with Ethereum.
@Time   : 2020/8/26 14:28
@Author : Wei Mingjiang
"""

from web3 import Web3, HTTPProvider

class Agent:
    """
    An class that interacts with Ethereum via web3.py
    """
    def __init__(self, ip, port, abi=None, contract_address=None, contract_code=None):
        self.device_ip = ip
        self.chain_port = port
        self.w3 = Web3(HTTPProvider("http://{}:{}".format(self.device_ip, self.chain_port)))
        self.abi = abi                              # Application binary interface of the smart contract
        self.contract_code = contract_code          # Binary files of the contract, for the deployment of smart contract
        self.contract_address = contract_address    # The address of the smart contract, for connecting to the deployed contract
        self.contract = None
        self.my = self.w3.eth.accounts[0]

    def unlock_account(self, account=None, pass_phrase="default account's pass phrase"):
        if account is None:
            account = self.my
        unlock = self.w3.geth.personal.unlock_account(account, pass_phrase)
        return unlock

    def wait(self, tx_hash):
        self.w3.geth.miner.start(4)
        tx_receipt = self.w3.eth.waitForTransactionReceipt(tx_hash)
        self.w3.geth.miner.stop()
        return tx_receipt

    def connect_contract(self):
        if self.abi is not None and self.contract_address is not None:
            address = Web3.toChecksumAddress(self.contract_address)
            self.contract = self.w3.eth.contract(address=address, abi=self.abi)  # get the contract
        else:
            raise Exception('Insufficient parameters')

    def deploy_contract(self):
        if self.abi is not None and self.contract_code is not None:
            self.contract = self.w3.eth.contract(abi=self.abi, bytecode=self.contract_code)
            if self.unlock_account(self.w3.eth.coinbase, 'pass phrase'):
                deploy_txn = self.contract.constructor().transact(
                    {
                        'from': self.w3.eth.coinbase,
                        'gas': 3000000
                    }
                )
                self.wait(deploy_txn)
                txn_receipt = self.w3.eth.getTransactionReceipt(deploy_txn)
                self.contract_address = txn_receipt['contractAddress']
        else:
            raise Exception('Insufficient parameters')


def deploy_contract(abi: list, code: str):
    """
    An example of the deployment of the contract.
    :param abi: Your contract's Application Binary Interface.
    :param code: Your contract's Binary files.
    :return: None
    """
    ip = ""
    chain_port = 0000
    agent = Agent(ip=ip, port=chain_port)
    agent.abi = abi
    agent.contract_code = code
    agent.deploy_contract()


if __name__ == '__main__':
    deploy_contract(abi=[], code='')