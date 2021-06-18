/*
 * @Descripttion: 
 * @Author: 张洪涛
 * @Date: 2020-05-23 15:48:34
 */
import 'package:flutter/material.dart';

class DialogRouter extends PageRouteBuilder {
  final Widget page;

  DialogRouter(this.page)
      : super(
          opaque: false,
          barrierColor: Color(0x00000001),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        );
}
