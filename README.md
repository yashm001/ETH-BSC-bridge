# ETH-BSC-bridge

this project allows user to exchange any ERC20 token to any BEP20 token and vice versa.

# Working
ETH -> BSC SWAP

1) the contract swap the user's ERC20 token to USDT(ERC20) and then deposit it into gatewayVault.

2) The bridge script listens to the event and when the deposit is made, the equal amount of USDT(BEP20) is transfered to smart contract from gatewayValut on binance

3) The contract swap the USDT(BEP20) to the desired BEP20 token user wants and transfers those to user.
