import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

/// Describe: 投票 排序
/// Date: 4/21/21 4:58 PM
/// Path: page/earnings/dialog/SortingDialog.dart
class SortingDialog {
  final BuildContext context;
  final Function sortingClick;

  /// 排序的名字
  String sortingName = "";

  SortingDialog({@required this.context, this.sortingClick, this.sortingName});

  Future<void> show() async {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _item(S.of(context).vote_sort_two, angle: 10),
              _item(S.of(context).vote_sort_one),
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
    bool _isOk = (sortingName == name);
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
        if (!_isOk) {
          if (name == S.of(context).vote_sort_one) {
            sortingClick?.call(true);
          } else {
            sortingClick?.call(false);
          }
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
