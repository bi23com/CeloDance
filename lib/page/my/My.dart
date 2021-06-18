import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class My extends StatefulWidget {
  final Function onItemClick;

  My({Key key, this.onItemClick}) : super(key: key);

  @override
  _MyState createState() => _MyState();
}

class _MyState extends State<My> {
  String _lang = "";
  String _currency = "";

  @override
  void initState() {
    // TODO: implement initState
    String language =
        SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE, defValue: "zh");
    if (language == "zh") {
      _lang = "简体中文";
    } else if (language == "en") {
      _lang = "English";
    }
    String currency =
        SpUtil.getString(SpUtilConstant.CHOOSE_ASSETS, defValue: "CNY");
    if (currency == "CNY") {
      _currency = "¥ CNY";
    } else if (currency == "USD") {
      _currency = "\$ USD";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.getInstance().screenWidth / 1.5;
    return Container(
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: 60,
                bottom: 30,
                left: ScreenUtil.getInstance().getWidth(19)),
            child: Text(
              S.of(context).mine,
              style: TextStyle(
                  color: Color(0xFF48515B),
                  fontWeight: FontWeight.w600,
                  fontSize: ScreenUtil.getInstance().getSp(17)),
            ),
          ),
          _getFunctionItem("cd_my_address_icon.png",
              S.of(context).address_administration, ""),
          Container(
            margin:
                EdgeInsets.only(left: ScreenUtil.getInstance().getWidth(17)),
            height: 0.5,
            color: Color(0XA1DEDEDE),
          ),
          _getFunctionItem("cd_my_asset_icon.png",
              S.of(context).asset_administration, _currency),
          Container(
            margin:
                EdgeInsets.only(left: ScreenUtil.getInstance().getWidth(17)),
            height: 0.5,
            color: Color(0XA1DEDEDE),
          ),
          _getFunctionItem(
              "cd_my_language_icon.png", S.of(context).language_choice, _lang),
          Container(
            margin:
                EdgeInsets.only(left: ScreenUtil.getInstance().getWidth(17)),
            height: 0.5,
            color: Color(0XA1DEDEDE),
          ),
          Visibility(
              visible: Tools.isHint,
              child: _getFunctionItem(
                  "cd_node_icon.png", S.of(context).node_selection, "")),
          Visibility(
              visible: Tools.isHint,
              child: Container(
                margin: EdgeInsets.only(
                    left: ScreenUtil.getInstance().getWidth(17)),
                height: 0.5,
                color: Color(0XA1DEDEDE),
              )),
          _getFunctionItem(
              "cd_privacy_icon.png", S.of(context).privacy_policy, ""),
          Container(
            margin:
                EdgeInsets.only(left: ScreenUtil.getInstance().getWidth(17)),
            height: 0.5,
            color: Color(0XA1DEDEDE),
          ),
          Expanded(child: SizedBox()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // _appItem("telegram", 0),
                _appItem("twitter", 1),
                // _appItem("discord", 2),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "V${HttpTools.getVerName()}",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFFA1A1A1),
                  fontWeight: FontWeight.w400,
                  fontSize: ScreenUtil.getInstance().getSp(14)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Align(
              alignment: Alignment.center,
              child: Text(
                S.of(context).start_hint,
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().getSp(11),
                  color: Color(0XFFBABABA),
                ),
              )),
          SizedBox(
            height: 2,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "${S.of(context).start_donors_hint}",
              // "${S.of(context).start_donors_hint} v${HttpTools.getVerName()}",
              style: TextStyle(
                fontSize: ScreenUtil.getInstance().getSp(10),
                color: Color(0XFFBABABA),
              ),
            ),
          ),
          SizedBox(
            height: 25 + MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }

  Widget _appItem(String iconName, int position) {
    return GestureDetector(
      onTap: () {
        switch (position) {
          case 0:
            launch("https://telegram.me/Bi23Labs");
            break;
          case 1:
            launch("https://twitter.com/bi23com");
            break;
          case 2:
            launch("https://discord.gg/ykbMkMSDpJ");
            break;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Image.asset(
          "assets/img/cd_${iconName}_icon.png",
          width: ScreenUtil.getInstance().getWidth(30),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  /*
   * 功能选项
   */
  Widget _getFunctionItem(String imgUrl, String name, String hint) {
    return FlatButton(
      disabledTextColor: Color(0XFFFFFFFF),
      disabledColor: Color(0XFFA6A6A6),
      padding: EdgeInsets.only(
          top: ScreenUtil.getInstance().getWidth(16),
          left: ScreenUtil.getInstance().getWidth(17),
          right: ScreenUtil.getInstance().getWidth(5),
          bottom: ScreenUtil.getInstance().getWidth(16)),
      onPressed: () {
        Navigator.of(context).pop();
        widget.onItemClick?.call(name);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Image.asset("assets/img/$imgUrl",
              fit: BoxFit.fill,
              height: ScreenUtil.getInstance().getWidth(16),
              width: ScreenUtil.getInstance().getWidth(16)),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(left: ScreenUtil.getInstance().getWidth(6)),
              child: Text(
                name,
                style: TextStyle(
                    color: const Color(0xFF48515B),
                    fontWeight: FontWeight.w600,
                    fontSize: ScreenUtil.getInstance().getSp(13)),
              ),
            ),
          ),
          Text(
            hint,
            style: TextStyle(
                color: const Color(0xFFA1A1A1),
                fontSize: ScreenUtil.getInstance().getSp(11)),
          ),
          SizedBox(
            width: ScreenUtil.getInstance().getWidth(5),
          ),
          Image.asset("assets/img/cd_right_arrow_icon.png",
              fit: BoxFit.fill,
              height: ScreenUtil.getInstance().getWidth(12),
              width: ScreenUtil.getInstance().getWidth(12)),
        ],
      ),
      color: Color(0XFFFFFFFF),
      highlightColor: Colors.black12,
    );
  }
}
