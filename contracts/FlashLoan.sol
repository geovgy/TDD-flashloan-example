//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// MUST HAVEs for AaveV2 Flashloan
import { FlashLoanReceiverBase } from "./libraries/FlashLoanReceiverBase.sol";
import { ILendingPool } from "./interfaces/ILendingPool.sol";
import { ILendingPoolAddressesProvider } from "./interfaces/ILendingPoolAddressesProvider.sol";
import { IERC20 } from "./interfaces/IERC20.sol";

import { SafeMath } from "./libraries/SafeMath.sol";

// Only for HELPER test function
import { IUniswapV2Router02 } from "./interfaces/uniswap/IUniswapV2Router02.sol";


contract FlashLoan is FlashLoanReceiverBase {
    using SafeMath for uint256;

    constructor(ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) {
        // No additional logic
    }

    /**
        This function is called after your contract has received the flash loaned amount
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {

        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //
        
        console.log("Current Borrowed Funds: ", amounts[0].div(10**18));

        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.
        
        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }
        
        return true;
    }

    // Use a DEX aggregator on client side to decide router addresses (e.g. CoinGecko, 1inch, Paraswap, etc.)
    function flashloanCall(address _token, uint256 _amount) public {
        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = _token;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;

        // 0 = no debt, 1 = stable, 2 = variable
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        address onBehalfOf = msg.sender;

        bytes memory params = "";
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    // HELPER - This function is ONLY for testing
    function swapETHForDAI() external payable {
        IUniswapV2Router02 router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);  // UniswapV2 Router Address on Mainnet
        
        address[] memory path = new address[](2);
        path[0] = router.WETH(); // Must wrap ETH before swapping
        path[1] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI address on Mainnet

        // DO NOT set minAmountOut as 0 for production! This is ONLY for testing example
        router.swapExactETHForTokens{value: msg.value}(0, path, msg.sender, block.timestamp);
    }
}