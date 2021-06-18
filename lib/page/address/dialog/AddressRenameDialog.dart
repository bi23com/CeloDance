import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 地址改名
/// Date: 3/29/21 9:47 AM
/// Path: page/address/dialog/AddressRenameDialog.dart
class AddressRenameDialog {
  final BuildContext context;
  final Function onClick;

  /// 设置规则
  final String rules;

  /// url 集合
  final List<String> list;

  AddressRenameDialog(
      {@required this.context, this.onClick, this.rules = "", this.list});

  Future<bool> show() async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AddressRename(onClick: onClick, rules: rules, list: list);
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
          SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class AddressRename extends StatefulWidget {
  AddressRename({Key key, this.onClick, this.rules, this.list})
      : super(key: key);
  final Function onClick;
  final List<String> list;

  /// 设置规则
  final String rules;

  @override
  _AddressRenameState createState() => _AddressRenameState();
}

class _AddressRenameState extends State<AddressRename> {
  TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller?.dispose();
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
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 50,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                                maxLength: 100,
                                maxLines: 1,
                                autofocus: true,
                                onTap: () {},
                                style: TextStyle(
                                  color: Color(0xFF48515B),
                                  fontSize: ScreenUtil.getInstance().getSp(16),
                                ),
                                controller: _controller,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  suffixIcon: SizedBox(
                                      width: 100,
                                      height: 50,
                                      child: FlatButton(
                                        disabledTextColor: Color(0XFFFFFFFF),
                                        disabledColor: Color(0XFFA6A6A6),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        //画圆角
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        onPressed: () {
                                          _ok();
                                        },
                                        child: Icon(
                                          Icons.done,
                                          color: Colors.white,
                                        ),
                                        color: Color(0XFF34D07F),
                                        highlightColor:
                                            Color(0XFF34D07F).withAlpha(80),
                                      )),

                                  //  errorText: "error",
                                  //  errorMaxLines: 1,
                                  //  errorStyle: TextStyle(color: Colors.red),
                                  //  errorBorder: UnderlineInputBorder(),
                                  counterText: "",
                                  hintText: "",
                                  hintMaxLines: 1,
                                  hintStyle: TextStyle(color: Colors.black38),
                                  prefixText:
                                      widget.rules != "url" ? "" : "https://",
                                  prefixStyle: TextStyle(
                                    color: Color(0xFF48515B),
                                    fontSize:
                                        ScreenUtil.getInstance().getSp(16),
                                  ),
                                )))
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
    );
  }

  _ok() async {
    if (!Tools.isNull(_controller.text.toString())) {
      if (Tools.isNull(widget.rules)) {
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.of(context).pop();
        widget.onClick?.call(_controller.text.toString());
      } else if (widget.rules == "url") {
        if (widget.list.contains("https://${_controller.text}")) {
          Tools.showToast(context, S.of(context).http_are_err);
        } else {
          String url = "https://${_controller.text.toString()}";
          Respond respond = await checkUrl(url: url);
          if (respond.code == 0) {
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.of(context).pop();
            widget.onClick?.call(url);
          } else {
            Tools.showToast(context, S.of(context).http_err);
          }
        }
      }
    }
  }
}
