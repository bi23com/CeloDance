import 'package:cool_ui/cool_ui.dart';
import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/page/address/dialog/PinPawDialog.dart';
import 'package:dpos/page/address/entity/SendHomeEntity.dart';
import 'package:dpos/page/earnings/entity/VoteEntity.dart';
import 'package:dpos/page/record/SendRecordDetails.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/Content.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

/// Describe: 收益 弹窗 锁定 解锁 取回
/// Date: 4/21/21 11:46 AM
/// Path: page/earnings/dialog/EarningsDialog.dart
class EarningsDialog {
  final BuildContext context;
  final String title;
  final String address;
  final String btnName;
  final String walletJson;
  final String toAddress;
  final num coinNum;

  /// 投票 单个记录列表
  final VoteEntity voteEntity;

  /// 投票激活的数量
  final num active;

  /// 投票待激活的数量
  final num pending;
  final int type;
  final int isValora;
  final Function exitDialog;

  EarningsDialog(
      {@required this.context,
      this.title,
      this.address,
      this.active,
      this.pending,
      this.btnName,
      this.walletJson,
      this.isValora,
      this.type,
      this.voteEntity,
      this.toAddress,
      this.exitDialog,
      this.coinNum});

  Future<bool> show() async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return EarningsD(
          coinNum: coinNum,
          active: active,
          pending: pending,
          address: address,
          btnName: btnName,
          isValora: isValora,
          title: title,
          voteEntity: voteEntity,
          type: type,
          exitDialog: exitDialog,
          toAddress: toAddress,
          walletJson: walletJson,
        );
      },
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      // 设置背景颜色
      transitionDuration: Duration(milliseconds: 400),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          fromBottom(animation, secondaryAnimation, child),
    );
  }

  // 从下往上弹出动画效果
  fromBottom(Animation<double> animation, Animation<double> secondaryAnimation,
      Widget child) {
    return ScaleTransition(
      scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  }
}

class EarningsD extends StatefulWidget {
  EarningsD(
      {Key key,
      @required this.title,
      this.address,
      this.coinNum,
      this.btnName,
      this.type,
      this.isValora,
      this.active,
      this.pending,
      this.exitDialog,
      this.toAddress,
      this.voteEntity,
      this.walletJson})
      : super(key: key);
  final String title;
  final String address;
  final String btnName;
  final String walletJson;
  final String toAddress;
  final num coinNum;
  final int type;
  final Function exitDialog;
  final int isValora;

  /// 投票 单个记录列表
  final VoteEntity voteEntity;

  /// 投票激活的数量
  final num active;

  /// 投票待激活的数量
  final num pending;

  @override
  _EarningsDState createState() => _EarningsDState();
}

class _EarningsDState extends State<EarningsD> {
  TextEditingController _numController;
  FocusNode _numFocusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _numController = TextEditingController();
    _numFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _numController?.dispose();
    _numFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.of(context).pop();
          },
          child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil.getInstance().screenHeight / 4),
                      child: GestureDetector(
                          onTap: () {},
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    right: 20, left: 20, top: 26, bottom: 20),
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: _homeLayout(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        Navigator.of(context).pop();
                                      },
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(right: 30, top: 13),
                                        child: Image.asset(
                                          "assets/img/cd_close_icon.png",
                                          height: ScreenUtil.getInstance()
                                              .getWidth(13),
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ))
                                ],
                              ),
                            ],
                          )),
                    )
                  ],
                ),
              ))),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
    );
  }

  _homeLayout() {
    double size10 = ScreenUtil.getInstance().getWidth(10);
    double size20 = ScreenUtil.getInstance().getWidth(20);
    String address;
    if (widget.type == 3 || widget.type == 4) {
      address = widget.toAddress
              ?.replaceRange(10, widget.toAddress.length - 10, "......") ??
          "";
    } else {
      address = widget.address
              ?.replaceRange(10, widget.address.length - 10, "......") ??
          "";
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Text(
              widget.title ?? "",
              style: TextStyle(
                  color: Color(0XFF404044),
                  fontWeight: FontWeight.w600,
                  fontSize: ScreenUtil.getInstance().getSp(14)),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text(
              address,
              style: TextStyle(
                color: Color(0xFF48515B),
                fontSize: ScreenUtil.getInstance().getSp(12),
              ),
              textAlign: TextAlign.right,
            ))
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            S.of(context).number,
            style: TextStyle(
                color: Color(0XFF404044),
                fontWeight: FontWeight.w600,
                fontSize: ScreenUtil.getInstance().getSp(14)),
            textAlign: TextAlign.left,
          ),
        ),
        TextField(
          maxLength: 20,
          controller: _numController,
          focusNode: _numFocusNode,
          autofocus: true,
          keyboardType: NumberKeyboard.inputType,
          // keyboardType: TextInputType.number,
          inputFormatters: [
            //只允许输入小数
            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
          ],
          style: TextStyle(
            color: Color(0xFF48515B),
            fontSize: ScreenUtil.getInstance().getSp(16),
          ),
          cursorColor: Color(0xFF353535),
          autocorrect: true,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              // filled: true,
              helperText:
                  "${S.of(context).maximum} ${Tools.formattingNumCommaEight(widget.coinNum ?? 0)} CELO",
              helperStyle: TextStyle(
                color: Color(0xFF9B9EA2),
                fontSize: ScreenUtil.getInstance().getSp(11),
              ),
              border: OutlineInputBorder(),
              hintStyle: TextStyle(
                color: Color(0xFFC1C6C9),
                fontSize: ScreenUtil.getInstance().getSp(12),
              ),
              contentPadding: EdgeInsets.all(0),
              hintText: S.of(context).input_num_hint,
              counterText: "",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xA6DEDEDE),
                    width: ScreenUtil.getInstance().getWidthPx(1)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xFF48515B),
                    width: ScreenUtil.getInstance().getWidthPx(1)),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size10,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      "CELO",
                      style: TextStyle(
                          color: Color(0XFF363F4D),
                          fontSize: ScreenUtil.getInstance().getSp(11)),
                    ),
                  ),
                  SizedBox(
                    width: size10,
                  ),
                  SizedBox(
                      width: ScreenUtil.getInstance().getWidth(58),
                      height: size20,
                      child: FlatButton(
                        disabledTextColor: Color(0XFFFFFFFF),
                        disabledColor: Color(0XFFA6A6A6),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        //画圆角
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        onPressed: () {
                          _numController.text =
                              "${Tools.formattingNumCommaEight(widget.coinNum ?? 0)}";
                          // _numController.text = "${widget.coinNum}";
                          _numController.selection = TextSelection.fromPosition(
                            ///用来设置文本的位置
                            TextPosition(
                                affinity: TextAffinity.downstream,

                                /// 光标向后移动的长度
                                offset: _numController?.text?.length ?? 0),
                          );
                        },
                        child: Text(
                          S.of(context).all,
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().getSp(11),
                              height: 1),
                        ),
                        color: Color(0XFFECECEC),
                        textColor: Color(0XFF363F4D),
                        highlightColor: Colors.grey.withAlpha(80),
                      )),
                ],
              )),
        ),
        BtnBgSolid(
          alignment: Alignment.center,
          btnStatus: true,
          btnString: widget.btnName ?? "",
          btnCallback: () {
            try {
              num number = double.parse(_numController.text.toString());
              if (number > 0) {
                if (number < 0.00000001) {
                  Tools.showToast(
                      context, S.of(context).minimum_input_num_hint);
                } else {
                  if (number > widget.coinNum) {
                    Tools.showToast(context, S.of(context).input_num_err_hint);
                  } else {
                    btnOk();
                  }
                }
              }
            } catch (e) {}
          },
          paddingTop: 20,
          paddingBottom: 1,
        ),
      ],
    );
  }

  btnOk() {
    FocusScope.of(context).requestFocus(_numFocusNode);
    if (widget.isValora == 1) {
      _sendAction();
    } else
      PinPawDialog(
              context: context,
              onOk: (paw) async {
                // print("===密码====$paw");
                _sendAction(paw: paw);
                // DetailsEnum detailsEnum;
                // if (S.of(context).lock_e == widget.btnName) {
                //   /// 锁定
                // } else if (S.of(context).unlock == widget.btnName) {
                //   /// 解锁
                // } else if (S.of(context).revoke == widget.btnName) {
                //   /// 撤票
                // } else if (S.of(context).vote == widget.btnName) {
                //   /// 投票
                //
                // } else if (S.of(context).withdraw == widget.btnName) {
                //   /// 取回
                // }
              },
              payPawBehavior:
                  SpUtil.getBool(SpUtilConstant.IS_PASSWORD, defValue: false)
                      ? PinPawBehavior.use
                      : PinPawBehavior.open)
          .show();
  }

  /// 发起
  _sendAction({String paw}) {
    num allNum = num.parse(_numController.text.toString());
    if (S.of(context).revoke == widget.btnName) {
      /// 撤票
      if (allNum > widget.pending && allNum > widget.active) {
        if (widget.pending > widget.active) {
          Tools.showToast(
              context, S.of(context).withdraw_money_err_one(widget.pending));
        } else {
          Tools.showToast(
              context, S.of(context).withdraw_money_err_two(widget.active));
        }
      } else {
        if (allNum <= widget.pending) {
          _sendRadio(
              paw: paw,
              tip: "pending",
              count: allNum,
              isGo: true,
              detailsEnum: DetailsEnum.vote);
        } else if (allNum <= widget.active) {
          _sendRadio(
              paw: paw,
              tip: "active",
              count: allNum,
              isGo: true,
              detailsEnum: DetailsEnum.vote);
        }
      }
      // if (widget.isValora == 1) {
      //
      // } else {
      //   if (allNum <= widget.pending) {
      //     _sendRadio(
      //         paw: paw,
      //         tip: "pending",
      //         count: allNum,
      //         isGo: true,
      //         detailsEnum: DetailsEnum.activateOrRecap);
      //   } else {
      //     _sendRadio(
      //         paw: paw,
      //         tip: "pending",
      //         count: widget.pending,
      //         detailsEnum: DetailsEnum.activateOrRecap);
      //     _sendRadio(
      //         paw: paw,
      //         tip: "active",
      //         count: allNum - widget.pending,
      //         detailsEnum: DetailsEnum.activateOrRecap);
      //     Navigator.of(context).pop();
      //     widget.exitDialog?.call();
      //     int timeM = Tools.currentTimeMillis();
      //     var strtime = DateTime.fromMillisecondsSinceEpoch(timeM);
      //     RouteTools.startActivity(context, RouteTools.SEND_RECORD_DETAILS,
      //         address: widget.address,
      //         recordEntity: RecordEntity(
      //             rollOutAddress: widget.address,
      //             count: allNum,
      //             coinName: "CELO",
      //             type: widget.type,
      //             time: strtime.toLocal().toString().split(".")[0] ?? "",
      //             timeStamp: timeM.toString(),
      //             state: 0),
      //         detailsEnum: DetailsEnum.activateOrRecap);
      //   }
      // }
    } else {
      _sendRadio(paw: paw, tip: "", count: allNum, isGo: true);
    }
  }

  /// 发送广播
  _sendRadio(
      {num count,
      String tip,
      String paw,
      DetailsEnum detailsEnum = DetailsEnum.vote,
      bool isGo = false}) {
    int timeM = Tools.currentTimeMillis();
    var strtime = DateTime.fromMillisecondsSinceEpoch(timeM);
    RecordEntity recordEntity = RecordEntity(
        rollOutAddress: widget.address,
        count: count,
        coinName: "CELO",
        type: widget.type,
        tag: "vote",
        time: strtime.toLocal().toString().split(".")[0] ?? "",
        timeStamp: timeM.toString(),
        state: 0);
    Tools.voteList.add(recordEntity);
    EventBusTools.getEventBus()?.fire(SendHomeEntity(
        name: "voteData",
        count: count,
        coinName: "CELO",
        address: widget.address,
        tip: tip,
        isValora: widget.isValora,
        voteEntity: widget.voteEntity,
        toAddress: widget.toAddress,
        pending: widget.pending ?? 0,
        active: widget.active ?? 0,
        type: widget.type,
        apiUrl: SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY),
        privateKey: widget.walletJson,
        paw: paw,
        timeM: timeM.toString()));
    if (isGo) {
      Navigator.of(context).pop();
      widget.exitDialog?.call();
      if (widget.isValora == 0) {
        RouteTools.startActivity(context, RouteTools.SEND_RECORD_DETAILS,
            address: widget.address,
            recordEntity: recordEntity,
            detailsEnum: detailsEnum);
      }
    }
  }
}
