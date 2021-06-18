import 'package:dpos/page/earnings/entity/VoteEntity.dart';
import 'package:dpos/tools/WalletTool.dart';

/// Describe: 广播发送实体类
/// Date: 4/9/21 4:16 PM
/// Path: page/address/entity/SendHomeEntity.dart
class SendHomeEntity {
  /// 广播名称
  String name;

  /// 投票激活总数
  num active;

  /// 投票待激活总数
  num pending;

  /// 数量
  num count;

  /// 币种名称
  String coinName;

  /// 查询地址
  String address;

  /// 要交易的地址
  String toAddress;

  /// 交易的key
  String privateKey;

  /// 交易密码
  String paw;

  /// 交易的类型
  ContractType tokenType;

  /// 标签
  String tip;

  /// 时间戳字符串
  String timeM;

  /// 交易的url
  String apiUrl;

  /// 属性
  int type;

  /// 下标
  int index;

  /// 是否是 Valora 地址
  int isValora;

  /// 投票单个 实体类
  VoteEntity voteEntity;

  SendHomeEntity(
      {this.name,
      this.count,
      this.coinName,
      this.address,
      this.privateKey,
      this.toAddress,
      this.paw,
      this.tokenType,
      this.tip,
      this.type,
      this.apiUrl,
      this.isValora,
      this.active,
      this.voteEntity,
      this.index,
      this.pending,
      this.timeM});

}
