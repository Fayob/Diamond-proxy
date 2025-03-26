// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "../interfaces/IERC20.sol";

error INVALID_ADDRESS();
error INSUFFICIENT_BALANCE();
error INSUFFICIENT_ALLOWANCE();
error VALUE_MUST_BE_GREATER_THAN_ZERO();
error ONLY_OWNER_IS_AUTHORIZE();

contract ERC20 is IERC20 {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private immutable _decimal;

    address owner;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 value
    );
    event Mint(address indexed _owner, uint256 value);
    event Burnt(address indexed _owner, uint256 value);

    constructor(
        string memory _name_,
        string memory _symbol_,
        uint8 _decimal_,
        uint256 _totalSupply_
    ) {
        _name = _name_;
        _symbol = _symbol_;
        _decimal = _decimal_;
        _totalSupply = _totalSupply_ * (10 ** uint256(_decimal));
        balances[msg.sender] = _totalSupply;

        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert ONLY_OWNER_IS_AUTHORIZE();
        _;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        if (_spender == address(0)) revert INVALID_ADDRESS();

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        if (_to == address(0)) revert INVALID_ADDRESS();
        if (balances[msg.sender] < _value) revert INSUFFICIENT_BALANCE();

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        success = true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        if (_from == address(0) || _to == address(0)) revert INVALID_ADDRESS();
        if (_value <= 0) revert VALUE_MUST_BE_GREATER_THAN_ZERO();
        if (allowances[_from][msg.sender] < _value)
            revert INSUFFICIENT_ALLOWANCE();

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        success = true;
    }

    function mint(uint256 _value) public onlyOwner returns (bool) {
        if (_value <= 0) revert VALUE_MUST_BE_GREATER_THAN_ZERO();

        balances[msg.sender] += _value;
        _totalSupply += _value;

        emit Mint(msg.sender, _value);

        return true;
    }

    function burn(uint256 _value) public returns (bool) {
        if (msg.sender == address(0)) revert INVALID_ADDRESS();
        if (balances[msg.sender] < _value) revert INSUFFICIENT_BALANCE();

        balances[msg.sender] -= _value;
        _totalSupply -= _value;

        emit Burnt(msg.sender, _value);

        return true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimal;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        if (_owner == address(0)) revert INVALID_ADDRESS();
        balance = balances[_owner];
    }

    function allowance(
        address _token_owner,
        address _spender
    ) public view returns (uint256 remaining) {
        if (_token_owner == address(0) || _spender == address(0))
            revert INVALID_ADDRESS();
        remaining = allowances[_token_owner][_spender];
    }
}