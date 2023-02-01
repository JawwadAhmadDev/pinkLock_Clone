// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero.");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


contract PinksaleICO is ReentrancyGuard {
    using SafeMath for uint256;

    struct ICOInfo {
        IERC20 sale_token; // Sale token
        IERC20 buy_token; // in case of buy with BUSD/USDT/USDC
        string buy_token_name; // used to store buy token name to get at front end.
        uint256 token_rate; // 1 base token = ? s_tokens, fixed price
        uint256 token_supply; // total supply user will sale by creating an ICO.
        uint256 ICO_start;
        uint256 ICO_end;
    }

    struct ICOStatus {
        uint256 raised_amount; // Total base currency raised (usually ETH)
        uint256 sold_amount; // Total ICO tokens sold
        uint256 num_buyers; // Number of unique participants
    }

    struct BuyerInfo {
        uint256 base; // Total base token (usually ETH) deposited by user, can be withdrawn on presale failure
        uint256 sale; // Num presale tokens a user owned, can be withdrawn on presale success
    }
    
    struct TokenInfo {
        string name;
        string symbol;
        uint256 decimal;
    }

    address public owner;

    ICOInfo public ICO_info;
    ICOStatus public status;
    TokenInfo public tokeninfo;

    uint256 public ICOSetting;


    mapping(address => BuyerInfo) private buyers;

    event ICOCreated(address, address);
    event UserDepsitedSuccess(address, uint256);
    event OwnerWithdrawRemainingTokensSuccess(uint256);
    event OwnerWithdrawCollectedBNBSuccess(uint256);
    event OwnerWithdrawCollectedTokenSuccess(uint256);

    modifier onlyOwner() {
        require(owner == msg.sender, "Not ICO owner.");
        _;
    }


    constructor(
        address owner_,
        IERC20 _sale_token,
        IERC20 _buy_token,
        string memory _buy_token_name,
        uint256 _token_rate,
        uint256 _token_supply,
        uint256 _ICO_start,
        uint256 _ICO_end
    ) {
        owner = msg.sender;
        init_private(
            _sale_token,
            _buy_token,
            _buy_token_name,
            _token_rate,
            _token_supply,
            _ICO_start,
            _ICO_end
        );
        owner = owner_;
        
        emit ICOCreated(owner, address(this));
    }

    function init_private (
        IERC20 _sale_token,
        IERC20 _buy_token,
        string memory _buy_token_name,
        uint256 _token_rate,
        uint256 _token_supply,
        uint256 _ICO_start,
        uint256 _ICO_end
        ) private onlyOwner {

        require(ICOSetting == 0, "Already setted");
        require(address(_sale_token) != address(0), "Zero Address");
        
        ICO_info.sale_token = _sale_token;
        if(address(_buy_token) != address(0)){
            ICO_info.buy_token = _buy_token;
        }
        ICO_info.buy_token_name = _buy_token_name;
        ICO_info.token_rate = _token_rate;
        ICO_info.token_supply = _token_supply;
        ICO_info.ICO_end = _ICO_end;
        ICO_info.ICO_start =  _ICO_start;

        //Set token token info
        tokeninfo.name = ICO_info.sale_token.name();
        tokeninfo.symbol = ICO_info.sale_token.symbol();
        tokeninfo.decimal = ICO_info.sale_token.decimals();

        ICOSetting = 1;
    }

    // Receive BNB and transfer ERC20 token according to the set exchange rate.
    function buyWithBNB() external payable nonReentrant {
        require(block.timestamp >= ICO_info.ICO_start && block.timestamp <= ICO_info.ICO_end, "ICO: Invalid buy time");

        address _buyer = msg.sender; // for later redundent use. Purpose: Gas consumption.
        uint256 _BNBAmount_in = msg.value; // for later redundent use. Purpose: gas consumption.
        uint256 _actualBNB_in; // actual amount of bnb to be received.
        uint256 _tokens_out; // total ERC20 tokens out.
        uint256 _remaining_out; // unused amount of bnb
        uint256 _remaining_supply = remainingSupply();

        require(_BNBAmount_in > 0, "ICO: Invalid amount of sent BNB");
        require(address(ICO_info.buy_token) == address(0), "ICO: Token cannot buy with bnb");
        _tokens_out = _BNBAmount_in * ICO_info.token_rate;

        if(_tokens_out > _remaining_supply) {
            _tokens_out = _remaining_supply; // actual tokens out.
            _remaining_out = _BNBAmount_in.sub(_tokens_out.div(ICO_info.token_rate)); // unused bnb amount.
            _actualBNB_in = _BNBAmount_in.sub(_remaining_out); // acutual bnb amount to be received.
            _BNBAmount_in = _actualBNB_in; // update the _BNBAmount_in value for later use.
        }

        BuyerInfo storage buyer = buyers[_buyer];
        if(buyer.base == 0){
            status.num_buyers++;
        }
        //update buyer data and contract data.
        buyer.base = buyer.base.add(_BNBAmount_in);
        buyer.sale = buyer.sale.add(_tokens_out);
        status.raised_amount = status.raised_amount.add(_BNBAmount_in);
        status.sold_amount = status.sold_amount.add(_tokens_out);

        ICO_info.sale_token.transfer(_buyer, _tokens_out); // transfer ERC20 tokens to the buyer.

        if(_remaining_out != 0){
            payable(_buyer).transfer(_remaining_out); // refund unused bnb to the buyer.
        }

        emit UserDepsitedSuccess(_buyer, _BNBAmount_in);
    }

    // Receive BUSD/USDT/USDC and transfer Sale token according to the set exchange rate.
    function buyWithoutBNB(IERC20 _token, uint256 _amount) external nonReentrant {
        require(block.timestamp >= ICO_info.ICO_start && block.timestamp <= ICO_info.ICO_end, "ICO: Invalid buy time");

        address _buyer = msg.sender; // for later redundent use. Purpose: Gas consumption.
        uint256 _amount_in = _amount;
        uint256 _actualAmount_in; // actual amount of sent BUSD/USDT/USDC token to be received.
        uint256 _tokens_out; // total ERC20 tokens out.
        uint256 _remaining_out; // unused amount of sent BUSD/USDT/USDC token
        uint256 _remaining_supply = remainingSupply(); 

        require(_token == ICO_info.buy_token, "ICO buy: Invalid _token address");
        require(_amount_in > 0, "ICO: Invalid amount of sent BUSD/USDT/USDC");
        require(_token.balanceOf(_buyer) >= _amount, "ICO buy: Insufficient balance");

        _tokens_out = _amount_in * ICO_info.token_rate; // total exchanged ERC20 tokens according to rate.

        if(_tokens_out > _remaining_supply) {
            _tokens_out = _remaining_supply; // actual tokens out.
            _remaining_out = _amount_in.sub(_tokens_out.div(ICO_info.token_rate)); // unused bnb amount.
            _actualAmount_in = _amount_in.sub(_remaining_out); // acutual bnb amount to be received.
            _amount_in = _actualAmount_in; // update _tokens
        }

        _token.transferFrom(_buyer, address(this), _amount_in); // take tokens in BUSD/USDT/USDC from user.
        
        BuyerInfo storage buyer = buyers[_buyer];
        if(buyer.base == 0){
            status.num_buyers++;
        }
        //update buyer data and contract data.
        buyer.base = buyer.base.add(_amount_in);
        buyer.sale = buyer.sale.add(_tokens_out);
        status.raised_amount = status.raised_amount.add(_amount_in);
        status.sold_amount = status.sold_amount.add(_tokens_out);

        ICO_info.sale_token.transfer(_buyer, _tokens_out); // transfer ERC20 tokens to the buyer.

        emit UserDepsitedSuccess(_buyer, _amount_in);
    }
    
    
    // On ICO Ended
    function ownerWithdrawRemainingTokens () external onlyOwner {
        require(block.timestamp > ICO_info.ICO_end, "ICO OwnerwithDraw: ICO is not ended yet"); // ICO Ended
        IERC20 _token = ICO_info.sale_token;
        require(_token.balanceOf(address(this)) > 0, "ICO ownerWithdraw: Already withdrawn");
        _token.transfer(owner, _token.balanceOf(address(this)));
        
        emit OwnerWithdrawRemainingTokensSuccess(_token.balanceOf(address(this)));
    }

    // on ICO ended.
    function ownerWithdrawCollectedBNBs () external onlyOwner {
        require(block.timestamp > ICO_info.ICO_end, "ICO OwnerwithDraw: ICO is not ended yet"); // ICO Ended
        require(address(ICO_info.buy_token) == address(0), "ICO: ICO didn't created with bnb");
        require(address(this).balance > 0, "ICO ownerWithdraw: Not collected any BNB yet");
        
        payable(owner).transfer(address(this).balance);
        
        emit OwnerWithdrawCollectedBNBSuccess(address(this).balance);
    }

    // on ICO ended.
    function ownerWithdrawCollectedToken () external onlyOwner {
        require(block.timestamp > ICO_info.ICO_end, "ICO OwnerWithdraw: ICO is not ended yet"); // ICO ended.
        require(address(ICO_info.buy_token) != address(0), "ICO OwnerWithdraw: ICO created with BNB");
        require(ICO_info.buy_token.balanceOf(address(this)) > 0, "ICO OwnerWithdraw: Not collected any token yet.");

        IERC20 _token = ICO_info.buy_token;
        _token.transfer(owner, _token.balanceOf(address(this)));

        emit OwnerWithdrawCollectedTokenSuccess(_token.balanceOf(address(this)));
    }

    // get ICO start and end time.
    function getICOTimes () public view returns (uint256, uint256) {
        return (ICO_info.ICO_start, ICO_info.ICO_end);
    }

    // get remaining supply of the sale token.
    function remainingSupply() public view returns (uint256) {
        return ICO_info.token_supply.sub(status.sold_amount);
    }

    // get amount of bnb/busd/usdt/usdc sent by user to smart contract
    function baseByUserCount (address _user) public view returns (uint256) {
        return buyers[_user].base;
    }
    
    // get amount of _saleTokens purchased by user
    function saleToUserCount(address _user) public view returns (uint256) {
        return buyers[_user].sale;
    }
}