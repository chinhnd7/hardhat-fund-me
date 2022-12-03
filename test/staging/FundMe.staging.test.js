const { inputToConfig } = require("@ethereum-waffle/compiler")
const { assert } = require("chai")
const { getNamedAccounts, ethers, network } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

// staging tests only run on testnet
// unit tests only run on development chains
developmentChains.includes(network.name)
    ? describe.skip
    : describe("FundMe", async function () {
          let FundMe
          let deployer
          const sendValue = ethers.utils.parseEther("0.005")
          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              fundMe = await ethers.getContract("FundMe", deployer)
          })

          it("Allows people to fund and withdraw", async function () {
              await fundMe.fund({ value: sendValue })
              await fundMe.withdraw()
              const endingBalance = await fundMe.provider.getBalance(
                  fundMe.address
              )
              assert.equal(endingBalance.toString(), "0")
          })
      })
