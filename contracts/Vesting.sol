// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract IDO is ERC20, Ownable {
    using SafeMath for uint256;
    struct user {
        uint256 amount;
        uint256 userClaim;
    }

    mapping(address => user) listVesting;

    IERC20 public Token;
    uint256 public firstRelease;
    // uint256 public firstClaim;
    uint256 public starTime;
    uint256 public totalPeriods;
    uint256 public timePerPeriod;
    uint256 public cliff;
    uint256 public totalToken;

    constructor() ERC20("Near Protocol", "NEAR") {
        _mint(msg.sender, 1000000000 * 10**18);
        Token = IERC20(address(this));
        totalPeriods = 8;
        timePerPeriod = 1;
        cliff = 1;
        starTime = block.timestamp;
        totalToken = 10000;
    }

    function joinWhiteList(uint256 amount) public payable {
        require(amount < 10000, "User can only claim 10,000 Token");
        require(totalToken > 0, "Sold out");
        transfer(_msgSender(), (amount / 100) * 10**18); // 1 token = 100 ehther
        listVesting[_msgSender()].amount = amount;
        listVesting[_msgSender()].userClaim = 0;
        totalToken.trySub(amount);
    }

    function fundVesting() public onlyOwner {
        Token.transfer(address(this), 1000000000 * 10**18);
    }

    function claim() public {
        uint256 YearsGoneBy = ((block.timestamp - starTime) / 10);
        uint256 MonthsGoneBy = ((block.timestamp - starTime) % 10);
        require(listVesting[msg.sender].amount > 0, "You are not in vesting");

        if (YearsGoneBy < cliff) {
            /// first claim
            // check first claim of user
            uint256 firstClaim = (listVesting[msg.sender].amount * 20) / 100;
            require(
                listVesting[msg.sender].userClaim <= firstClaim,
                "You have claimed in this year"
            );

            Token.transfer(address(this), (firstClaim / 100) * 10**18);
            listVesting[msg.sender].userClaim =
                (listVesting[msg.sender].amount * 20) /
                100;
        } else {
            if (
                (YearsGoneBy > cliff && MonthsGoneBy >= totalPeriods) ||
                YearsGoneBy >= 2
            ) {
                // claim all after cliff

                // Check if user have claim all
                require(
                    listVesting[msg.sender].userClaim <=
                        listVesting[msg.sender].amount,
                    "You have claimed all token"
                );
                uint256 tokenLeft = listVesting[msg.sender].amount -
                    listVesting[msg.sender].amount;

                Token.transfer(address(this), tokenLeft * 10**18);
                listVesting[msg.sender].userClaim = listVesting[msg.sender]
                    .amount;
            } else {
                // total token in this month
                uint256 totalClaim = (listVesting[msg.sender].amount * 20) /
                    100 +
                    (listVesting[msg.sender].amount * MonthsGoneBy * 10) /
                    100;

                // total token that user can claim in this month
                uint256 thisMonthClaim = totalClaim -
                    listVesting[msg.sender].userClaim;

                //check if user claim have claim in this month or not
                require(
                    listVesting[msg.sender].userClaim <= totalClaim,
                    "You have claimed in this month"
                );

                Token.transfer(address(this), thisMonthClaim * 10**18);
                listVesting[msg.sender].userClaim.tryAdd(thisMonthClaim);
            }
        }
    }
}
