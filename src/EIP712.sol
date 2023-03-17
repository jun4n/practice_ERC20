//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EIP712 {

    
    
    // name: signing domain의 이름(예를 ㄷ르어서 Dapp의 이름)
    // version: signing domain의 major version
    /*
EIP712Domain": [
      {
        "name": "name",
        "type": "string"
      },
      {
        "name": "version",
        "type": "string"
      },
      {
        "name": "chainId",
        "type": "uint256"
      },
      {
        "name": "verifyingContract",
        "type": "address"
      }
    ]
    */
    bytes32 private DOMAIN_SEPARATOR;
    constructor() {
        // DOMAIN_SEPRATOR 설정
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                "DREAM TOKEN",
                "1.0.0",
                block.chainid,
                address(this)
            )
        );
    }

    // 현재 체인의 DOMAIN_SEPERATOR를 리턴한다.
    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
    
    // 해싱된 structured data를 받아서 이 도메인에 완전히 인코딩된 EIP712로 만들어서 반환한다.
    // 도메인에 완전히 인코딩한다는건 DOMAIN SEPERATOR와 함께 해싱한다는 것
    //  bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline))
    function _toTypedDataHash(bytes32 structHash) public returns (bytes32 data) {
        bytes32 domain_separator = _domainSeparator();
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domain_separator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

}