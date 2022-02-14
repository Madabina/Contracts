// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

/* Signature Verification
# Signing
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

# Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
*/

contract VerifySignature {

    /* 1. Unlock MetaMask account
    ethereum.enable()
    */

    /* 2. Get message hash to sign
    getMessageHash(
        0x72480bC5a8a4ca9ed3008cEc09256432c867Eb8f,
        20, 
        9000
    )

    hash = "0xa0717b9d9b83fef1e620a37f5bf461a37af59f73cbb167ba76905e863aa1de67"
    */
    function getMessageHash(
        address _to,
        uint256 _amount,
        /*string memory _message,*/
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, /*_message,*/ _nonce));
    }  

/* 2. Get getEncodePacked
    getEncodePacked(
        0x72480bC5a8a4ca9ed3008cEc09256432c867Eb8f,
        20, 
        9000
    )*/
    function getEncodePacked(
        address _to,
        uint256 _amount,
        /*string memory _message,*/
        uint256 _nonce
    ) public pure returns ( bytes memory) {
        bytes memory res = abi.encodePacked(_to, _amount, /*_message,*/ _nonce);
        return res;
    }

    /* 3. Sign message hash
    # using browser
    account_signer = "0x70B7562b53b4c7563A0c4DFccf307DfA1e8E81DC"
    ethereum.request({ method: "personal_sign", params: ["0x70B7562b53b4c7563A0c4DFccf307DfA1e8E81DC", "hash"]}).then(console.log)

    # using web3
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    Signature will be different for different accounts :
    0x00000000000000000000000000000000000000000000
    */
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }



    /* 4. Verify signature
    signer = 0x70B7562b53b4c7563A0c4DFccf307DfA1e8E81DC
    to = 0x72480bC5a8a4ca9ed3008cEc09256432c867Eb8f
    amount = 20 
    nonce = 1
    signature = 0x00000000000000000000000000000000000
    */
    function verifySignature(
        address _signer,
        address _to,
        uint256 _amount,
        /*string memory _message,*/
        uint256 _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, /*_message,*/ _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }


    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        //require(sig.length == 64, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}