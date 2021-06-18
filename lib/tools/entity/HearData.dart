import 'package:dpos/http/HttpTools.dart';

/// Describe: 存储 价格 收益组 数据的实体类
/// Date: 3/26/21 5:50 PM
/// Path: tools/entity/HearData.dart
// class HearData {
//   int code;
//   Result result;
//
//   HearData({this.code, this.result});
//
//   HearData.fromJson(Map<String, dynamic> json) {
//     code = json['code'] ?? 0;
//     result =
//         json['result'] != null ? new Result.fromJson(json['result']) : null;
//   }
// }
//
// /// 数组总体
// class Result {
//   RewardTypes rewardTypes;
//   AccountTypes accountTypes;
//   Prices prices;
//   List tip;
//
//   Result({this.rewardTypes, this.accountTypes, this.prices});
//
//   Result.fromJson(Map<String, dynamic> json) {
//
//     tip = json['tip'];
//     rewardTypes = json['reward_types'] != null
//         ? new RewardTypes.fromJson(json['reward_types'])
//         : null;
//     accountTypes = json['account_types'] != null
//         ? new AccountTypes.fromJson(json['account_types'])
//         : null;
//     prices =
//         json['prices'] != null ? new Prices.fromJson(json['prices']) : null;
//   }
// }

/// Describe: 收益组 相关数据
/// Date: 3/26/21 5:52 PM
/// Path: tools/entity/HearData.dart
class RewardTypes {
  RewardTypesItem vote_zh; //投票收益
  RewardTypesItem holdCUSD_zh; // 持有cusd收益
  RewardTypesItem verifyGroup_zh; // 验证组收益
  RewardTypesItem verifyPerson_zh; //验证人收益
  RewardTypesItem note_zh; //短信证明收益
  RewardTypesItem inform_zh; // 举报收益

  RewardTypesItem vote_en; //投票收益
  RewardTypesItem holdCUSD_en; // 持有cusd收益
  RewardTypesItem verifyGroup_en; // 验证组收益
  RewardTypesItem verifyPerson_en; //验证人收益
  RewardTypesItem note_en; //短信证明收益
  RewardTypesItem inform_en; // 举报收益

  RewardTypes.fromJson(Map<String, dynamic> json) {
    _zh(json['cn']);
    _en(json['en']);
  }

  _zh(Map<String, dynamic> json) {
    vote_zh = RewardTypesItem.fromJson(json['1'].cast<String>());
    holdCUSD_zh = RewardTypesItem.fromJson(json['2'].cast<String>());
    verifyGroup_zh = RewardTypesItem.fromJson(json['3'].cast<String>());
    verifyPerson_zh = RewardTypesItem.fromJson(json['4'].cast<String>());
    note_zh = RewardTypesItem.fromJson(json['5'].cast<String>());
    inform_zh = RewardTypesItem.fromJson(json['6'].cast<String>());
  }

  _en(Map<String, dynamic> json) {
    vote_en = RewardTypesItem.fromJson(json['1'].cast<String>());
    holdCUSD_en = RewardTypesItem.fromJson(json['2'].cast<String>());
    verifyGroup_en = RewardTypesItem.fromJson(json['3'].cast<String>());
    verifyPerson_en = RewardTypesItem.fromJson(json['4'].cast<String>());
    note_en = RewardTypesItem.fromJson(json['5'].cast<String>());
    inform_en = RewardTypesItem.fromJson(json['6'].cast<String>());
  }
}

/// 收益组每条数据
class RewardTypesItem {
  String title; //收益组的名称
  String unit; // 单位
  String coinName; // 币的名称
  String tipTitle; // tip 标题
  String tipUrl; // tip 跳转地址

  RewardTypesItem.fromJson(List<String> data) {
    if (data.length >= 5) {
      title = data[0];
      unit = data[1];
      coinName = data[2];
      tipTitle = data[3];
      tipUrl = data[4];
    } else {
      title = "";
      unit = "";
      coinName = "";
    }
  }
}

/// 账户属性
class AccountTypes {
  String account_zh; // 一般账户
  String verifyGroup_zh; // 验证组
  String verifyPerson_zh; //验证人
  String contract_zh; // 合约

  String account_en; // 一般账户
  String verifyGroup_en; // 验证组
  String verifyPerson_en; //验证人
  String contract_en; // 合约
  AccountTypes.fromJson(Map<String, dynamic> json) {
    _zh(json['cn']);
    _en(json['en']);
  }

  _zh(Map<String, dynamic> json) {
    account_zh = json['0'];
    verifyGroup_zh = json['1'];
    verifyPerson_zh = json['2'];
    contract_zh = json['3'];
  }

  _en(Map<String, dynamic> json) {
    account_en = json['0'];
    verifyGroup_en = json['1'];
    verifyPerson_en = json['2'];
    contract_en = json['3'];
  }
}

/// 价格
class Prices {
  COIN cELO;
  COIN cUSD;
  COIN cEUR;

  Prices({this.cELO, this.cUSD, this.cEUR});

  Prices.fromJson(Map<String, dynamic> json) {
    cELO = COIN.fromJson(json['CELO']);
    cUSD = COIN.fromJson(json['CUSD']);
    cEUR = COIN.fromJson(json['CEUR']);
  }
}

/// 币的价格 属性
class COIN {
  double cNY;
  double uSD;
  double bTC;

  COIN({this.cNY, this.uSD, this.bTC});

  COIN.fromJson(Map<String, dynamic> json) {
    cNY = json['CNY'] ?? 0;
    uSD = double.parse(json['USD']?.toString() ?? "0");
    bTC = double.parse(json['BTC']?.toString() ?? "0");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CNY'] = this.cNY;
    data['USD'] = this.uSD;
    data['BTC'] = this.bTC;
    return data;
  }
}
