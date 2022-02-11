// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Verify-Signature.sol";

contract AffiliateManagementSystem is VerifySignature{
    address public tokenWallet;
    address public wallet;
    address public signer;
    uint256 public weiClaimed;

    ERC20 public token;

    //VerifySignature public verifySignature;

    constructor(address _tokenWallet, ERC20 _token, address _signer) payable { 
        wallet = msg.sender;
        tokenWallet = _tokenWallet;
        token = _token; 
        signer = _signer; 
    }

    // Events
    event Rewarded(
        address indexed wallet_address,
        uint256 nonce,
        uint256 amount
    );

    // Claim reward
    function claimReward(address _beneficiary, uint256 _nonce, uint256 _weiAmount, string memory _message, bytes memory _sig) public{
         
        _preValidateReward(_beneficiary, _weiAmount); 
        uint256 tokens = _weiAmount; 

        weiClaimed = weiClaimed + _weiAmount;

        _processReward(_beneficiary, tokens);

        emit Rewarded( 
            _beneficiary,
            _weiAmount,
            tokens
        );
        
        _forwardFunds();
    } 

    function _processReward(address _beneficiary, uint256 _tokenAmount) internal{
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal{ 
        token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);
    }

    function remainingTokens() public view returns (uint256) {
        return token.allowance(tokenWallet, address(this));
    }

    function _forwardFunds() internal { 
        payable(wallet).transfer(msg.value);
    }

    // Validations
    function _preValidateReward(address _beneficiary, uint256 _weiAmount) view internal{
        require(_beneficiary != address(0), "Beneficiary is null!");
        require(_weiAmount != 0, "Purchased Amount is zero!"); 
        require(_weiAmount > remainingTokens(), "Remaining Tokens < Reward Amount!");
    }
}