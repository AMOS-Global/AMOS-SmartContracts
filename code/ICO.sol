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
contract ICO is Ownable {
    using SafeMath for uint256;

    // Token contract instance
    TokenERC20 token;

    // Amount of ether user sent
    mapping(address => uint256) public weiSent;

    // Sales period.
    uint256 public startDate;
    uint256 public endDate;

    // Token Cap of public sale
    uint256 public saleCap;

    // Remaining token to sell
    uint256 public supply;

    // Address where funds are collected.
    address public wallet;

    // Amount of raised money in wei.
    uint256 public weiRaised;
    // Event
    event TokenPurchase(address indexed purchaser, address indexed referrer, uint256 value, uint256 amount);

    /**
     * @dev Constructor of ICO contract
     * @param _token ICO token address
     * @param _wallet The address where funds are collected
     * @param _saleCap The token cap in public round
     * @param _start Start date in seconds
     * @param _end End date in seconds
     */
    constructor(address _token, address _wallet, uint256 _saleCap, uint256 _start, uint256 _end) public {
        token = TokenERC20(_token);
        wallet = _wallet;
        saleCap = _saleCap;
        supply = _saleCap;
        startDate = _start;
        endDate = _end;
    }

    function rate() public view returns(uint256){
        if(now < startDate + 15 days){
            return 21000;
        }
        else {
            return 20000;
        }
    }

    function saleActive() public view returns (bool) {
        return (now >= startDate &&
                        now <= endDate && supply > 0);
    }

    /**
     * @dev Fallback function can be used to buy tokens
     */
    function () payable public{
        if(msg.value > 0)
            buyTokens(address(0x0));
    }

    /**
     * @dev Buy tokens
     * @param ref The address of referrer
     */
    function buyTokens(address ref) public payable {
        require(saleActive());

        uint256 weiAmount = msg.value;

        address buyer = msg.sender;

        // Calculate token amount to be purchased
        uint256 amount = weiAmount.mul(rate());

        weiSent[buyer] = weiAmount.add(weiSent[buyer]);

        require(token.transfer(buyer,amount));

        if(ref != 0x0 && ref != buyer){
            require(token.transfer(ref, amount/10));
            amount = amount.add(amount/10);
        }

        // Update state.
        supply = supply.sub(amount);
        weiRaised = weiRaised.add(weiAmount);

        emit TokenPurchase(buyer, ref, weiAmount, amount);
    }

    /**
     * @dev Withdraw all ether in this contract back to the wallet
     */
    function withdraw() onlyOwner public {
        wallet.transfer(address(this).balance);
    }

    /**
     * @dev Withdraw unsold token in this contract back to the wallet
     */
    function withdrawToken() onlyOwner public{
        require(!saleActive());
        token.transfer(wallet,supply);
        supply = 0;
    }

}