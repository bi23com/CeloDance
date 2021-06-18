import 'dart:convert';
import 'dart:typed_data';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/AppInterface.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/page/address/dialog/PinPawDialog.dart';
import 'package:dpos/page/address/import/ImportAddress.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/dialog/BaseLoadingDialog.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'view/CreateAddressVerify.dart';
import 'view/CreateAddressWord.dart';

class CreateAddress extends StatefulWidget {
  CreateAddress({Key key}) : super(key: key);

  @override
  CreateAddressState createState() => CreateAddressState();
}

class CreateAddressState extends State<CreateAddress> {
  PageController mPageController = PageController(initialPage: 0);

  /// 备份助记词页面的key
  GlobalKey<CreateAddressWordState> createAddressWordKey = GlobalKey();

  /// 备份助记词九宫格页面的key
  GlobalKey<CreateAddressVerifyState> createAddressVerifyeKey = GlobalKey();
  BaseLoadingDialog _baseLoadingDialog;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _baseLoadingDialog = BaseLoadingDialog(context);
    });
  }

  @override
  void dispose() {
    _baseLoadingDialog = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (mPageController.page > 0) {
            mPageController?.animateToPage(mPageController.page.toInt() - 1,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          } else {
            Navigator.of(context).pop();
          }
          return false;
        },
        child: PageView.builder(
            itemCount: 2,
            scrollDirection: Axis.horizontal,
            controller: mPageController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index) {},
            // physics: PageScrollPhysics(parent: BouncingScrollPhysics()),
            itemBuilder: (context, index) {
              if (index == 0)
                // 选择钱包 的创建 链
                return CreateAddressWord(
                  key: createAddressWordKey,
                  okClick: () {
                    mPageController?.animateToPage(1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                    createAddressVerifyeKey?.currentState?.refresh(
                        createAddressWordKey?.currentState?.getDoc() ?? "");
                  },
                );
              else
                // 创建钱包提示
                return CreateAddressVerify(
                    key: createAddressVerifyeKey,
                    wordData: createAddressWordKey?.currentState?.getDoc(),
                    onTap: (position) {
                      if (position == 0) {
                        mPageController?.animateToPage(0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      } else {
                        _ok();
                      }
                    });
            }));
  }

  _ok() async {
    _baseLoadingDialog?.show(loadText: S.of(context).load_text);
    Uint8List uint8List = await compute(getAddressUint8List,
        createAddressWordKey?.currentState?.getDoc()?.toString() ?? "");
    _baseLoadingDialog?.hide();
    if (uint8List != null) {
      PinPawDialog(
              context: context,
              onOk: (paw) async {
                // print("===密码====$paw");
                _baseLoadingDialog?.show(loadText: S.of(context).load_text);
                CeloWallet celoWallet = await compute(syncFibonacci,
                    CeloWallet("", "", paw: paw, uint8list: uint8List));
                if (Tools.isNull(celoWallet.address) ||
                    Tools.isNull(celoWallet.walletJson)) {
                  _baseLoadingDialog?.hide();
                  Tools.showToast(context,S.of(context).address_create_err);
                } else {
                  String address = celoWallet.address.toLowerCase();
                  List<Map> list = await SqlManager.queryAddressData(address);
                  User user = User.fromSaveSqlJson(
                      address: address,
                      map: {},
                      privateKey: celoWallet.walletJson,
                      isValora: 0);
                  int code = 0;
                  if (list == null || list.isEmpty) {
                    code = await SqlManager.addData(user.toSQLJson());
                  } else {
                    code = await SqlManager.updateMoreFieldData(
                        address: address,
                        keys: ["privateKey"],
                        values: [celoWallet.walletJson]);
                  }
                  _baseLoadingDialog?.hide();
                  if (code > 0) {
                    if (Tools.isNull(SpUtil.getString(
                            SpUtilConstant.PAW_ENCRYPTION_KEY)) ||
                        Tools.isNull(
                            SpUtil.getString(SpUtilConstant.PAW_ADDRESS_KEY))) {
                      SpUtil.putString(SpUtilConstant.PAW_ENCRYPTION_KEY,
                          celoWallet.walletJson);
                      SpUtil.putString(
                          SpUtilConstant.PAW_ADDRESS_KEY, celoWallet.address);
                    }
                    Navigator.of(context).pop(jsonEncode(user.toSQLJson()));
                  } else {
                    Tools.showToast(context,S.of(context).save_address_err_hint);
                  }
                }
              },
              payPawBehavior:
                  SpUtil.getBool(SpUtilConstant.IS_PASSWORD, defValue: false)
                      ? PinPawBehavior.use
                      : PinPawBehavior.open)
          .show();
    } else {
      Tools.showToast(context,S.of(context).address_create_err);
    }
  }
}
