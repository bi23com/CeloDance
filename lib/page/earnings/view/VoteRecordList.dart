import 'dart:async';
import 'dart:convert';

import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/AppInterface.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/page/record/SendRecordDetails.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/view/RefreshHeadIdle.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Describe: 投票记录
/// Date: 4/21/21 5:07 PM
/// Path: page/earnings/view/VoteRecordList.dart
class VoteRecordList extends StatefulWidget {
  VoteRecordList({Key key, this.type, this.address}) : super(key: key);
  final int type;
  final String address;

  @override
  _VoteRecordListState createState() => _VoteRecordListState();
}

class _VoteRecordListState extends State<VoteRecordList>
    with AutomaticKeepAliveClientMixin {
  List<RecordEntity> _list = List.empty(growable: true);
  List<RecordEntity> _allList = List.empty(growable: true);
  List<Map> recordMap;

  // 个数
  int _count = 40;

  // 是否开启上拉加载,默认不开启
  bool isPullUp = false;

  // 刷新的方法
  RefreshController _refreshController;

  // 显示view 1 显示主布局
  int _isShowView = 0;

  @override
  void initState() {
    // TODO: implement initState
    _refreshController = RefreshController(initialRefresh: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return ScrollConfiguration(
        behavior: NoScrollBehavior(),
        child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: isPullUp,
            onLoading: _onLoading,
            controller: _refreshController,
            onRefresh: _onRefresh,
            header: RefreshHeadIdle(),
            child: _getHomeLayout()));
  }

  /*
   * 下拉刷新用到的方法
   */
  Future<void> _onRefresh() async {
    _count = 40;
    _getListData();
//    await Future.delayed(Duration(milliseconds: 2000));
//    // if failed,use refreshFailed()
//    _refreshController?.refreshCompleted();
  }

  /*
   * 上拉加载
   */
  Future<void> _onLoading() async {
    _count += 40;
    _getListData();
  }

  /*
   * 列表数据
   */
  _getListData() async {
    // Respond respond = await getTransactions([widget.address]);
    // LogUtil.v('请求结果：${respond.code}');
    // LogUtil.v('请求结果：${respond.data}');
    // if (respond.code == 0) {
    //   int a = 0;
    //   respond.data.forEach((element) {
    //     print("类型=$a=${element['transName']}");
    //     a++;
    //   });
    // } else {}
    // _refreshController?.refreshCompleted();
    Map<String, dynamic> json = await HttpTools.requestJSONSyncData(
      AppInterface.TRANSFERS_INTERFACE,
      data: {
        "address": widget.address,
        "type": "00",
        "count": _count,
      },
      context: context,
    );
    try {
      if (json != null && mounted && json['code'] == 1) {
        Map<String, dynamic> result = json['result'];
        HttpTools.timestamp = result['timestamp'];
        List items = result['items'];
        // print("items===$items");
        _parsingRecord(items);
        if (_allList.length == 0) _isShowView = 1;
        if (_count == 40) {
          if (recordMap == null || recordMap.isEmpty) {
            SqlManager.addRecordData(
                address: widget.address,
                key: "voteAll",
                value: jsonEncode(items));
          } else {
            SqlManager.updateMoreFieldData(
                address: widget.address,
                keys: [
                  'voteAll',
                ],
                values: [jsonEncode(items)],
                name: SqlManager.RECORD);
          }
        }
      } else {
        if (_allList.length == 0) _isShowView = 1;
      }
    } catch (e) {
      print(e);
    }
    if (_count == 40)
      _refreshController?.refreshCompleted();
    else
      _refreshController?.loadComplete();
    if (mounted) setState(() {});
  }

  /*
   * 返回首页布局
   */
  Widget _getHomeLayout() {
    if (_isShowView == 1) {
      return _allList.length == 0
          ? Padding(
              padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil.getInstance().getWidthPx(190)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    "assets/img/cd_no_address_record_icon.png",
                    width: ScreenUtil.getInstance().getWidth(283),
                    fit: BoxFit.fitWidth,
                  ),
                  Text(
                    S.of(context).no_record,
                    style: TextStyle(
                        color: Color(0XFFA6A6A6),
                        fontSize: ScreenUtil.getInstance().getSp(15)),
                  )
                ],
              ),
            )
          : ListView.builder(
              // physics: NeverScrollableScrollPhysics(), //禁用滑动事件
              padding: EdgeInsets.only(bottom: 10),
              itemCount: _allList.length,
              itemBuilder: (cont, index) {
                return _item(_allList[index]);
              },
            );
    } else {
      return Text("");
    }
  }

  /// 列表布局
  Widget _item(RecordEntity recordEntity) {
    String stateTitle = "";
    Color stateColor;
    switch (recordEntity.state ?? 0) {
      case 0:
        stateTitle = S.of(context).confirmation;
        stateColor = Color(0XFFF7B500);
        break;
      case 1:
        stateTitle = S.of(context).been_completed;
        stateColor = Color(0XFF999999);
        break;
      case 2:
        stateTitle = S.of(context).fail;
        stateColor = Color(0XFFFF4F41);
        break;
      default:
        stateTitle = "";
        stateColor = Color(0XFF999999);
        break;
    }
    String title = "";
    if (Tools.isNull(recordEntity.tag)) {
      /// 3:锁定 4:解锁 5:投票 6:取消投票 7:激活 8:取回 9
      switch (recordEntity.type ?? 0) {
        case 3:
          title = S.of(context).lock_e;
          break;
        case 4:
          title = S.of(context).unlock;
          break;
        case 5:
          title = S.of(context).vote;
          break;
        case 6:
          title = S.of(context).revoke;
          break;
        case 8:
          title = S.of(context).withdraw;
          break;
        case 7:
          title = S.of(context).vote_activated;
          break;
        case 9:
          title = S.of(context).cancel_inactive_votes;
          break;
      }
    } else {
      /// 属性 1 锁定  2 解锁  3 投票   4 撤票   5取回 6 激活
      switch (recordEntity.type ?? 0) {
        case 1:
          title = S.of(context).lock_e;
          break;
        case 2:
          title = S.of(context).unlock;
          break;
        case 3:
          title = S.of(context).vote;
          break;
        case 4:
          title = S.of(context).revoke;
          break;
        case 5:
          title = S.of(context).withdraw;
          break;
        case 6:
          title = S.of(context).vote_activated;
          break;
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlatButton(
          padding: EdgeInsets.only(
              left: 15,
              top: ScreenUtil.getInstance().getWidth(14),
              right: ScreenUtil.getInstance().getWidth(13),
              bottom: ScreenUtil.getInstance().getWidth(12)),
          onPressed: () {
            RouteTools.startActivity(context, RouteTools.SEND_RECORD_DETAILS,
                address: widget.address,
                recordEntity: recordEntity,
                title: title,
                detailsEnum: DetailsEnum.vote);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: Color(0xFF2E3339),
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenUtil.getInstance().getSp(14)),
                  ),
                  Text(
                    stateTitle,
                    style: TextStyle(
                        color: stateColor,
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenUtil.getInstance().getSp(14)),
                  )
                ],
              ),
              SizedBox(
                height: 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${Tools.formattingNumCommaEight(recordEntity.count)} CELO",
                    style: TextStyle(
                        color: Color(0xFFA1A1A1),
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenUtil.getInstance().getSp(10)),
                  ),
                  Text(
                    recordEntity.time,
                    style: TextStyle(
                        color: Color(0xFFA1A1A1),
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenUtil.getInstance().getSp(10)),
                  ),
                ],
              ),
            ],
          ),
          color: Color(0XFFFFFFFF),
          highlightColor: Color(0XFFF3F2F3),
        ),
        Container(
          margin: EdgeInsets.only(left: 15),
          height: 0.5,
          width: double.infinity,
          color: Color(0XFFDEDEDE),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  /// 初始化数据
  _initData() async {
    recordMap = await SqlManager.queryAddressData(widget.address,
        name: SqlManager.RECORD);
    if (recordMap.isNotEmpty) {
      String record = recordMap[0]['voteAll'] ?? "";
      // print("==$record");
      if (!Tools.isNull(record)) {
        try {
          _parsingRecord(jsonDecode(record));
        } catch (e) {
          print(e);
        }
        setState(() {});
        _onRefresh();
      } else {
        _refreshController?.requestRefresh();
      }
    } else {
      _refreshController?.requestRefresh();
    }
  }

  /// 解析数据
  _parsingRecord(List items) {
    _allList.clear();
    _list.clear();
    for (int i = 0; i < items.length; i++) {
      RecordEntity recordEntity = RecordEntity.fromVoteJson(items[i]);
      try {
        for (int q = 0; q < Tools.voteList.length; q++) {
          if ((Tools.voteList[q].rollOutAddress?.toLowerCase() ?? "") == (widget.address?.toLowerCase() ?? "")) {
            if ((recordEntity.txHash?.toLowerCase() ?? "") == (Tools.voteList[q]?.txHash?.toLowerCase() ?? "")) {
              Tools.voteList.removeAt(i);
              break;
            }
          }
        }
      } catch (e) {
        // print("111==$e");
      }
      _list.add(recordEntity);
    }
    Tools.voteList.forEach((element) {
      if ((element.rollOutAddress?.toLowerCase() ?? "") == (widget.address?.toLowerCase() ?? "") && !Tools.isNull(element.txHash)) {
        element.tag = "vote";
        _allList.insert(0, element);
      }
    });
    _allList.addAll(_list);

    // if (items.length % 20 == 0) {
    //   isPullUp = true;
    // } else {
    //   isPullUp = false;
    // }
    _isShowView = 1;
  }
}
