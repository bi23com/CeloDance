/*
 * @Descripttion: 刷新头部动画
 * @Author: 张洪涛
 * @Date: 2020-05-27 15:39:37
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RefreshHeadAnimation extends StatefulWidget {
  RefreshHeadAnimation({Key key, this.startAnimation = false})
      : super(key: key);

  final bool startAnimation;
  @override
  RefreshHeadAnimationState createState() {
    return RefreshHeadAnimationState();
  }
}

class RefreshHeadAnimationState extends State<RefreshHeadAnimation>
    with SingleTickerProviderStateMixin {
  Animation<double> whiteAnimation;
  AnimationController controller;

  double _distance = 50;

  /* 
   * 设置距离
   */
  setDistance(double distance) {
    if (distance < 50 && distance > 30) {
      setState(() {
        _distance = 50 - distance + 30;
      });
    }
  }

  @override
  initState() {
    super.initState();
    if (widget.startAnimation) {
      controller = AnimationController(
          duration: const Duration(milliseconds: 500), vsync: this);
      whiteAnimation = Tween(begin: 30.0, end: 70.0).animate(controller)
        ..addListener(() {
          setState(() {
            _distance = whiteAnimation.value;
            // the state that has changed here is the animation object’s value
          });
        });
      controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 110,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: _distance,
            width: 10,
            height: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0XFF62E19F), // 底色
                shape: BoxShape.circle, // 默认值也是矩形
              ),
              width: 10,
              height: 10,
            ),
          ),
          Positioned(
            right: _distance,
            width: 10,
            height: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0XFFD1FFE7), // 底色
                shape: BoxShape.circle, // 默认值也是矩形
              ),
              width: 10,
              height: 10,
            ),
          )
        ],
      ),
    );
  }

  @override
  dispose() {
    if (controller != null) {
      controller.stop();
      controller.dispose();
    }
    super.dispose();
  }
}
