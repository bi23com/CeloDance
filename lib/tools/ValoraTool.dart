import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_apps/device_apps.dart';
import 'package:web3dart/web3dart.dart' as Web3;
import 'package:web3dart/crypto.dart';
import 'package:http/http.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert' as convert;

import 'WalletTool.dart';

/**
 * valora 调用 交易
 * */
Future<Respond> sendTransactionByValora(String from, String txData,
    {String requestId = 'transfer',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    ContractType contractType = ContractType.CELO,
    int estimatedGas = 1000000,
    var mValue}) async {
  try {
    var url = 'celo://wallet/dappkit?';
    url += 'type=' + 'sign_tx';
    url += '&requestId=' + requestId;
    url += '&callback=' + callback;
    url += '&dappName=' + dappName;
    var httpClient = new Client();
    var ethClient = new Web3.Web3Client(apiUrl, httpClient);
    var nonce = await ethClient.getTransactionCount(
        Web3.EthereumAddress.fromHex(from),
        atBlock: const Web3.BlockNum.current());
    //合约地址
    var to = Web3.EthereumAddress.fromHex(contractType.contract.address,
            enforceEip55: true)
        .hex;
    var value;
    if (mValue == null || mValue.toString().length == 0) {
      value = "0";
    } else {
      value = mValue;
    }
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
    if (isAppInstalled) {
      await launch(url);
    } else {
      return Respond(-99, msg: 'Could not launch $url');
    }
    //
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   return Respond(-1, msg: 'Could not launch $url');
    // }
    return Respond(0, msg: 'success');
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 查询该地址是否是账户
 * */
Future<Respond> isAccount(String address,
    {String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final isAccount =
        ContractType.Accounts.contract.contract.function('isAccount');
    final isAccountRet = await client.call(
        contract: ContractType.Accounts.contract.contract,
        function: isAccount,
        params: [Web3.EthereumAddress.fromHex(address)]);
    await client.dispose();
    return Respond(0, msg: 'success', data: isAccountRet[0]);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 创建账户
 * */
Future<Respond> createAccountByValora(String from,
    {String requestId = 'createAccountByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final transferFunction =
        ContractType.Accounts.contract.contract.function('createAccount'); //修改
    var parame = []; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.Accounts,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 锁定
 * */
Future<Respond> lockByValora(num amount, String from,
    {String requestId = 'lockByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final transferFunction =
        ContractType.LockedGold.contract.contract.function('lock'); //修改
    var parame = []; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    var value = (new Web3.EtherAmount.inWei(getWeiAmount(amount)))
        .getInWei
        .toString(); //仅lock使用
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.LockedGold,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl,
        mValue: value);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 再锁定
 * */
Future<Respond> relockByValora(num amount, String from,
    {int index = 0,
    String requestId = 'relockByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final transferFunction =
        ContractType.LockedGold.contract.contract.function('relock'); //修改
    var parame = [BigInt.from(index), getWeiAmount(amount)]; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.LockedGold,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 解锁
 * */
Future<Respond> unlockByValora(num amount, String from,
    {String requestId = 'unlockByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final transferFunction =
        ContractType.LockedGold.contract.contract.function('unlock'); //修改
    var parame = [getWeiAmount(amount)]; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.LockedGold,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 取回
 * */
Future<Respond> withdrawByValora(int index, String from,
    {String requestId = 'withdrawByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final transferFunction =
        ContractType.LockedGold.contract.contract.function('withdraw'); //修改
    var parame = [BigInt.from(index)]; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.LockedGold,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 投票
 * */
Future<Respond> voteByValora(num amount, String groupAddress, String from,
    {String requestId = 'voteByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    var eligibleValidatorGroups}) async {
  try {
    Respond respond = await getLesserAndGreater(groupAddress,
        eligibleValidatorGroups: eligibleValidatorGroups);
    if (respond.code != 0) {
      return respond;
    }
    final transferFunction =
        ContractType.Election.contract.contract.function('vote'); //修改
    var parame = [
      Web3.EthereumAddress.fromHex(groupAddress),
      getWeiAmount(amount),
      respond.data[0],
      respond.data[1]
    ]; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.Election,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 激活
 * */
Future<Respond> activateByValora(String groupAddress, String from,
    {String requestId = 'activateByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node'}) async {
  try {
    final transferFunction =
        ContractType.Election.contract.contract.function('activate'); //修改
    var parame = [Web3.EthereumAddress.fromHex(groupAddress)]; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.Election,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 撤销pending投票
 * */
Future<Respond> revokePendingByValora(
    num amount, String groupAddress, String from,
    {String requestId = 'revokePendingByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    var eligibleValidatorGroups}) async {
  try {
    Respond respond = await getLesserAndGreater(groupAddress,
        eligibleValidatorGroups: eligibleValidatorGroups);
    if (respond.code != 0) {
      return respond;
    }
    //获取index
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final getGroupsVotedForByAccount = ContractType.Election.contract.contract
        .function('getGroupsVotedForByAccount');
    final groups = await client.call(
        contract: ContractType.Election.contract.contract,
        function: getGroupsVotedForByAccount,
        params: [Web3.EthereumAddress.fromHex(from)]);
    var index = -1;
    for (int i = 0; i < groups[0].length; i++) {
      if (groups[0][i].toString().toLowerCase() == groupAddress.toLowerCase()) {
        index = i;
        break;
      }
    }
    await client.dispose();
    if (index < 0) {
      return Respond(-1, msg: "param error");
    }
    final transferFunction =
        ContractType.Election.contract.contract.function('revokePending'); //修改
    var parame = [
      Web3.EthereumAddress.fromHex(groupAddress),
      getWeiAmount(amount),
      respond.data[0],
      respond.data[1],
      BigInt.from(index)
    ]; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.Election,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}

/**
 * 撤销激活投票
 * */
Future<Respond> revokeActiveByValora(
    num amount, String groupAddress, String from,
    {String requestId = 'revokeActiveByValora',
    String callback = 'celodance://valora',
    String dappName = 'CeloDance',
    String apiUrl = 'https://celo.dance/node',
    String wsUrl = 'https://celo.dance/node',
    var eligibleValidatorGroups}) async {
  try {
    Respond respond = await getLesserAndGreater(groupAddress,
        eligibleValidatorGroups: eligibleValidatorGroups);
    if (respond.code != 0) {
      return respond;
    }
    //获取index
    final client = Web3.Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final getGroupsVotedForByAccount = ContractType.Election.contract.contract
        .function('getGroupsVotedForByAccount');
    final groups = await client.call(
        contract: ContractType.Election.contract.contract,
        function: getGroupsVotedForByAccount,
        params: [Web3.EthereumAddress.fromHex(from)]);
    var index = -1;
    for (int i = 0; i < groups[0].length; i++) {
      if (groups[0][i].toString().toLowerCase() == groupAddress.toLowerCase()) {
        index = i;
        break;
      }
    }
    await client.dispose();
    if (index < 0) {
      return Respond(-1, msg: "param error");
    }
    final transferFunction =
        ContractType.Election.contract.contract.function('revokeActive'); //修改
    var parame = [
      Web3.EthereumAddress.fromHex(groupAddress),
      getWeiAmount(amount),
      respond.data[0],
      respond.data[1],
      BigInt.from(index)
    ]; //修改
    var txData =
        bytesToHex(transferFunction.encodeCall(parame), include0x: true);
    return await sendTransactionByValora(from, txData,
        contractType: ContractType.Election,
        //修改
        requestId: requestId,
        callback: callback,
        dappName: dappName,
        apiUrl: apiUrl,
        wsUrl: wsUrl);
  } catch (e) {
    return Respond(-1, msg: e.toString());
  }
}
