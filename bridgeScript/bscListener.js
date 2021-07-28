var Web3 = require("web3");
    // "web3": "^1.0.0-beta.37"

var fs = require('fs');
const path = require('path');
var Tx = require('ethereumjs-tx');
const fetch = require('node-fetch');
const common = require('ethereumjs-common');

// const initConfig = require("../configs/initConfigs");

const smartSwapAbi = require("./abis/BridgeBsc.json");
const crossSmartSwapAbi = require("./abis/BridgeEth.json");
const degenAbi = require("./abis/BscDegen.json");

const CROSS_CHAIN_ID = 97;
const CHAIN_ID = 3;
const GAS_LIMIT = "800000";

const OWNER_ADDRESS = "0xddf7Fe34171251c98664E756F990EAcd9360718b";
const pKey = "cd932cdd5c97797018e4ecbe0439f9bd1c3f2959c98891c7137654baf356daa2";

const DEGEN_ADDRESS = '0x87343D8CD06f3799F16e8a2A9E48d08ACb47Ca11';
const CROSS_SWAP_ADDRESS = "0x4A4B6fb358cEA2E80a6809b0FE935dcf706BA070";
// const { swapHelper, priceHelper } = require("../helpers/");

// const web3 = new Web3(new Web3.providers.HttpProvider(initConfig.bscRpc));
const web3 = new Web3(new Web3.providers.HttpProvider('https://data-seed-prebsc-2-s1.binance.org:8545/'));
const web3Eth = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/e3706a59ed38418095f619d56df648e0"));

const SWAP_INSTANCE = new web3.eth.Contract(smartSwapAbi, '0xb762771608791aa6Ab459bae0eE203015654F412');
const CROSS_SWAP_INSTANCE = new web3Eth.eth.Contract(crossSmartSwapAbi, CROSS_SWAP_ADDRESS);
const DEGEN_INSTANCE = new web3.eth.Contract(degenAbi, DEGEN_ADDRESS);
var cronJob = require('cron').CronJob;

// const SwapTxModel = require("../models").swapSchema;


// var Ethnonce = 0;
// function initEthNonce(){
//     web3Eth.eth.getTransactionCount(OWNER_ADDRESS).then(function (_nonce) {
//         if(_nonce > Ethnonce){
//             Ethnonce = _nonce;
//             console.log("Ethnonce",Ethnonce);
//         }
//     });
// }
// var Bscnonce = 0;
// function initBscNonce(){
//     web3.eth.getTransactionCount(OWNER_ADDRESS).then(function (_nonce) {
//         if(_nonce > Bscnonce){
//             Bscnonce = _nonce;
//             console.log("Bscnonce",Bscnonce);
//         }
//     });
// }

var Bscnonce = 0;
async function  initBscNonce(){
    var _nonce = await web3.eth.getTransactionCount(OWNER_ADDRESS)
      if(_nonce > Bscnonce){
          Bscnonce = _nonce;
          console.log("Bscnonce",Bscnonce);
      }
    
}

var Ethnonce = 0;
async function  initEthNonce(){
    var _nonce = await web3Eth.eth.getTransactionCount(OWNER_ADDRESS)
      if(_nonce > Ethnonce){
          Ethnonce = _nonce;
          console.log("Ethnonce",Ethnonce);
      }
    
}
 
var cronJ1 = new cronJob("*/1 * * * *", async function () {
    // initNonce();
    checkPending()
}, undefined, true, "GMT");

const eth = "0x0000000000000000000000000000000000000002";
const bnb = "0x0000000000000000000000000000000000000001";

async function checkPending() {
    // initNonce();
    fs.readFile(path.resolve(__dirname, 'bscBlock.json'), async (err, blockData) => {

        if (err) {
            console.log(err);
            return;
        }

        blockData = JSON.parse(blockData);
        let lastcheckBlock = blockData["lastblock"];
        const latest = await web3.eth.getBlockNumber();
        console.log(lastcheckBlock,latest)
        blockData["lastblock"] = latest;

        SWAP_INSTANCE.getPastEvents({},
            {
                fromBlock: lastcheckBlock,
                toBlock: latest // You can also specify 'latest'          
            })
            .then(async function (resp) {
                for (let i = 0; i < resp.length; i++) {
                    if (resp[i].event === "SwapRequest") {
                        console.log("SwapRequest emitted");
                        SwapRequest(resp[i])
                    }else if (resp[i].event === "ClaimRequest") {
                        console.log("ClaimRequest emitted");
                        // ClaimRequest(resp[i]);
                    } else if (resp[i].event === "ClaimApprove") {
                        console.log("ClaimApprove emitted");
                        // ClaimApprove(resp[i]);
                        // break;
                    }
                }
            })
            .catch((err) => console.error(err));

        fs.writeFile(path.resolve(__dirname, './bscBlock.json'), JSON.stringify(blockData), (err) => {
            if (err);
            console.log(err);
        });
    });
}

const getRawTransactionApp = function (_address, _nonce, _gasPrice, _gasLimit, _to, _value,_chainID, _data) {
    return {

        nonce: web3.utils.toHex(_nonce),
        // gasPrice: _gasPrice === null ? '0x098bca5a00' : web3.utils.toHex(2*_gasPrice),
        gasPrice: web3.utils.toHex(web3.utils.toWei('200', 'gwei')),
        // gasLimit: _gasLimit === null ? '0x96ed' : web3.utils.toHex(2*_gasLimit),
        gasLimit: web3.utils.toHex(1000000),

        to: _to,
        value: _value === null ? '0x00' : web3.utils.toHex(_value),
        // value: web3.utils.toHex(web3.utils.toWei('0.01', 'ether')),
        data: _data === null ? '' : _data,
        chainId: _chainID
    }
}

const getRawTransactionApp2 = function (_address, _nonce, _gasPrice, _gasLimit, _to, _value,_chainID, _data) {
    return {

        nonce: web3Eth.utils.toHex(_nonce),
        // gasPrice: _gasPrice === null ? '0x098bca5a00' : web3.utils.toHex(2*_gasPrice),
        gasPrice: web3Eth.utils.toHex(web3Eth.utils.toWei('200', 'gwei')),
        // gasLimit: _gasLimit === null ? '0x96ed' : web3.utils.toHex(2*_gasLimit),
        gasLimit: web3Eth.utils.toHex(1000000),

        to: _to,
        value: _value === null ? '0x00' : web3Eth.utils.toHex(_value),
        // value: web3.utils.toHex(web3.utils.toWei('0.01', 'ether')),
        data: _data === null ? '' : _data,
        chainId: _chainID
    }
}


async function ClaimApprove(resp){
    await initBscNonce();
    console.log(resp.returnValues);
    const tokenA = resp.returnValues.tokenA;
    const tokenB = resp.returnValues.tokenB;
    const user = resp.returnValues.user;
    const amount = resp.returnValues.amount;
    const crossOrderType = resp.returnValues.crossOrderType;

    let orderType = [2,1,2,1];


    let USDT_BSC = "0x55d398326f99059fF775485246999027B3197955";

    const path = [USDT_BSC,tokenA];
    console.log("0");

    var encodeABI = DEGEN_INSTANCE.methods.callbackCrossExchange(orderType[crossOrderType],path,amount,user).encodeABI();
    console.log("a");

    // var encodeABI = BRIDGE_INSTANCE.methods.claimTokenBehalf(tokenB,USDT_ETH,USDT_ETH,user).encodeABI();
    const response = await fetch('https://ethgasstation.info/json/ethgasAPI.json');
    const json = await response.json();
    
    console.log("1");
    let gas_limit = (json.fast/10).toString();

    console.log("2");

    // console.log("nonce is:",nonce);
    var rawData = await getRawTransactionApp(
        OWNER_ADDRESS,
        Bscnonce,
        web3.utils.toWei(gas_limit, "gwei"),
        GAS_LIMIT,
        DEGEN_ADDRESS,
        null,
        CROSS_CHAIN_ID,
        encodeABI
    );
    const chain = common.default.forCustomChain(
      'mainnet',{
        name: 'bnb',
        networkId: 97,
        chainId: 97
      },
      'petersburg'
    )

    // var chain = common.default.forCustomChain ('ropsten', { networkId: 1994, chainId: 1994, name: 'geth' }, 'muirGlacier');


    console.log("3");

    // var tx = new Tx(rawData, {common: chain});
    var tx = new Tx(rawData);
    // var tx = new Tx(rawData, {chain:'ropsten', hardfork: 'petersburg'});
    let privateKey = new Buffer.from(pKey, 'hex');
    console.log("4");

    tx.sign(privateKey);
    var serializedTx = tx.serialize();
    console.log("5");

    // changing web3 instance
    web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'), function (error, hash) {
        if (error) {
            console.log("Tx Error : ", error);
        } else {
            // nonce += 1;
            console.log("Tx Success : ", hash)
        }
    })

    // const transactionHash = resp.transactionHash;
    // const blockNumber = resp.blockNumber;

    // const remainTx = await SwapTxModel.findOne({ claimID:claimID,recivedChainId:initConfig.bscChainId });
    // console.log("claim-approve:",transactionHash);
    // if(remainTx === null){
    //     return;
    // }
    
    // remainTx.txStatus = 3;
    // remainTx.oracleTx = transactionHash;
    // remainTx.oracleBlock = blockNumber;
    // remainTx.recivedAmount  = web3.utils.fromWei(nativeAmount);
    // remainTx.foreignAmount = web3.utils.fromWei(foreignAmount);
    // remainTx.save();
}

// async function ClaimRequest(resp){
//     const claimID = resp.returnValues.claimID;
//     const transactionHash = resp.transactionHash;

//     const remainTx = await SwapTxModel.findOne({ recivedTx:transactionHash });
//     if(remainTx === null){
//         return;
//     }
//     console.log("claim-request:",transactionHash)
//     remainTx.txStatus = 2;
//     remainTx.claimID = claimID;
//     remainTx.save();

// }

async function SwapRequest(resp){
    await initEthNonce();
    console.log(resp.returnValues);
    const tokenA = resp.returnValues.tokenA;
    const tokenB = resp.returnValues.tokenB;
    const user = resp.returnValues.user;
    const amount = resp.returnValues.amount;
    const crossOrderType = resp.returnValues.crossOrderType;
    const id = resp.returnValues.nonce

    let USDT_ETH = "0xdAC17F958D2ee523a2206206994597C13D831ec7";

    const path = [USDT_ETH,tokenB];
    console.log("0");

    var encodeABI = CROSS_SWAP_INSTANCE.methods.claimTokenBehalf(path, user,amount,crossOrderType,id).encodeABI();
    console.log("a");

    // var encodeABI = BRIDGE_INSTANCE.methods.claimTokenBehalf(tokenB,USDT_ETH,USDT_ETH,user).encodeABI();
    const response = await fetch('https://ethgasstation.info/json/ethgasAPI.json');
    const json = await response.json();
    
    console.log("1");
    let gas_limit = (json.fast/10).toString();

    console.log("2");

    // console.log("nonce is:",nonce);
    var rawData = await getRawTransactionApp2(
        OWNER_ADDRESS,
        Ethnonce,
        web3.utils.toWei(gas_limit, "gwei"),
        GAS_LIMIT,
        CROSS_SWAP_ADDRESS,
        null,
        CHAIN_ID,
        encodeABI
    );
    const chain = common.default.forCustomChain(
      'mainnet',{
        name: 'bnb',
        networkId: 97,
        chainId: 97
      },
      'petersburg'
    )

    // var chain = common.default.forCustomChain ('ropsten', { networkId: 1994, chainId: 1994, name: 'geth' }, 'muirGlacier');


    console.log("3");

    // var tx = new Tx(rawData, {common: chain});
    var tx = new Tx(rawData);
    // var tx = new Tx(rawData, {chain:'ropsten', hardfork: 'petersburg'});
    let privateKey = new Buffer.from(pKey, 'hex');
    console.log("4");

    tx.sign(privateKey);
    var serializedTx = tx.serialize();
    console.log("5");

    // changing web3 instance
    web3Eth.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'), function (error, hash) {
        if (error) {
            console.log("Tx Error : ", error);
        } else {
            // nonce += 1;
            console.log("Tx Success : ", hash)
        }
    })

    // const transactionHash = resp.transactionHash;
    // const blockNumber = resp.blockNumber;

    // const remainTx = await SwapTxModel.findOne({ claimID:claimID,recivedChainId:initConfig.bscChainId });
    // console.log("claim-approve:",transactionHash);
    // if(remainTx === null){
    //     return;
    // }
    
    // remainTx.txStatus = 3;
    // remainTx.oracleTx = transactionHash;
    // remainTx.oracleBlock = blockNumber;
    // remainTx.recivedAmount  = web3.utils.fromWei(nativeAmount);
    // remainTx.foreignAmount = web3.utils.fromWei(foreignAmount);
    // remainTx.save();
}
// async function SwapRequest(resp){
//     const tokenA = resp.returnValues.tokenA;
//     const tokenB = resp.returnValues.tokenB;
//     const sender = resp.returnValues.sender;
//     const receiver = resp.returnValues.receiver;
//     const amountA = resp.returnValues.amountA;
//     const blockNumber = resp.blockNumber;
//     const transactionHash = resp.transactionHash;
//     const bnbPrice = await priceHelper.getPrice(bnb);
    
//     const data = {
//         tokenA,
//         tokenB,
//         sender,
//         receiver,
//         sentAmount: web3.utils.fromWei(amountA),
//         sentTx: transactionHash,
//         sendBlock: blockNumber,
//         sentChainId:initConfig.bscChainId,
//         sentAPrice:bnbPrice
//     }
//     console.log("swap-request:",transactionHash)
//     swapHelper.addNewRecords(data);

// }

// initNonce();
cronJ1.start();