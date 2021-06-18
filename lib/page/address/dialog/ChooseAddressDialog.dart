import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 选择地址
/// Date: 3/29/21 11:34 AM
/// Path: page/address/dialog/ChooseAddressDialog.dart
class ChooseAddressDialog {
  final BuildContext context;
  final Function onItemClick;
  final String address;
  List<Map> list = List.empty(growable: true);

  ChooseAddressDialog({@required this.context, this.onItemClick, this.address});

  Future<void> show() async {
    list.addAll(await SqlManager.queryData());
    int length = list.length;
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            constraints: BoxConstraints(
                maxHeight: ScreenUtil.getInstance().screenHeight / 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: ScrollConfiguration(
                behavior: NoScrollBehavior(),
                child: ListView.builder(
                  itemCount: length,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
                  // shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _item(list[index], angle: index == 0 ? 10 : 0);
                  },
                )),
          );
        });
  }

  Widget _item(Map map, {double angle = 0}) {
    double size17 = ScreenUtil.getInstance().getWidth(17);
    String addressS = map['address'] ?? "";
    int addressLength = addressS.length;
    String tag = "";
    Color tagColor;
    Color textColor;
    if (map['isValora'] == 0 && Tools.isNull(map['privateKey'])) {
      tag = S.of(context).observe_address;
      tagColor = Color(0X63D1F0FF);
      textColor = Color(0XFF33B2FF);
    } else if (map['isValora'] == 1) {
      tag = "Valora";
      tagColor = Color(0X63FFE9B6);
      textColor = Color(0XFFFFBC1F);
    }
    return FlatButton(
      disabledTextColor: Color(0XFFFFFFFF),
      disabledColor: Color(0XFFA6A6A6),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(angle), topRight: Radius.circular(angle)),
      ),
      height: ScreenUtil.getInstance().getWidth(60),
      onPressed: () {
        onItemClick?.call(addressS);
        Navigator.pop(context);
      },
      child: Container(
        height: ScreenUtil.getInstance().getWidth(60),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: size17,
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            addressLength > 24
                                ? (addressS.substring(0, 10) +
                                    "......" +
                                    addressS.substring(
                                        addressLength - 10, addressLength))
                                : addressS,
                            style: TextStyle(
                                color: Color(0XFF404044),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenUtil.getInstance().getSp(15)),
                          ),
                          Visibility(
                              visible: !Tools.isNull(tag),
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: tagColor,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(2)),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                      fontSize:
                                          ScreenUtil.getInstance().getSp(11),
                                      height: 1,
                                      color: textColor),
                                ),
                              ))
                        ],
                      ),
                      Visibility(
                          visible: !Tools.isNull(map['earningsName']),
                          child: Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              map['earningsName'] ?? "",
                              style: TextStyle(
                                  color: Color(0XFFC1C6C9),
                                  fontSize: ScreenUtil.getInstance().getSp(12)),
                            ),
                          ))
                    ],
                  )),
                  Visibility(
                      visible: address == addressS,
                      child: Icon(Icons.check_outlined,
                          color: Color(0xFF34D07F),
                          size: ScreenUtil.getInstance().getWidth(20))),
                  SizedBox(
                    width: size17,
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
