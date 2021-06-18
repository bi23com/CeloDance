/// 交易记录 实体类
class RecordEntity {
  /// 交易地址
  String rollOutAddress;

  /// 接收地址
  String receiveAddress;

  /// 交易时间
  String time;

  /// 时间戳
  String timeStamp;

  /// 交易代币名称
  String coinName;

  /// 广播的名称
  String name;

  /// tag
  String tag;

  /// 广播 传的值
  int position;

  /// 交易id
  String txHash;

  /// 交易代币数量
  num count;

  /// 交易的状态 0 确认中 1 成功 2失败
  int state;

  /// 属性 1 锁定  2 解锁  3 投票   4 撤票   5取回 6 激活
  int type;

  /// 下标
  int index;

  RecordEntity(
      {this.rollOutAddress,
      this.receiveAddress,
      this.time,
      this.position,
      this.name,
      this.coinName,
      this.count,
      this.type,
      this.tag,
      this.timeStamp,
      this.index,
      this.state});

  RecordEntity.fromJson(List list) {
    time = list[0]?.toString() ?? "";
    rollOutAddress = list[1]?.toString() ?? "";
    receiveAddress = list[2]?.toString() ?? "";
    coinName = list[3]?.toString() ?? "";
    count = list[4] ?? 0;
    txHash = list[5]?.toString() ?? "";
    state = 1;
  }

  RecordEntity.fromVoteJson(List list) {
    time = list[0]?.toString() ?? "";
    rollOutAddress = list[1]?.toString() ?? "";
    receiveAddress = list[2]?.toString() ?? "";
    coinName = "CELO";
    // coinName = list[3]?.toString() ?? "";
    count = list[4] ?? 0;
    txHash = list[5]?.toString() ?? "";
    type = list[6] ?? 0;
    state = 1;
  }
}
