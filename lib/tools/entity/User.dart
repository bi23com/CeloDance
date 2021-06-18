import 'dart:convert';

import 'package:dpos/page/home/Home.dart';

import '../Tools.dart';

/// Describe:  用户表 存储地址 相关数据
/// Date: 3/23/21 11:00 AM
/// Path: tools/entity/User.dart
class User {
  String address;
  String name;
  String privateKey;

  /// 收益界面 链的名称 和 logo
  String earningsName;
  String earningsLogo;

  /// 手机号
  String phoneNum;

  ///帐号属性
  int type;

  /// 1 代表是Valora 授权地址  0 代表不是Valora的地址
  int isValora;

  /// 币的数量
  num celo;
  num celoAvailable;
  num celoLocked;
  num celoPending;
  num celoNonvoting;
  num cusd;
  num ceur;

  /// 币的价格
  num celoMoney;
  num cusdMoney;
  num ceurMoney;
  num allMoney;

  /// 上次收益 累计 celo 总数量
  num totalNum = 0;
  num lastNum = 0;
  List rewardsList = List.empty(growable: true);
  String rewards;

  User(
      {this.address,
      this.name,
      this.privateKey,
      this.celo,
      this.celoAvailable,
      this.celoLocked,
      this.celoNonvoting,
      this.celoPending,
      this.cusd,
      this.ceur,
      this.rewards});

  User.fromJson(Map map) {
    address = map['address'] ?? "";
    name = map['name'] ?? "";
    privateKey = map['privateKey'] ?? "";
    celo = num.parse(map['celo']?.toString() ?? "0");
    celoAvailable = num.parse(map['celoAvailable']?.toString() ?? "0");
    celoLocked = num.parse(map['celoLocked']?.toString() ?? "0");
    celoNonvoting = num.parse(map['celoNonvoting']?.toString() ?? "0");
    celoPending = num.parse(map['celoPending']?.toString() ?? "0");
    cusd = num.parse(map['cusd']?.toString() ?? "0");
    ceur = num.parse(map['ceur']?.toString() ?? "0");
    rewards = map['rewards'] ?? "";
    earningsName = map['earningsName'] ?? "";
    earningsLogo = map['earningsLogo'] ?? "";
    phoneNum = map['phoneNum'] ?? "";
    type = map['type'] ?? 0;
    isValora = map['isValora'] ?? 0;
  }

  User.fromHomeJson(Map map) {
    Map<String, dynamic> assets = map['assets'];
    Map<String, dynamic> celoMap = assets['celo'];
    celoAvailable = celoMap['available'] ?? 0;
    celoLocked = celoMap['locked'] ?? 0;
    celoNonvoting = celoMap['nonvoting'] ?? 0;
    celoPending = celoMap['pending'] ?? 0;
    celo = celoAvailable + celoLocked + celoPending;
    cusd = assets['cusd'] ?? 0.0;
    ceur = assets['ceur'] ?? 0.0;
    celoMoney = celo * HomeState.celoPrices;
    cusdMoney = cusd * HomeState.cusdPrices;
    ceurMoney = ceur * HomeState.ceurPrices;
    allMoney = celoMoney + ceurMoney + cusdMoney;
    earningsName = map['name'] ?? "";
    // print("earningsName===$earningsName");
    earningsLogo = map['logo'] ?? "";
    // print("earningsLogo===$earningsLogo");
    phoneNum = "";
    type = map['type'] ?? 0;
    // print("allMoney====$allMoney");
    rewardsList = map['rewards'];
    rewardsList.forEach((element) {
      num total = element['total'] ?? 0;
      num last = element['last'] ?? 0;
      switch (element['type'] ?? 0) {
        case 1:
          totalNum += total;
          lastNum += last;
          break;
        case 2:
          totalNum += total;
          lastNum += last;
          break;
        // case 3:
        //   totalMoney += total * HomeState.cusdPrices;
        //   lastMoney += last * HomeState.cusdPrices;
        //   break;
        // case 4:
        //   totalMoney += total * HomeState.cusdPrices;
        //   lastMoney += last * HomeState.cusdPrices;
        //   break;
        // case 5:
        //   totalMoney += total * HomeState.cusdPrices;
        //   lastMoney += last * HomeState.cusdPrices;
        //   break;
        case 6:
          totalNum += total;
          lastNum += last;
          break;
        default:
          totalNum += 0;
          lastNum += 0;
      }
    });
  }

  User.fromSQLHomeJson(Map map) {
    address = map['address'] ?? "";
    name = map['name'] ?? "";
    privateKey = map['privateKey'] ?? "";
    isValora = map['isValora'] ?? 0;
    celoAvailable = num.parse(map['celoAvailable']?.toString() ?? "0");
    celoLocked = num.parse(map['celoLocked']?.toString() ?? "0");
    celoNonvoting = num.parse(map['celoNonvoting']?.toString() ?? "0");
    celoPending = num.parse(map['celoPending']?.toString() ?? "0");
    celo = num.parse(map['celo']?.toString() ?? "0");
    cusd = num.parse(map['cusd']?.toString() ?? "0");
    ceur = num.parse(map['ceur']?.toString() ?? "0");
    celoMoney = celo * HomeState.celoPrices;
    cusdMoney = cusd * HomeState.cusdPrices;
    ceurMoney = ceur * HomeState.ceurPrices;
    allMoney = celoMoney + ceurMoney + cusdMoney;
    earningsName = map['earningsName'] ?? "";
    earningsLogo = map['earningsLogo'] ?? "";
    phoneNum = map['phoneNum'] ?? "";
    type = map['type'] ?? 0;
    if (!Tools.isNull(map['rewards'])) {
      rewardsList = jsonDecode(map['rewards']);
      rewardsList.forEach((element) {
        num total = element['total'] ?? 0;
        num last = element['last'] ?? 0;
        // print("total===$total");
        // print("last===$last");
        switch (element['type'] ?? 0) {
          case 1:
            totalNum += total;
            lastNum += last;
            break;
          case 2:
            totalNum += total;
            lastNum += last;
            break;
          // case 3:
          //   totalMoney += total * HomeState.cusdPrices;
          //   lastMoney += last * HomeState.cusdPrices;
          //   break;
          // case 4:
          //   totalMoney += total * HomeState.cusdPrices;
          //   lastMoney += last * HomeState.cusdPrices;
          //   break;
          // case 5:
          //   totalMoney += total * HomeState.cusdPrices;
          //   lastMoney += last * HomeState.cusdPrices;
          //   break;
          case 6:
            totalNum += total;
            lastNum += last;
            break;
          default:
            totalNum += 0;
            lastNum += 0;
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['name'] = this.name;
    data['privateKey'] = this.privateKey;
    return data;
  }

  /// 存储保存 sql数据格式 的 map
  User.fromSaveSqlJson(
      {String address, String privateKey, Map map, int isValora}) {
    this.address = address;
    this.isValora = isValora;
    name = "";
    this.privateKey = privateKey ?? "";
    Map<String, dynamic> assets = map['assets'] ?? {};
    Map<String, dynamic> celoMap = assets['celo'] ?? {};
    celoAvailable = celoMap['available'] ?? 0;
    celoLocked = celoMap['locked'] ?? 0;
    celoNonvoting = celoMap['nonvoting'] ?? 0;
    celoPending = celoMap['pending'] ?? 0;
    celo = celoAvailable + celoLocked + celoPending;
    cusd = assets['cusd'] ?? 0.0;
    ceur = assets['ceur'] ?? 0.0;
    rewards = jsonEncode(map['rewards']) ?? "";
    earningsName = "";
    earningsLogo = "";
    phoneNum = "";
    type = 0;
  }

  ///  sql数据格式 的 map
  Map<String, dynamic> toSQLJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address?.toLowerCase() ?? "";
    data['name'] = this.name ?? "";
    data['privateKey'] = this.privateKey ?? "";
    data['celo'] = this.celo?.toString() ?? "0";
    data['celoAvailable'] = this.celoAvailable?.toString() ?? "0";
    data['celoLocked'] = this.celoLocked?.toString() ?? "0";
    data['celoNonvoting'] = this.celoNonvoting?.toString() ?? "0";
    data['celoPending'] = this.celoPending?.toString() ?? "0";
    data['cusd'] = this.cusd?.toString() ?? "0";
    data['ceur'] = this.ceur?.toString() ?? "0";
    data['rewards'] = this.rewards ?? "";
    data['isValora'] = this.isValora ?? 0;
    data['earningsName'] = this.earningsName ?? "";
    data['earningsLogo'] = this.earningsLogo ?? "";
    data['phoneNum'] = this.phoneNum ?? "";
    data['type'] = this.type ?? 0;
    return data;
  }
}
