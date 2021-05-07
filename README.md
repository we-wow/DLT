# DLT
This is a prototype implementation of smart contract of the paper of 
[ Peer-to-Peer Electricity Trading of Interconnected Flexible Distribution Networks Based on Distributed Ledger].

* In the design of smart contracts: 
  The feasible SOP solution set is primarily formed considering the SOP power balance constraints after receiving offer lists from all the regions. 
  Second, the modified HCO principle is adopted to intelligently determine the trading solution resulting in the least summed operation costs of all the interconnected regions. 
  Then, based on the average-profit sharing principle, the trading price is automatically settled without privacy sharing. 
  Finally, the traded SOP operation schedules are sent to related controllers of regions.

* The smart contract is written in Solidity language, compiled using the Remix IDE, deployed on the private chain using the Web3.py client and executed on an Ethereum Virtual Machine (EVM).