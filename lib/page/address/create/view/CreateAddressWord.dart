import 'dart:convert';
import 'dart:typed_data';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/page/address/dialog/PinPawDialog.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Describe: 获取助记词地址页面
/// Date: 3/31/21 4:16 PM
/// Path: page/address/create/view/CreateAddressWord.dart
class CreateAddressWord extends StatefulWidget {
  CreateAddressWord({Key key, this.okClick}) : super(key: key);
  final Function okClick;

  @override
  CreateAddressWordState createState() => CreateAddressWordState();
}

class CreateAddressWordState extends State<CreateAddressWord>
    with AutomaticKeepAliveClientMixin<CreateAddressWord> {
  // 更改按钮样式 和 禁用
  GlobalKey<BtnState> btnKey = GlobalKey();

  /// 是否 开关
  bool _flag = false;

  /// 助记词
  String _doc = "";
  String _address = "0x";

  @override
  void initState() {
    // TODO: implement initState
    _doc = getMnemonic();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Respond respond = await compute(getAddressData, _doc);
      if (respond.code == 0) {
        _address = respond.data.toString().toLowerCase();
      } else {
        _address = respond.msg;
      }
      if (mounted) setState(() {});
      // js.context.callMethod('aaaa',['哈哈哈哈哈哈']);
      // var aaaa =  js.context.callMethod('getAddressByMnemonic', [_doc]);
      // var aaaa =  js.context.callMethod('getAddressByMnemonic', [_doc]);
      // print("地址====$aaaa");
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double size69 = ScreenUtil.getInstance().getWidthPx(69);
    return BaseTitle(
      title: S.of(context).address_create,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   _address ?? '',
          //   style: TextStyle(
          //       fontSize: ScreenUtil.getInstance().getSp(12),
          //       color: _address == "0x" ? Colors.white : Color(0XFF999999)),
          //
          Padding(
              padding: EdgeInsets.only(
                  left: size69,
                  top: 10,
                  bottom: ScreenUtil.getInstance().getWidth(15),
                  right: size69),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_address.length > 10) {
                    Clipboard.setData(ClipboardData(text: _address));
                    Tools.showToast(context, S.of(context).copy_success);
                  }
                },
                child: RichText(
                  text: TextSpan(
                      text: _address ?? '',
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().getSp(12),
                          color: _address == "0x"
                              ? Colors.white
                              : Color(0XFF999999)),
                      children: [
                        WidgetSpan(
                            child: Visibility(
                          visible: _address.length > 10,
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 0, bottom: 2),
                            child: Image.asset(
                              "assets/img/cd_aa_copy_icon.png",
                              width: ScreenUtil.getInstance().getWidth(13),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        )),
                      ]),
                ),
              )),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil.getInstance().getWidthPx(58)),
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil.getInstance().getWidth(17),
                vertical: ScreenUtil.getInstance().getWidth(15)),
            decoration: BoxDecoration(
              color: Color(0XFFF5F5F5),
              borderRadius: BorderRadius.circular(9),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!Tools.isNull(_doc)) {
                  Clipboard.setData(ClipboardData(text: _doc));
                  Tools.showToast(context, S.of(context).copy_success);
                }
              },
              child: RichText(
                strutStyle:
                    StrutStyle(forceStrutHeight: true, height: 1, leading: 1),
                text: TextSpan(
                    text: _doc,
                    style: TextStyle(
                        color: Color(0XFF404044),
                        fontWeight: FontWeight.w600,
                        wordSpacing: 5,
                        fontSize: ScreenUtil.getInstance().getSp(14)),
                    children: [
                      WidgetSpan(
                          child: Padding(
                        padding: EdgeInsets.only(left: 10, top: 0),
                        child: Image.asset(
                          "assets/img/cd_aa_copy_icon.png",
                          width: ScreenUtil.getInstance().getWidth(13),
                          fit: BoxFit.fitWidth,
                        ),
                      )),
                    ]),
              ),
            ),
          ),

          // Text(
          //   _doc,
          //   strutStyle:
          //   StrutStyle(forceStrutHeight: true, height: 1, leading: 1),
          //   style: TextStyle(
          //       color: Color(0XFF404044),
          //       fontWeight: FontWeight.w600,
          //       wordSpacing: 5,
          //       fontSize: ScreenUtil.getInstance().getSp(14)),
          // )
          Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil.getInstance().getWidthPx(58),
                right: size69,
                top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2, right: 2),
                  child: Image.asset("assets/img/cd_verify_hint_icon.png",
                      fit: BoxFit.fill,
                      height: ScreenUtil.getInstance().getWidth(14),
                      width: ScreenUtil.getInstance().getWidth(14)),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(S.of(context).address_create_hint_two,
                      strutStyle: StrutStyle(
                          forceStrutHeight: true, height: 0.5, leading: 1),
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().getSp(12),
                          color: Color(0XFFC1C6C9))),
                )
              ],
            ),
          ),
          Expanded(child: SizedBox()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size69),
            child: Row(
              children: [
                Transform.scale(
                    scale: 0.75,
                    child: CupertinoSwitch(
                        value: _flag,
                        activeColor: Color(0XFF34D07F),
                        trackColor: Color(0XFFECECEC),
                        onChanged: (v) {
                          btnKey?.currentState?.setBtnStatus(v);
                          setState(() => _flag = v);
                        })),
                Text(
                  !_flag
                      ? S.of(context).address_create_hint_three
                      : S.of(context).all_backups,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(12),
                      color: Color(0XFF5D5D5D)),
                )
              ],
            ),
          ),
          BtnBgSolid(
            btnStatus: false,
            btnString: S.of(context).next_step,
            key: btnKey,
            fontWeight: FontWeight.w600,
            btnCallback: () {
              widget.okClick?.call();
            },
            paddingTop: 35,
            paddingBottom: 55,
          ),
        ],
      ),
    );
  }

  /// 获取助记词
  getDoc() => _doc;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

/// 生成地址
Future<Respond> getAddressData(String doc) async {
  return getAddressByMnemonic(doc);
}
