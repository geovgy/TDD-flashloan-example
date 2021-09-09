# Example TDD Flashloan Project

This project demonstrates a basic flashloan smart contract using Aave V2 and how to test with mainnet forking on Hardhat.

Key components:
1. API Key to an archive node (such as Alchemy) and network settings in hardhat.config.js
2. AaveV2 imports in smart contract to perform flashloan

## To Test
Smart contracts compile automatically if any changes are made.

```shell
npx hardhat test
```

## Other available tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
