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
        address sale_token; // Sale token
        address buy_token; // in case of buy with BUSD/USDT/USDC
        uint256 token_rate; // 1 base token = ? s_tokens, fixed price
        uint256 token_supply; // total supply user will sale by creating an ICO.
        uint256 ICO_start;
        uint256 ICO_end;
        // bool canceled;
    }

    struct ICOStatus {
        // bool force_failed; // Set this flag to force fail the presale
        uint256 raised_amount; // Total base currency raised (usually ETH)
        uint256 sold_amount; // Total ICO tokens sold
        // uint256 token_withdraw; // Total tokens withdrawn post successful presale
        // uint256 base_withdraw; // Total base tokens withdrawn on presale failure
        uint256 num_buyers; // Number of unique participants
    }

    struct BuyerInfo {
        uint256 base; // Total base token (usually ETH) deposited by user, can be withdrawn on presale failure
        uint256 sale; // Num presale tokens a user owned, can be withdrawn on presale success
    }
    
    struct TokenInfo {
        string name;
        string symbol;
        uint256 totalsupply;
        uint256 decimal;
    }

    address public owner;

    ICOInfo public ICO_info;
    ICOStatus public status;
    TokenInfo public tokeninfo;

    uint256 public ICOSetting;


    mapping(address => BuyerInfo) public buyers;

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
        address _sale_token,
        address _buy_token,
        uint256 _token_rate,
        uint256 _token_supply,
        uint256 _ICO_start,
        uint256 _ICO_end
    ) {
        owner = msg.sender;
        init_private(
            _sale_token,
            _buy_token,
            _token_rate,
            _ICO_start,
            _ICO_end
        );
        owner = owner_;

        require(IERC20(_sale_token).balanceOf(owner) >= _token_supply, "ICO constructor: Total supply error");
        IERC20(_sale_token).transferFrom(owner, address(this), _token_supply);
        
        emit ICOCreated(owner, address(this));
    }

    function init_private (
        address _sale_token,
        address _buy_token,
        uint256 _token_rate,
        uint256 _ICO_start,
        uint256 _ICO_end
        ) public onlyOwner {

        require(ICOSetting == 0, "Already setted");
        require(_sale_token != address(0), "Zero Address");
        
        ICO_info.sale_token = address(_sale_token);
        if(_buy_token != address(0)){
            ICO_info.buy_token = address(_buy_token);
        }
        ICO_info.token_rate = _token_rate;
        ICO_info.ICO_end = _ICO_end;
        ICO_info.ICO_start =  _ICO_start;
        // ICO_info.canceled = false;

        //Set token token info
        tokeninfo.name = IERC20(ICO_info.sale_token).name();
        tokeninfo.symbol = IERC20(ICO_info.sale_token).symbol();
        tokeninfo.decimal = IERC20(ICO_info.sale_token).decimals();
        tokeninfo.totalsupply = IERC20(ICO_info.sale_token).totalSupply();

        ICOSetting = 1;
    }

    // function setOwner(address _newOwner) public onlyOwner {
    //     owner = _newOwner;
    // }

    
    function getICOStatus() public view returns (uint256) {
        // if(ICO_info.canceled == true) {
        //     return 4; // Canceled
        // }
        if(block.timestamp < ICO_info.ICO_start){
            return 3; // upcoming
        }
        if(block.timestamp > ICO_info.ICO_end){
            return 2; // ICO ended
        }
        if(status.raised_amount != ICO_info.token_supply) {
            return 1; // ICO: Sale Live
        }
            return 0; // Wonderful: Total Supply sold
    }

    modifier buyEnabled() {
        require(getICOStatus() == 1, "ICO: Buying ERC20 tokens is unabled");
        _;
    }

    // Receive BNB and transfer ERC20 token according to the set exchange rate.
    function buyWithBNB() external payable nonReentrant buyEnabled {
        uint256 _BNBAmount_in = msg.value; // for later redundent use. Purpose: gas consumption.
        uint256 _actualBNB_in; // actual amount of bnb to be received.
        uint256 _remaining_supply = ICO_info.token_supply - status.raised_amount; 
        uint256 _tokens_out; // total ERC20 tokens out.
        uint256 _remaining_out; // unused amount of bnb
        address _buyer = msg.sender; // for later redundent use. Purpose: Gas consumption.

        require(_BNBAmount_in > 0, "ICO: Invalid amount of sent BNB");
        require(ICO_info.buy_token == address(0), "ICO: Token cannot buy with bnb");
        _tokens_out = _BNBAmount_in * ICO_info.token_rate;

        if(_tokens_out > _remaining_supply) {
            _tokens_out = _remaining_supply; // actual tokens out.
            _remaining_out = _BNBAmount_in - _tokens_out.div(ICO_info.token_rate); // unused bnb amount.
            _actualBNB_in = _BNBAmount_in - _remaining_out; // acutual bnb amount to be received.
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

        IERC20(ICO_info.sale_token).transfer(_buyer, _tokens_out); // transfer ERC20 tokens to the buyer.

        if(_remaining_out != 0){
            payable(_buyer).transfer(_remaining_out); // refund unused bnb to the buyer.
        }

        emit UserDepsitedSuccess(_buyer, _BNBAmount_in);
    }

    // Receive BUSD/USDT/USDC and transfer Sale token according to the set exchange rate.
    function buyWithoutBNB(IERC20 _token, uint256 _amount) external nonReentrant buyEnabled {
        address _buyer = msg.sender; // for later redundent use. Purpose: Gas consumption.
        uint256 _amount_in = _amount;
        uint256 _actualAmount_in; // actual amount of sent BUSD/USDT/USDC token to be received.
        uint256 _remaining_supply = ICO_info.token_supply - status.raised_amount; 
        uint256 _tokens_out; // total ERC20 tokens out.
        uint256 _remaining_out; // unused amount of sent BUSD/USDT/USDC token

        require(_token == IERC20(ICO_info.buy_token), "ICO buy: Invalid _token address");
        require(_amount_in > 0, "ICO: Invalid amount of sent BUSD/USDT/USDC");
        require(_token.balanceOf(_buyer) >= _amount, "ICO buy: Insufficient balance");

        _tokens_out = _amount_in * ICO_info.token_rate; // total exchanged ERC20 tokens according to rate.

        if(_tokens_out > _remaining_supply) {
            _tokens_out = _remaining_supply; // actual tokens out.
            _remaining_out = _amount_in - _tokens_out.div(ICO_info.token_rate); // unused bnb amount.
            _actualAmount_in = _amount_in - _remaining_out; // acutual bnb amount to be received.
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

        IERC20(ICO_info.sale_token).transfer(_buyer, _tokens_out); // transfer ERC20 tokens to the buyer.

        // if(_remaining_out != 0){
        //     _token.transfer(_buyer, _remaining_out); // transfer unused bnb to the buyer.
        // }

        emit UserDepsitedSuccess(_buyer, _amount_in);
    }
    
    
    // On ICO Ended
    function ownerWithdrawRemainingTokens () external onlyOwner {
        require(getICOStatus() == 2, "ICO OwnerwithDraw: ICO is not ended yet"); // ICO Ended
        IERC20 _token = IERC20(ICO_info.sale_token);
        _token.transfer(owner, _token.balanceOf(address(this)));
        
        emit OwnerWithdrawRemainingTokensSuccess(_token.balanceOf(address(this)));
    }

    // on ICO ended.
    function ownerWithdrawCollectedBNBs () external onlyOwner {
        require(getICOStatus() == 2, "ICO OwnerwithDraw: ICO is not ended yet"); // ICO Ended
        require(ICO_info.buy_token == address(0), "ICO: ICO didn't created with bnb");
        require(address(this).balance > 0, "ICO ownerWithdraw: Not collected any BNB yet");
        
        payable(owner).transfer(address(this).balance);
        
        emit OwnerWithdrawCollectedBNBSuccess(address(this).balance);
    }

    // on ICO ended.
    function ownerWithdrawCollectedToken () external onlyOwner {
        require(getICOStatus() == 2, "ICO OwnerWithdraw: ICO is not ended yet"); // ICO ended.
        require(ICO_info.buy_token != address(0), "ICO OwnerWithdraw: ICO created with BNB");
        require(IERC20(ICO_info.buy_token).balanceOf(address(this)) > 0, "ICO OwnerWithdraw: Not collected any token yet.");

        IERC20 _token = IERC20(ICO_info.buy_token);
        _token.transfer(owner, _token.balanceOf(address(this)));

        emit OwnerWithdrawCollectedTokenSuccess(_token.balanceOf(address(this)));
    }

    // function setCancel() public onlyOwner {
    //     ICO_info.canceled = true;
    // }

    // get ICO start and end time.
    function getICOTimes () public view returns (uint256, uint256) {
        return (ICO_info.ICO_start, ICO_info.ICO_end);
    }
}