const { expect } = require("chai");
const { ethers } = require("hardhat");

// describe("Token contract", function () {
//   it("Deployment should assign the total supply of tokens to the owner", async function () {
//     const [owner] = await ethers.getSigners();

//     const Token = await ethers.getContractFactory("BEP20");

//     const hardhatToken = await Token.deploy();

//     const ownerBalance = await hardhatToken.balanceOf(owner.address);
//     expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
//   });
// });
const {
  experimentalAddHardhatNetworkMessageTraceHook,
} = require("hardhat/config");
const {
  isCallTrace,
} = require("hardhat/internal/hardhat-network/stack-traces/message-trace");
let hardhatToken;
let owner;
let addr1;
let addr2;
let addrs;
let Token;
beforeEach(async () => {
  myToken = await ethers.getContractFactory("QKCToken");
  [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
  hardhatToken = await myToken.deploy(1000);
});
describe("Deployment", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
describe("Transaction", async function () {
  it("User 1 claim token", async function () {
    await hardhatToken.connect(addr1).claimToken(100);
    const addr1Balance = await hardhatToken.balanceOf(addr1.address);
    expect(addr1Balance).to.equal(
      ethers.BigNumber.from("100000000000000000000")
    );
  });
  it("User 2 claim token", async function () {
    await hardhatToken.connect(addr1).claimToken(200);
    const addr1Balance = await hardhatToken.balanceOf(addr1.address);
    expect(addr1Balance).to.equal(
      ethers.BigNumber.from("200000000000000000000")
    );
  });

  it("User 1 & 2 claim token", async function () {
    await hardhatToken.connect(addr1).claimToken(100);
    const addr1Balance = await hardhatToken.balanceOf(addr1.address);
    expect(addr1Balance).to.equal(
      ethers.BigNumber.from("100000000000000000000")
    );
    await hardhatToken.connect(addr2).claimToken(200);
    const addr2Balance = await hardhatToken.balanceOf(addr2.address);
    expect(addr2Balance).to.equal(
      ethers.BigNumber.from("200000000000000000000")
    );
  });
});
