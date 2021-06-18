import 'package:dpos/generated/l10n.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

import '../Tools.dart';

/// Describe:  自定义弹窗
/// Date: 3/22/21 10:48 AM
/// Path: tools/dialog/TextDialog.dart
class TextDialogBoard {
  final BuildContext context;

  final String title;
  final String confirm;
  final Widget content;
  final Function okClick;
  final Function noClick;

  TextDialogBoard({
    @required this.context,
    @required this.title,
    this.confirm,
    this.content,
    this.okClick,
    this.noClick,
  });

  Future<bool> show() async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return TextDialog(
          title: title,
          confirm: confirm,
          content: content,
          okClick: okClick,
          noClick: noClick,
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

class TextDialog extends StatefulWidget {
  TextDialog(
      {this.title = "", this.content, this.okClick, this.noClick, this.confirm})
      : super();

  final String title;
  final String confirm;
  final Widget content;
  final Function okClick;
  final Function noClick;

  @override
  _TextDialogState createState() => _TextDialogState();
}

class _TextDialogState extends State<TextDialog> {
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
                child: Center(
                    child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: ScreenUtil.getInstance().getWidth(240),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: ScreenUtil.getInstance().getWidthPx(35),
                              bottom: ScreenUtil.getInstance().getWidthPx(35)),
                          child: Text(
                            widget.title ?? S.of(context).hint,
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().getSp(14),
                                color: Color(0XFF353535),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: ScreenUtil.getInstance().getWidthPx(41),
                              left: ScreenUtil.getInstance().getWidthPx(26),
                              right: ScreenUtil.getInstance().getWidthPx(26)),
                          child: widget.content,
                        ),
                        Divider(
                          height: ScreenUtil.getInstance().getWidthPx(1),
                          color: Color(0XFFDEDEDE),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: FlatButton(
                              disabledColor: Color(0XFFA6A6A6),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              //画圆角
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5)),
                              ),
                              onPressed: () => {
                                Navigator.pop(context),
                                widget.okClick?.call()
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: ScreenUtil.getInstance()
                                        .getWidthPx(35)),
                                child: Text(
                                  Tools.isNull(widget.confirm)
                                      ? S.of(context).confirm
                                      : widget.confirm,
                                  style: TextStyle(
                                      color: Color(0XFF353535),
                                      fontSize:
                                          ScreenUtil.getInstance().getSp(14)),
                                ),
                              ),
                              color: Colors.white,
                              highlightColor: Color(0XFFFAFAFA),
                            )),
                            Container(
                              height: ScreenUtil.getInstance().getWidthPx(100),
                              child: VerticalDivider(
                                color: Color(0XFFDEDEDE),
                                width: ScreenUtil.getInstance().getWidthPx(3),
                              ),
                            ),
                            Expanded(
                                child: FlatButton(
                              disabledColor: Color(0XFFA6A6A6),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              //画圆角
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(5))),
                              onPressed: () => {
                                Navigator.pop(context),
                                widget?.noClick?.call()
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: ScreenUtil.getInstance()
                                        .getWidthPx(35)),
                                child: Text(
                                  S.of(context).cancel,
                                  style: TextStyle(
                                      color: Color(0XFFA6A6A6),
                                      fontSize:
                                          ScreenUtil.getInstance().getSp(14)),
                                ),
                              ),
                              color: Colors.white,
                              highlightColor: Color(0XFFFAFAFA),
                            )),
                          ],
                        )
                      ],
                    ),
                  ),
                )),
              ))),
      onWillPop: () {
        Navigator.pop(context);
        widget?.noClick?.call();
        return Future.value(false);
      },
    );
  }
}
