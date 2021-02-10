const DollarTokenDeployer = artifacts.require("EuroToken");
const OracleDeployer = artifacts.require("ElasticEuroOracle");
const EurOracleDeployer = artifacts.require("EuroOracle");
// const PoolDeployer = artifacts.require("EuroPool");
const BootstrapPoolDeployer = artifacts.require("BootstrapPool")
const DAO = artifacts.require("DAO");
const Root = artifacts.require("Root");

const Oracle = artifacts.require("Oracle");
// const Pool = artifacts.require("Pool")

async function deployAll(deployer) {
  // Deploys the token deployer & initializes an instance of the token
  const tokenDeployer = await deployer.deploy(DollarTokenDeployer);

  // Deploys the root proxy & sets implementation to the token deployer address
  const rootProxy = await deployer.deploy(Root, tokenDeployer.address);

  // Grab instance of the token deployer @ the root proxy address
  const proxiedTokenDeployer = await DollarTokenDeployer.at(rootProxy.address);

  // Deploys the oracle deployer & initializes an instance of the oracle
  const oracleDeployer = await deployer.deploy(OracleDeployer);
  
  // Upgrades the proxied contract to the oracle deployer
  await proxiedTokenDeployer.implement(oracleDeployer.address);

  // Grab instance of the oracle deployer @ the root proxy address
  const proxiedOracleDeployer = await OracleDeployer.at(rootProxy.address);

  // Deploys the eurOracle deployer & initializes instance of the eurOracle
  const eurOracleDeployer = await deployer.deploy(EurOracleDeployer);

  // Upgrades the proxied contract to the eurOracle deployer
  await proxiedOracleDeployer.implement(eurOracleDeployer.address);

  // Grab instance of the eurOracle deployer @ the root proxy address
  const proxiedEurOracleDeployer = await EurOracleDeployer.at(rootProxy.address);

  // Deploys the pool deployer & initializes an instance of the pool
  // const poolDeployer = await deployer.deploy(PoolDeployer);

  // Upgrades the proxied contract to the pool deployer
  // await proxiedEurOracleDeployer.implement(poolDeployer.address)

  // Grab instance of the pool deployer @ the root proxy address
  // const proxiedPoolDeployer = await PoolDeployer.at(rootProxy.address)

  const bootstrapPoolDeployer = await deployer.deploy(BootstrapPoolDeployer);

  await proxiedEurOracleDeployer.implement(bootstrapPoolDeployer.address)

  const proxiedPoolDeployer = await BootstrapPoolDeployer.at(rootProxy.address)

  // Deploys/initializes the dao.
  const dao = await deployer.deploy(DAO);

  // Upgrades the proxied contract to the DAO.
  await proxiedPoolDeployer.implement(dao.address);

  // addresses:

  // Grab an instance of the dao implementation to query the vars from
  const proxiedDAO = await DAO.at(rootProxy.address)

  const rootAddress = rootProxy.address
  console.log(`Root Address: ${rootAddress}`)

  const daoAddress = await proxiedDAO.implementation()
  console.log(`Dao Address: ${daoAddress}`)

  const tokenAddress = await proxiedDAO.euro()
  console.log(`Token Address: ${tokenAddress}`)
  
  const oracleAddress = await proxiedDAO.oracle()
  console.log(`Oracle Address: ${oracleAddress}`)

  const eurOracleAddress = await proxiedDAO.eurOracle()
  console.log(`EurOracle Address: ${eurOracleAddress}`)

  const poolAddress = await proxiedDAO.pool()
  console.log(`Pool Address: ${poolAddress}`)
  
  const oracle = await Oracle.at(oracleAddress)
  const uniPairAddress = await oracle.pair()
  console.log(`Uniswap Pair Address: ${uniPairAddress}`)

  const currentEpoch = await proxiedDAO.epoch()
  console.log(`Current Epoch: ${currentEpoch}`)

  const blockTimestamp = await proxiedDAO.epochTime()
  console.log(`Epoch Time: ${blockTimestamp}`)

  // debug here:
  // const pool = await Pool.at(poolAddress)
  
  // const globalStagedAmount = await pool.totalStaged()
  // console.log(`Global Staged Amount: ${globalStagedAmount}`)

  // const globalBondedAmount = await pool.totalBonded()
  // console.log(`Global Bonded Amount: ${globalBondedAmount}`)

  // const globalClaimableAmount = await pool.totalClaimable()
  // console.log(`Global Claimable Amount: ${globalClaimableAmount}`)
  
  // to further upgrade pieces of the system,
  // dao can vote to change storage of individual contracts
}

module.exports = function(deployer) {
  deployer.then(async() => {
    console.log(deployer.network);
    switch (deployer.network) {
      case 'mainnet':
      case 'mainnet-fork':
        await deployAll(deployer);
        break;
      case 'develop':
        await deployAll(deployer);
        break;
      case 'rinkeby':
				await deployAll(deployer);
				break;
      case 'ropsten':
        await deployAll(deployer);
        break;
      default:
        throw("Unsupported network");
    }
  })
};
