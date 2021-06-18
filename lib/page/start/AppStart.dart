import 'dart:async';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe:  启动页面
/// Date: 3/22/21 10:22 AM
/// Path: page/start/AppStart.dart
class AppStart extends StatefulWidget {
  @override
  _AppStartState createState() => _AppStartState();
}

class _AppStartState extends State<AppStart>
    with SingleTickerProviderStateMixin {
  // Animation<double> _animation;
  // AnimationController _controller;

// 倒计时的计时器。
  Timer _timer;

// 启动倒计时的计时器。
  void _startTimer() {
// 计时器（`Timer`）组件的定期（`periodic`）构造函数，创建一个新的重复计时器。
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      _timer?.cancel();
      _timer = null;
      // RouteTools.startActivity(
      //   context,
      //   SpUtil.getBool(SpUtilConstant.FIRST_OPEN_APP, defValue: true)
      //       ? RouteTools.GUIDE_PAGE
      //       : RouteTools.HOME,
      // );
      RouteTools.startActivity(
        context,
        RouteTools.HOME,
      );
    });
  }

  Future<bool> _requestPop() {
    return Future.value(false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  @override
  dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: BaseTitle(
            isShowAppBar: false,
            backgroundColor: Colors.white,
            body: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  "assets/img/cd_start_icon.png",
                  width: ScreenUtil.getInstance().getWidth(139),
                  fit: BoxFit.fitWidth,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    "assets/img/cd_start_top_icon.png",
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "assets/img/cd_start_bottom_icon.png",
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      S.of(context).start_hint,
                      style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(12),
                        color: Color(0XFFBABABA),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      "${S.of(context).start_donors_hint}",
                      style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(11),
                        color: Color(0XFFBABABA),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().getHeight(20),
                    ),
                  ],
                )
              ],
            )),
        onWillPop: _requestPop);
  }
}
