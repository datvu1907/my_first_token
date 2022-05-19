// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract IDO is ERC20, Ownable {
    using SafeMath for uint256;
    struct user {
        uint256 amount;
        uint256 userClaim;
        bool firstClaim;
        uint256 firstJoin;
    }

    mapping(address => user) listVesting;

    IERC20 public Token;
    uint256 public firstRelease;
    uint256 public firstClaim;
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
        starTime = now();
    }

    function joinWhiteList(address userAdress, uint256 amount) public payable {
        require(amount < 10000, "User can only claim 10,000 Token");
        transfer(owner(), (amount / 100) * 10**18); // 1 token = 100 ehther
        listVesting[userAdress].amount = amount;
        listVesting[userAdress].userClaim = 0;
        listVesting[userAdress].firstClaim = false;
        listVesting[userAdress].firstJoin = now();
        _approve(address(this), userAdress, amount);
    }

    function fundVesting() public onlyOwner {
        transfer(address(this), 1000000000 * 10**18);
    }

    function claim() public {
        require(listVesting[msg.sender].amount > 0, "You are not in vesting");

        if (listVesting[userAdress].firstClaim == false) {
            transferFrom(
                address(this),
                msg.sender,
                (((listVesting[msg.sender].amount / 100) * 20) / 100) * 10**18
            );
            listVesting[msg.sender].userClaim =
                (listVesting[msg.sender].amount * 20) /
                100;
        }
    }
}
