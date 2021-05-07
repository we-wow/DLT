pragma solidity ^0.6.0;

contract HCO {
    mapping (address => uint256) deposit;
    mapping (address => int256[13]) prefer;
    mapping (address => bool) hasInput;
    mapping (address => bool) settled;
    address[] agents;
    
    // Ballot
    receive() external payable {
        bool depositExisted = false;
        for(uint8 i = 0; i < agents.length; i++)
            if (agents[i] == msg.sender)
                depositExisted = true;
        require(
            depositExisted || agents.length <= 4,
            "Invalid address"
            );
        if (depositExisted)
            deposit[msg.sender] += msg.value;
        else
        {
            deposit[msg.sender] = msg.value;
            hasInput[msg.sender] = false;
            settled[msg.sender] = false;
            agents.push(msg.sender);
        }
    }
    
    // Deposit and account related functions
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function viewDeposit() public view returns(uint256){
        bool depositExisted = false;
        for(uint8 i = 0; i < agents.length; i++)
            if (agents[i] == msg.sender)
                depositExisted = true;
        
        require(
            depositExisted,
            "Not existed"
            );
        return deposit[msg.sender];
    }
    
    function getDeposit() public payable{
        bool depositExisted = false;
        for(uint8 i = 0; i < agents.length; i++)
            if (agents[i] == msg.sender)
                depositExisted = true;
        
        require(
            depositExisted && !hasInput[msg.sender],
            "Not authorized"
            );
        if (deposit[msg.sender] > 0)
            msg.sender.transfer(deposit[msg.sender]);
        deposit[msg.sender] = 0;
    }
    
    // Check whether all participants have submitted bid proposal
    function isAllInput() public view returns(bool, uint256){
        bool isInput = true;
        if (agents.length == 4)
        {
            for (uint8 i = 0; i < 4; i++)
                if (!hasInput[agents[i]])
                {
                    isInput = false;
                    break;
                }
        }
        else
            isInput = false;

        return (isInput, agents.length);
    }
    
    // Submit bid proposal
    event inOfferRes(
        bool success
        );
    function inOffer(int256[13] memory _prefer) public{
        bool depositExisted = false;
        for(uint8 i = 0; i < agents.length; i++)
            if (agents[i] == msg.sender)
                depositExisted = true;
        
        require(
            depositExisted,
            "Not authorized"
            );
        depositExisted = true;
        for (uint8 i = 0; i < 13; i++)
            if (_prefer[i] > 0 && uint256(_prefer[i]) > deposit[msg.sender])
            {
                depositExisted = false;
                break;
            }
        require(
            depositExisted,
            "Deposit is not enough"
            );
        bool allInput = true;
        for (uint8 i = 0; i < agents.length; i++)
            if (!hasInput[agents[i]])
            {
                allInput = false;
                break;
            }    
        
        if (!allInput)
        {
            prefer[msg.sender] = _prefer;
            hasInput[msg.sender] = true;
            emit inOfferRes(true);
        }
        else
            emit inOfferRes(false);
    }
    
    // Settlement
    event settlement(
        bool authorized,
        int8 bin,
        int256 payment
        );
    function settle() public {
        bool allInput = true;
        bool depositExisted = false;
        uint8 index;
        if (agents.length < 4) allInput = false;
        else
        {
            for(uint8 i = 0; i < 4; i++)
                if (agents[i] == msg.sender)
                    {
                        depositExisted = true;
                        index = i;
                        break;
                    }
            
            for (uint8 i = 0; i < 4; i++)
                if (!hasInput[agents[i]])
                {
                    allInput = false;
                    break;
                }
        }
        require(
            allInput && depositExisted && !settled[msg.sender],
            "Invalid time-point or account"
            );
        int256 maxOffer = 0;
        int8[4] memory res;
        for (int8 a = -6; a < 7; a++)
            for (int8 b = -6; b < 7; b++)
            {
                if ((a + b > 6 && a > 0) || (a + b < -6 && a < 0))
                    continue;
                for (int8 c = -6; c < 7; c++)
                {
                    if ((a + b + c > 6 && a > 0 && b > 0) || (a + b + c < -6 && a < 0 && b < 0)
                    || (a + c > 6 && a > 0) || (a + c < -6 && a < 0)
                    || (c + b > 6 && b > 0) || (c + b < -6 && b < 0))
                        continue;
                    for (int8 d = -6; d < 7; d++)
                    {
                        if(a + b + c + d == 0 &&
                        prefer[agents[0]][uint8(a+6)] + prefer[agents[1]][uint8(b+6)]+prefer[agents[2]][uint8(c+6)] + prefer[agents[3]][uint8(d+6)] > maxOffer)
                        {
                            maxOffer = prefer[agents[0]][uint8(a+6)] + prefer[agents[1]][uint8(b+6)]+prefer[agents[2]][uint8(c+6)] + prefer[agents[3]][uint8(d+6)];
                            res[0] = a;
                            res[1] = b;
                            res[2] = c;
                            res[3] = d;
                        }
                    }
                }
            }
        bool authorize = true;
        if (prefer[agents[index]][uint8(res[index] + 6)] > 0)
        {
            deposit[msg.sender] -= uint256(prefer[agents[index]][uint8(res[index]+6)]);
            for (uint8 i = 0; i < 4 && i != index; i++)
                if (prefer[agents[i]][uint8(res[i]+6)] > prefer[agents[index]][uint8(res[index]+6)])
                {
                    authorize = false;
                    break;
                }
        }
        else
            authorize = false;
        deposit[msg.sender] += uint256(maxOffer) / 4;
        settled[msg.sender] = true;
        allInput = true;
        for (uint8 i = 0; i < 4 && i != index; i++)
            if (!settled[agents[i]])
                allInput = false;
        if (allInput)
            for (uint8 i = 0; i < 4; i++)
            {
                settled[agents[i]] = false;
                hasInput[agents[i]] = false;
            }
        emit settlement(authorize, res[index], maxOffer / 4);            
    }
    
    // Reset contract
    function reset() public{
        while(agents.length > 0)
        {
            if (hasInput[agents[0]])
                delete prefer[agents[0]];
            delete hasInput[agents[0]];
            delete settled[agents[0]];
            delete deposit[agents[0]];
            agents.pop();
        }
    }
    
}
