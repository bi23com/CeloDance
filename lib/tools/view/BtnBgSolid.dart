import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../Tools.dart';

/// Describe: 全黑背景的按钮
/// Date: 3/22/21 8:14 PM
/// Path: lib/view/BtnBgSolid.dart
class BtnBgSolid extends StatefulWidget {
  BtnBgSolid(
      {@required this.btnString,
      this.btnCallback,
      Key key,
      this.paddingTop = 35,
      this.paddingBottom = 0,
      this.fontWeight = FontWeight.w600,
      this.alignment = Alignment.center,
      this.btnTextSize = 14,
      this.btnStatus = true})
      : super(key: key);

  final String btnString; // btn 的文字
  final FontWeight fontWeight; // btn 的文字
  final double btnTextSize; // btn 的文字

  final Function btnCallback; //btn 的 回调方法

  final double paddingTop; //btn 按钮的上间距
  final double paddingBottom; //btn 按钮的下间距

  final bool btnStatus; //btn 状态
  final AlignmentGeometry alignment; //btn 状态
  @override
  BtnState createState() {
    return BtnState();
  }
}

class BtnState extends State<BtnBgSolid> {
  bool _status;
  String _name;

  /*
   * 设置当前 按钮的状态
   */
  setBtnStatus(bool btnStatus, {String name}) {
    if (btnStatus != _status || (!Tools.isNull(name) && name != _name)) {
      if (!Tools.isNull(name)) _name = name;
      setState(() {
        _status = btnStatus;
      });
    }
  }

  @override
  void initState() {
    _status = widget.btnStatus;
    _name = widget.btnString;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.alignment,
      padding: EdgeInsets.only(
          top: ScreenUtil.getInstance().getWidth(widget.paddingTop),
          bottom: ScreenUtil.getInstance().getWidth(widget.paddingBottom == 0
              ? widget.paddingTop
              : widget.paddingBottom)),
      child: SizedBox(
          width: ScreenUtil.getInstance().getWidth(241),
          height: ScreenUtil.getInstance().getWidth(40),
          child: FlatButton(
            disabledTextColor: Color(0XFFFFFFFF),
            disabledColor: Color(0XFFA6A6A6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //画圆角
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(ScreenUtil.getInstance().getWidth(5)),
            ),
            onPressed: _status ? () => {widget?.btnCallback?.call()} : null,
            child: Text(
              _name,
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().getSp(widget.btnTextSize),
                  height: 1,
                  fontWeight: widget.fontWeight),
            ),
            color: Color(0XFF34D07F),
            textColor: Color(0XFFFFFFFF),
            highlightColor: Colors.green.withAlpha(80),
          )),
    );
  }
}
