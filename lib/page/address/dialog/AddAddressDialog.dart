import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

/// Describe: 添加地址 选择弹窗
/// Date: 3/24/21 8:30 PM
/// Path: page/address/dialog/AddAddressDialog.dart
class AddAddressDialog {
  final BuildContext context;
  final Function onItemClick;

  AddAddressDialog({@required this.context, this.onItemClick});

  Future<void> show() async {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _item(S.of(context).observe_address_add, "cd_add_observe_icon",
                  angle: 10),
              Container(
                height: 0.5,
                color: Color(0XFFEFEFEF),
              ),
              _item(S.of(context).import_wallet, "cd_add_impot_icon"),
              Container(
                height: 0.5,
                color: Color(0XFFEFEFEF),
              ),
              _item(S.of(context).address_create, "cd_add_crean_icon"),
              Container(
                height: 0.5,
                color: Color(0XFFEFEFEF),
              ),
              Visibility(
                  visible: Tools.isHint,
                  child: _item(S.of(context).valora_authorization,
                      "cd_add_valora_icon")),
              Container(
                height: MediaQuery.of(context).padding.bottom,
                color: Colors.white,
              ),
            ],
          );
        });
  }

  Widget _item(String name, String imgUrl, {double angle = 0}) {
    return FlatButton(
      disabledTextColor: Color(0XFFFFFFFF),
      disabledColor: Color(0XFFA6A6A6),
      padding: EdgeInsets.zero,
      height: ScreenUtil.getInstance().getWidth(60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(angle), topRight: Radius.circular(angle)),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        onItemClick?.call(name);
      },
      child: Container(
        height: ScreenUtil.getInstance().getWidth(60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/img/$imgUrl.png",
              width: ScreenUtil.getInstance().getWidth(15),
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              name,
              style: TextStyle(
                  color: Color(0XFFA1A1A1),
                  fontWeight: FontWeight.w400,
                  fontSize: ScreenUtil.getInstance().getSp(14)),
            ),
          ],
        ),
      ),
      color: Colors.white,
      highlightColor: Color(0XFFF7FDFA).withAlpha(70),
    );
  }
}

class AddAddress extends StatefulWidget {
  AddAddress({Key key, this.onItemClick}) : super(key: key);
  final Function onItemClick;

  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
        },
        child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _item(S.of(context).observe_address,
                                "cd_add_observe_icon",
                                angle: 10),
                            Container(
                              height: 0.5,
                              color: Color(0XFFEFEFEF),
                            ),
                            _item(S.of(context).import_wallet,
                                "cd_add_impot_icon"),
                            Container(
                              height: 0.5,
                              color: Color(0XFFEFEFEF),
                            ),
                            _item(S.of(context).address_create,
                                "cd_add_crean_icon"),
                            Container(
                              height: 0.5,
                              color: Color(0XFFEFEFEF),
                            ),
                            _item(S.of(context).valora_authorization,
                                "cd_add_valora_icon"),
                          ],
                        ),
                      ))
                ],
              ),
            )),
      ),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
    );
  }

  Widget _item(String name, String imgUrl, {double angle = 0}) {
    return FlatButton(
      disabledTextColor: Color(0XFFFFFFFF),
      disabledColor: Color(0XFFA6A6A6),
      padding: EdgeInsets.zero,
      height: ScreenUtil.getInstance().getWidth(60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(angle), topRight: Radius.circular(angle)),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        widget.onItemClick?.call(name);
      },
      child: Container(
        height: ScreenUtil.getInstance().getWidth(60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/img/$imgUrl.png",
              width: ScreenUtil.getInstance().getWidth(15),
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              width: 14,
            ),
            Text(
              name,
              style: TextStyle(
                  color: Color(0XFFA1A1A1),
                  fontWeight: FontWeight.w400,
                  fontSize: ScreenUtil.getInstance().getSp(14)),
            ),
          ],
        ),
      ),
      color: Colors.white,
      highlightColor: Color(0XFFF7FDFA).withAlpha(70),
    );
  }
}
