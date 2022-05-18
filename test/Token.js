const { expect } = require("chai");
const { ethers } = require("hardhat");
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

beforeEach(async () => {
  const Token = await ethers.getContractFactory("QKCToken");
  hardhatToken = await Token.deploy(10000);
});
describe("Deployment", async function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
describe("Transaction", async function () {
  it("User 1 claim token", async function () {
    await hardhatToken.connect(addr1).get(100);
    const addr1Balance = await hardhatToken.balanceOf(addr1.address);
    expect(addr1Balance).to.equal(100000000000000000000);
  });
});
