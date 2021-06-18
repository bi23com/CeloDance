import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

/// Describe: 语言切换
/// Date: 4/1/21 9:35 AM
/// Path: page/my/dialog/LanguageDialog.dart
class LanguageDialog {
  final BuildContext context;
  String _lang = "";

  LanguageDialog({@required this.context});

  Future<void> show() async {
    String language =
        SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE, defValue: "zh");
    if (language == "zh") {
      _lang = "简体中文";
    } else if (language == "en") {
      _lang = "English";
    }
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _item("简体中文", angle: 10),
              _item("English"),
              Container(
                height: MediaQuery.of(context).padding.bottom,
                color: Colors.white,
              )
            ],
          );
        });
  }

  Widget _item(String name, {double angle = 0}) {
    double size17 = ScreenUtil.getInstance().getWidth(17);
    bool _isOk = (_lang == name);
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
        String lang = "";
        if ("简体中文" == name) {
          lang = "zh";
        } else if ("English" == name) {
          lang = "en";
        } else {
          lang = "zh";
        }
        if (lang != SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE)) {
          SpUtil.putString(SpUtilConstant.CHOOSE_LANGUAGE, lang);
          localeChange("");
        }
        Navigator.of(context).pop();
      },
      child: Container(
        height: ScreenUtil.getInstance().getWidth(60),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: size17 + size17,
                  ),
                  Expanded(
                      child: Text(
                    name,
                    style: TextStyle(
                        color: Color(_isOk ? 0xFF48515B : 0XFFC1C6C9),
                        fontSize: ScreenUtil.getInstance().getSp(13)),
                  )),
                  Visibility(
                      visible: _isOk,
                      child: Icon(Icons.check_outlined,
                          color: Color(0xFF34D07F),
                          size: ScreenUtil.getInstance().getWidth(20))),
                  SizedBox(
                    width: size17 + size17,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: size17),
              height: 0.5,
              color: Color(0XA1DEDEDE),
            ),
          ],
        ),
      ),
      color: Color(0XFFFFFFFF),
      highlightColor: Colors.black12,
    );
  }
}
