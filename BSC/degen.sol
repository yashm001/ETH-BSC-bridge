/**
 *Submitted for verification at BscScan.com on 2021-07-06
*/

/**
 *Submitted for verification at Etherscan.io on 2021-05-18
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(),"Not Owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function mint(address to, uint256 amount) external returns(bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}



interface IPanCake {
    
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) 
    external 
    returns (uint[] memory amounts);
    
    function swapTokensForExactTokens(uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline) 
    external 
    returns (uint[] memory amounts);
        
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable 
    returns (uint[] memory amounts);
        
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external 
    returns (uint[] memory amounts);
        
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external 
    returns (uint[] memory amounts);
        
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable 
    returns (uint[] memory amounts);
    
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
    external payable 
    returns (uint amountToken, uint amountETH, uint liquidity);
    
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
    
}

// interface IPoolSwapPair {
//     event Approval(address indexed owner, address indexed spender, uint value);
//     event Transfer(address indexed from, address indexed to, uint value);

//     function name() external pure returns (string memory);
//     function symbol() external pure returns (string memory);
//     function decimals() external pure returns (uint8);
//     function totalSupply() external view returns (uint);
//     function balanceOf(address owner) external view returns (uint);
//     function allowance(address owner, address spender) external view returns (uint);

//     function approve(address spender, uint value) external returns (bool);
//     function transfer(address to, uint value) external returns (bool);
//     function transferFrom(address from, address to, uint value) external returns (bool);

//     function DOMAIN_SEPARATOR() external view returns (bytes32);
//     function PERMIT_TYPEHASH() external pure returns (bytes32);
//     function nonces(address owner) external view returns (uint);

//     function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

//     event Mint(address indexed sender, uint amount0, uint amount1);
//     event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
//     event Swap(
//         address indexed sender,
//         uint amount0In,
//         uint amount1In,
//         uint amount0Out,
//         uint amount1Out,
//         address indexed to
//     );
//     event Sync(uint112 reserve0, uint112 reserve1);

//     function MINIMUM_LIQUIDITY() external pure returns (uint);
//     function factory() external view returns (address);
//     function token0() external view returns (address);
//     function token1() external view returns (address);
//     function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
//     function price0CumulativeLast() external view returns (uint);
//     function price1CumulativeLast() external view returns (uint);
//     function kLast() external view returns (uint);

//     function mint(address to) external returns (uint liquidity);
//     function burn(address to) external returns (uint amount0, uint amount1);
//     function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
//     function skim(address to) external;
//     function sync() external;

//     function initialize(address, address) external;
// }

interface IGatewayVault {
    function vaultTransfer(address token, address recipient, uint256 amount) external returns (bool);
    function vaultApprove(address token, address spender, uint256 amount) external returns (bool);
}

interface IReimbursement {
    function getLicenseeFee(address licenseeVault, address projectContract) external view returns(uint256); // return fee percentage with 2 decimals
    function getVaultOwner(address vault) external view returns(address);
    // returns address of fee receiver or address(0) if licensee can't receive the fee (fee should be returns to user)
    function requestReimbursement(address user, uint256 feeAmount, address licenseeVault) external returns(address);
}



abstract contract Router {
  
    
    enum OrderType {BNBForTokens, TokensForBNB, TokensForTokens}

    event Received(address, uint);
    event Error(address);

    receive() external payable {
        // if (validUser[msg.sender] == true) {
        //     balance[msg.sender][ETH] += msg.value;
        emit Received(msg.sender, msg.value);
        // } else {
        //     balance[owner][ETH] += msg.value;
        // }
    }

    fallback() external payable {
        revert();
    }

    IPanCake PanCake;
    
     // add these variables into contract and initialize it in constructor.
    // also, create setter functions for it with onlyOwner restriction.

   

    constructor(address _panCake) public payable {
        // owner = payable(msg.sender);
        PanCake = IPanCake(_panCake);
    }
    
    function getBestQuote(address[] memory path, uint256 amountIn, OrderType orderType) public view returns (uint256) {
        // uint256 returnAmount;
        uint256[] memory panAmounts;
        
        if(orderType == OrderType.BNBForTokens){
            path[0] = PanCake.WETH();
            (panAmounts) = PanCake.getAmountsOut(amountIn, path);
        } else if(orderType == OrderType.TokensForBNB){
            path[path.length-1] = PanCake.WETH();
            (panAmounts) = PanCake.getAmountsOut(amountIn, path);
        } else{
            (panAmounts) = PanCake.getAmountsOut(amountIn, path);
        }
        
        return panAmounts[path.length-1];
        
    }
    
    
 
    
}
interface ISwapFactory {
     function swap(address tokenA, address tokenB, uint256 amount, address user, uint8 crossOrderType) external payable returns (bool);

}



contract Degen is Router,Ownable {
    using SafeMath for uint256;

    
    address _panCake = address(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet network address for panCake
    address USDT = address(0x55d398326f99059fF775485246999027B3197955); // USDT on BSC
    address system;
    address gatewayVault;
    uint256 proccessingFee = 0 ;

     IReimbursement public reimbursementContract;       // reimbursement contract address

    address public companyToken;        // company reimbursement token (BSWAP, DEGEN, SMART)
    address public companyVault;    // the vault address of our company registered in reimbursement contract

    
    uint256 nonce = 0;
    ISwapFactory swapFactory;
    // IPoolSwapPair poolContract;
    
   
    modifier onlySystem() {
        require(msg.sender == system || owner() == msg.sender,"Caller is not the system");
        _;
    }
    
    
    constructor(address _companyToken,address _swapFactory, address _system, address _gatewayVault, address _companyVault, address _reimbursementContract) Router(_panCake) public {
     
        companyToken = _companyToken;
        companyVault = _companyVault;
        reimbursementContract = IReimbursement(_reimbursementContract);
        //  poolContract = IPoolSwapPair(_degBNBPool);
         swapFactory = ISwapFactory(_swapFactory);
         system = _system;
         gatewayVault = _gatewayVault;
         
    }
    
    function setSwapFactory(address _swapFactory) external onlyOwner returns(bool){
        swapFactory = ISwapFactory(_swapFactory);
        return true;
    }
    
    function setGatewayVault(address _gatewayVault) external onlyOwner returns(bool) {
        gatewayVault = _gatewayVault;
        return true;
    }
    
    function setSystem(address _system) external onlyOwner returns(bool){
        system = _system;
        return true;
    }

    function setCompanyToken(address _companyToken) external onlyOwner returns(bool){
        companyToken = _companyToken;
        return true;
    }

    function setCompanyVault(address _comapnyVault) external onlyOwner returns(bool){
        companyVault = _companyVault;
        return true;
    }

    function setReimbursementContract(address _reimbursementContarct) external onlyOwner returns(bool){
        reimbursementContract = IReimbursement(_reimbursementContarct);
        return true;
    }

    function setProccessingFee(uint256 _processingFees ) external onlySystem {
        proccessingFee = _processingFees;
    }

    
    // function degenPrice() public view returns (uint256){
    //     (uint112 reserve0, uint112 reserve1,) = poolContract.getReserves();
    //     if(poolContract.token0() == panCake.WETH()){
    //         return ((reserve1 * (10**18)) /(reserve0));
    //     } else {
    //         return ((reserve0 * (10**18)) /(reserve1));
    //     }
    // }
    
    function processFee(uint256 txGas, uint256 feeAmount, address licenseeVault, address user) internal {
        if (address(reimbursementContract) == address(0)) {
            payable(user).transfer(feeAmount); // return fee to sender if no reimbursement contract
            return;
        }

        uint256 licenseeFeeRate = reimbursementContract.getLicenseeFee(licenseeVault, address(this));
        uint256 companyFeeRate = reimbursementContract.getLicenseeFee(companyVault, address(this));
        uint256 licenseeFeeAmount = (feeAmount * licenseeFeeRate)/(licenseeFeeRate + companyFeeRate);
        if (licenseeFeeAmount != 0) {
            address licenseeFeeTo = reimbursementContract.requestReimbursement(user, licenseeFeeAmount, licenseeVault);
            if (licenseeFeeTo == address(0)) {
                payable(user).transfer(licenseeFeeAmount);    // refund to user
            } else {
                payable(licenseeFeeTo).transfer(licenseeFeeAmount);  // transfer to fee receiver
            }
        }
        feeAmount -= licenseeFeeAmount; // company's part of fee

        // swap half fee to company token
        address[] memory path = new address[](2);
        path[0] = panCake.WETH();
        path[1] = companyToken;
        
        uint[] memory amounts = panCake.swapExactETHForTokens{value: feeAmount/2}(
            0,
            path,
            address(this),
            block.timestamp
        );
        // use tokens and rest of fee to addLiquidity
        IERC20(path[1]).approve(address(panCake),amounts[1]);

        uniV2Router.addLiquidityETH{value: feeAmount/2}(
            path[1],
            amounts[1],
            0,
            0,
            reimbursementContract.getVaultOwner(companyVault),  // company address will receive LP
            block.timestamp
        );

        txGas -= gasleft(); // get gas amount that was spent on Licensee fee
        txGas = txGas * tx.gasprice;
        // request reimbursement for user
        reimbursementContract.requestReimbursement(user, feeAmount+txGas, companyVault);
    }
    
    function executeSwap(OrderType orderType, address[] memory path, uint256 assetInOffered, uint256 fees, uint256 minExpectedAmount, address licenseeVault) external payable{
        uint256 receivedFees = 0;
        uint256 gasA = gasleft();
        if(orderType == OrderType.BNBForTokens){
            require(msg.value >= assetInOffered.add(fees), "Payment = assetInOffered + fees");
            receivedFees = receivedFees + msg.value - assetInOffered;
        } else {
            require(msg.value >= fees, "fees not received");
            receivedFees = receivedFees + msg.value;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
        }
        
        
        _swap(orderType,path,assetInOffered,minExpectedAmount,msg.sender);
        
        processFee(gasA, receivedFees, licenseeVault, msg.sender);
    }
    
    function _swap(OrderType orderType, address[] memory path,uint256 assetInOffered, uint256 minExpectedAmount, address user ) internal returns(uint256) {
        uint256 minAmountExpected = getBestQuote(path, assetInOffered, orderType);
        require(minExpectedAmount <= minAmountExpected  , "Degen : Higher slippage than allowed.");
        
        
        uint[] memory swapResult;
        
        if(orderType == OrderType.BNBForTokens) {
             path[0] = panCake.WETH();
             swapResult = panCake.swapExactETHForTokens{value:assetInOffered}(minAmountExpected, path, user,block.timestamp);
        }
        else if (orderType == OrderType.TokensForBNB) {
            path[path.length-1] = panCake.WETH();
            TransferHelper.safeApprove(path[0], address(_panCake), assetInOffered);
            swapResult = panCake.swapExactTokensForETH(assetInOffered, minAmountExpected, path,user, block.timestamp);
        }
        else if (orderType == OrderType.TokensForTokens) {
            TransferHelper.safeApprove(path[0], address(_panCake), assetInOffered);
            swapResult = panCake.swapExactTokensForTokens(assetInOffered, minAmountExpected, path, user, block.timestamp);
        }
        
        return minAmountExpected;
    }
    
    function executeCrossExchange(address[] memory path, OrderType orderType, uint8 crossOrderType, uint256 assetInOffered, uint256 fees , uint256 minExpectedAmount, address licenseeVault) external payable {
        
        uint256 receivedFees = 0;
        uint256 gasA = gasleft();

        if(orderType == OrderType.BNBForTokens){
            require(msg.value >= assetInOffered.add(fees).add(proccessingFee), "Payment = assetInOffered + fees + proccessingFee");
            receivedFees = receivedFees + msg.value - assetInOffered;
        } else {
            require(msg.value >= fees.add(proccessingFee), "fees not received");
            receivedFees = receivedFees + msg.value;
            TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), assetInOffered);
        }

        
        if(path[0] == USDT) {
            IERC20(USDT).approve(address(swapFactory),assetInOffered);
            swapFactory.swap(USDT,path[path.length-1],assetInOffered,msg.sender,crossOrderType);
        }
        
        else {
            address tokenB = path[path.length-1];
            path[path.length-1] = USDT;
            
            
            uint256 minAmountExpected = _swap(orderType,path,assetInOffered,minExpectedAmount,address(this));
            
            
            IERC20(USDT).approve(address(swapFactory),minAmountExpected);
            swapFactory.swap(USDT,tokenB,minAmountExpected,msg.sender,crossOrderType);
        
        }
        
        processFee(gasA, receivedFees, licenseeVault, msg.sender);
    }


    function callbackCrossExchange(OrderType orderType, address[] memory path,uint256 assetInOffered, address user) external returns(bool){
        require(msg.sender == address(swapFactory) , "Degen : caller is not SwapFactory");
        _swap(orderType,path,assetInOffered,0,user);
   
        
        
    }




}