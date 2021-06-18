import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/view/BtnBgHollow.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Tools.dart';

/// Describe: 版本升级弹窗
/// Date: 4/13/21 4:04 PM
/// Path: tools/dialog/APPUpgradeDialog.dart
class APPUpgradeDialog extends Dialog {
  APPUpgradeDialog({this.list}) : super();

  /// 更新信息
  final List list;

  // // 下载地址
  // final String downloadUrl;
  //
  // // 版本号
  // final String ver;
  //
  // // 版本号
  // final String updateContent;

  // 打开默认浏览器
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    num flg = list[0];
    String title = list[1];
    String content = list[2];
    String webUrl = list[3];
    return BaseTitle(
      isShowAppBar: false,
      backgroundColor: Color(0X99000000),
      body: WillPopScope(
          child: Center(
              //保证控件居中效果
              child: Container(
            margin: EdgeInsets.only(
                bottom: ScreenUtil.getInstance().getWidthPx(164)),
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil.getInstance().getWidthPx(72)),
            child: Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtil.getInstance().getWidthPx(164)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    "assets/img/cd_update_top_bg.png",
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.getInstance().getWidth(15),
                        vertical: ScreenUtil.getInstance().getWidth(19)),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                              ScreenUtil.getInstance().getWidthPx(26)),
                          bottomRight: Radius.circular(
                              ScreenUtil.getInstance().getWidthPx(26))),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          title ?? "",
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().getSp(16),
                              fontWeight: FontWeight.w500,
                              color: Color(0xff4A4A4A)),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(
                            top: ScreenUtil.getInstance().getWidth(15),
                            bottom: ScreenUtil.getInstance().getWidthPx(66),
                          ),
                          constraints: BoxConstraints(
                              minHeight:
                                  ScreenUtil.getInstance().getWidthPx(500)),
                          child: Text(
                            content ?? "",
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().getSp(13.3),
                                height: 1.6,
                                color: Color(0xff95A1A9)),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Visibility(
                                visible: flg == 0,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: ScreenUtil.getInstance()
                                          .getWidthPx(58)),
                                  child: SizedBox(
                                    height:
                                        ScreenUtil.getInstance().getWidthPx(86),
                                    width: ScreenUtil.getInstance()
                                        .getWidthPx(325),
                                    child: BtnBgHollow(
                                      S.of(context).shut_down,
                                      () => Navigator.pop(context),
                                      textColor: Color(0xFFA6A6A6),
                                      bgColor: Color(0xFFD1D1D1),
                                    ),
                                  ),
                                )),
                            Visibility(
                                visible: !Tools.isNull(webUrl),
                                child: SizedBox(
                                    width: ScreenUtil.getInstance()
                                        .getWidthPx(325),
                                    height:
                                        ScreenUtil.getInstance().getWidthPx(86),
                                    child: FlatButton(
                                      disabledTextColor: Color(0XFFFFFFFF),
                                      disabledColor: Color(0XFFA6A6A6),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      //画圆角
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            ScreenUtil.getInstance()
                                                .getWidthPx(63)),
                                      ),
                                      onPressed: () async {
                                        await _launchURL(webUrl);
                                        if (flg == 1) {
                                          await SystemChannels.platform
                                              .invokeMethod(
                                                  'SystemNavigator.pop');
                                        } else {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Text(
                                        S.of(context).jump,
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance()
                                                .getSp(13.3)),
                                      ),
                                      color: Color(0XFF34D07F),
                                      textColor: Color(0XFFFFFFFF),
                                      highlightColor: Colors.black12,
                                    ))),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
          onWillPop: () async {
            if (flg == 0) {
              Navigator.of(context).pop();
            }
            return Future.value(false);
          }),
    );
  }
}
