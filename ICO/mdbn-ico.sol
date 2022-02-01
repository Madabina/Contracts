// ███    ███  █████  ██████   █████  ██████  ██ ███    ██  █████      ██████  ██████  ███    ███ 
// ████  ████ ██   ██ ██   ██ ██   ██ ██   ██ ██ ████   ██ ██   ██    ██      ██    ██ ████  ████ 
// ██ ████ ██ ███████ ██   ██ ███████ ██████  ██ ██ ██  ██ ███████    ██      ██    ██ ██ ████ ██ 
// ██  ██  ██ ██   ██ ██   ██ ██   ██ ██   ██ ██ ██  ██ ██ ██   ██    ██      ██    ██ ██  ██  ██ 
// ██      ██ ██   ██ ██████  ██   ██ ██████  ██ ██   ████ ██   ██ ██  ██████  ██████  ██      ██

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC20/ERC20.sol"; 
//import "https://github.com/ConsenSysMesh/openzeppelin-solidity/blob/master/contracts/crowdsale/Crowdsale.sol";


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract mdbn_ico{
    address public tokenWallet;
    address public wallet;
    uint256 public rate; 
    uint256 public weiRaised;

    ERC20 public token;

    constructor(uint256 _rate, address _tokenWallet, ERC20 _token) payable {
        require(_rate > 0);

        rate = _rate;
        wallet = msg.sender;
        tokenWallet = _tokenWallet;
        token = _token;
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

        //_updatePurchasingState(_beneficiary, weiAmount);
        _forwardFunds();
        //_postValidatePurchase(_beneficiary, weiAmount);
    }

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256){
        return _weiAmount * rate;
    }


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
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) pure internal{
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }
}