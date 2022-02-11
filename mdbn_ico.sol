// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20/ERC20.sol"; 
//import "https://github.com/ConsenSysMesh/openzeppelin-solidity/blob/master/contracts/crowdsale/Crowdsale.sol";


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract mdbn_ico{
    address public tokenWallet;
    address public wallet;
    uint256 public initialRate;
    uint256 public finalRate;
    uint256 public rate; 
    uint256 public weiRaised;

    ERC20 public token;

    constructor(uint256 _initialRate, uint256 _finalRate, address _tokenWallet, ERC20 _token) payable {
        require(_initialRate > 0);
        require(_finalRate > 0);

        rate = _initialRate;
        wallet = msg.sender;
        tokenWallet = _tokenWallet;
        token = _token;
        initialRate = _initialRate;
        finalRate = _finalRate;
    }

    receive () external payable {
        buyTokens(msg.sender);
    }

    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    function buyTokens(address _beneficiary) public payable{
        uint256 weiAmount = msg.value;

        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        weiRaised = weiRaised + weiAmount;

        _processPurchase(_beneficiary, tokens);

        emit TokenPurchase(
            msg.sender,
            _beneficiary,
            weiAmount,
            tokens
        );
        
        _forwardFunds();
    }

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256){
        return _weiAmount * rate;
    }

    //function getCurrentRate() public view returns (uint256) {
    // solium-disable-next-line security/no-block-members
    //uint256 elapsedTime = block.timestamp.sub(openingTime);
    //uint256 timeRange = closingTime.sub(openingTime);
    //uint256 rateRange = initialRate.sub(finalRate);
    //return initialRate.sub(elapsedTime.mul(rateRange).div(timeRange));
    //}

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal{
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal{
        //token.transfer(_beneficiary, _tokenAmount);
        token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);
    }

    function remainingTokens() public view returns (uint256) {
        return token.allowance(tokenWallet, address(this));
    }

    function _forwardFunds() internal {
        //wallet.transfer(msg.value);
        payable(wallet).transfer(msg.value);
    }

    // Validations
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) view internal{
        require(_beneficiary != address(0), "Beneficiary is null!");
        require(_weiAmount != 0, "Purchased Amount is zero!"); 
        require(_weiAmount > remainingTokens(), "Remaining Tokens < Purchased Amount!");
    }
}