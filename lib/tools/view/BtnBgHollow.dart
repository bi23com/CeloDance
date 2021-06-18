/*
 * @Description: 背景镂空的按钮
 * @Author: 张洪涛
 * @Date: 2020-05-11 20:51:27
 */
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe:
/// Date: 4/13/21 4:12 PM
/// Path: lib/view/BtnBgHollow.dart
class BtnBgHollow extends StatefulWidget {
  BtnBgHollow(
    this.name,
    this.callback, {
    Key key,
    this.textColor = const Color(0xFF353535),
    this.bgColor = const Color(0xFF353535),
    this.btnStatus = true,
  }) : super(key: key);

  final String name;
  final Function callback; //btn 的 回调方法
  final Color textColor;
  final Color bgColor;
  final bool btnStatus; //btn 状态
  @override
  BtnBgHollowState createState() {
    return BtnBgHollowState();
  }
}

class BtnBgHollowState extends State<BtnBgHollow> {
  String _name;

  //更新文字值
  setName(String name) {
    setState(() {
      _name = name;
    });
  }

  bool _status;

  /*
   * 设置当前 按钮的状态
   */
  setBtnStatus(bool btnStatus) {
    if (btnStatus != _status) {
      setState(() {
        _status = btnStatus;
      });
    }
  }

  @override
  void initState() {
    _name = widget.name;
    _status = widget.btnStatus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      //画圆角
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(ScreenUtil.getInstance().getWidthPx(43)),
      ),
      borderSide: BorderSide(
          color: widget.bgColor,
          width: ScreenUtil.getInstance().getWidthPx(1),
          style: BorderStyle.solid),
      onPressed: _status ? () => {widget?.callback?.call()} : null,
      child: Text(_name,
          style: TextStyle(fontSize: ScreenUtil.getInstance().getSp(14))),
      textColor: widget.textColor,
      highlightedBorderColor: Color(0XFFA2A2A2),
      highlightColor: Colors.black12,
    );
  }
}
