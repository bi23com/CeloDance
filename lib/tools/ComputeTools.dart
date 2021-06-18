import 'package:dpos/page/address/entity/SendHomeEntity.dart';

import 'WalletTool.dart';

/// Describe: 后台运行的方法 的工具类
/// Date: 4/24/21 2:32 PM
/// Path: tools/ComputeTools.dart

/// 地址发送交易方法
Future<Respond> sendAddress(SendHomeEntity sendHomeEntity) async {
  return await sendTransactionByAbi(
      sendHomeEntity.toAddress, sendHomeEntity.count,
      celoWallet: CeloWallet(sendHomeEntity.privateKey, sendHomeEntity.address),
      pwd: sendHomeEntity.paw,
      wsUrl: sendHomeEntity.apiUrl,
      apiUrl: sendHomeEntity.apiUrl,
      contractType: sendHomeEntity.tokenType,
      remarks: sendHomeEntity.tip);
}

/// 锁定
Future<Respond> lockResult(SendHomeEntity sendHomeEntity) async {
  return await lock(
    sendHomeEntity.count,
    celoWallet: CeloWallet(sendHomeEntity.privateKey, sendHomeEntity.address),
    pwd: sendHomeEntity.paw,
    wsUrl: sendHomeEntity.apiUrl,
    apiUrl: sendHomeEntity.apiUrl,
  );
}

/// 投票
Future<Respond> voteResult(SendHomeEntity sendHomeEntity) async {
  return await vote(
    sendHomeEntity.count,
    sendHomeEntity.toAddress,
    celoWallet: CeloWallet(sendHomeEntity.privateKey, sendHomeEntity.address),
    pwd: sendHomeEntity.paw,
    wsUrl: sendHomeEntity.apiUrl,
    apiUrl: sendHomeEntity.apiUrl,
  );
}

/// 解锁
Future<Respond> unlockResult(SendHomeEntity sendHomeEntity) async {
  return await unlock(
    sendHomeEntity.count,
    celoWallet: CeloWallet(sendHomeEntity.privateKey, sendHomeEntity.address),
    pwd: sendHomeEntity.paw,
    wsUrl: sendHomeEntity.apiUrl,
    apiUrl: sendHomeEntity.apiUrl,
  );
}

/// 撤销激活投票
Future<Respond> revokeActiveResult(SendHomeEntity sendHomeEntity) async {
  print("toAddress==激活===${sendHomeEntity.toAddress}");
  return await revokeActive(
    sendHomeEntity.toAddress,
    celoWallet: CeloWallet(sendHomeEntity.privateKey, sendHomeEntity.address),
    pwd: sendHomeEntity.paw,
    amount: sendHomeEntity.count > sendHomeEntity.active
        ? sendHomeEntity.active
        : sendHomeEntity.count,
    wsUrl: sendHomeEntity.apiUrl,
    apiUrl: sendHomeEntity.apiUrl,
  );
}

/// 撤销Pending投票
Future<Respond> revokePendingResult(SendHomeEntity sendHomeEntity) async {
  // print("toAddress==撤销===${sendHomeEntity.toAddress}");
  return await revokePending(
    sendHomeEntity.toAddress,
    celoWallet: CeloWallet(sendHomeEntity.privateKey, sendHomeEntity.address),
    pwd: sendHomeEntity.paw,
    amount: sendHomeEntity.count > sendHomeEntity.pending
        ? sendHomeEntity.pending
        : sendHomeEntity.count,
    wsUrl: sendHomeEntity.apiUrl,
    apiUrl: sendHomeEntity.apiUrl,
  );
}

/// 激活投票
Future<Respond> activateResult(SendHomeEntity sendHomeEntity) async {
  Respond respond = await activate(
    sendHomeEntity.toAddress,
    celoWallet: CeloWallet(sendHomeEntity.privateKey, sendHomeEntity.address),
    pwd: sendHomeEntity.paw,
    wsUrl: sendHomeEntity.apiUrl,
    apiUrl: sendHomeEntity.apiUrl,
  );
  respond.address = sendHomeEntity.address;
  respond.timeM = sendHomeEntity.timeM;
  return respond;
}

/// 取回 celo
Future<Respond> withdrawResult(SendHomeEntity sendHomeEntity) async {
  return await withdraw(
    sendHomeEntity.index,
    celoWallet: CeloWallet(sendHomeEntity.privateKey, sendHomeEntity.address),
    pwd: sendHomeEntity.paw,
    wsUrl: sendHomeEntity.apiUrl,
    apiUrl: sendHomeEntity.apiUrl,
  );
}

/// 取回 当前区块高度
Future<Respond> getNowEpochfirstBlocNumResult(SendHomeEntity sendHomeEntity) async {
  return await getNowEpochfirstBlocNum(
    apiUrl: sendHomeEntity.apiUrl,
  );
}
