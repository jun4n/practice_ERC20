// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP712.sol";

contract ERC20 is EIP712{
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    // prevent replay attack
    mapping(address => uint256) private nonce;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    bool private lock = false;
    address private owner;


    constructor (string memory name_, string memory symbol_) {
        owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;
    }

    function name() public view returns(string memory) {
        return _name;
    }
    function symbol() public view returns(string memory) {
        return _symbol;
    }
    function decimals() public view returns(uint8){
        return _decimals;
    }
    function totalSupply() public view returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address _owner) public view returns(uint256){
        return balances[_owner];
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address _to, uint256 _value) external returns(bool success){
        require(lock == false, "paused now");
        require(_to != address(0), "transfer to the zero address");
        require(balances[msg.sender] >= _value, "value exceeds balance");

        unchecked{
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool success) {
        require(_spender != address(0), "approve to the zero address");

        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
        require(lock == false, "paused now");
        require(_from != address(0), "transfer to zero address");
        require(_to != address(0), "transfer to zero address");

        uint currentAllowance = allowances[_from][msg.sender];
        if(currentAllowance != type(uint256).max) {
            require(currentAllowance >= _value, "insufficient allowance");
            unchecked {
                allowances[_from][msg.sender] -= _value;
            }
        }

        require(balances[_from] >= _value, "value exceed balance");
        unchecked {
            balances[_from] -= _value;
            balances[_to] += _value;
        }
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    function _mint(address _owner, uint256 _value) internal {
        require(_owner != address(0), "mint to the zero address");
        _totalSupply += _value;
        unchecked {
            balances[_owner] += _value;
        }
        emit Transfer(address(0), _owner, _value);
    }
    function _burn(address _owner, uint256 _value) internal {
        require(_owner != address(0), "burn from the zero address");
        require(balances[_owner] >= _value, "burn amount exceeds balance");

        unchecked{
            balances[_owner] -= _value;
            _totalSupply -= _value;
        }
        emit Transfer(msg.sender, address(0), _value);
    }

    function pause() public {
        require(msg.sender == owner, "only owner can pause");
        lock = true;
    }

/*
"message": {
    "owner": owner,
    "spender": spender,
    "value": value,
    "nonce": nonce,
    "deadline": deadline
  }*/
    function permit(address _owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(block.timestamp <= deadline, "dead line is alread passed");

        bytes32 structHash = keccak256(abi.encode(
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
            _owner,
            spender,
            value,
            nonce[_owner],
            deadline
        ));
        bytes32 hash = _toTypedDataHash(structHash);

        address signer = ecrecover(hash, v, r, s);

        require(signer == _owner, "INVALID_SIGNER");
        _approve(_owner, spender, value);
        nonce[_owner] += 1;
    }

    function _approve(address _owner, address _spender, uint _value) private {
        require(_spender != address(0), "approve to the zero address");

        allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function nonces(address owner) external view returns (uint) {
        return nonce[owner];
    }
 }