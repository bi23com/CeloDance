import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flustars/flustars.dart';
import 'package:web3dart/web3dart.dart' as Web3;
import 'package:web3dart/crypto.dart';
import 'package:http/http.dart';

import 'package:web_socket_channel/io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' as convert;
import 'ABI.dart';
import 'SpUtilConstant.dart';

/**
 * 创建新的钱包
 * */
String getMnemonic() {
  String mnemonic = bip39.generateMnemonic(strength: 256);
  return mnemonic;
}

/**
 * 根据助记词获取种子
 * */
Uint8List getSeedByMnemonic(String mnemonic) {
  if (!bip39.validateMnemonic(mnemonic)) {
    return null;
  }
  return bip39.mnemonicToSeed(mnemonic);
}

/**
 * 根据助记词获取以太坊地址
 * */
Future<Respond> getAddressByMnemonic(String mnemonic) async {
  try {
    var seed = getSeedByMnemonic(mnemonic);
    HDWallet hdWallet = HDWallet.fromSeed(seed);
    hdWallet = hdWallet.derivePath("m/44'/52752'/0'/0/0");
    Web3.Credentials credentials = Web3.EthPrivateKey.fromHex(hdWallet.privKey);
    var adder = (await credentials.extractAddress()).hex;
    return Respond(0, msg: 'success', data: adder);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 导入钱包
 * */
Future<CeloWallet> ImportWallet(Uint8List seed, String pwd) async {
  HDWallet hdWallet = HDWallet.fromSeed(seed);
  hdWallet = hdWallet.derivePath("m/44'/52752'/0'/0/0");
  // print("私钥: " + hdWallet.privKey);
  Web3.Credentials credentials = Web3.EthPrivateKey.fromHex(hdWallet.privKey);
  var random = new Random.secure();
  Web3.Wallet wallet = Web3.Wallet.createNew(credentials, pwd, random);
  var address = await credentials.extractAddress();
  return CeloWallet(wallet.toJson(), address.hex);
}

/**
 * celo 钱包
 * */
class CeloWallet {
  final String walletJson;
  final String address;
  final String paw;
  final Uint8List uint8list;

  CeloWallet(this.walletJson, this.address, {this.uint8list, this.paw});
}

/**
 * 响应
 * */
class Respond {
  final int code;
  String msg;
  dynamic data;
  String timeM;
  String address;

  Respond(this.code, {this.msg, this.data, this.timeM, this.address});
}

class SmartContract {
  String name; //合约名称
  String abi; //abi
  String address; //合约地址

  var contract; //合约
  SmartContract(this.name, this.abi, this.address) {
    Web3.EthereumAddress contractAddr =
        Web3.EthereumAddress.fromHex(address, enforceEip55: true);
    this.contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(abi, name), contractAddr);
  }
}

/**
 * 合约类型
 * */
enum ContractType {
  CELO,
  cUSD,
  cEUR,
  Election,
  LockedGold,
  Accounts,
  Validators
}

/**
 * 合约类型扩展
 * */
extension ContractTypeExtension on ContractType {
  SmartContract get contract {
    switch (this) {
      case ContractType.CELO:
        return SmartContract("GoldToken", abis["GoldToken"],
            "0x471EcE3750Da237f93B8E339c536989b8978a438");
      case ContractType.cUSD:
        return SmartContract("StableToken", abis["StableToken"],
            "0x765DE816845861e75A25fCA122bb6898B8B1282a");
      case ContractType.cEUR:
        return SmartContract("GoldToken", abis["GoldToken"],
            "0xD8763CBa276a3738E6DE85b4b3bF5FDed6D6cA73");
      case ContractType.Election:
        return SmartContract("Election", abis["Election"],
            "0x8D6677192144292870907E3Fa8A5527fE55A7ff6");
      case ContractType.LockedGold:
        return SmartContract("LockedGold", abis["LockedGold"],
            "0x6cC083Aed9e3ebe302A6336dBC7c921C9f03349E");
      case ContractType.Accounts:
        return SmartContract("Accounts", abis["Accounts"],
            "0x7d21685C17607338b313a7174bAb6620baD0aaB7");
      case ContractType.Validators:
        return SmartContract("Validators", abis["Validators"],
            "0xaEb865bCa93DdC8F47b8e29F40C5399cE34d0C58");
    }
  }
}

/**
 * 以太坊地址合法性校验
 * */
bool isValidAddress(String address) {
  try {
    Web3.EthereumAddress adde =
        Web3.EthereumAddress.fromHex(address, enforceEip55: true);
    return true;
  } catch (e) {
    try {
      Web3.EthereumAddress adde = Web3.EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/**
 * 查询Celo余额
 * */
Future<Respond> getCeloBalance(String address,
    {String apiUrl = 'https://celo.dance/node'}) async {
  try {
    var httpClient = new Client();
    var ethClient = new Web3.Web3Client(apiUrl, httpClient);
    Web3.EthereumAddress adde = Web3.EthereumAddress.fromHex(address);
    Web3.EtherAmount balance = await ethClient.getBalance(adde);
    String blce = balance.getValueInUnit(Web3.EtherUnit.ether).toString();
    await ethClient.dispose();
    return Respond(0, msg: 'success', data: blce);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 发送Celo交易
 * */
Future<Respond> sendCeloTransaction(String toAddress, num amount,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String remarks}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    var amtGwei = (amount * 1000000000).round();
    var httpClient = new Client();
    var ethClient = new Web3.Web3Client(apiUrl, httpClient);
    var credentials = await ethClient.credentialsFromPrivateKey(priKey);
    await ethClient.sendTransaction(
        credentials,
        Web3.Transaction(
            to: Web3.EthereumAddress.fromHex(toAddress),
            // gasPrice: Web3.EtherAmount.inWei(BigInt.one),
            maxGas: maxGas,
            value:
                Web3.EtherAmount.fromUnitAndValue(Web3.EtherUnit.gwei, amtGwei),
            data:
                remarks == null ? null : Uint8List.fromList(remarks.codeUnits)),
        chainId: chainId);
    await ethClient.dispose();
    return Respond(0, msg: 'success');
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 验证密码
 * */
Future<Respond> checkPwd(CeloWallet celoWallet, String pwd) async {
  Web3.Wallet wallet;
  try {
    wallet = Web3.Wallet.fromJson(celoWallet.walletJson, pwd);
    String priKey = bytesToHex(wallet.privateKey.privateKey);
    final credentials = await Web3.EthPrivateKey.fromHex(priKey);
    String addre = (await credentials.extractAddress()).hex;
    if (Comparable.compare(addre, celoWallet.address) == 0) {
      return Respond(0, msg: 'success', data: priKey);
    }
  } catch (e) {}
  return Respond(-2, msg: 'pwd error');
}

/**
 * 根据智能合约Abi获取余额
 * */
Future<Respond> getBlanceByAbi(String address,
    {String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    ContractType contractType = ContractType.CELO}) async {
  try {
    apiUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    wsUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    final ownAddress = Web3.EthereumAddress.fromHex(address);
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        contractType.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(contractType.contract.abi, 'ERC-20'),
        contractAddr);
    final balanceFunction = contract.function('balanceOf');
    // check our balance in MetaCoins by calling the appropriate function
    final balance = await client.call(
        contract: contract, function: balanceFunction, params: [ownAddress]);
    await client.dispose();
    var bl = getAmount(balance[0].toString());
    return Respond(0, msg: 'success', data: bl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 根据智能合约Abi完成交易
 * */
Future<Respond> sendTransactionByAbi(String toAddress, num amount,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    ContractType contractType = ContractType.CELO,
    String remarks}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    //合约地址
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        contractType.contract.address,
        enforceEip55: true);
    //收款人地址
    final receiver = Web3.EthereumAddress.fromHex(toAddress);
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(contractType.contract.abi, 'ERC-20'),
        contractAddr);
    var ret;
    if (remarks != null) {
      final transferFunction = contract.function('transferWithComment');
      ret = await client.sendTransaction(
          credentials,
          Web3.Transaction.callContract(
            contract: contract,
            function: transferFunction,
            parameters: [receiver, getWeiAmount(amount), remarks],
          ),
          chainId: chainId);
    } else {
      final transferFunction = contract.function('transfer');
      ret = await client.sendTransaction(
          credentials,
          Web3.Transaction.callContract(
            contract: contract,
            function: transferFunction,
            parameters: [receiver, getWeiAmount(amount)],
          ),
          chainId: chainId);
    }
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 根据hash获取交易详情
 * */
Future<Respond> getTransactionReceipt(String hash,
    {int timeOut = 1000, String apiUrl = 'https://celo.dance/node'}) async {
  try {
    apiUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    var httpClient = new Client();
    var ethClient = new Web3.Web3Client(apiUrl, httpClient);
    var transactionReceipt = null;
    var startTime = new DateTime.now().millisecondsSinceEpoch;
    while (transactionReceipt == null &&
        new DateTime.now().millisecondsSinceEpoch <
            startTime + timeOut * 1000) {
      transactionReceipt = await ethClient.getTransactionReceipt(hash);
      await Future.delayed(Duration(seconds: 3));
    }
    await ethClient.dispose();
    if (transactionReceipt == null) {
      return Respond(-2, msg: 'timeout');
    }
    return Respond(0, msg: 'success', data: transactionReceipt);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * valora 调用 获取地址
 * */
Future<Respond> valoraGetAddress(
    {String requestId = 'login',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance'}) async {
  var url = 'celo://wallet/dappkit?';
  url += 'type=' + 'account_address';
  url += '&requestId=' + requestId;
  url += '&callback=' + callback;
  url += '&dappName=' + dappName;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    return Respond(-1, msg: 'Could not launch $url');
  }
  return Respond(0, msg: 'success');
}

/**
 * valora 调用 交易
 * */
Future<Respond> sendTransactionRequestByValora(
    String fromAddress, String toAddress, num amount,
    {String requestId = 'transfer',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    ContractType contractType = ContractType.CELO,
    String remarks,
    int estimatedGas = 1000000}) async {
  try {
    var url = 'celo://wallet/dappkit?';
    url += 'type=' + 'sign_tx';
    url += '&requestId=' + requestId;
    url += '&callback=' + callback;
    url += '&dappName=' + dappName;
    apiUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    wsUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    var httpClient = new Client();
    var ethClient = new Web3.Web3Client(apiUrl, httpClient);
    var from = fromAddress;
    // var to = toAddress;
    var nonce = await ethClient.getTransactionCount(
        Web3.EthereumAddress.fromHex(from),
        atBlock: const Web3.BlockNum.pending());
    //合约地址
    var to = Web3.EthereumAddress.fromHex(contractType.contract.address,
            enforceEip55: true)
        .hex;
    var txData;
    if (remarks != null) {
      final transferFunction =
          ContractType.cUSD.contract.contract.function('transferWithComment');
      txData = bytesToHex(
          transferFunction.encodeCall([
            Web3.EthereumAddress.fromHex(toAddress),
            getWeiAmount(amount),
            remarks
          ]),
          include0x: true);
    } else {
      final transferFunction =
          ContractType.cUSD.contract.contract.function('transfer');
      txData = bytesToHex(
          transferFunction.encodeCall(
              [Web3.EthereumAddress.fromHex(toAddress), getWeiAmount(amount)]),
          include0x: true);
    }
    var value = "0";
    Map<String, dynamic> params = Map();
    params['txData'] = txData;
    params['estimatedGas'] = estimatedGas;
    params['from'] = from;
    params['to'] = to;
    params['nonce'] = nonce;
    params['feeCurrencyAddress'] = Web3.EthereumAddress.fromHex(
            ContractType.cUSD.contract.address,
            enforceEip55: true)
        .hex;
    params['value'] = value;
    final list = [convert.jsonEncode(params)];
    var txs =
        Base64Codec().encode(Uint8List.fromList(list.toString().codeUnits));
    url += '&txs=' + txs;
    await ethClient.dispose();
    bool isAppInstalled = false;
    if (Platform.isAndroid) {
      isAppInstalled = await DeviceApps.isAppInstalled('co.clabs.valora');
    } else if (Platform.isIOS) {
      isAppInstalled = await canLaunch("celo://wallet/dappkit");
    }
    print("isAppInstalled===$isAppInstalled");
    if (isAppInstalled) {
      await launch(url);
    } else {
      return Respond(-99, msg: 'Could not launch $url');
    }
    return Respond(0, msg: 'success');
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

// /**
//  * valora 调用 交易
//  * */
// Future<Respond> sendTransactionRequestByValora(
//     String fromAddress, String toAddress, double amount,
//     {String requestId = 'transfer',
//     String callback = 'celodance://valora',
//     String dappName = 'CeloDance',
//     int maxGas = 20000000,
//     int chainId = 42220,
//     String apiUrl = 'https://celo.dance/node',
//     String wsUrl = 'https://celo.dance/node',
//     ContractType contractType = ContractType.CELO,
//     String remarks,
//     int estimatedGas = 200000}) async {
//   try {
//     var url = 'celo://wallet/dappkit?';
//     url += 'type=' + 'sign_tx';
//     url += '&requestId=' + requestId;
//     url += '&callback=' + callback;
//     url += '&dappName=' + dappName;
//     apiUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
//     wsUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
//     print("contractType===${contractType}");
//     var httpClient = new Client();
//     var ethClient = new Web3.Web3Client(apiUrl, httpClient);
//     var from = fromAddress;
//     // var to = toAddress;
//     var nonce = await ethClient.getTransactionCount(
//         Web3.EthereumAddress.fromHex(from),
//         atBlock: const Web3.BlockNum.pending());
//     var feeCurrencyAddress = Web3.EthereumAddress.fromHex(
//         ContractType.cUSD.contract.address,
//         enforceEip55: true);
//     //合约地址
//     var to = Web3.EthereumAddress.fromHex(contractType.contract.address,
//             enforceEip55: true)
//         .hex;
//     final contract = Web3.DeployedContract(
//         Web3.ContractAbi.fromJson(contractType.contract.abi, 'ERC-20'),
//         feeCurrencyAddress);
//     var txData;
//     if (remarks != null) {
//       final transferFunction = contract.function('transferWithComment');
//       txData = bytesToHex(
//           transferFunction.encodeCall([
//             Web3.EthereumAddress.fromHex(toAddress),
//             getWeiAmount(amount),
//             remarks
//           ]),
//           include0x: true);
//     } else {
//       final transferFunction = contract.function('transfer');
//       txData = bytesToHex(
//           transferFunction.encodeCall(
//               [Web3.EthereumAddress.fromHex(toAddress), getWeiAmount(amount)]),
//           include0x: true);
//     }
//     var value = "0";
//     Map<String, dynamic> params = Map();
//     params['txData'] = txData;
//     params['estimatedGas'] = estimatedGas;
//     params['from'] = from;
//     params['to'] = to;
//     params['nonce'] = nonce;
//     params['feeCurrencyAddress'] = feeCurrencyAddress;
//     params['value'] = value;
//     final list = [convert.jsonEncode(params)];
//     var txs =
//         Base64Codec().encode(Uint8List.fromList(list.toString().codeUnits));
//     url += '&txs=' + txs;
//     await ethClient.dispose();
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       return Respond(-1, msg: 'Could not launch $url');
//     }
//     return Respond(0, msg: 'success');
//     // if (await canLaunch(url)) {
//     //   await launch(url);
//     // } else {
//     //   return Respond(-1, msg: 'Could not launch $url');
//     // }
//     // return Respond(0, msg: 'success');
//   } catch (e) {
//     return Respond(-1, msg: e.toString());
//   }
// }

/**
 * 发送签名交易
 * */
Future<Respond> sendRawTransaction(String rawTxs,
    {String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    apiUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    wsUrl = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    var rcv = await client.sendRawTransaction(hexToBytes(rawTxs));
    await client.dispose();
    return Respond(0, msg: 'success', data: rcv);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 根据交易hash获取交易后的余额及状态
 * */
getInfoByHash(Function fun, String hash) {
  getTransactionReceipt(hash).then((value) {
    Web3.TransactionReceipt transactionReceipt = new Web3.TransactionReceipt();
    if (value.code == 0) {
      //获取余额
      var from = value.data.from;
      getBlanceByAbi(from.toString(), contractType: ContractType.CELO)
          .then((celoBlRet) {
        if (celoBlRet.code == 0) {
          getBlanceByAbi(from.toString(), contractType: ContractType.cUSD)
              .then((cusdBlRet) {
            if (cusdBlRet.code == 0) {
              getBlanceByAbi(from.toString(), contractType: ContractType.cEUR)
                  .then((ceurBlRet) {
                if (ceurBlRet.code == 0) {
                  fun.call(Respond(0, msg: 'success', data: {
                    "celo_bl": celoBlRet.data,
                    "cusd_bl": cusdBlRet.data,
                    "ceur_bl": ceurBlRet.data,
                    "from": from.toString(),
                    "state": value.data.status
                  }));
                } else {
                  fun.call(cusdBlRet);
                }
              });
            } else {
              fun.call(cusdBlRet);
            }
          });
        } else {
          fun.call(celoBlRet);
        }
      });
    } else {
      fun.call(value);
    }
  });
}

/**
 * 锁定 lock   ulocked ==> locked
 * */
Future<Respond> lock(num amount,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    //合约地址
    final credentials = await client.credentialsFromPrivateKey(priKey);
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.LockedGold.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.LockedGold.contract.abi, 'LockedGold'),
        contractAddr);
    //isAccount
    Web3.EthereumAddress accountContractAddr = Web3.EthereumAddress.fromHex(
        ContractType.Accounts.contract.address,
        enforceEip55: true);
    final accountContract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.Accounts.contract.abi, 'Accounts'),
        accountContractAddr);
    final isAccount = accountContract.function('isAccount');
    final isAccountRet = await client.call(
        contract: accountContract,
        function: isAccount,
        params: [Web3.EthereumAddress.fromHex(celoWallet.address)]);
    if (isAccountRet[0] == false) {
      final createAccountFunction = accountContract.function('createAccount');
      var ret = await client.sendTransaction(
          credentials,
          Web3.Transaction.callContract(
              contract: accountContract,
              function: createAccountFunction,
              parameters: [],
              maxGas: maxGas),
          chainId: chainId);
      if (ret[0] != true) {
        return Respond(-1, msg: "create account fail");
      }
    }
    final transferFunction = contract.function('lock');
    var ret = await client.sendTransaction(
        credentials,
        Web3.Transaction.callContract(
            contract: contract,
            function: transferFunction,
            parameters: [],
            value: new Web3.EtherAmount.inWei(getWeiAmount(amount)),
            maxGas: maxGas),
        chainId: chainId);
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 重新锁定 relock  Pending==>Locked
 * */
Future<Respond> relock(num amount,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    int index = 0,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    //合约地址
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.LockedGold.contract.address,
        enforceEip55: true);
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.LockedGold.contract.abi, 'LockedGold'),
        contractAddr);
    final transferFunction = contract.function('relock');
    var ret = await client.sendTransaction(
        credentials,
        Web3.Transaction.callContract(
            contract: contract,
            function: transferFunction,
            parameters: [BigInt.from(index), getWeiAmount(amount)],
            maxGas: maxGas),
        chainId: chainId);
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 解锁 unlock Locked==>Pending
 * */
Future<Respond> unlock(num amount,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    ContractType contractType = ContractType.CELO}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    //合约地址
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.LockedGold.contract.address,
        enforceEip55: true);
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.LockedGold.contract.abi, 'LockedGold'),
        contractAddr);
    final transferFunction = contract.function('unlock');
    var ret = await client.sendTransaction(
        credentials,
        Web3.Transaction.callContract(
            contract: contract,
            function: transferFunction,
            parameters: [getWeiAmount(amount)],
            maxGas: maxGas),
        chainId: chainId);
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 取回 withdraw Pending==>Unlocked
 * */
Future<Respond> withdraw(int index,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    ContractType contractType = ContractType.CELO}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    //合约地址
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.LockedGold.contract.address,
        enforceEip55: true);
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.LockedGold.contract.abi, 'LockedGold'),
        contractAddr);
    final transferFunction = contract.function('withdraw');
    var ret = await client.sendTransaction(
        credentials,
        Web3.Transaction.callContract(
            contract: contract,
            function: transferFunction,
            parameters: [BigInt.from(index)],
            maxGas: maxGas),
        chainId: chainId);
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 获取unlocked、pending、locked金额以及pending可取回金额
 * */
Future<Respond> getAccountInfo(String address,
    {String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final ownAddress = Web3.EthereumAddress.fromHex(address);
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.LockedGold.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.LockedGold.contract.abi, 'LockedGold'),
        contractAddr);

    //锁定数量
    final getAccountTotalLockedGold =
        contract.function('getAccountTotalLockedGold');
    final totalLockedGold = await client.call(
        contract: contract,
        function: getAccountTotalLockedGold,
        params: [ownAddress]);
    var lockedNum = getAmount(totalLockedGold[0].toString());
    //锁定未投票
    final getAccountNonvotingLockedGold =
        contract.function('getAccountNonvotingLockedGold');
    final nonvotingLockedGold = await client.call(
        contract: contract,
        function: getAccountNonvotingLockedGold,
        params: [ownAddress]);
    var nonvotingLockedNum = getAmount(nonvotingLockedGold[0].toString());
    //未锁定数量
    Web3.EthereumAddress tokenContractAddr = Web3.EthereumAddress.fromHex(
        ContractType.CELO.contract.address,
        enforceEip55: true);
    final tokenContract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(ContractType.CELO.contract.abi, 'ERC-20'),
        tokenContractAddr);
    final balanceFunction = tokenContract.function('balanceOf');
    final balance = await client.call(
        contract: tokenContract,
        function: balanceFunction,
        params: [ownAddress]);
    var unlockedNum = getAmount(balance[0].toString());
    //待取回数量
    final getTotalPendingWithdrawals =
        contract.function('getTotalPendingWithdrawals');
    final totalPending = await client.call(
        contract: contract,
        function: getTotalPendingWithdrawals,
        params: [ownAddress]);
    var pendingNum = getAmount(totalPending[0].toString());
    //待取回详情列表
    final getPendingWithdrawals = contract.function('getPendingWithdrawals');
    final pending = await client.call(
        contract: contract,
        function: getPendingWithdrawals,
        params: [ownAddress]);
    var pendingList = [];
    if (pending[0].length > 0) {
      for (int i = 0; i < pending[0].length; i++) {
        var p = {
          'index': i,
          'num': getAmount(pending[0][i].toString()),
          'extractable_time': pending[1][i].toInt() * 1000
        };
        pendingList.add(p);
      }
    }
    var retData = {
      "lockedNum": lockedNum,
      "nonvotingLockedNum": nonvotingLockedNum,
      "pendingNum": pendingNum,
      "pendingDetails": pendingList,
      "unlockedNum": unlockedNum
    };
    print(pending);
    print(new DateTime.now());
    await client.dispose();
    return Respond(0, msg: 'success', data: retData);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 获取验证组列表
 * */
Future<Respond> getEligibleValidatorGroups(
    {String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    bool isNeedOther = true}) async {
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.Election.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.Election.contract.abi, 'Election'),
        contractAddr);

    final getEligibleValidatorGroups =
        contract.function('getTotalVotesForEligibleValidatorGroups');
    final validatorGroupsList = await client.call(
        contract: contract, function: getEligibleValidatorGroups, params: []);
    var validatorGroups = [];
    for (int i = 0; i < validatorGroupsList[0].length; i++) {
      Web3.EthereumAddress accountsContractAddr = Web3.EthereumAddress.fromHex(
          ContractType.Accounts.contract.address,
          enforceEip55: true);
      final accountsContract = Web3.DeployedContract(
          Web3.ContractAbi.fromJson(
              ContractType.Accounts.contract.abi, 'Accounts'),
          accountsContractAddr);
      var validatorGroup = {
        "address": validatorGroupsList[0][i],
        "votes": getAmount(validatorGroupsList[1][i].toString())
      };
      if (isNeedOther) {
        //获取名称
        final getName = accountsContract.function('getName');
        final grourName = await client.call(
            contract: accountsContract,
            function: getName,
            params: [validatorGroupsList[0][i]]);
        validatorGroup.putIfAbsent("name", () => grourName[0]).toString();
        //Elected/Total
        //Current Votes
        //of Total Votes
        //Overall Status
      }
      validatorGroups.add(validatorGroup);
    }
    await client.dispose();
    return Respond(0, msg: 'success', data: validatorGroups);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 投票
 * */
Future<Respond> vote(num amount, String address,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    var eligibleValidatorGroups,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    Respond respond = await getLesserAndGreater(address,
        eligibleValidatorGroups: eligibleValidatorGroups);
    if (respond.code != 0) {
      return respond;
    }
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final to = Web3.EthereumAddress.fromHex(address);
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.Election.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.Election.contract.abi, 'Election'),
        contractAddr);
    final voteFunctoin = contract.function('vote');
    var ret = await client.sendTransaction(
        credentials,
        Web3.Transaction.callContract(
            contract: contract,
            function: voteFunctoin,
            parameters: [
              to,
              getWeiAmount(amount),
              respond.data[0],
              respond.data[1]
            ],
            maxGas: maxGas),
        chainId: chainId);
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 获取已投票验证组列表列表
 * */
Future<Respond> getVotedList(String address,
    {String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.Election.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.Election.contract.abi, 'Election'),
        contractAddr);
    var account = Web3.EthereumAddress.fromHex(address);
    final getTotalVotesByAccount = contract.function('getTotalVotesByAccount');
    final totalVotes = await client.call(
        contract: contract,
        function: getTotalVotesByAccount,
        params: [account]);
    //获取验证组列表
    final getEligibleValidatorGroups =
        contract.function('getTotalVotesForEligibleValidatorGroups');
    final validatorGroupsList = await client.call(
        contract: contract, function: getEligibleValidatorGroups, params: []);
    var votedNum = BigInt.zero;
    var data = [];
    for (int i = 0;
        i < validatorGroupsList[0].length && votedNum < totalVotes[0];
        i++) {
      //获取该验证组激活数量
      final getActiveVotesForGroup =
          contract.function('getActiveVotesForGroupByAccount');
      final activeVotes = await client.call(
          contract: contract,
          function: getActiveVotesForGroup,
          params: [validatorGroupsList[0][i], account]);
      //获取该验证组Pending数量
      final getPendingVotesForGroup =
          contract.function('getPendingVotesForGroupByAccount');
      final pendingVotes = await client.call(
          contract: contract,
          function: getPendingVotesForGroup,
          params: [validatorGroupsList[0][i], account]);
      if (activeVotes[0] + pendingVotes[0] == BigInt.zero) {
        continue;
      }
      votedNum += activeVotes[0] + pendingVotes[0];
      Web3.EthereumAddress accountsContractAddr = Web3.EthereumAddress.fromHex(
          ContractType.Accounts.contract.address,
          enforceEip55: true);
      final accountsContract = Web3.DeployedContract(
          Web3.ContractAbi.fromJson(
              ContractType.Accounts.contract.abi, 'Accounts'),
          accountsContractAddr);
      final getName = accountsContract.function('getName');
      final grourName = await client.call(
          contract: accountsContract,
          function: getName,
          params: [validatorGroupsList[0][i]]);
      var voteInfo = {
        "active": getAmount(activeVotes[0].toString()),
        "pending": getAmount(pendingVotes[0].toString()),
        "pendingIsActivatable": false,
        "address": validatorGroupsList[0][i],
        "accountTotalVote":
            getAmount((activeVotes[0] + pendingVotes[0]).toString()),
        "totalVotes": getAmount(validatorGroupsList[1][i].toString()),
        "name": grourName[0]
      };
      if (pendingVotes[0] != BigInt.zero) {
        //查询是否有待激活投票
        final hasActivatablePendingVotes =
            contract.function('hasActivatablePendingVotes');
        final groupTotalVotes = await client.call(
            contract: contract,
            function: hasActivatablePendingVotes,
            params: [
              Web3.EthereumAddress.fromHex(address),
              validatorGroupsList[0][i]
            ]);
        voteInfo.update("pendingIsActivatable", (value) => groupTotalVotes[0]);
      }
      data.add(voteInfo);
    }
    //获取锁定未投票数量
    Web3.EthereumAddress lockedGoldContractAddr = Web3.EthereumAddress.fromHex(
        ContractType.LockedGold.contract.address,
        enforceEip55: true);
    final lockedGoldContract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.LockedGold.contract.abi, 'LockedGold'),
        lockedGoldContractAddr);
    final getNonvotingLockedGold =
        lockedGoldContract.function('getAccountNonvotingLockedGold');
    final nonvotingLockedGold = await client.call(
        contract: lockedGoldContract,
        function: getNonvotingLockedGold,
        params: [Web3.EthereumAddress.fromHex(address)]);

    await client.dispose();
    return Respond(0, msg: 'success', data: {
      "unused_locked": getAmount(nonvotingLockedGold[0].toString()),
      "voted": data
    });
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * activate投票
 * */
Future<Respond> activate(String groupAddress,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final to = Web3.EthereumAddress.fromHex(groupAddress);
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.Election.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.Election.contract.abi, 'Election'),
        contractAddr);
    final activateFunctoin = contract.function('activate');
    var ret = await client.sendTransaction(
        credentials,
        Web3.Transaction.callContract(
            contract: contract,
            function: activateFunctoin,
            parameters: [to],
            maxGas: maxGas),
        chainId: chainId);
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 撤销激活投票
 * */
Future<Respond> revokeActive(String groupAddress,
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    num amount,
    var eligibleValidatorGroups,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    Respond respond = await getLesserAndGreater(groupAddress,
        eligibleValidatorGroups: eligibleValidatorGroups);
    if (respond.code != 0) {
      return respond;
    }
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final to = Web3.EthereumAddress.fromHex(groupAddress);
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.Election.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.Election.contract.abi, 'Election'),
        contractAddr);
    //获取index
    final getGroupsVotedForByAccount =
        contract.function('getGroupsVotedForByAccount');
    final groups = await client.call(
        contract: contract,
        function: getGroupsVotedForByAccount,
        params: [Web3.EthereumAddress.fromHex(celoWallet.address)]);
    var index = -1;
    for (int i = 0; i < groups[0].length; i++) {
      if (groups[0][i].toString().toLowerCase() == groupAddress.toLowerCase()) {
        index = i;
        break;
      }
    }
    if (index < 0) {
      return Respond(-1, msg: "param error");
    }
    var ret;
    if (amount != null) {
      final revokeActiveFunctoin = contract.function('revokeActive');
      ret = await client.sendTransaction(
          credentials,
          Web3.Transaction.callContract(
              contract: contract,
              function: revokeActiveFunctoin,
              parameters: [
                to,
                getWeiAmount(amount),
                respond.data[0],
                respond.data[1],
                BigInt.from(index)
              ],
              maxGas: maxGas),
          chainId: chainId);
    } else {
      final revokeAllActiveFunctoin = contract.function('revokeAllActive');
      ret = await client.sendTransaction(
          credentials,
          Web3.Transaction.callContract(
              contract: contract,
              function: revokeAllActiveFunctoin,
              parameters: [
                to,
                respond.data[0],
                respond.data[1],
                BigInt.from(index)
              ],
              maxGas: maxGas),
          chainId: chainId);
    }

    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 撤销Pending投票
 * */
Future<Respond> revokePending(String groupAddress,
    {CeloWallet celoWallet,
    num amount,
    String pwd,
    String priKey,
    var eligibleValidatorGroups,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  if ((celoWallet == null || celoWallet.walletJson == null) && priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    Respond respond = await getLesserAndGreater(groupAddress,
        eligibleValidatorGroups: eligibleValidatorGroups);
    if (respond.code != 0) {
      return respond;
    }
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final to = Web3.EthereumAddress.fromHex(groupAddress);
    Web3.EthereumAddress contractAddr = Web3.EthereumAddress.fromHex(
        ContractType.Election.contract.address,
        enforceEip55: true);
    final contract = Web3.DeployedContract(
        Web3.ContractAbi.fromJson(
            ContractType.Election.contract.abi, 'Election'),
        contractAddr);
    //获取index
    final getGroupsVotedForByAccount =
        contract.function('getGroupsVotedForByAccount');
    final groups = await client.call(
        contract: contract,
        function: getGroupsVotedForByAccount,
        params: [Web3.EthereumAddress.fromHex(celoWallet.address)]);
    // print("groups====$groups");
    var index = -1;
    for (int i = 0; i < groups[0].length; i++) {
      if (groups[0][i].toString().toLowerCase() == groupAddress.toLowerCase()) {
        index = i;
        break;
      }
    }
    if (index < 0) {
      return Respond(-1, msg: "param error");
    }
    final revokePendingFunctoin = contract.function('revokePending');
    var ret = await client.sendTransaction(
        credentials,
        Web3.Transaction.callContract(
            contract: contract,
            function: revokePendingFunctoin,
            parameters: [
              to,
              getWeiAmount(amount),
              respond.data[0],
              respond.data[1],
              BigInt.from(index)
            ],
            maxGas: maxGas),
        chainId: chainId);
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * amountToWeiAmount
 * */
BigInt getWeiAmount(num amount) {
  String amtStr = (amount * 10000000).round().toString() + '00000000000';
  return BigInt.parse(amtStr);
}

// /**
//  * amountToWeiAmount
//  * */
// double getAmount(BigInt amount) {
//   var amt = amount == BigInt.zero
//       ? "0"
//       : (int.parse(amount
//                   .toString()
//                   .substring(0, amount.toString().length - 12)) /
//               1000000.000000)
//           .toString();
//   return double.tryParse(amt);
// }

/**
 * amount To WeiAmount
 * */
double getAmount(String amount) {
  // var amt = amount == BigInt.zero?"0":(int.parse(amount.toString().substring(0,amount.toString().length-12))/1000000.000000).toString();
  if (amount == null || amount.length == 0) {
    return 0;
  }
  if (!RegExp(r'^-?[0-9]+').hasMatch(amount)) {
    return 0;
  }
  var amt = amount.toString();
  while (amt.length < 19) {
    amt = '0' + amt;
  }
  var inte = num.tryParse(amt.substring(0, amt.length - 18));
  var dec = amt.substring(amt.length - 18);
  amt = inte.toString() + '.' + dec;
  return double.tryParse(amt);
}

/**
 * 获取验证组票数仅大于和仅小于要投票的验证组地址
 * */
Future<Respond> getLesserAndGreater(String address,
    {var eligibleValidatorGroups}) async {
  if (eligibleValidatorGroups == null) {
    Respond respond = await getEligibleValidatorGroups(isNeedOther: false);
    if (respond.code == 0) {
      eligibleValidatorGroups = respond.data;
    } else {
      return respond;
    }
  } else {
    //排序
  }
  var lesserAddress = Web3.EthereumAddress.fromHex(
      "0x0000000000000000000000000000000000000000");
  var greaterAddress = Web3.EthereumAddress.fromHex(
      "0x0000000000000000000000000000000000000000");
  for (int i = 0; i < eligibleValidatorGroups.length; i++) {
    // print(i.toString() + " " + eligibleValidatorGroups[i]["name"] + " " + eligibleValidatorGroups[i]["address"]);
    if (eligibleValidatorGroups[i]["address"].toString().compareTo(address) ==
        0) {
      if (i > 0) {
        greaterAddress = eligibleValidatorGroups[i - 1]["address"];
      }
      if (i + 1 < eligibleValidatorGroups.length) {
        lesserAddress = eligibleValidatorGroups[i + 1]["address"];
      }
      break;
    }
  }
  return Respond(0, msg: 'success', data: [lesserAddress, greaterAddress]);
}

/**
 * 返回待取回列表
 * */
Future<Respond> getPendingInfo(String address,
    {String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
//待取回详情列表
  try {
    final ownAddress = Web3.EthereumAddress.fromHex(address);
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final isAccount =
        ContractType.Accounts.contract.contract.function('isAccount');
    final isAccountRet = await client.call(
        contract: ContractType.Accounts.contract.contract,
        function: isAccount,
        params: [Web3.EthereumAddress.fromHex(address)]);
    if (isAccountRet[0] == false) {
      return Respond(0, msg: 'success', data: []);
    }
    final getPendingWithdrawals = ContractType.LockedGold.contract.contract
        .function('getPendingWithdrawals');
    final pending = await client.call(
        contract: ContractType.LockedGold.contract.contract,
        function: getPendingWithdrawals,
        params: [ownAddress]);
    var pendingList = [];
    if (pending[0].length > 0) {
      for (int i = 0; i < pending[0].length; i++) {
        var p = {
          'index': i,
          'num': getAmount(pending[0][i].toString()),
          'extractable_time': pending[1][i].toInt() * 1000
        };
        pendingList.add(p);
      }
    }
    await client.dispose();
    return Respond(0, msg: 'success', data: pendingList);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 获取交易记录
 * */
// Future<Respond> getTransactions(List<String> addressList, {ContractType contractType,int fromBlockNum, int toBlockNum, String apiUrl = 'https://celo.dance/node', String wsUrl = 'https://celo.dance/node'}) async{
//   try {
//     final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
//       return IOWebSocketChannel.connect(wsUrl).cast<String>();
//     });
//     Web3.BlockNum fromBlock = (fromBlockNum == null || fromBlockNum == 0 ? Web3.BlockNum.genesis() : Web3.BlockNum.exact(fromBlockNum));
//     Web3.BlockNum toBlock = (toBlockNum == null || toBlockNum == 0 ? Web3.BlockNum.current() : Web3.BlockNum.exact(toBlockNum));
//     List<String> address_topics = [];
//     for(int i = 0 ; i < addressList.length; i ++){
//       var address = addressList[i].toString();
//       address_topics.add("0x000000000000000000000000" + Web3.EthereumAddress.fromHex(address).hexNo0x);
//     }
//     var trances = {};
//     List ret;
//     // celo交易记录
//     // if(contractType == null || contractType == ContractType.CELO){
//     //   ret = await client.getLogs(new Web3.FilterOptions(fromBlock: fromBlock,
//     //       toBlock:toBlock,
//     //       address: Web3.EthereumAddress.fromHex(ContractType.CELO.contract.address,enforceEip55: true),
//     //       topics: [[],address_topics]));
//     //   for(int i = 0 ; i < ret.length ; i ++){
//     //     trances.putIfAbsent(ret[i].transactionHash, () => ret[i]);
//     //   }
//     //   ret = await client.getLogs(new Web3.FilterOptions(fromBlock: fromBlock,
//     //       toBlock:toBlock,
//     //       address: Web3.EthereumAddress.fromHex(ContractType.CELO.contract.address,enforceEip55: true),
//     //       topics: [[],[],address_topics]));
//     //   for(int i = 0 ; i < ret.length ; i ++){
//     //     trances.putIfAbsent(ret[i].transactionHash, () => ret[i]);
//     //   }
//     // }
//
//     //cUSD交易记录
//     // if(contractType == null || contractType == ContractType.cUSD){
//     //   ret = await client.getLogs(new Web3.FilterOptions(fromBlock: fromBlock,
//     //       toBlock:toBlock,
//     //       address: Web3.EthereumAddress.fromHex(ContractType.cUSD.contract.address,enforceEip55: true),
//     //       topics: [[],address_topics]));
//     //   for(int i = 0 ; i < ret.length ; i ++){
//     //     trances.putIfAbsent(ret[i].transactionHash, () => ret[i]);
//     //   }
//     //
//     //   ret = await client.getLogs(new Web3.FilterOptions(fromBlock: fromBlock,
//     //       toBlock:toBlock,
//     //       address: Web3.EthereumAddress.fromHex(ContractType.cUSD.contract.address,enforceEip55: true),
//     //       topics: [[],[],address_topics]));
//     //   for(int i = 0 ; i < ret.length ; i ++){
//     //     trances.putIfAbsent(ret[i].transactionHash, () => ret[i]);
//     //   }
//     // }
//
//     //锁定交易记录
//     if(contractType == null || contractType == ContractType.LockedGold){
//       ret = await client.getLogs(new Web3.FilterOptions(fromBlock: fromBlock,
//           toBlock:toBlock,
//           address: Web3.EthereumAddress.fromHex(ContractType.LockedGold.contract.address,enforceEip55: true),
//           topics: [[],address_topics]));
//       for(int i = 0 ; i < ret.length ; i ++){
//         trances.putIfAbsent(ret[i].transactionHash, () => ret[i]);
//       }
//       ret = await client.getLogs(new Web3.FilterOptions(fromBlock: fromBlock,
//           toBlock:toBlock,
//           address: Web3.EthereumAddress.fromHex(ContractType.LockedGold.contract.address,enforceEip55: true),
//           topics: [[],[],address_topics]));
//       for(int i = 0 ; i < ret.length ; i ++){
//         trances.putIfAbsent(ret[i].transactionHash, () => ret[i]);
//       }
//     }
//
//     //投票交易记录
//     if(contractType == null || contractType == ContractType.Election){
//       ret = await client.getLogs(new Web3.FilterOptions(fromBlock: fromBlock,
//           toBlock:toBlock,
//           address: Web3.EthereumAddress.fromHex(ContractType.Election.contract.address,enforceEip55: true),
//           topics: [[],address_topics]));
//       for(int i = 0 ; i < ret.length ; i ++){
//         trances.putIfAbsent(ret[i].transactionHash, () => ret[i]);
//       }
//       ret = await client.getLogs(new Web3.FilterOptions(fromBlock: fromBlock,
//           toBlock:toBlock,
//           address: Web3.EthereumAddress.fromHex(ContractType.Election.contract.address,enforceEip55: true),
//           topics: [[],[],address_topics]));
//       for(int i = 0 ; i < ret.length ; i ++){
//         trances.putIfAbsent(ret[i].transactionHash, () => ret[i]);
//       }
//     }
//     var tranceList = [];
//     for(var key in trances.keys){
//       var info = {};
//       Web3.TransactionReceipt tr = await client. getTransactionReceipt(key);
//       info.putIfAbsent("transactionHash", () => bytesToHex(tr.transactionHash,include0x: true));
//       info.putIfAbsent("transactionIndex", () => tr.transactionIndex);
//       info.putIfAbsent("transactionIndex", () => tr.transactionIndex);
//       info.putIfAbsent("blockHash", () => bytesToHex(tr.blockHash,include0x: true));
//       info.putIfAbsent("blockNumber", () => tr.blockNumber);
//       info.putIfAbsent("from", () => tr.from.hex);
//       info.putIfAbsent("to", () => tr.to.hex);
//       info.putIfAbsent("cumulativeGasUsed", () => getAmount(tr.cumulativeGasUsed.toString()));
//       info.putIfAbsent("gasUsed", () => getAmount(tr.gasUsed.toString()));
//       info.putIfAbsent("contractAddress", () => tr.contractAddress);
//       info.putIfAbsent("status", () => tr.status);
//       info.putIfAbsent("gasUsed", () => tr.gasUsed);
//       var myBlock = await client.getBlock(bytesToHex(tr.blockHash,include0x: true));
//       info.putIfAbsent("time", () => BigInt.parse(myBlock["timestamp"]));
//       if(tr.logs.length > 0){
//         switch(tr.logs[0].topics[0].toString()){
//           case '0x0f0f2fc5b4c987a49e1663ce2c2d65de12f3b701ff02b4d09461421e63e609e7'://GoldLocked
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "lock()");
//             info.putIfAbsent("transName",() => "锁定");
//             break;
//           case "0xa823fc38a01c2f76d7057a79bb5c317710f26f7dbdea78634598d5519d0f7cb0"://GoldRelocked
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "relock()");
//             info.putIfAbsent("transName",() => "锁定");
//             break;
//           case '0xb1a3aef2a332070da206ad1868a5e327f5aa5144e00e9a7b40717c153158a588'://GoldUnlocked
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "unlock()");
//             info.putIfAbsent("transName",() => "解锁");
//             break;
//           case "0x292d39ba701489b7f640c83806d3eeabe0a32c9f0a61b49e95612ebad42211cd"://GoldWithdrawn
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "withdraw()");
//             info.putIfAbsent("transName",() => "赎回");
//             break;
//           case '0xd3532f70444893db82221041edb4dc26c94593aeb364b0b14dfc77d5ee905152'://ValidatorGroupVoteCast
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "vote()");
//             info.putIfAbsent("transName",() => "投票");
//             break;
//           case '0x148075455e24d5cf538793db3e917a157cbadac69dd6a304186daf11b23f76fe'://ValidatorGroupPendingVoteRevoked
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "revokePending()");
//             info.putIfAbsent("transName",() => "投票(pending)撤销");
//             break;
//           case '0xae7458f8697a680da6be36406ea0b8f40164915ac9cc40c0dad05a2ff6e8c6a8'://ValidatorGroupActiveVoteRevoked
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "revokeActive()");//
//             info.putIfAbsent("transName",() => "投票(Active)撤销");
//             break;
//           case '0x45aac85f38083b18efe2d441a65b9c1ae177c78307cb5a5d4aec8f7dbcaeabfe'://ValidatorGroupVoteActivated
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "ValidatorGroupVoteActivated()");
//             info.putIfAbsent("transName",() => "投票激活");
//             break;
//           case '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'://Transfer
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "transferWithComment()");
//             info.putIfAbsent("transName",() => "转账交易");
//             break;
//           case '0xe5d4e30fb8364e57bc4d662a07d0cf36f4c34552004c4c3624620a2c1d1c03dc'://TransferComment
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "TransferComment");
//             info.putIfAbsent("transName",() => "转账交易");
//             break;
//           case "0x402ac9185b4616422c2794bf5b118bfcc68ed496d52c0d9841dfa114fdeb05ba"://Exchanged
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "Exchanged");
//             info.putIfAbsent("transName",() => "兑换");
//             break;
//           case "0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"://Approval
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "approve()");
//             info.putIfAbsent("transName",() => "未知");
//             break;
//           case "0x805996f252884581e2f74cf3d2b03564d5ec26ccc90850ae12653dc1b72d1fa2"://AccountCreated
//             info.putIfAbsent("amount",() => getAmount(Web3.EtherAmount.inWei(BigInt.parse(tr.logs[0].data)).getInWei.toString()));
//             info.putIfAbsent("transType",() => "AccountCreated");
//             info.putIfAbsent("transName",() => "创建账户");
//             break;
//           default :
//             print("不识别交易:" +  info.toString());
//             break;
//         }
//       }else{
//         //特殊处理
//         print("不识别交易:" + info.toString());
//       }
//       tranceList.add(info);
//     }
//     await client.dispose();
//     return Respond(0,msg:'success',data:tranceList);
//   } catch (e) {
//     return Respond(-1 , msg:e.toString());
//   }
// }
/**
 * 创建账户
 * */

Future<Respond> createAccount(
    {CeloWallet celoWallet,
    String pwd,
    String priKey,
    int maxGas = 20000000,
    int chainId = 42220,
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  if ((celoWallet == null || celoWallet.walletJson == null || pwd == null) &&
      priKey == null) {
    return Respond(1, msg: 'Parameter error');
  }
  if (priKey == null) {
    Respond respond = await checkPwd(celoWallet, pwd);
    if (respond.code == 0) {
      priKey = respond.data;
    }
  }
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final credentials = await client.credentialsFromPrivateKey(priKey);
    final createAccountFunction =
        ContractType.Accounts.contract.contract.function('createAccount');
    var ret = await client.sendTransaction(
        credentials,
        Web3.Transaction.callContract(
            contract: ContractType.Accounts.contract.contract,
            function: createAccountFunction,
            parameters: [],
            maxGas: maxGas),
        chainId: chainId);
    if (ret[0] != true) {
      return Respond(-1, msg: "create account fail");
    }
    await client.dispose();
    return Respond(0, msg: 'success', data: ret);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 测试节点有效性
 * */
Future<Respond> checkUrl({String url = 'https://celo.dance/node'}) async {
  try {
    var httpClient = new Client();
    var clinet = new Web3.Web3Client(url, httpClient);
    var ver = await clinet.getClientVersion();
    await clinet.dispose();
    return Respond(0, msg: 'success', data: true);
  } catch (e) {
    return Respond(-1, msg: 'success', data: false);
  }
}

/**
 * 根据区块号获取当前伦茨的第一个区块号
 * */
Future<Respond> getNowEpochfirstBlocNum(
    {int blockNumber, String apiUrl = 'https://celo.dance/node'}) async {
  try {
    var httpClient = new Client();
    var clinet = new Web3.Web3Client(apiUrl, httpClient);
    if (blockNumber == null || blockNumber == 0) {
      //获取当前块
      blockNumber = await clinet.getBlockNumber();
    }
    final getEpochSize =
        ContractType.Election.contract.contract.function('getEpochSize');
    final epochSize = await clinet.call(
        contract: ContractType.Election.contract.contract,
        function: getEpochSize,
        params: []);
    int size = int.parse(epochSize[0].toString());
    int startBl = blockNumber - size;
    //获取blockNumber 轮次号
    final getEpochNumberOfBlock = ContractType.Election.contract.contract
        .function('getEpochNumberOfBlock');
    final epochNumberOfBlock = await clinet.call(
        contract: ContractType.Election.contract.contract,
        function: getEpochNumberOfBlock,
        params: [BigInt.parse(startBl.toString())]);
    int startNum = int.parse(epochNumberOfBlock[0].toString());
    int endBl = blockNumber;
    while (true) {
      int bl = (startBl + endBl) ~/ 2;
      if (bl + 1 == endBl) {
        break;
      }
      try {
        final epochNumber = await clinet.call(
            contract: ContractType.Election.contract.contract,
            function: getEpochNumberOfBlock,
            params: [BigInt.parse(bl.toString())]);
        if (startNum == int.parse(epochNumber[0].toString())) {
          startBl = bl;
        } else {
          endBl = bl;
        }
      } catch (e) {
        endBl = bl;
      }
    }
    await clinet.dispose();
    return Respond(0,
        msg: 'success', data: {'end': endBl + size, "start": blockNumber});
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}
