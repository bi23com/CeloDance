import 'dart:async';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'entity/RecordEntity.dart';

/// Describe: 发送记录详情
/// Date: 3/26/21 2:01 PM
/// Path: page/record/send/SendRecordDetails.dart
class SendRecordDetails extends StatefulWidget {
  SendRecordDetails(
      {Key key,
      this.recordEntity,
      this.address,
      this.detailsEnum,
      this.typeName})
      : super(key: key);

  final String address;
  final String typeName;
  final RecordEntity recordEntity;
  final DetailsEnum detailsEnum;

  @override
  _SendRecordDetailsState createState() => _SendRecordDetailsState();
}

class _SendRecordDetailsState extends State<SendRecordDetails> {
  /// + - 符号 接收是+ 转出是-
  String symbol = "";
  String typeTitle = "";
  String addressTitle = "";
  StreamSubscription _detailS;
  RecordEntity _recordEntity;

  /// 是否显示 地址 和 hash 的布局
  bool _isShowAddressOrHash;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recordEntity = widget.recordEntity;
    _isShowAddressOrHash = (widget.detailsEnum != DetailsEnum.activateOrRecap);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _detailS?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String title;
    String address;
    if (widget.detailsEnum == DetailsEnum.vote ||
        widget.detailsEnum == DetailsEnum.activateOrRecap) {
      symbol = "";
      if (Tools.isNull(widget.typeName)) {
        /// 属性 1 锁定  2 解锁  3 投票   4 撤票   5取回
        switch (_recordEntity.type) {
          case 1:
            typeTitle = S.of(context).lock_e;
            break;
          case 2:
            typeTitle = S.of(context).unlock;
            break;
          case 3:
            typeTitle = S.of(context).vote;
            break;
          case 4:
            typeTitle = S.of(context).revoke;
            break;
          case 5:
            typeTitle = S.of(context).withdraw;
            break;
          case 6:
            typeTitle = S.of(context).activation;
            break;
        }
      } else {
        typeTitle = widget.typeName;
      }
      addressTitle = S.of(context).address;
      title = S.of(context).details;
      // address = _recordEntity?.rollOutAddress?.toLowerCase() ?? "";
    } else {
      if (widget.address.toLowerCase() ==
          _recordEntity.receiveAddress.toLowerCase()) {
        symbol = "+";
        typeTitle = S.of(context).receive;
        addressTitle = S.of(context).roll_out_address;
        title = S.of(context).receive_details;
        address = _recordEntity?.rollOutAddress?.toLowerCase() ?? "";
      } else {
        symbol = "-";
        typeTitle = S.of(context).send;
        addressTitle = S.of(context).receive_address;
        title = S.of(context).send_details;
        address = _recordEntity?.receiveAddress?.toLowerCase() ?? "";
      }
    }
    String stateTitle = "";
    String stateImg = "";
    switch (_recordEntity.state) {
      case 0:
        stateTitle = S.of(context).confirmation;
        stateImg = "cd_waiting_icon";
        break;
      case 1:
        stateTitle = S.of(context).been_completed;
        stateImg = "cd_successful_icon";
        break;
      case 2:
        stateTitle = S.of(context).fail;
        stateImg = "cd_failure_icon";
        break;
      default:
        stateImg = "cd_waiting_icon";
        break;
    }
    // print("_isShowAddressOrHash===$_isShowAddressOrHash");
    return BaseTitle(
        title: title,
        body: ScrollConfiguration(
          behavior: NoScrollBehavior(),
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: ScreenUtil.getInstance().getWidth(60), bottom: 10),
                child: Image.asset(
                  "assets/img/$stateImg.png",
                  height: ScreenUtil.getInstance().getWidth(60),
                  fit: BoxFit.fitHeight,
                ),
              ),
              Text(
                stateTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w600,
                    fontSize: ScreenUtil.getInstance().getSp(14)),
              ),
              SizedBox(
                height: 40,
              ),
              RichText(
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                text: TextSpan(
                    text:
                        "$symbol ${Tools.formattingNumCommaEight(_recordEntity?.count ?? 0)}",
                    style: TextStyle(
                        color: Color(0xFF2E3339),
                        fontWeight: FontWeight.w600,
                        fontSize: ScreenUtil.getInstance().getSp(20)),
                    children: [
                      TextSpan(
                        text: "  ${_recordEntity?.coinName ?? ""}",
                        style: TextStyle(
                          color: Color(0xFFC1C6C9),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenUtil.getInstance().getSp(12),
                        ),
                      ),
                    ]),
              ),
              SizedBox(
                height: 8,
              ),
              _getItem(S.of(context).type, typeTitle),
              // _getItem(S.of(context).state, stateTitle),
              Tools.getLine(left: 14),
              // _getItem(S.of(context).service_charge, "0"),
              // _getLine(),
              Visibility(
                  visible: _isShowAddressOrHash ? !Tools.isNull(address) : true,
                  child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!Tools.isNull(address)) {
                          Clipboard.setData(ClipboardData(text: address));
                          Tools.showToast(context, S.of(context).copy_success);
                        }
                      },
                      child: _getCopyItem(addressTitle, address))),
              Visibility(
                visible: _isShowAddressOrHash ? !Tools.isNull(address) : true,
                child: Tools.getLine(left: 14),
              ),
              Visibility(
                  visible: _isShowAddressOrHash,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!Tools.isNull(_recordEntity?.txHash ?? "")) {
                        Clipboard.setData(
                            ClipboardData(text: _recordEntity?.txHash ?? ""));
                        Tools.showToast(context, S.of(context).copy_success);
                      }
                    },
                    child: _getCopyItem("TXhash", _recordEntity?.txHash ?? ""),
                  )),
              Visibility(
                visible: _isShowAddressOrHash,
                child: Tools.getLine(left: 14),
              ),
              _getItem(S.of(context).trading_hours, _recordEntity?.time ?? ""),
              Tools.getLine(left: 14),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 50,
              )
            ],
          ),
        ));
  }

  /// 布局item
  Widget _getItem(String leftName, String rightName) {
    return Container(
      height: 60,
      padding: EdgeInsets.only(left: 14),
      child: Row(
        children: [
          Text(
            leftName,
            style: TextStyle(
                color: Color(0xFFA1A1A1),
                fontWeight: FontWeight.w400,
                height: 1,
                fontSize: ScreenUtil.getInstance().getSp(12)),
          ),
          SizedBox(
            width: ScreenUtil.getInstance().getWidth(25),
          ),
          Expanded(
              child: Text(
            rightName,
            textAlign: TextAlign.right,
            style: TextStyle(
                color: Color(0xFF48515B),
                height: 1,
                fontSize: ScreenUtil.getInstance().getSp(11)),
          )),
          SizedBox(
            width: 14,
          )
        ],
      ),
    );
  }

  /// 带 复制 的布局item
  Widget _getCopyItem(String leftName, String rightName) {
    // if (!Tools.isNull(rightName)) {
    //   if (rightName.length <= 42) {
    //     addressOne = rightName.substring(0, 32);
    //     addressTwo = rightName.substring(32, rightName.length);
    //   } else {
    //     addressOne = rightName.substring(0, 40);
    //     addressTwo = rightName.substring(32, rightName.length);
    //   }
    // }
    return Container(
      height: 60,
      padding: EdgeInsets.only(left: 14),
      child: Row(
        children: [
          Text(
            leftName,
            style: TextStyle(
                color: Color(0xFFA1A1A1),
                fontWeight: FontWeight.w400,
                height: 1,
                fontSize: ScreenUtil.getInstance().getSp(12)),
          ),
          SizedBox(
            width: ScreenUtil.getInstance().getWidth(25),
          ),
          Expanded(
              child: Visibility(
                  visible: !Tools.isNull(rightName),
                  child: RichText(
                      textAlign: TextAlign.right,
                      // strutStyle: StrutStyle(forceStrutHeight: true, height:0.6, leading: 1),
                      text: TextSpan(
                          text: rightName,
                          style: TextStyle(
                              color: Color(0xFF48515B),
                              fontSize: ScreenUtil.getInstance().getSp(12)),
                          children: [
                            WidgetSpan(
                                child: Padding(
                              padding: EdgeInsets.only(left: 5, top: 3),
                              child: Image.asset(
                                "assets/img/cd_aa_copy_icon.png",
                                width: ScreenUtil.getInstance().getWidth(16),
                                fit: BoxFit.fitWidth,
                              ),
                            )),
                          ])))),
          // Expanded(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Text(
          //       addressOne,
          //       textAlign: TextAlign.right,
          //       style: TextStyle(
          //           color: Color(0xFF48515B),
          //           fontSize: ScreenUtil.getInstance().getSp(11)),
          //     ),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         Text(
          //           addressTwo,
          //           style: TextStyle(
          //               color: Color(0xFF48515B),
          //               fontSize: ScreenUtil.getInstance().getSp(11)),
          //         ),
          //         Visibility(
          //             visible: !Tools.isNull(addressTwo),
          //             child: Image.asset(
          //               "assets/img/cd_aa_copy_icon.png",
          //               width: ScreenUtil.getInstance().getWidth(16),
          //               fit: BoxFit.fitWidth,
          //             ))
          //       ],
          //     )
          //   ],
          // )),
          SizedBox(
            width: 14,
          )
        ],
      ),
    );
  }

  /// 初始化数据
  _initData() async {
    if (widget.detailsEnum != DetailsEnum.normal) {
      _detailS = EventBusTools.getEventBus()
          ?.on<RecordEntity>()
          ?.listen((event) async {
        if ("updateVoteDetails" == event.name) {
          if (mounted) {
            if (Tools.isNull(event.tag)) {
              for (int i = 0; i < Tools.voteList.length; i++) {
                if (Tools.voteList[i].timeStamp == event.time) {
                  _recordEntity = Tools.voteList[i];
                  setState(() {});
                  break;
                }
              }
            } else if (event.tag == "trading") {
              for (int i = 0; i < Tools.recordList.length; i++) {
                if (Tools.recordList[i].timeStamp == event.time) {
                  _recordEntity = Tools.recordList[i];
                  setState(() {});
                  break;
                }
              }
            }
          }
        }
      });
    }
  }
}

///  列表详情枚举类
///  0 正常布局不需要更新 1.交易成功 2 投票 /撤票  3 激活 / 取回 隐藏地址 和 hash
enum DetailsEnum {
  /// 正常布局不需要更新
  normal,

  /// 交易
  deal,

  /// 投票 /撤票
  vote,

  /// 激活 / 取回 隐藏地址 和 hash
  activateOrRecap,
}
