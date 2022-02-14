// ███    ███  █████  ██████   █████  ██████  ██ ███    ██  █████      ██████  ██████  ███    ███ 
// ████  ████ ██   ██ ██   ██ ██   ██ ██   ██ ██ ████   ██ ██   ██    ██      ██    ██ ████  ████ 
// ██ ████ ██ ███████ ██   ██ ███████ ██████  ██ ██ ██  ██ ███████    ██      ██    ██ ██ ████ ██ 
// ██  ██  ██ ██   ██ ██   ██ ██   ██ ██   ██ ██ ██  ██ ██ ██   ██    ██      ██    ██ ██  ██  ██ 
// ██      ██ ██   ██ ██████  ██   ██ ██████  ██ ██   ████ ██   ██ ██  ██████  ██████  ██      ██

// SPDX-License-Identifier: MIT

// Deploy Params for testing: 
//"0x72480bC5a8a4ca9ed3008cEc09256432c867Eb8f", "0xf86547d54fad2f2b4454e887b6c0e7336fbc094a", "0x70B7562b53b4c7563A0c4DFccf307DfA1e8E81DC"

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Verify-Signature.sol";

contract AffiliateManagementSystem is VerifySignature{
    address public owner;
    address public tokenWallet;
    address public wallet;
    address public signer;
    uint256 public weiClaimed;

    ERC20 public token; // MDBN Token

    mapping (uint => bool) public nonces; // Securité for replay attack

    //VerifySignature public verifySignature;

    constructor(address _tokenWallet, ERC20 _token, address _signer) {
        owner = msg.sender;
        wallet = msg.sender;
        tokenWallet = _tokenWallet;
        token = _token; 
        signer = _signer; 
    }

    // Events
    event Rewarded(
        address indexed to,
        uint256 nonce,
        uint256 amount
    );

    // Claim reward
    function claimReward( 
        address _to,
        uint256 _amount, 
        uint256 _nonce,
        bytes memory _signature
    ) public{
         
        _preValidateReward(_to, _amount, _nonce, _signature); 
        uint256 tokens = _amount; 

        weiClaimed = weiClaimed + _amount;

        _processReward(_to, tokens);

        emit Rewarded( 
            _to,
            _amount,
            tokens
        );        
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

    // Validations
    function _preValidateReward(address _to, uint256 _amount, uint256 _nonce, bytes memory _signature) view public{
        // # check signer
        require(verifySignature(signer, _to, _amount, _nonce, _signature) != true, "Signature Error");
        // # check nonce
        require(nonces[_nonce] != true, "Already Claimed");

        require(_to != address(0), "Beneficiary is null!");
        require(_amount != 0, "Purchased Amount is zero!"); 
        require(_amount > remainingTokens(), "Remaining Tokens < Reward Amount!");
    }

    // setSigner
    function setSigner  (address _signer) public onlyOwner{
        signer = _signer;
    }

    // setOwner
    function setOwner  (address _owner) public onlyOwner{
        owner = _owner;
    }

    // Modifier onlyOwner
    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }
}