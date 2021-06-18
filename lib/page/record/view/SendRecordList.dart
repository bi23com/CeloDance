import 'dart:async';
import 'dart:convert';

import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/AppInterface.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/view/RefreshHeadIdle.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Describe:
/// Date: 3/26/21 1:39 PM
/// Path: page/record/send/view/SendRecordList.dart
class SendRecordList extends StatefulWidget {
  SendRecordList({Key key, this.type, this.address}) : super(key: key);
  final int type;
  final String address;

  @override
  _SendRecordListState createState() => _SendRecordListState();
}

class _SendRecordListState extends State<SendRecordList>
    with AutomaticKeepAliveClientMixin {
  StreamSubscription _SRStreamSubscription;
  List<RecordEntity> _list = List.empty(growable: true);
  List<RecordEntity> _allList = List.empty(growable: true);
  List<Map> recordMap;

  /// 是否注册广播 和 显示记录
  bool _isSend = false;

  // 个数
  int _count = 20;

  // 是否开启上拉加载,默认不开启
  bool isPullUp = false;

  // 刷新的方法
  RefreshController _refreshController;

  // 显示view 1 显示主布局
  int _isShowView = 0;

  /// + - 符号 接收是+ 转出是-
  String symbol = "";

  /// 保存 sql 数据的名字
  String sqlRecordName;

  @override
  void initState() {
    // TODO: implement initState
    _refreshController = RefreshController(initialRefresh: false);
    if (widget.type == 0) {
      symbol = "";
      sqlRecordName = "allRecord";
      _isSend = true;
    } else if (widget.type == 1) {
      symbol = "-";
      sqlRecordName = "rollOut";
      _isSend = true;
    } else if (widget.type == 2) {
      symbol = "+";
      sqlRecordName = "receive";
      _isSend = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _SRStreamSubscription?.cancel();
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
    _count = 20;
    _getListData();
//    await Future.delayed(Duration(milliseconds: 2000));
//    // if failed,use refreshFailed()
//    _refreshController?.refreshCompleted();
  }

  /*
   * 上拉加载
   */
  Future<void> _onLoading() async {
    _count += 20;
    _getListData();
  }

  /*
   * 列表数据
   */
  _getListData() async {
    Map<String, dynamic> json = await HttpTools.requestJSONSyncData(
      AppInterface.TRANSFERS_INTERFACE,
      data: {
        "address": widget.address,
        "type": widget.type,
        "count": _count,
      },
      context: context,
    );
    try {
      if (json != null && mounted && json['code'] == 1) {
        Map<String, dynamic> result = json['result'];
        HttpTools.timestamp = result['timestamp'];
        List items = result['items'];
        _parsingRecord(items);
        if (_allList.length == 0) _isShowView = 1;
        if (_count == 20) {
          if (recordMap == null || recordMap.isEmpty) {
            SqlManager.addRecordData(
                address: widget.address,
                key: sqlRecordName,
                value: jsonEncode(items));
          } else {
            SqlManager.updateMoreFieldData(
                address: widget.address,
                keys: [
                  sqlRecordName,
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
    if (_count == 20)
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
    switch (recordEntity.state) {
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
    if (widget.type == 0) {
      if (widget.address.toLowerCase() ==
          recordEntity.receiveAddress.toLowerCase()) {
        symbol = "+";
      } else {
        symbol = "-";
      }
    }
    String address;
    if (widget.address.toLowerCase() ==
        recordEntity.receiveAddress.toLowerCase()) {
      address = recordEntity?.rollOutAddress?.toLowerCase() ?? "";
    } else {
      address = recordEntity?.receiveAddress?.toLowerCase() ?? "";
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
                address: widget.address, recordEntity: recordEntity);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        text:
                            "$symbol ${Tools.formattingNumCommaEight(recordEntity.count ?? 0)}",
                        style: TextStyle(
                            color: Color(0xFF2E3339),
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenUtil.getInstance().getSp(14)),
                        children: [
                          TextSpan(
                            text: "  ${recordEntity.coinName}",
                            style: TextStyle(
                              color: Color(0xFFA6A6A6),
                              fontSize: ScreenUtil.getInstance().getSp(10),
                            ),
                          ),
                        ]),
                  )),
                  Text(
                    stateTitle,
                    style: TextStyle(
                        color: stateColor,
                        fontWeight: FontWeight.w600,
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
                    address.length > 21
                        ? (address.substring(0, 10) +
                            "......" +
                            address.substring(
                                address.length - 10, address.length))
                        : address,
                    style: TextStyle(
                        color: Color(0xFFC1C6C9),
                        fontSize: ScreenUtil.getInstance().getSp(11)),
                  ),
                  Text(
                    recordEntity.time,
                    style: TextStyle(
                        color: Color(0xFFC1C6C9),
                        fontSize: ScreenUtil.getInstance().getSp(11)),
                  )
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
      String record = recordMap[0][sqlRecordName] ?? "";
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
    if (_isSend) {
      _SRStreamSubscription = EventBusTools.getEventBus()
          ?.on<RecordEntity>()
          ?.listen((event) async {
        if ("updateSendRecord" == event.name) {
          _allList.clear();
          Tools.recordList.forEach((element) {
            if ((element.rollOutAddress?.toLowerCase() ?? "") ==
                (widget.address?.toLowerCase() ?? "")) {
              _allList.add(element);
            }
          });
          _allList.addAll(_list);
          if (mounted) setState(() {});
        }
      });
    }
  }

  /// 解析数据
  _parsingRecord(List items) {
    _allList.clear();
    _list.clear();
    // for (int q = 0; q < Tools.recordList.length; q++) {
    //   print("==$q===${Tools.recordList[q].receiveAddress}");
    //   print("==$q===${Tools.recordList[q].rollOutAddress}");
    // }
    for (int i = 0; i < items.length; i++) {
      RecordEntity recordEntity = RecordEntity.fromJson(items[i]);
      try {
        if (_isSend) {
          for (int q = 0; q < Tools.recordList.length; q++) {
            if ((Tools.recordList[q].rollOutAddress?.toLowerCase() ?? "") ==
                (widget.address?.toLowerCase() ?? "")) {
              if ((recordEntity.txHash?.toLowerCase() ?? "") ==
                  (Tools.recordList[q]?.txHash?.toLowerCase() ?? "")) {
                Tools.recordList.removeAt(i);
                break;
              }
            }
          }
        }
      } catch (e) {
        // print("111==$e");
      }
      _list.add(recordEntity);
    }
    if (_isSend) {
      Tools.recordList.forEach((element) {
        if ((element.rollOutAddress?.toLowerCase() ?? "") ==
                (widget.address?.toLowerCase() ?? "") &&
            !Tools.isNull(element.txHash)) {
          _allList.insert(0, element);
        }
      });
    }
    _allList.addAll(_list);

    if (items.length % 20 == 0) {
      isPullUp = true;
    } else {
      isPullUp = false;
    }
    _isShowView = 1;
  }
}
