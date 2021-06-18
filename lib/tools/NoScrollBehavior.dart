import 'package:flutter/widgets.dart';

/// Describe: 无蓝边 适用于列表页面
/// Date: 2020/12/1 2:52 PM
class NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}
