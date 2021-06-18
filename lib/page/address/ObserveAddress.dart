import 'dart:convert';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/AppInterface.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 观察地址
/// Date: 3/24/21 7:28 PM
/// Path: page/address/ObserveAddress.dart
class ObserveAddress extends StatefulWidget {
  final String crtCity;

  const ObserveAddress({Key key, @required this.crtCity}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ObserveAddressState();
}

class ObserveAddressState extends State<ObserveAddress> {
  // 更改按钮样式 和 禁用
  GlobalKey<BtnState> btnKey = GlobalKey();

// 获取输入的文字
  TextEditingController _addressController;
  FocusNode _addressFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    _addressController = TextEditingController();
    _addressController?.addListener(() {
      btnKey?.currentState?.setBtnStatus(_addressController.text.length > 10);
    });
    // _addressController?.text = "0x07fa1874ad4655ad0c763a7876503509be11e29e";
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _addressController?.dispose();
    _addressFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseTitle(
      resizeToAvoidBottomInset: true,
      title: S.of(context).observe_address,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Text(
              S.of(context).observe_address_hint,
              strutStyle:
                  StrutStyle(forceStrutHeight: true, height: 1, leading: 0.3),
              style: TextStyle(
                  color: Color(0XFFC1C6C9),
                  fontWeight: FontWeight.w600,
                  wordSpacing: 2,
                  fontSize: ScreenUtil.getInstance().getSp(12)),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              "assets/img/cd_observe_top_icon.png",
              width: 147,
              height: 147,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 35),
            height: ScreenUtil.getInstance().getWidth(45),
            child: TextField(
                controller: _addressController,
                focusNode: _addressFocusNode,
                autocorrect: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (data) => _ok(),
                style: TextStyle(
                    color: Color(0xFF48515B),
                    fontSize: ScreenUtil.getInstance().getSp(14)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.none),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(style: BorderStyle.none),
                      gapPadding: 0,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(style: BorderStyle.none),
                      gapPadding: 0,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  suffixIcon: InkWell(
                    onTap: () {
                      if (!_addressFocusNode.hasFocus) {
                        _addressFocusNode.canRequestFocus = false;
                        Future.delayed(Duration(milliseconds: 200), () {
                          _addressFocusNode.canRequestFocus = true;
                        });
                      }
                      Tools.requestCameraPermissions(context, S.of(context).scan_permissions_hint).then((value) {
                        if (value) {
                          RouteTools.startActivity(context, RouteTools.QR_CODE,
                              callbackContent: (data) {
                            try {
                              if (!Tools.isNull(data)) {
                                _addressController?.text = data;
                              }
                            } catch (e) {
                              print(e);
                            }
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Image.asset(
                        "assets/img/cd_observe_scan_icon.png",
                      ),
                    ),
                  ),
                  fillColor: Color(0XFFF6F7F7),
                  filled: true,
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 0, top: 0, bottom: 0),
                  hintText: S.of(context).input_address,
                  hintMaxLines: 1,
                  hintStyle: TextStyle(
                      color: Color(0XFF9899A6),
                      fontSize: ScreenUtil.getInstance().getSp(14)),
                )),
          ),
          BtnBgSolid(
              btnStatus: false,
              btnString: S.of(context).immediately_check,
              key: btnKey,
              btnCallback: () => _ok(),
              paddingTop: 35),
        ],
      ),
    );
  }

  _ok() async {
    if (isValidAddress(_addressController.text.toString())) {
      String address = _addressController.text.toString().toLowerCase();
      List<Map> list = await SqlManager.queryAddressData(address);
      if (list == null || list.isEmpty) {
        User user = User.fromSaveSqlJson(
            address: address, map: {}, privateKey: "", isValora: 0);
        int code = await SqlManager.addData(user.toSQLJson());
        if (code > 0) {
          Navigator.of(context).pop(jsonEncode(user.toSQLJson()));
        } else {
          Tools.showToast(context, S.of(context).save_address_err_hint);
        }
      } else {
        Tools.showToast(context, S.of(context).save_address_err_one);
      }
    } else {
      Tools.showToast(context, S.of(context).import_celo_address);
    }
  }
}
