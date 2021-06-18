/*
 * @Description: load 动画
 * @Author: 张洪涛
 * @Date: 2020-05-27 15:39:37
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BaseLoadAnimation extends StatefulWidget {
  @override
  BaseLoadAnimationState createState() => BaseLoadAnimationState();
}

class BaseLoadAnimationState extends State<BaseLoadAnimation>
    with SingleTickerProviderStateMixin {
  Animation<double> whiteAnimation;
  AnimationController controller;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    whiteAnimation = Tween(begin: 35.0, end: 55.0).animate(controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 100,
      height: 30,
      constraints: BoxConstraints(
        maxHeight: 30,
        maxWidth: 100,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: whiteAnimation.value,
            width: 10,
            height: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0XFFFFFFFF), // 底色
                shape: BoxShape.circle, // 默认值也是矩形
              ),
              width: 10,
              height: 10,
            ),
          ),
          Positioned(
            right: whiteAnimation.value,
            width: 10,
            height: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0XFF9F9F9F), // 底色
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
    controller.stop();
    controller.dispose();
    super.dispose();
  }
}
