import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

/// Describe: 币种类 弹窗
/// Date: 3/25/21 3:06 PM
/// Path: page/address/dialog/CoinTypeDialog.dart
class CoinTypeDialog {
  final BuildContext context;
  final Function onItemClick;
  final String coinName;
  final bool isShowCEUR;

  CoinTypeDialog(
      {@required this.context,
      this.onItemClick,
      this.coinName,
      this.isShowCEUR = true});

  Future<void> show() async {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return CoinType(
            onItemClick: onItemClick,
            coinName: coinName,
            isShowCEUR: isShowCEUR,
          );
        });
  }
}

class CoinType extends StatefulWidget {
  CoinType({Key key, this.onItemClick, this.coinName, this.isShowCEUR})
      : super(key: key);
  final Function onItemClick;
  final bool isShowCEUR;
  final String coinName;

  @override
  _CoinTypeState createState() => _CoinTypeState();
}

class _CoinTypeState extends State<CoinType> {
  List<String> list = List.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list.add("CELO");
    list.add("cUSD");
    if (widget.isShowCEUR) list.add("cEUR");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        child: ScrollConfiguration(
            behavior: NoScrollBehavior(),
            child: ListView.builder(
              itemCount: list.length,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _item(list[index], angle: index == 0 ? 10 : 0);
              },
            )),
      ),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
    );
  }

  Widget _item(String coinName, {double angle = 0}) {
    double size17 = ScreenUtil.getInstance().getWidth(17);
    return Container(
      height: ScreenUtil.getInstance().getWidth(60),
      child: Column(
        children: [
          Expanded(
            child: FlatButton(
                disabledTextColor: Color(0XFFFFFFFF),
                disabledColor: Color(0XFFA6A6A6),
                padding: EdgeInsets.zero,
                height: ScreenUtil.getInstance().getWidth(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(angle),
                      topRight: Radius.circular(angle)),
                ),
                onPressed: () {
                  widget.onItemClick?.call(coinName);
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: size17,
                    ),
                    Expanded(
                      child: Text(
                        coinName,
                        style: TextStyle(
                            color: Color(0XFF404044),
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenUtil.getInstance().getSp(15)),
                      ),
                    ),
                    Visibility(
                        visible: widget.coinName == coinName,
                        child: Icon(Icons.check_outlined,
                            color: Color(0xFF34D07F),
                            size: ScreenUtil.getInstance().getWidth(20))),
                    SizedBox(
                      width: size17,
                    ),
                  ],
                ),
                color: Color(0XFFFFFFFF),
                highlightColor: Colors.black12),
          ),
          Container(
            margin: EdgeInsets.only(left: size17),
            height: 0.5,
            color: Color(0XA1DEDEDE),
          ),
        ],
      ),
    );
  }
}
