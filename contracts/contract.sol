// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract QKCToken is ERC20, Ownable {
    mapping(address => uint) approver;
    event Claim(address owner, address indexed user, uint amount);

    constructor(uint256 initialSupply) ERC20("EvonDev", "EVD") {
        _mint(msg.sender, initialSupply * 10**18); //1000000000000000000
    }

    function tranferToken(address register, uint256 amount) external onlyOwner {
        approve(register, amount);
        approver[register] = amount;
    }

    function claimToken(uint amount) public {
        address user = _msgSender();
        address owner = owner();
        _approve(owner, user, amount);
        transferFrom(owner, user, amount * 10**18);
        emit Claim(owner, user, amount);
    }
}
