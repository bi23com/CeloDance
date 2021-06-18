import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/dialog/BaseLoadingDialog.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: pin 码设置
/// Date: 3/24/21 11:41 AM
/// Path: page/address/dialog/PinPawDialog.dart

List<String> digital = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

class PinPawDialog {
  final BuildContext context;
  final Function onOk;
  final Function onClose;
  final PinPawBehavior payPawBehavior;

  PinPawDialog(
      {@required this.context,
      this.onOk,
      this.onClose,
      this.payPawBehavior = PinPawBehavior.use});

  Future<void> show() async {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true, //一：设为true，此时为全屏展示
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SizedBox(
            height: ScreenUtil.getInstance().screenHeight * 0.66,
            child: PayPassword(
              onOk: onOk,
              onClose: onClose,
              payPawBehavior: payPawBehavior,
            ),
          );
        });
  }
}

class PayPassword extends StatefulWidget {
  PayPassword({Key key, this.onOk, this.onClose, this.payPawBehavior})
      : super(key: key);

  final Function onOk;
  final Function onClose;
  final PinPawBehavior payPawBehavior;

  @override
  _PayPasswordState createState() => _PayPasswordState();
}

class _PayPasswordState extends State<PayPassword> {
  BaseLoadingDialog _baseLoadingDialog;
  List<String> moneyBtn = [
    "-1",
    "-1",
    "-1",
    "-1",
    "-1",
    "-1",
    "-1",
    "-1",
    "-1",
    "",
    "-1",
    "删除",
  ];

  /// 获取一个私钥字符串 用于解密 验证密码正确不正确
  String privateKey = "";
  String address = "";

  // 输入的密码
  String _password = "";
  String _passwordOne = "";

  String _title = "";
  bool _isPawHint = true;

  @override
  void initState() {
    super.initState();
    digital.shuffle();
    _getAddressList();
    int index = 0;
    for (int i = 0; i < moneyBtn.length; i++) {
      if ("-1" == moneyBtn[i]) {
        moneyBtn[i] = digital[index++];
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (PinPawBehavior.open == widget.payPawBehavior) {
        _title = S.of(context).pin_title_three;
      } else {
        _title = S.of(context).pin_title_one;
      }
      _baseLoadingDialog = BaseLoadingDialog(context);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _baseLoadingDialog = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sizeBox = (ScreenUtil.getInstance().screenWidth - 107) / 6;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          color: Colors.white,
          child: WillPopScope(
              onWillPop: () {
                Navigator.pop(context);
                widget.onClose?.call();
                return Future.value(false);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: ScreenUtil.getInstance().getWidth(55),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(""),
                        ),
                        Text(
                          _title,
                          style: TextStyle(
                              color: Color(0xFF48515B),
                              fontSize: ScreenUtil.getInstance().getSp(14),
                              height: 1,
                              fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onClose?.call();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil.getInstance()
                                          .getWidth(18)),
                                  child: Icon(Icons.close,
                                      color: Color(0xFFC6CBCE),
                                      size: ScreenUtil.getInstance()
                                          .getWidthPx(70)),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 50, right: 50, top: 17),
                    height: sizeBox,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Color(0X80F8F8F8),
                        border: Border.all(color: Color(0X80979797), width: 1),
                        borderRadius: BorderRadius.circular(6)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext cxt, int index) {
                        return Container(
                          alignment: Alignment.center,
                          height: sizeBox,
                          width: sizeBox,
                          child: index < _password.length
                              ? ClipOval(
                                  child: Container(
                                    width: 10,
                                    color: Color(0XFF717171),
                                    height: 10,
                                  ),
                                )
                              : Text(""),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          width: 1,
                          height: sizeBox,
                          color: Color(0X80979797),
                        );
                      },
                      itemCount: 6,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 50),
                    height: ScreenUtil.getInstance().getWidth(30),
                    alignment: Alignment.centerLeft,
                    child: Visibility(
                      visible: !_isPawHint,
                      child: Text(
                        S.of(context).pin_simple_hint,
                        style: TextStyle(
                            color: Color(0XFFf73d3b),
                            fontSize: ScreenUtil.getInstance().getSp(12)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 30),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Color(0XA1DEDEDE),
                  ),
                  Container(
                    color: Color(0XA1DEDEDE),
                    padding: EdgeInsets.only(bottom: 1),
                    child: ScrollConfiguration(
                        behavior: NoScrollBehavior(),
                        child: GridView.count(
                          crossAxisSpacing: 1,
                          padding: EdgeInsets.zero,
                          mainAxisSpacing: 1,
                          crossAxisCount: 3,
                          childAspectRatio: 2.3,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: List.generate(moneyBtn.length, (index) {
                            String data = moneyBtn[index];
                            return FlatButton(
                              padding: EdgeInsets.all(0),
                              color: Colors.white,
                              highlightColor: Color(0XFFF3F2F3),
                              disabledColor: Colors.white,
                              child: data == "删除"
                                  ? Icon(
                                      Icons.backspace,
                                      size: 24,
                                      color: Color(0xff333333),
                                    )
                                  : Text(
                                      data,
                                      style: TextStyle(
                                          color: Color(0XFF1A2636),
                                          fontSize: 20),
                                    ),
                              onPressed: Tools.isNull(data)
                                  ? null
                                  : () {
                                      if ("删除" == data) {
                                        // 删除键
                                        if (!Tools.isNull(_password)) {
                                          int len = _password.length;
                                          if (len > 0) {
                                            _password =
                                                _password.substring(0, len - 1);
                                            setState(() {});
                                          }
                                        }
                                      } else {
                                        // 正常输入键
                                        _inputPayPaw(data);
                                      }
                                    },
                            );
                          }),
                        )),
                  ),
                  Container(
                    height: MediaQuery.of(context).padding.bottom,
                    color: Colors.white,
                  )
                ],
              )),
        )
      ],
    );
  }

  ///获取全部地址
  _getAddressList() async {
    privateKey = SpUtil.getString(SpUtilConstant.PAW_ENCRYPTION_KEY);
    address = SpUtil.getString(SpUtilConstant.PAW_ADDRESS_KEY);
  }

  /// 输入支付密码
  _inputPayPaw(String data) async {
    if (_password.length < 6) {
      _isPawHint = true;
      _password += data;
      if (_password.length == 6) {
        if (widget.payPawBehavior == PinPawBehavior.use) {
          // 0支付
          if (!Tools.isNull(privateKey)) {
            _baseLoadingDialog?.show(loadText: S.of(context).load_text);
            Respond respond = await compute(
                getRespond, CeloWallet(privateKey, address, paw: _password));
            _baseLoadingDialog?.hide();
            // Respond respond =
            //     await checkPwd(CeloWallet(privateKey, address), _password);
            if (respond.code == 0) {
              if (mounted) Navigator.pop(context);
              widget.onOk?.call(_password);
            } else {
              _password = "";
              setState(() {});
              Tools.showToast(context, S.of(context).paw_err_hint);
            }
          } else {
            if (mounted) Navigator.pop(context);
            widget.onOk?.call(_password);
          }
        } else if (widget.payPawBehavior == PinPawBehavior.open) {
          //      忘记密码  开启新密码
          _isPawHint = Tools.isPass(_password);
          if (_isPawHint) {
            _twoInput();
          } else {
            _password = "";
          }
        }
      }
    }
    setState(() {});
  }

  /// 输入两次的判断方法
  _twoInput() {
    if (Tools.isNull(_passwordOne)) {
      _passwordOne = _password;
      _password = "";
      _title = S.of(context).pin_title_two;
    } else {
      if (_password == _passwordOne) {
        if (widget.payPawBehavior == PinPawBehavior.open) {
          SpUtil.putBool(SpUtilConstant.IS_PASSWORD, true);
          if (mounted) Navigator.pop(context);
          widget.onOk?.call(_password);
        }
      } else {
        _password = "";
        _passwordOne = "";
        _title = S.of(context).pin_title_three;
        Tools.showToast(context, S.of(context).pin_error_hint);
      }
    }
  }
}

/// 密码 枚举类
enum PinPawBehavior {
  /// 开启Pin密码
  open,

  /// 使用
  use,
}

Future<Respond> getRespond(CeloWallet celoWallet) async {
  return await checkPwd(
      CeloWallet(celoWallet.walletJson, celoWallet.address), celoWallet.paw);
}
