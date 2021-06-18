import 'dart:async';

import 'package:cool_ui/cool_ui.dart';
import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/page/record/SendRecordDetails.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/dialog/BaseLoadingDialog.dart';
import 'package:dpos/tools/dialog/TextDialog.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'dialog/ChooseAddressDialog.dart';
import 'dialog/CoinTypeDialog.dart';
import 'dialog/PinPawDialog.dart';
import 'entity/SendHomeEntity.dart';

/// Describe: 发送界面
/// Date: 3/27/21 1:51 PM
/// Path: page/address/AddressSend.dart
class AddressSend extends StatefulWidget {
  AddressSend({Key key, this.address}) : super(key: key);
  final String address;

  @override
  _AddressSendState createState() => _AddressSendState();
}

class _AddressSendState extends State<AddressSend> {
  StreamSubscription _ASStreamSubscription;
  BaseLoadingDialog _baseLoadingDialog;

  /// 用于跳转详情页面的数据
  RecordEntity _recordEntity;

  // 更改按钮样式 和 禁用
  GlobalKey<BtnState> btnKey = GlobalKey();

  /// 是否选中 不使用标签
  bool _isNoLabel = false;

  // 获取输入的文字
  TextEditingController _addressController;
  FocusNode _addressFocusNode = FocusNode();
  TextEditingController _numController;
  FocusNode _numFocusNode = FocusNode();
  TextEditingController _tipsController;

  // 币的名称
  String _coinName = "CELO";

  // 币的数量
  num _coinNum = 0;

  /// 货币交易的数量
  num _coinAccountNum = 0;

  // 交易手续费
  num _coinPoundageNum = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addressController = TextEditingController();
    _numController = TextEditingController();
    _tipsController = TextEditingController();
    _tipsController.addListener(() {
      if (!Tools.isNull(_tipsController.text.toString())) {
        if (_isNoLabel) {
          setState(() {
            _isNoLabel = false;
          });
        }
      }
      calculateBtnStatus();
    });
    _addressController.addListener(() {
      calculateBtnStatus();
    });
    _numController.addListener(() {
      calculateBtnStatus();
      //如果输入的第一个和第二个字符都为0，则消除第二个0
      try {
        _coinAccountNum = double.parse(_numController.text.toString());
      } catch (e) {
        print(e);
        _coinAccountNum = 0;
      }
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _addressController?.dispose();
    _numController?.dispose();
    _tipsController?.dispose();
    _addressFocusNode?.dispose();
    _numFocusNode?.dispose();
    _ASStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double size5 = ScreenUtil.getInstance().getWidth(5);
    double size10 = ScreenUtil.getInstance().getWidth(10);
    double size14 = ScreenUtil.getInstance().getWidth(14);
    double size20 = ScreenUtil.getInstance().getWidth(20);
    return KeyboardMediaQuery(//用于键盘弹出的时候页面可以滚动到输入框的位置
        child: Builder(builder: (ctx) {
      return BaseTitle(
        resizeToAvoidBottomInset: true,
        title: S.of(context).send,
        body: ScrollConfiguration(
            behavior: NoScrollBehavior(),
            child: ListView(
              padding: EdgeInsets.only(left: 20, right: 2, top: 40),
              children: [
                Text(
                  S.of(context).collection_address,
                  style: TextStyle(
                      color: Color(0XFF404044),
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil.getInstance().getSp(14)),
                  textAlign: TextAlign.left,
                ),
                TextField(
                  maxLength: 100,
                  focusNode: _addressFocusNode,
                  style: TextStyle(
                    color: Color(0xFF48515B),
                    fontSize: ScreenUtil.getInstance().getSp(16),
                  ),
                  onTap: () {},
                  controller: _addressController,
                  cursorColor: Color(0xFF353535),
                  autocorrect: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      // filled: true,
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(
                        color: Color(0xFFC1C6C9),
                        fontSize: ScreenUtil.getInstance().getSp(12),
                      ),
                      contentPadding: EdgeInsets.all(0),
                      hintText: S.of(context).input_address,
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
                            onTap: () {
                              if (!_addressFocusNode.hasFocus) {
                                _addressFocusNode.canRequestFocus = false;
                                Future.delayed(Duration(milliseconds: 400), () {
                                  _addressFocusNode.canRequestFocus = true;
                                });
                              }
                              ChooseAddressDialog(
                                  context: context,
                                  address: _addressController.text.toString(),
                                  onItemClick: (name) {
                                    _addressController.text = name;
                                    _addressFocusNode.requestFocus();
                                  }).show();
                              // Future.delayed(Duration(milliseconds: 100), () {
                              //   if (mounted)
                              //     FocusScope.of(context)
                              //         .requestFocus(FocusNode());
                              // });
                            },
                            child: Image.asset(
                              "assets/img/cd_send_address_icon.png",
                              width: size20,
                              height: size20,
                            ),
                          ),
                          Container(
                            width: 1,
                            margin: EdgeInsets.symmetric(horizontal: size5),
                            height: size20,
                            color: Color(0XA1DEDEDE),
                          ),
                          InkWell(
                            onTap: () {
                              if (!_addressFocusNode.hasFocus) {
                                _addressFocusNode.canRequestFocus = false;
                                Future.delayed(Duration(milliseconds: 400), () {
                                  _addressFocusNode.canRequestFocus = true;
                                });
                              }
                              Tools.requestCameraPermissions(context,
                                      S.of(context).scan_permissions_hint)
                                  .then((value) {
                                if (value) {
                                  RouteTools.startActivity(
                                      context, RouteTools.QR_CODE,
                                      callbackContent: (data) {
                                    if (!Tools.isNull(data)) {
                                      _addressController.text = data;
                                    }
                                  });
                                }
                              });
                            },
                            child: Image.asset(
                              "assets/img/cd_send_scan_icon.png",
                              width: size20,
                              height: size20,
                            ),
                          ),
                          SizedBox(
                            width: size20,
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  height: size20,
                ),
                Text(
                  S.of(context).collection_num,
                  style: TextStyle(
                      color: Color(0XFF404044),
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil.getInstance().getSp(14)),
                  textAlign: TextAlign.left,
                ),
                TextField(
                  maxLength: 100,
                  controller: _numController,
                  // focusNode: _numFocusNode,
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
                          "${S.of(context).available} ${Tools.formattingNumCommaEight(_coinNum ?? 0)} $_coinName",
                      // "${S.of(context).available} ${Tools.formattingNumComma(_coinNum)} $_coinName",
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
                              onTap: () {
                                if (!_numFocusNode.hasFocus) {
                                  _numFocusNode.canRequestFocus = false;
                                  Future.delayed(Duration(milliseconds: 200),
                                      () {
                                    _numFocusNode.canRequestFocus = true;
                                  });
                                }
                                CoinTypeDialog(
                                    context: context,
                                    isShowCEUR: true,
                                    coinName: _coinName,
                                    onItemClick: (name) {
                                      _queryCoinNum(name);
                                    }).show();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _coinName,
                                    style: TextStyle(
                                        color: Color(0XFF363F4D),
                                        fontSize:
                                            ScreenUtil.getInstance().getSp(11)),
                                  ),
                                  SizedBox(
                                    width: size5,
                                  ),
                                  Image.asset(
                                    "assets/img/cd_send_arrows_down_icon.png",
                                    width: size14,
                                    height: size14,
                                  ),
                                ],
                              )),
                          SizedBox(
                            width: size10,
                          ),
                          SizedBox(
                              width: ScreenUtil.getInstance().getWidth(58),
                              height: size20,
                              child: FlatButton(
                                disabledTextColor: Color(0XFFFFFFFF),
                                disabledColor: Color(0XFFA6A6A6),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                //画圆角
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                onPressed: () {
                                  if (!_numFocusNode.hasFocus) {
                                    _numFocusNode.canRequestFocus = false;
                                    Future.delayed(Duration(milliseconds: 200),
                                        () {
                                      _numFocusNode.canRequestFocus = true;
                                    });
                                  }
                                  _numController.text = Tools.formattingNumCommaEight(_coinNum ?? 0);
                                  _numController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                          affinity: TextAffinity.downstream,
                                          offset: _numController.text
                                              .toString()
                                              .length));
                                },
                                child: Text(
                                  S.of(context).all,
                                  style: TextStyle(
                                      fontSize:
                                          ScreenUtil.getInstance().getSp(11),
                                      height: 1),
                                ),
                                color: Color(0XFFECECEC),
                                textColor: Color(0XFF363F4D),
                                highlightColor: Colors.grey.withAlpha(80),
                              )),
                          SizedBox(
                            width: size20,
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  height: size20 + 8,
                ),
                // Text(
                //   S.of(context).service_charge,
                //   style: TextStyle(
                //       color: Color(0XFFC1C6C9),
                //       fontWeight: FontWeight.w600,
                //       fontSize: ScreenUtil.getInstance().getSp(12)),
                //   textAlign: TextAlign.left,
                // ),
                // TextField(
                //   maxLength: 100,
                //   enabled: false,
                //   style: TextStyle(
                //     color: Color(0xFF48515B),
                //     fontSize: ScreenUtil.getInstance().getSp(14),
                //   ),
                //   cursorColor: Color(0xFF353535),
                //   autocorrect: true,
                //   textAlignVertical: TextAlignVertical.center,
                //   decoration: InputDecoration(
                //       // filled: true,
                //       border: OutlineInputBorder(),
                //       hintStyle: TextStyle(
                //         color: Color(0xFFC1C6C9),
                //         fontSize: ScreenUtil.getInstance().getSp(14),
                //       ),
                //       contentPadding: EdgeInsets.all(0),
                //       hintText: "${Tools.formattingNumComma(_coinPoundageNum)}",
                //       counterText: "",
                //       enabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(
                //             color: Color(0xA6DEDEDE),
                //             width: ScreenUtil.getInstance().getWidthPx(1)),
                //       ),
                //       focusedBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(
                //             color: Color(0xFF48515B),
                //             width: ScreenUtil.getInstance().getWidthPx(1)),
                //       ),
                //       disabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(
                //             color: Color(0xA6DEDEDE),
                //             width: ScreenUtil.getInstance().getWidthPx(1)),
                //       ),
                //       suffixIcon: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           SizedBox(
                //             width: size10,
                //           ),
                //           Text(
                //             _coinName,
                //             style: TextStyle(
                //                 color: Color(0XFF9B9EA2),
                //                 fontSize: ScreenUtil.getInstance().getSp(11)),
                //           ),
                //           SizedBox(
                //             width: size20,
                //           ),
                //         ],
                //       )),
                // ),
                // SizedBox(
                //   height: size20,
                // ),
                Text(
                  S.of(context).label,
                  style: TextStyle(
                      color: Color(0XFF404044),
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil.getInstance().getSp(14)),
                  textAlign: TextAlign.left,
                ),
                TextField(
                  maxLength: 100,
                  controller: _tipsController,
                  style: TextStyle(
                    color: Color(0xFF48515B),
                    fontSize: ScreenUtil.getInstance().getSp(16),
                  ),
                  cursorColor: Color(0xFF353535),
                  autocorrect: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      // filled: true,
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(
                        color: Color(0xFFC1C6C9),
                        fontSize: ScreenUtil.getInstance().getSp(12),
                      ),
                      contentPadding: EdgeInsets.all(0),
                      hintText: S.of(context).input_tag_hint,
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
                      suffixIcon: SizedBox(width: size20)),
                ),
                SizedBox(
                  height: size20,
                ),
                GestureDetector(
                  onTap: () {
                    // if (!_isNoLabel) {
                    //   TextDialogBoard(
                    //       context: context,
                    //       content: Text(
                    //         S.of(context).label_hint,
                    //         textAlign: TextAlign.center,
                    //         style: TextStyle(
                    //             color: Color(0XFF353535),
                    //             fontSize: ScreenUtil.getInstance().getSp(12)),
                    //       ),
                    //       okClick: () async {
                    //         _isNoLabel = true;
                    //         _tipsController?.text = "";
                    //         _closeKeyboard();
                    //         setState(() {});
                    //         calculateBtnStatus();
                    //       }).show();
                    // } else {
                    //
                    // }
                    _isNoLabel = !_isNoLabel;
                    if (_isNoLabel) {
                      _tipsController.text = "";
                      _closeKeyboard();
                    }
                    setState(() {});
                    calculateBtnStatus();
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/img/cd_${_isNoLabel ? "selected" : "uncheck"}_icon.png",
                        width: 17,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(S.of(context).no_label,
                          style: TextStyle(
                              color: Color(0XFFC1C6C9),
                              height: 1,
                              fontSize: ScreenUtil.getInstance().getSp(12)))
                    ],
                  ),
                ),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   children: [
                //     Expanded(
                //         child: Text(
                //       S.of(context).account_num,
                //       style: TextStyle(
                //           color: Color(0XFF32373C),
                //           fontWeight: FontWeight.w600,
                //           height: 1,
                //           fontSize: ScreenUtil.getInstance().getSp(14)),
                //       textAlign: TextAlign.left,
                //     )),
                //     Text(
                //       "${Tools.formattingNumComma(_coinAccountNum - _coinPoundageNum)}",
                //       style: TextStyle(
                //           color: Color(0XFF34D07F),
                //           fontWeight: FontWeight.w600,
                //           height: 1,
                //           fontSize: ScreenUtil.getInstance().getSp(16)),
                //     ),
                //     SizedBox(
                //       width: size5,
                //     ),
                //     Text(
                //       _coinName,
                //       style: TextStyle(
                //           color: Color(0XFF9B9EA2),
                //           height: 1,
                //           fontSize: ScreenUtil.getInstance().getSp(11)),
                //     ),
                //     SizedBox(
                //       width: size20,
                //     ),
                //     SizedBox(
                //       width: size10,
                //     ),
                //   ],
                // ),
                BtnBgSolid(
                  btnStatus: false,
                  btnString: S.of(context).send,
                  key: btnKey,
                  btnCallback: () {
                    _okOne();
                  },
                  paddingTop: 100,
                  paddingBottom: 30,
                ),
              ],
            )),
      );
    }));
  }

  /*
   * 计算按钮的状态
   */
  calculateBtnStatus() {
    btnKey?.currentState?.setBtnStatus(_addressController.text.length > 8 &&
        _numController.text.length > 0 &&
        (!Tools.isNull(_tipsController.text.toString()) || _isNoLabel));
  }

  /// 初始化数据
  _initData() async {
    Tools.keyboardDone = S.of(context).done;
    _baseLoadingDialog = BaseLoadingDialog(context);
    _ASStreamSubscription =
        EventBusTools.getEventBus()?.on<RecordEntity>()?.listen((event) async {
      if ("exitAddressSend" == event.name) {
        if (mounted) Navigator.pop(context);
        // RouteTools.startActivity(context, RouteTools.SEND_RECORD,
        //     address: widget.address);
        RouteTools.startActivity(context, RouteTools.SEND_RECORD_DETAILS,
            address: widget.address,
            recordEntity: _recordEntity,
            detailsEnum: DetailsEnum.deal);
      }
    });
    _queryCoinNum(_coinName);
  }

  /// 查询币的数量
  void _queryCoinNum(String coinName) async {
    List<Map> addressMap = await SqlManager.queryAddressData(widget.address);
    _coinName = coinName;
    if (addressMap.isNotEmpty) {
      User user = User.fromSQLHomeJson(addressMap[0]);
      if (coinName == "CELO") {
        _coinNum = user.celoAvailable;
      } else if (coinName == "cUSD") {
        _coinNum = user.cusd;
      } else if (coinName == "cEUR") {
        _coinNum = user.ceur;
      }
    } else {
      _coinNum = 0;
    }
    setState(() {});
  }

  /// 确定 按钮判断的方法
  _okOne() {
    if ((widget.address?.toLowerCase() ?? "") !=
        (_addressController?.text?.toString()?.toLowerCase() ?? "")) {
      if (_coinAccountNum > 0) {
        if (_coinAccountNum > _coinNum) {
          Tools.showToast(context, S.of(context).input_num_err_hint);
        } else {
          _closeKeyboard();
          _ok();
          // if (!_isNoLabel && Tools.isNull(_tipsController.text.toString())) {
          //   TextDialogBoard(
          //       context: context,
          //       content: Text(
          //         S.of(context).label_hint,
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //             color: Color(0XFF353535),
          //             fontSize: ScreenUtil.getInstance().getSp(12)),
          //       ),
          //       okClick: () async {
          //         _ok();
          //       }).show();
          // } else {
          //   _ok();
          // }
        }
      } else {
        Tools.showToast(context, S.of(context).no_deal_hint);
      }
    } else {
      Tools.showToast(context, S.of(context).address_equality_hint);
    }
  }

  /// 关闭键盘方法
  _closeKeyboard() {
    _addressFocusNode.requestFocus();
    _numFocusNode.requestFocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  _ok() async {
    if (isValidAddress(_addressController.text.toString())) {
      List<Map> list = await SqlManager.queryAddressData(widget.address);
      if (list != null && list.isNotEmpty) {
        String privateKey = list[0]['privateKey'] ?? "";
        int isValora = list[0]['isValora'] ?? 0;
        if (isValora == 1) {
          _baseLoadingDialog?.show(loadText: S.of(context).load_text);
          ContractType tokenType;
          if (_coinName == "CELO") {
            tokenType = ContractType.CELO;
          } else if (_coinName == "cUSD") {
            tokenType = ContractType.cUSD;
          } else if (_coinName == "cEUR") {
            tokenType = ContractType.cEUR;
          }
          if (tokenType != null) {
            int timeM = Tools.currentTimeMillis();
            var strtime = DateTime.fromMillisecondsSinceEpoch(timeM);
            _recordEntity = RecordEntity(
                receiveAddress: _addressController.text.toString(),
                rollOutAddress: widget.address,
                count: _coinAccountNum,
                coinName: _coinName,
                time: strtime.toLocal().toString().split(".")[0] ?? "",
                timeStamp: timeM.toString(),
                state: 0);
            Tools.recordList.add(_recordEntity);
            SendHomeEntity sendHomeEntity = SendHomeEntity(
                count: _coinAccountNum,
                address: widget.address,
                toAddress: _addressController.text.toString(),
                apiUrl: SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY),
                tokenType: tokenType,
                timeM: timeM.toString(),
                tip: _tipsController.text.toString());
            // print("respond==1==");
            Respond respond = await sendTransactionRequestByValora(
                sendHomeEntity.address,
                sendHomeEntity.toAddress,
                sendHomeEntity.count,
                apiUrl: sendHomeEntity.apiUrl,
                wsUrl: sendHomeEntity.apiUrl,
                contractType: sendHomeEntity.tokenType,
                remarks: sendHomeEntity.tip,
                requestId: sendHomeEntity.timeM);
            // print("respond====${respond.code}");
            // print("respond====${respond.msg}");
            // Respond respond = await compute(
            //     sendAddressValora,
            //     );
            if (mounted) {
              _baseLoadingDialog?.hide();
              if (respond.code == -99) {
                Tools.showValoraDialog(context);
              } else if (respond.code != 0) {
                Tools.showToast(context, respond.msg);
              }
            }
          } else {
            Tools.showToast(context, S.of(context).no_coin_trading_err);
          }
        } else if (Tools.isNull(privateKey)) {
          Tools.showToast(context, S.of(context).observe_address_no_trading);
        } else {
          PinPawDialog(
                  context: context,
                  onOk: (paw) async {
                    ContractType tokenType;
                    if (_coinName == "CELO") {
                      tokenType = ContractType.CELO;
                    } else if (_coinName == "cUSD") {
                      tokenType = ContractType.cUSD;
                    } else if (_coinName == "cEUR") {
                      tokenType = ContractType.cEUR;
                    }
                    if (tokenType != null) {
                      //   CeloWallet(map['privateKey'], map['address']),
                      // map['paw'],
                      // map['toAddress'],
                      // map['num'],
                      // tokenType: map['tokenType'],
                      // remarks: map['tip']);
                      int timeM = Tools.currentTimeMillis();
                      var strtime = DateTime.fromMillisecondsSinceEpoch(timeM);
                      _recordEntity = RecordEntity(
                          receiveAddress: _addressController.text.toString(),
                          rollOutAddress: widget.address,
                          count: _coinAccountNum,
                          coinName: _coinName,
                          time:
                              strtime.toLocal().toString().split(".")[0] ?? "",
                          timeStamp: timeM.toString(),
                          state: 0);
                      Tools.recordList.add(_recordEntity);
                      EventBusTools.getEventBus()?.fire(SendHomeEntity(
                          name: "sendData",
                          count: _coinAccountNum,
                          coinName: _coinName,
                          address: widget.address,
                          apiUrl:
                              SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY),
                          privateKey: privateKey,
                          toAddress: _addressController.text.toString(),
                          paw: paw,
                          tokenType: tokenType,
                          tip: _tipsController.text.toString(),
                          timeM: timeM.toString()));
                      Navigator.of(context).pop();
                      // RouteTools.startActivity(context, RouteTools.SEND_RECORD,
                      //     address: widget.address);
                      RouteTools.startActivity(
                          context, RouteTools.SEND_RECORD_DETAILS,
                          address: widget.address,
                          recordEntity: _recordEntity,
                          detailsEnum: DetailsEnum.deal);

                      // Respond respond = await sendTransactionByAbi(
                      //     CeloWallet(privateKey, widget.address),
                      //     paw,
                      //     _addressController.text.toString(),
                      //     _coinAccountNum,
                      //     tokenType: tokenType,
                      //     remarks: _tipsController.text.toString());
                    } else {
                      Tools.showToast(
                          context, S.of(context).no_coin_trading_err);
                    }
                  },
                  payPawBehavior: SpUtil.getBool(SpUtilConstant.IS_PASSWORD,
                          defValue: false)
                      ? PinPawBehavior.use
                      : PinPawBehavior.open)
              .show();
        }
      }
    } else {
      Tools.showToast(context, S.of(context).send_address_err);
    }
  }
}
