/*function deployFunc() {
    console.log("Hi!")
}

module.exports.default = deployFunc
*/
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
//const helperConfig = require("../helper-hardhat-config")
//const networkConfig = helperConfig.networkConfig
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

//module.exports = async (hre) => {
module.exports = async ({ getNamedAccounts, deployments }) => {
    //const { getNamedAccounts, deployments } = hre
    // hre.getNamedAccounts()
    // hre.deployments
    const { deploy, log } = deployments // pull 2 fcts out of deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    //const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]

    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }
    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }
    log("--------------------------------------")
}
module.exports.tags = ["all", "fundme"]
