pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}
/**
 * @title TokenERC20Interface
 * @dev A simple ERC20 standard token interface
 */
contract TokenERC20 {
    function balanceOf(address _owner) view public returns(uint256);
    function allowance(address _owner, address _spender) view public returns(uint256);
    function transfer(address _to, uint256 _value) public returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
    function approve(address _spender, uint256 _value) public returns(bool);
}


/**
 * @title ICO
 * @dev Initial Coin Offering Contract of AMOS token.
 */
contract airdrop is Ownable {
    using SafeMath for uint256;

    // Token contract instance
    TokenERC20 token;

    mapping(address => bool) public airdropUsed;

    // airdrop period.
    uint256 public startDate;
    uint256 public endDate;

    // Token Cap of airdrop
    uint256 public airdropPot;

    // Address where remaining token are collected.
    address public wallet;

    uint256 private airdropCount;

    /**
     * @dev Constructor of ICO contract
     * @param _token ICO token address
     * @param _wallet The address where funds are collected
     * @param _airdropPot The token amount for airdrop
     * @param _start Start date in seconds
     * @param _end End date in seconds
     */
    constructor(address _token, address _wallet, uint256 _airdropPot, uint256 _start, uint256 _end) public {
        token = TokenERC20(_token);
        wallet = _wallet;
        airdropPot = _airdropPot;
        startDate = _start;
        endDate = _end;
    }


    function airdropActive() public view returns (bool) {
        return (now >= startDate &&
                        now <= endDate);
    }

    /**
     * @dev Fallback function can be used to buy tokens
     */
    function () public{
        require(airdropActive());
        if(!airdropUsed[msg.sender]){
            airdropCount += 1;
            airdropUsed[msg.sender] = true;
            if (airdropCount < 100){
                airdropPot = airdropPot.sub(77000000000000000000);
                token.transfer(msg.sender,77000000000000000000);
            }
            else{
                airdropPot = airdropPot.sub(777000000000000000000);
                token.transfer(msg.sender,777000000000000000000);
                airdropCount = 0;
            }
        }
    }

    /**
     * @dev Withdraw unsold token in this contract back to the wallet
     */
    function withdrawToken() onlyOwner public{
        require(!airdropActive());
        token.transfer(wallet,airdropPot);
        airdropPot = 0;
    }

}