import 'package:dpos/tools/Tools.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 公共title
/// Date: 3/22/21 10:41 AM
/// Path: base/BaseTitle.dart
class BaseTitle extends StatefulWidget {
  BaseTitle(
      {Key key,
      this.title = "",
      this.titleWidget,
      this.appBar,
      this.goBackCallback,
      this.backgroundColor = Colors.white,
      this.appBarBackgroundColor = Colors.white,
      this.centerTitle = true,
      this.isShowAppBar = true,
      this.resizeToAvoidBottomInset = false,
      this.body,
      this.bottomNavigationBar,
      this.brightness = Brightness.light,
      this.rightLeading,
      this.elevation = 0,
      this.appBarTop = 0,
      this.leading,
      this.leftDrawer})
      : super(key: key);

  // 标题内容
  final String title;

  // 自定义title 布局
  final Widget titleWidget;

  // 返回右侧按钮自定义
  final List<Widget> rightLeading;

  //返回按钮
  final Widget leading;

  // 返回appBar自定义
  final Widget appBar;

  // 标题是否居中
  final bool centerTitle;
  final bool resizeToAvoidBottomInset;

  // 子布局
  final Widget body;

  // 背景颜色
  final Color backgroundColor;

  // 背景颜色
  final Color appBarBackgroundColor;

  // 标题样式
  final Brightness brightness;

  // 自定义返回方法
  final GoBackCallback goBackCallback;

  // 不显示appBar  用户顶部距离
  final double appBarTop;
  final Widget leftDrawer;

// 底部分割线
  final double elevation;
  final Widget bottomNavigationBar;
  final bool isShowAppBar;

  @override
  State<StatefulWidget> createState() => BaseTitleState();
}

class BaseTitleState extends State<BaseTitle> {
  List<Widget> _rightLeading;
  String _title = "";

  /// 设置文字title
  setTitleString(String title) {
    setState(() {
      _title = title;
    });
  }

  /// 设置右上角按钮
  setRightBtnList(List<Widget> rightLeading) {
    if (_rightLeading != null)
      _rightLeading.clear();
    else
      _rightLeading = <Widget>[];
    _rightLeading.addAll(rightLeading);
    setState(() {});
  }

  setRightBtnListAndTitle(String title, List<Widget> rightLeading) {
    if (_rightLeading != null)
      _rightLeading.clear();
    else
      _rightLeading = <Widget>[];
    _rightLeading.addAll(rightLeading);
    if (!Tools.isNull(title)) _title = title;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _rightLeading = widget.rightLeading;
    _title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      backgroundColor: widget.backgroundColor,
      appBar: widget.isShowAppBar
          ? (widget.appBar == null
              ? AppBar(
                  backgroundColor: widget.appBarBackgroundColor,
                  elevation: widget.elevation,
                  brightness: widget.brightness,
                  title: widget.titleWidget == null
                      ? Text(
                          _title,
                          style: TextStyle(
                              color: Color(0XFF1A2636),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil.getInstance().getSp(16)),
                        )
                      : widget.titleWidget,
                  centerTitle: widget.centerTitle,
                  leadingWidth: 41,
                  leading: widget.leading == null
                      ? IconButton(
                          alignment: Alignment.center,
                          splashRadius: ScreenUtil.getInstance().getWidth(18),
                          padding: EdgeInsets.all(3),
                          icon: Icon(
                            Icons.arrow_back_ios_sharp,
                            color: Colors.black,
                            size: ScreenUtil.getInstance().getWidth(18),
                          ),
                          onPressed: () {
                            if (widget.goBackCallback == null)
                              Navigator.pop(context);
                            else
                              widget.goBackCallback.call();
                          },
                        )
                      : widget.leading,
                  actions: _rightLeading,
                )
              : widget.appBar)
          : null,
      drawer: widget.leftDrawer,
      body: Padding(
        padding: EdgeInsets.only(top: widget.appBarTop),
        child: widget.body,
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}

typedef void GoBackCallback();
