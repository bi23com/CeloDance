import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

/// Describe: 头部toast
/// Date: 4/8/21 5:20 PM
/// Path: tools/ToastUtils.dart
class ToastUtils {
  static OverlayEntry _overlayEntry; // toast靠它加到屏幕上
  static bool _showing = false; // toast是否正在showing
  static DateTime _startedTime; // 开启一个新toast的当前时间，用于对比是否已经展示了足够时间
  static String _msg; // 提示内容
  static int _showTime; // toast显示时间
  static Color _bgColor; // 背景颜色
  static Color _textColor; // 文本颜色
  static double _textSize; // 文字大小
  static String _toastPosition; // 显示位置
  static double _pdHorizontal; // 左右边距
  static double _pdVertical; // 上下边距
  static void toast(
    BuildContext context, {
    String msg,
    int showTime = 2000,
    Color bgColor = Colors.black,
    Color textColor = Colors.white,
    double textSize = 14.0,
    String position = 'center',
    double pdHorizontal = 20.0,
    double pdVertical = 10.0,
  }) async {
    assert(msg != null);
    _msg = msg;
    _startedTime = DateTime.now();
    _showTime = showTime;
    _bgColor = bgColor;
    _textColor = textColor;
    _textSize = textSize;
    _toastPosition = position;
    _pdHorizontal = pdHorizontal;
    _pdVertical = pdVertical;
    //获取OverlayState
    // OverlayState overlayState = Overlay.of(context);
    _showing = false;
    // if (_overlayEntry == null) {
    _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => Positioned(
              top: _calToastPosition(context),
              child: Container(
                alignment: Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: AnimatedOpacity(
                  opacity: _showing ? 1.0 : 0.0,
                  duration: _showing
                      ? Duration(milliseconds: 400)
                      : Duration(milliseconds: 600),
                  child: AnimatedPadding(
                    // xy坐标 是决定组件再父容器中的位置。 修改坐标即可完成组件平移
                    padding: _showing
                        ? EdgeInsets.only(top: 60)
                        : EdgeInsets.only(top: 0),
                    duration: _showing
                        ? Duration(milliseconds: 400)
                        : Duration(milliseconds: 600),
                    curve: Curves.fastOutSlowIn,
                    child: _buildToastWidget(),
                  ),
                ),
              ),
            ));
    // _overlayEntry = OverlayEntry(
    //     builder: (BuildContext context) => Positioned(
    //         //top值，可以改变这个值来改变toast在屏幕中的位置
    //         top: _calToastPosition(context),
    //         left: ScreenUtil.getInstance().getWidth(20),
    //         right: ScreenUtil.getInstance().getWidth(20),
    //         child: AnimatedPadding(
    //           duration: Duration(seconds: 1),
    //           curve: Curves.fastOutSlowIn,
    //           padding: _showing
    //               ? EdgeInsets.only(top: 60)
    //               : EdgeInsets.only(top: -60),
    //           onEnd: () => print('End'),
    //           child: AnimatedOpacity(
    //               opacity: _showing ? 1.0 : 0.0, //目标透明度
    //               duration: _showing
    //                   ? Duration(milliseconds: 100)
    //                   : Duration(milliseconds: 400),
    //               child: Container(
    //                   alignment: Alignment.center,
    //                   width: MediaQuery.of(context).size.width,
    //                   decoration: BoxDecoration(
    //                     color: _bgColor,
    //                     borderRadius: BorderRadius.all(Radius.circular(5)),
    //                   ),
    //                   child: Padding(
    //                     padding: EdgeInsets.symmetric(horizontal: 40.0),
    //                     child: _buildToastWidget(),
    //                     // child: AnimatedOpacity(
    //                     //   opacity: _showing ? 1.0 : 1.0, //目标透明度
    //                     //   duration: _showing
    //                     //       ? Duration(milliseconds: 100)
    //                     //       : Duration(milliseconds: 400),
    //                     //   child: _buildToastWidget(),
    //                     // ),
    //                   ))),
    //         )));
    //显示到屏幕上
    Overlay.of(context).insert(_overlayEntry);
    //等待(先加载 后平移 一个缓冲)
    await Future.delayed(Duration(milliseconds: 50));
    _showing = true;
    //平移到显示位置
    //重新绘制UI，类似setState
    _overlayEntry.markNeedsBuild();
    //等待
    await Future.delayed(Duration(milliseconds: _showTime));
    //2秒后 到底消失不消失
    if (DateTime.now().difference(_startedTime).inMilliseconds >= _showTime) {
      _showing = false;
      _overlayEntry.markNeedsBuild();
      //等待动画执行
      await Future.delayed(Duration(milliseconds: _showTime));
      if (!_showing) {
        _overlayEntry.remove();
        _overlayEntry = null;
      }
    }
    //   overlayState.insert(_overlayEntry);
    //   //等待(先加载 后平移 一个缓冲)
    //   await Future.delayed(Duration(milliseconds: 50));
    //   _showing = true;
    //   //平移到显示位置
    //   //重新绘制UI，类似setState
    //   _overlayEntry.markNeedsBuild();
    // } else {
    //   //重新绘制UI，类似setState
    //   _overlayEntry.markNeedsBuild();
    // }
    // await Future.delayed(Duration(milliseconds: _showTime)); // 等待时间
    //
    // //2秒后 到底消失不消失
    // if (DateTime.now().difference(_startedTime).inMilliseconds >= _showTime) {
    //   _showing = false;
    //   _overlayEntry.markNeedsBuild();
    //   await Future.delayed(Duration(milliseconds: 400));
    //   _overlayEntry.remove();
    //   _overlayEntry = null;
    // }
  }

  //toast绘制
  static _buildToastWidget() {
    // return Center(
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       SizedBox(
    //         height: 15,
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(
    //             horizontal: _pdHorizontal, vertical: _pdVertical),
    //         child: Text(
    //           _msg,
    //           style: TextStyle(
    //             inherit: false,
    //             fontSize: _textSize,
    //             fontWeight: FontWeight.w600,
    //             color: _textColor,
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 15,
    //       ),
    //     ],
    //   ),
    // );
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil.getInstance().getWidth(30)),
      color: _bgColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          //限制 最大宽度
          maxWidth: double.infinity,
          minWidth: double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
          child: Text(_msg,
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().getSp(14),
                color: _textColor,
              ),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

//  设置toast位置
  static _calToastPosition(context) {
    var backResult;
    if (_toastPosition == 'top') {
      backResult = 0.0;
      // backResult = 60 + MediaQuery.of(context).padding.top;
    } else if (_toastPosition == 'center') {
      backResult = MediaQuery.of(context).size.height * 2 / 5;
    } else {
      backResult = MediaQuery.of(context).size.height * 3 / 4;
    }
    return backResult;
  }
}

class CustomAnimatedPadding extends StatefulWidget {
  @override
  _CustomAnimatedPaddingState createState() => _CustomAnimatedPaddingState();
}

class _CustomAnimatedPaddingState extends State<CustomAnimatedPadding> {
  final EdgeInsets startPadding = EdgeInsets.all(10);
  final EdgeInsets endPadding = EdgeInsets.all(30);

  EdgeInsets _padding;

  @override
  void initState() {
    _padding = startPadding;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Switch(
            value: _padding == endPadding,
            onChanged: (v) {
              setState(() {
                _padding = v ? endPadding : startPadding;
              });
            }),
        Container(
          color: Colors.grey.withAlpha(22),
          width: 200,
          height: 100,
          child: AnimatedPadding(
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            padding: _padding,
            onEnd: () => print('End'),
            child: Container(
              alignment: Alignment.center,
              color: Colors.blue,
              child: Text(
                '张风捷特烈',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Toast {
  // 透明  默认
  static final int ANIMATED_OPACITY = 0;

  // 平移 下上下   （bottom -> top -> bottom）
  static final int ANIMATED_MOVEMENT_BTB = 1;

  // 平移 左中右   （left -> centre -> right）
  static final int ANIMATED_MOVEMENT_LCR = 2;

  //Tween  demo
  static final int ANIMATED_MOVEMENT_TWEEN = 3;

  static final int LENGTH_SHORT = 0;
  static final int LENGTH_LONG = 1;
  static final int SHORT = 2000;
  static final int LONG = 4000;

  // 默认显示时间
  static int _milliseconds = 2000;

  //toast靠它加到屏幕上
  static OverlayEntry _overlayEntry;

  //toast是否正在showing
  static bool _showing = false;

  //开启一个新toast的当前时间，用于对比是否已经展示了足够时间
  static DateTime _startedTime;

  static BuildContext _context;

  // 显示文本内容
  static String _content;
  static TextStyle _style;

  // 字体颜色
  static Color _contentColor = Colors.white;

  // 背景颜色
  static Color _backgroundColor = Colors.black54;

  //上边的 边距
  static double _top = -1;

  // 自定义 显示内容
  static Widget _toastWidget;

  // 动画
  static int _animated = 0;

  // 执行动画时间
  static int _millisecondsShow = 200;
  static int _millisecondsHide = 800;

  static Toast makeText({
    @required BuildContext context,
    String content, //文本内容
    Color contentColor, //字体颜色
    int duration = -1, // 显示时间
    Color backgroundColor, //背景
    double top, // 与上边  边距 距离
    int animated, // 动画， 默认透明/不透明
    Widget child, //自定义的 Toast
  }) {
    if (content == null && child == null) {
      content = '未知...';
    }
    //清除原有的 Toast
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }

    _context = context;
    _content = content;
    if (contentColor != null) {
      _contentColor = contentColor;
    }
    _milliseconds = duration <= LENGTH_SHORT ? SHORT : LONG;
    if (backgroundColor != null) {
      _backgroundColor = backgroundColor;
    }
    if (_top < 0) {
      _top = MediaQuery.of(context).size.height * 2 / 3;
    }
    _animated = animated;

    if (child != null) {
      _toastWidget = child;
    } else {
      _toastWidget = _defaultToastLayout();
    }
    return Toast();
  }

  void show() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _startedTime = DateTime.now();
    _showing = false;

    // 显示 Toast
    if (_animated == ANIMATED_MOVEMENT_TWEEN) {
      _makeTextShowTween();
    } else if (_animated == ANIMATED_MOVEMENT_LCR) {
      _makeTextShowMovementLCR();
    } else if (_animated == ANIMATED_MOVEMENT_BTB) {
      _makeTextShowMovementBTB();
    } else {
      _makeTextShowOpacity();
    }
  }

  //显示 文本 Toast  透明渐变
  static void _makeTextShowOpacity() async {
    _showing = true;

    //创建OverlayEntry
    _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => Positioned(
              //top值，可以改变这个值来改变toast在屏幕中的位置
              top: _top,
              child: Container(
                alignment: Alignment.center, //居中
                width: MediaQuery.of(context).size.width, //Container 宽
                child: AnimatedOpacity(
                  //目标透明度
                  opacity: _showing ? 1.0 : 0.0,
                  //执行时间
                  duration: _showing
                      ? Duration(milliseconds: _millisecondsShow)
                      : Duration(milliseconds: _millisecondsHide),
                  child: _toastWidget,
                ),
              ),
            ));
    //显示到屏幕上
    Overlay.of(_context).insert(_overlayEntry);
    //等待两秒
    await Future.delayed(Duration(milliseconds: _milliseconds));

    //2秒后 到底消失不消失
    if (DateTime.now().difference(_startedTime).inMilliseconds >=
        _milliseconds) {
      _showing = false;
      //重新绘制UI，类似setState
      _overlayEntry.markNeedsBuild();
      //等待动画执行
      await Future.delayed(Duration(milliseconds: _millisecondsHide));
      if (!_showing) {
        _overlayEntry.remove();
        _overlayEntry = null;
      }
    }
  }

  /*
  显示时 初始化在屏幕外（下边） 平移/透明 到显示位置
  隐藏时 平移/透明 到屏幕外（下边）
  */
  // 平移 位置 参数

  //显示 文本 Toast  上下移动
  static void _makeTextShowMovementBTB() async {
    double _x = 0;
    double _y = -1;
    Curve mCurve = MyCurve();

    //创建OverlayEntry
    _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => Positioned(
              top: _top,
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - _top,
                child: AnimatedOpacity(
                  opacity: _showing ? 1.0 : 0.0,
                  duration: _showing
                      ? Duration(milliseconds: _millisecondsShow)
                      : Duration(milliseconds: _millisecondsHide),
                  child: AnimatedAlign(
                    // xy坐标 是决定组件再父容器中的位置。 修改坐标即可完成组件平移
                    alignment: Alignment(_x, _y),
                    duration: _showing
                        ? Duration(milliseconds: _millisecondsShow)
                        : Duration(milliseconds: _millisecondsHide),
                    curve: mCurve,
                    child: _toastWidget,
                  ),
                ),
              ),
            ));
    //显示到屏幕上
    Overlay.of(_context).insert(_overlayEntry);
    //等待(先加载 后平移 一个缓冲)
    await Future.delayed(Duration(milliseconds: 50));
    _showing = true;
    //平移到显示位置
    _x = 0;
    _y = 1;
    //重新绘制UI，类似setState
    _overlayEntry.markNeedsBuild();
    //等待
    await Future.delayed(Duration(milliseconds: _milliseconds));
    //2秒后 到底消失不消失
    if (DateTime.now().difference(_startedTime).inMilliseconds >=
        _milliseconds) {
      _showing = false;
      mCurve = Curves.linear;
      _x = 0;
      _y = -1;
      _overlayEntry.markNeedsBuild();
      //等待动画执行
      await Future.delayed(Duration(milliseconds: _millisecondsHide));
      if (!_showing) {
        _overlayEntry.remove();
        _overlayEntry = null;
      }
    }
  }

  //显示 文本 Toast  左中右移动
  static void _makeTextShowMovementLCR() async {
    double _x = -3.5;
    double _y = -1;
    Curve mCurve = MyCurve();

    //创建OverlayEntry
    _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => Positioned(
              top: _top,
              child: Container(
                // color:Colors.yellow,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - _top + 50,
                child: AnimatedOpacity(
                  opacity: _showing ? 1.0 : 0.0,
                  duration: _showing
                      ? Duration(milliseconds: _millisecondsShow)
                      : Duration(milliseconds: _millisecondsHide),
                  child: AnimatedAlign(
                    // xy坐标 是决定组件再父容器中的位置。 修改坐标即可完成组件平移
                    alignment: Alignment(_x, _y),
                    duration: _showing
                        ? Duration(milliseconds: _millisecondsShow)
                        : Duration(milliseconds: _millisecondsHide),
                    curve: mCurve,
                    child: _toastWidget,
                  ),
                ),
              ),
            ));
    //显示到屏幕上
    Overlay.of(_context).insert(_overlayEntry);
    //等待(先加载 后平移 一个缓冲)
    await Future.delayed(Duration(milliseconds: 50));
    _showing = true;
    //平移到显示位置
    _x = 0;
    _y = -1;
    //重新绘制UI，类似setState
    _overlayEntry.markNeedsBuild();
    //等待
    await Future.delayed(Duration(milliseconds: _milliseconds));
    //2秒后 到底消失不消失
    if (DateTime.now().difference(_startedTime).inMilliseconds >=
        _milliseconds) {
      _showing = false;
      mCurve = Curves.linear;
      _x = 3.5;
      _y = -1;
      _overlayEntry.markNeedsBuild();
      //等待动画执行
      await Future.delayed(Duration(milliseconds: _millisecondsHide));
      if (!_showing) {
        _overlayEntry.remove();
        _overlayEntry = null;
      }
    }
  }

  //显示 文本 Toast  Tween 动画
  static void _makeTextShowTween() async {
    _overlayEntry?.remove();
    _overlayEntry = null;

    var overlayState = Overlay.of(_context);
    //透明显示动画控制器
    AnimationController showAnimationController = new AnimationController(
      vsync: overlayState,
      duration: Duration(milliseconds: 250),
    );
    //平移动画控制器
    AnimationController offsetAnimationController = new AnimationController(
      vsync: overlayState,
      duration: Duration(milliseconds: 350),
    );
    //透明隐藏动画控制器
    AnimationController hideAnimationController = new AnimationController(
      vsync: overlayState,
      duration: Duration(milliseconds: 250),
    );

    //透明显示动画
    Animation<double> opacityShow =
        new Tween(begin: 0.0, end: 1.0).animate(showAnimationController);
    //提供一个曲线，使动画感觉更流畅
    CurvedAnimation ffsetCurvedAnimation = new CurvedAnimation(
        parent: offsetAnimationController, curve: MyCurve());
    //平移动画
    Animation<double> offsetAnim =
        new Tween(begin: 50.0, end: 0.0).animate(ffsetCurvedAnimation);
    //透明隐藏动画
    Animation<double> opacityHide =
        new Tween(begin: 1.0, end: 0.0).animate(hideAnimationController);

    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        //top值，可以改变这个值来改变toast在屏幕中的位置
        top: _top,
        child: Container(
          alignment: Alignment.center, //居中
          width: MediaQuery.of(context).size.width, //Container 宽
          child: AnimatedBuilder(
            animation: opacityShow,
            child: _toastWidget,
            builder: (context, childToBuild) {
              return Opacity(
                opacity: opacityShow.value,
                child: AnimatedBuilder(
                  animation: offsetAnim,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, offsetAnim.value),
                      child: AnimatedBuilder(
                        animation: opacityHide,
                        builder: (context, _) {
                          return Opacity(
                            opacity: opacityHide.value,
                            child: childToBuild,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
    });
    //显示到屏幕上
    overlayState.insert(_overlayEntry);
    //执行显示动画
    showAnimationController.forward();
    offsetAnimationController.forward();
    //等待
    await Future.delayed(Duration(milliseconds: _milliseconds));

    //2秒后 到底消失不消失
    if (DateTime.now().difference(_startedTime).inMilliseconds >=
        _milliseconds) {
      //执行隐藏动画
      hideAnimationController.forward();
      //等待动画执行
      await Future.delayed(Duration(milliseconds: 250));
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  //toast绘制
  static _defaultToastLayout() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        //限制 最大宽度
        maxWidth: MediaQuery.of(_context).size.width / 5 * 4,
      ),
      child: Card(
        color: _backgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Text(_content,
              style: TextStyle(
                fontSize: 14.0,
                color: _contentColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

//自定义 一个曲线  当然 也可以使用SDK提供的 如： Curves.fastOutSlowIn
class MyCurve extends Curve {
  @override
  double transform(double t) {
    t -= 1.0;
    double b = t * t * ((2 + 1) * t + 2) + 1.0;
    return b;
  }
}
