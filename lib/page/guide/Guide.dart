import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/page/guide/view/One.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 引导页面
/// Date: 3/22/21 11:27 AM
/// Path: page/guide/Guide.dart
class Guide extends StatefulWidget {
  @override
  _GuideState createState() => _GuideState();
}

class _GuideState extends State<Guide> {
  List<Map> list = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    list.clear();
    list.add({
      "name": S.of(context).guide_hint_one,
      "imgName": "cd_guide_one_img",
    });
    list.add({
      "name": S.of(context).guide_hint_two,
      "imgName": "cd_guide_two_img",
    });
    return BaseTitle(
        isShowAppBar: false,
        body: Stack(
          children: [
            ScrollConfiguration(
              behavior: NoScrollBehavior(),
              child: PageView.builder(
                  itemCount: list.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return One(
                      position: index,
                      map: list[index],
                    );
                  }),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: ScreenUtil.getInstance().getWidthPx(
                      ScreenUtil.getInstance().statusBarHeight + 100),
                  right: ScreenUtil.getInstance().getWidth(20)),
              alignment: Alignment.topRight,
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0x29696969), // 底色
                    shape: BoxShape.rectangle, // 默认值也是矩形
                    borderRadius: BorderRadius.circular(100), // 圆角度
                  ),
                  padding: EdgeInsets.only(
                      left: ScreenUtil.getInstance().getWidth(15),
                      top: ScreenUtil.getInstance().getWidth(1),
                      bottom: ScreenUtil.getInstance().getWidth(1),
                      right: ScreenUtil.getInstance().getWidth(15)),
                  child: Text(
                    S.of(context).skip,
                    style: TextStyle(
                        color: Color(0XFF797979),
                        fontWeight: FontWeight.w500,
                        fontSize: ScreenUtil.getInstance().getSp(12)),
                  ),
                ),
                onTap: () {
                  SpUtil.putBool(SpUtilConstant.FIRST_OPEN_APP, false);
                  RouteTools.startActivity(
                    context,
                    RouteTools.HOME,
                  );
                },
              ),
            ),
          ],
        ));
  }
}
