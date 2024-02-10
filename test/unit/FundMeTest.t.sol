// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18; // stating version can so ^0.8.18(over stated version) or >=x.x.xx <y.y.yy(version interval)

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // always runs first
    FundMe fundMe;

    address USER = makeAddr("user"); //cheat code for address
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant GAS_PRICE = 1;

    // setUp is ran before every function
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); //cheat code for adding balance to test address
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        // console.log("FundMeTest.testFundMe");
    }

    function testOwnerIsMessageSender() public {
        // console.log("msg.sender: ", address(this));
        // console.log("fundMe i_owner: ", fundMe.i_owner());
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccutare() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // cheat code for revert
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER); //tells foundry that USER is the sender
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    // modifier is a way to add a function to a function
    // this way we can reutilize code
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    //User can't withdraw because it's not the owner
    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBlance = address(fundMe).balance;

        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();

        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        console.log("Gas used: ", gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBlance = address(fundMe).balance;

        assertEq(endingFundMeBlance, 0);

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBlance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint256 numebrOfFunders = 10;
        uint256 startingFunderIndex = 2;
        //SINCE 0.8 YOU CANNOT CAST FROM ADDRESS TO UINT256
        //FIRST WE HAVE TO CAST TO UINT160
        //LIKE SO:
        // uint256 a = uint256(uint160(addressValue))

        // ADD FUNDS FROM DIFFERENT ADDRESSES

        for (uint256 i = startingFunderIndex; i < numebrOfFunders; i++) {
            // hoax is not a cheat code but a regular function of foundry
            // it combines prank and deal
            hoax(address(uint160(i)), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            console.log(address(uint160(i)));
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBlance = address(fundMe).balance;

        // WITHRAW FUNDS AND CHECK RESULTS

        // like broadcast, but this tells to use a specific sender in the transactions between strat and close
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBlance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint256 numebrOfFunders = 10;
        uint256 startingFunderIndex = 2;
        //SINCE 0.8 YOU CANNOT CAST FROM ADDRESS TO UINT256
        //FIRST WE HAVE TO CAST TO UINT160
        //LIKE SO:
        // uint256 a = uint256(uint160(addressValue))

        // ADD FUNDS FROM DIFFERENT ADDRESSES

        for (uint256 i = startingFunderIndex; i < numebrOfFunders; i++) {
            // hoax is not a cheat code but a regular function of foundry
            // it combines prank and deal
            hoax(address(uint160(i)), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            console.log(address(uint160(i)));
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBlance = address(fundMe).balance;

        // WITHRAW FUNDS AND CHECK RESULTS

        // like broadcast, but this tells to use a specific sender in the transactions between strat and close
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBlance
        );
        assertEq(endingFundMeBalance, 0);
    }
}
