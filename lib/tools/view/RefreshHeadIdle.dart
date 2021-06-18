import 'package:dpos/generated/l10n.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'RefreshHeadAnimation.dart';

/// Describe: 刷新头部
/// Date: 3/26/21 1:44 PM
/// Path: tools/view/RefreshHeadIdle.dart
class RefreshHeadIdle extends StatefulWidget {
  RefreshHeadIdle({
    Key key,
    this.accomplishTextColor = const Color(0XFF353535),
  }) : super(key: key);
  final Color accomplishTextColor;

  @override
  RefreshHeadIdleState createState() {
    return RefreshHeadIdleState();
  }
}

class RefreshHeadIdleState extends State<RefreshHeadIdle> {
  GlobalKey<RefreshHeadAnimationState> animationKey = GlobalKey();

  Widget idleView;

  @override
  void initState() {
    super.initState();
    idleView = RefreshHeadAnimation(
      key: animationKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomHeader(onOffsetChange: (offset) {
      // LogUtil.v("=======offset==========$offset");
      if (animationKey.currentState != null)
        animationKey.currentState.setDistance(offset);
    }, builder: (BuildContext context, RefreshStatus mode) {
      Widget body;
      if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
        body = idleView;
      } else if (mode == RefreshStatus.completed) {
        DateTime now = new DateTime.now();
        body = Text(
          S.of(context).refresh_completed + "${now.hour}:${now.minute}",
          style: TextStyle(
            color: widget.accomplishTextColor,
            fontSize: ScreenUtil.getInstance().getSp(11.6),
          ),
        );
      } else if (mode == RefreshStatus.refreshing) {
        body = RefreshHeadAnimation(
          startAnimation: true,
        );
      } else if (mode == RefreshStatus.failed) {
        body = Text(
          S.of(context).refresh_failure,
          style: TextStyle(
            color: Color(0XFF353535),
            fontSize: ScreenUtil.getInstance().getSp(11.6),
          ),
        );
      }
      return Container(
        height: 55.0,
        alignment: Alignment.bottomCenter,
        child: body,
      );
    });
  }
}
