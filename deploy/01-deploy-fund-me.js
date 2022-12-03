// import
// main function
// calling of main function

// function deployFunc() {
//     console.log("Hi!")
// }

// module.exports.default = deployFunc

// module.exports = async (hre) => {
//     const {getNamedAccounts, deployments} = hre
//     (hre.getNamedAccounts) and (hre.deployments)
// }
// hre: hardhat runtime enviroment

const { networkConfig, developmentChains } = require("../helper-hardhat-config")
// const helperConfig = require("../helper-hardhat-config")
// const networkConfig = helperConfig.networkConfig
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // if chainId is X use price feed address of Y network
    // X Y are data stored in helper-hardhat-config.js

    let ethUsdPriceFeedAddress
    // hardhat or localhost
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    // if the contract doesn't exist, we deploy a minimal version of
    // for our local testing

    // well what happens when we want to change chains
    // when going for localhost or hardhat network we want to use a mock

    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, // put price feed address
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }
    log("------------------------------------")
}
module.exports.tags = ["all", "fundme"]
