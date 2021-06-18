import 'package:flustars/flustars.dart';
import 'package:flutter/widgets.dart';

/// Describe: 箭头切换动画
/// Date: 4/26/21 11:06 AM
/// Path: page/earnings/view/ArrowsSwitch.dart
class ArrowsSwitch extends StatefulWidget {
  ArrowsSwitch({
    Key key,
    this.onTap,
  }) : super(key: key);
  final Function onTap;

  @override
  ArrowsSwitchState createState() => ArrowsSwitchState();
}

class ArrowsSwitchState extends State<ArrowsSwitch>
    with TickerProviderStateMixin {
  bool _isOpenArrows = false;
  Animation _animationLocked;
  AnimationController _controllerLocked;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controllerLocked =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animationLocked = Tween(begin: 0.0, end: 0.50).animate(_controllerLocked);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_controllerLocked.status == AnimationStatus.completed) {
            _controllerLocked.reverse();
            widget.onTap?.call(false);
          } else if (_controllerLocked.status == AnimationStatus.dismissed) {
            _controllerLocked.forward();
            widget.onTap?.call(true);
          }
        },
        child: Padding(
            padding: EdgeInsets.only(left: 13, right: 25),
            child: RotationTransition(
                alignment: Alignment.center,
                turns: _animationLocked,
                child: Image.asset(
                  "assets/img/cd_arrows_down_icon.png",
                  width: ScreenUtil.getInstance().getWidth(11),
                  fit: BoxFit.fitWidth,
                ))));
  }
}
