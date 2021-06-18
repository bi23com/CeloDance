import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 引导页 1
/// Date: 3/22/21 11:54 AM
/// Path: page/guide/view/One.dart
class One extends StatefulWidget {
  One({Key key, this.position, this.map}) : super(key: key);

  final int position;
  final Map map;

  @override
  _OneState createState() => _OneState();
}

class _OneState extends State<One> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: Image.asset(
            "assets/img/${widget.map["imgName"]}.png",
            height: 189,
            fit: BoxFit.fitHeight,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 110,
            ),
            Text(
              S.of(context).app_name,
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().getSp(30),
                  color: Color(0xff34D07F),
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.map["name"] ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(14),
                    wordSpacing: 2,
                    color: Color(0xff818181)),
              ),
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              width: 80,
              height: 5,
              margin: EdgeInsets.only(bottom: 50),
              decoration: BoxDecoration(
                color: Color(0X96F0F0F0),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: widget.position == 0
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 40,
                      minWidth: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0X9634D07F),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ],
              )),
        ),
        Visibility(
          visible: widget.position == 1,
          child: BtnBgSolid(
            alignment: Alignment.bottomCenter,
            btnStatus: true,
            btnString: S.of(context).immediately_experience,
            btnCallback: () {
              SpUtil.putBool(SpUtilConstant.FIRST_OPEN_APP, false);
              RouteTools.startActivity(
                context,
                RouteTools.HOME,
              );
            },
            paddingTop: 30,
            paddingBottom: 80,
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
