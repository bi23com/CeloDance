import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

class AssetDialog {
  final BuildContext context;
  final Function update;

  AssetDialog({@required this.context, this.update});

  Future<void> show() async {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _item(
                "CNY",
                "¥ ",
                angle: 10,
              ),
              _item("USD", "\$ "),
              Container(
                height: MediaQuery.of(context).padding.bottom,
                color: Colors.white,
              )
            ],
          );
        });
  }

  Widget _item(String name, String symbol, {double angle = 0}) {
    double size17 = ScreenUtil.getInstance().getWidth(17);
    bool _isOk =
        (SpUtil.getString(SpUtilConstant.CHOOSE_ASSETS, defValue: "CNY") ==
            name);
    return FlatButton(
      disabledTextColor: Color(0XFFFFFFFF),
      disabledColor: Color(0XFFA6A6A6),
      padding: EdgeInsets.zero,
      height: ScreenUtil.getInstance().getWidth(60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(angle), topRight: Radius.circular(angle)),
      ),
      onPressed: () {
        if (name != SpUtil.getString(SpUtilConstant.CHOOSE_ASSETS)) {
          SpUtil.putString(SpUtilConstant.CHOOSE_ASSETS, name);
          update?.call();
        }
        Navigator.of(context).pop();
      },
      child: Container(
        height: ScreenUtil.getInstance().getWidth(60),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: size17 + size17,
                  ),
                  Expanded(
                      child: Text(
                    symbol + name,
                    style: TextStyle(
                        color: Color(_isOk ? 0xFF48515B : 0XFFC1C6C9),
                        fontSize: ScreenUtil.getInstance().getSp(13)),
                  )),
                  Visibility(
                      visible: _isOk,
                      child: Icon(Icons.check_outlined,
                          color: Color(0xFF34D07F),
                          size: ScreenUtil.getInstance().getWidth(20))),
                  SizedBox(
                    width: size17 + size17,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: size17),
              height: 0.5,
              color: Color(0XA1DEDEDE),
            ),
          ],
        ),
      ),
      color: Color(0XFFFFFFFF),
      highlightColor: Colors.black12,
    );
  }
}

class Asset extends StatefulWidget {
  final Function update;

  Asset({Key key, this.update}) : super(key: key);

  @override
  _AssetState createState() => _AssetState();
}

class _AssetState extends State<Asset> {
  List<String> list = List.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    list.add("CNY");
    list.add("USD");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(context);
          },
          child: Material(
              color: Colors.transparent,
              child: SafeArea(
                  child: Container(
                margin: EdgeInsets.only(
                    top: ScreenUtil.getInstance().screenHeight / 3),
                color: Colors.white,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              S.of(context).language_choice,
                              style: TextStyle(
                                  color: Color(0XFF292929),
                                  fontSize: ScreenUtil.getInstance().getSp(15),
                                  height: 1,
                                  fontWeight: FontWeight.w600),
                            ),
                            Container(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil.getInstance()
                                            .getWidth(18)),
                                    child: Icon(Icons.close,
                                        color: Color(0xFFC6CBCE),
                                        size: ScreenUtil.getInstance()
                                            .getWidthPx(70)),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Container(
                        height: ScreenUtil.getInstance().getWidth(1),
                        color: Color(0XFFf6f6f6),
                      ),
                      Expanded(
                          child: ScrollConfiguration(
                              behavior: NoScrollBehavior(),
                              child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  return _item(list[index]);
                                },
                              )))
                    ],
                  ),
                ),
              )))),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
    );
  }

  Widget _item(String name) {
    double size17 = ScreenUtil.getInstance().getWidth(17);
    bool _isOk =
        (SpUtil.getString(SpUtilConstant.CHOOSE_ASSETS, defValue: "CNY") ==
            name);
    return FlatButton(
      disabledTextColor: Color(0XFFFFFFFF),
      disabledColor: Color(0XFFA6A6A6),
      padding: EdgeInsets.zero,
      height: 50,
      onPressed: () {
        if (name != SpUtil.getString(SpUtilConstant.CHOOSE_ASSETS)) {
          SpUtil.putString(SpUtilConstant.CHOOSE_ASSETS, name);
          widget.update?.call();
        }
        Navigator.of(context).pop();
      },
      child: Container(
        height: 50,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: size17 + size17,
                  ),
                  Expanded(
                      child: Text(
                    name,
                    style: TextStyle(
                        color: Color(_isOk ? 0xFF48515B : 0XFFC1C6C9),
                        fontSize: ScreenUtil.getInstance().getSp(13)),
                  )),
                  Visibility(
                      visible: _isOk,
                      child: Icon(Icons.check_outlined,
                          color: Color(0xFF34D07F),
                          size: ScreenUtil.getInstance().getWidth(20))),
                  SizedBox(
                    width: size17 + size17,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: size17),
              height: 0.5,
              color: Color(0XA1DEDEDE),
            ),
          ],
        ),
      ),
      color: Color(0XFFFFFFFF),
      highlightColor: Colors.black12,
    );
  }
}
