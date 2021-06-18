/*
 * @Descripttion: 限制字体大小
 * @Author: 张洪涛
 * @Date: 2020-05-07 15:41:49
 */
import 'dart:math';

import 'package:flutter/widgets.dart';

/// Describe: 防止字体大小跟随系统
/// Date: 3/22/21 10:09 AM
/// Path: tools/MaxScaleTextWidget.dart
class MaxScaleTextWidget extends StatelessWidget {
  final double max;
  final Widget child;

  const MaxScaleTextWidget({
    Key key,
    this.max = 1.2,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.of(context);
    var scale = min(max, data.textScaleFactor);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}
