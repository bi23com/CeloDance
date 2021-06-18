/// 投票列表 实体类
class VoteEntity {
  // active: 0.050007,
  // pending: 0.0,
  // pendingIsActivatable: false,
  // address: 0xbf55df76204f00acf296f76cf4aaf86a866a5eb0
  /// 投票激活总数
  num active;

  /// 投票待激活总数
  num pending;

  /// false 投票已激活  true 投票未激活
  bool pendingIsActivatable;

  /// 地址
  String address;

  /// logo
  String logo;

  /// 验证组名称
  String name;

  /// 投票总数
  num votes;

  ///待取回 需要的下标
  int index;
  int timeStamp;
  String time;

  VoteEntity.formJson(Map map) {
    this.active = num.parse(map['active']?.toString() ?? "0");
    this.pending = num.parse(map['pending']?.toString() ?? "0");
    this.votes = num.parse(map['totalVotes']?.toString() ?? "0");
    this.pendingIsActivatable = map['pendingIsActivatable'] ?? false;
    this.address = map['address']?.toString() ?? "";
    this.name = map['name']?.toString() ?? "";
  }

  /// 待取回
  VoteEntity.formWithdrawJson(Map map) {
    // {index: 0, num: 0.01, extractable_time: 1619504471000}
    this.votes = num.parse(map['num']?.toString() ?? "0");
    this.index = map['index'] ?? 0;
    this.timeStamp = map['extractable_time'] ?? 0;
    if (this.timeStamp > 0) {
      this.time = DateTime.fromMillisecondsSinceEpoch(timeStamp)
              .toLocal()
              .toString()
              .split(".")[0] ??
          "";
      this.time = this.time.substring(5, this.time.length);
    } else {
      this.time = "";
    }
  }

  /// 投票验证组 集合
  VoteEntity.formGroupJson(Map map) {
    this.votes = num.parse(map['votes']?.toString() ?? "0");
    this.name = map['name']?.toString() ?? "";
    this.address = map['address']?.toString() ?? "";
    this.logo = "https://thecelo.com/logos/${this.address}.jpg";
    this.active = 0;
    this.pending = 0;
  }
}
