# Hardhat Fund Me Project

In remix compiler, we test this contract in Rinkeby network. As we see, we have to use hard code address in PriceConverter.sol which is data feed address. But this address only can use for Rinkeby network, price feed contract doesn't exist. So when going for localhost or hardhat network we want to use a mock.

- Việc sử dụng file deploy.js trong folder scrips như project hardhat-simple-storage khiến cho việc test, verify, deploy không được tiện dụng. 
=> Tách ra các folder deploy và utils.

import hardhat deploy:
yarn add --dev hardhat-deploy

Và sử dụng package này trong quá trình viết script deploy trong folder deploy.
yarn add --dev @nomiclabs/hardhat-ethers: npm:hardhat-deploy-ethers ethers

- Khi ta run yarn hardhat deploy, các file trong folder deploy sẽ được chạy, vì vậy nên đánh số thứ tự cho từng file (00, 01...)