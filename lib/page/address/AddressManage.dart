import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/dialog/TextDialog.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialog/AddAddressDialog.dart';
import 'dialog/AddressRenameDialog.dart';
import 'dialog/PinPawDialog.dart';
import 'entity/SendHomeEntity.dart';

/// Describe: 地址管理
/// Date: 3/31/21 5:21 PM
/// Path: page/address/AddressManage.dart
class AddressManage extends StatefulWidget {
  final String crtCity;

  const AddressManage({Key key, @required this.crtCity}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddressManageState();
}

class AddressManageState extends State<AddressManage> {
  SlidableController _slidableController = SlidableController();
  StreamSubscription _AMStreamSubscription;
  List<Map> list = List.empty(growable: true);
  bool _isManagement = false;

  // 标题的key
  GlobalKey<BaseTitleState> baseTitleKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _AMStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //     onWillPop: () async {
    //       _slidableController?.activeState?.close();
    //       Navigator.of(context).pop();
    //       return false;
    //     },
    //     child:
    return BaseTitle(
      key: baseTitleKey,
      title: S.of(context).address_administration,
      goBackCallback: () {
        _slidableController?.activeState?.close();
        Navigator.of(context).pop();
      },
      body: _getHomeLayout(),
    );
  }

  /// 初始化数据
  _initData() async {
    list.clear();
    list.addAll(await SqlManager.queryData());
    // print("event===list=====$list");
    _setRightBtn();
    _AMStreamSubscription =
        EventBusTools.getEventBus()?.on<String>()?.listen((event) async {
      // print("event===AM=====$event");
      if (mounted) {
        if ("AddressManageUpdate" == event) {
          list.clear();
          list.addAll(await SqlManager.queryData());
          _setRightBtn();
          if (mounted) setState(() {});
        }
      }
    });
    if (mounted) setState(() {});
  }

  _getHomeLayout() {
    int length = list.length;
    return length == 0
        ? Column(
            children: [
              Tools.noAddressShowLayout(
                  context: context,
                  function: () {
                    _showDialog();
                  })
            ],
          )
        : ScrollConfiguration(
            behavior: NoScrollBehavior(),
            child: ListView.separated(
              itemCount: length,
              padding: EdgeInsets.symmetric(vertical: 14),
              itemBuilder: (context, index) {
                // return index >= length
                //     ? Visibility(
                //         visible: !_isManagement,
                //         child: Tools.yesAddressShowLayout(
                //             context: context,
                //             bgColor: Colors.white,
                //             function: () {
                //               _showDialog();
                //             }))
                //     : _item(index);
                return _item(index);
              },
              separatorBuilder: (BuildContext context, int index) => SizedBox(
                height: 14,
              ),
            ));
  }

  /// 显示item 布局
  Widget _item(int index) {
    User user = User.fromSQLHomeJson(list[index]);
    String address = user.address ?? "";
    int addressLength = address.length;
    String tag = "";
    String tagImg = "";
    Color tagColor;
    if (user.isValora == 0 && Tools.isNull(user.privateKey)) {
      tag = S.of(context).observe_address;
      tagImg = "cd_am_item_o_bg";
      tagColor = Color(0XFF3CB1F2);
    } else if (user.isValora == 1) {
      tag = "Valora";
      tagImg = "cd_am_item_va_bg";
      tagColor = Color(0XFFFDC136);
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14),
      padding: EdgeInsets.only(right: 9),
      height: ScreenUtil.getInstance().getWidth(87),
      decoration: BoxDecoration(
        color: Color(0X96F6F7F7),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Stack(
            alignment: Alignment.topRight,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 13),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/img/cd_home_item_icon.png",
                          width: ScreenUtil.getInstance().getWidth(25),
                          height: ScreenUtil.getInstance().getWidth(25),
                          fit: BoxFit.fill,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Text(
                          addressLength > 23
                              ? (address.substring(0, 10) +
                                  "......" +
                                  address.substring(
                                      addressLength - 10, addressLength))
                              : address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0XFF404044),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil.getInstance().getSp(14)),
                        )),
                      ],
                    ),
                    Visibility(
                        visible: !Tools.isNull(user.earningsName),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.getInstance().getWidth(25) + 10),
                          child: Text(
                            user.earningsName,
                            style: TextStyle(
                                color: Color(0XFFC1C6C9),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenUtil.getInstance().getSp(13)),
                          ),
                        )),
                  ],
                ),
              ),
              Visibility(
                  visible: !Tools.isNull(tag),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 14, right: 7),
                        height: ScreenUtil.getInstance().getWidth(20),
                        decoration: BoxDecoration(
                          color: tagColor,
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(5)),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().getSp(11),
                              height: 1,
                              color: Colors.white),
                        ),
                      ),
                      Image.asset(
                        "assets/img/$tagImg.png",
                        height: ScreenUtil.getInstance().getWidth(20),
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ))
            ],
          )),
          Visibility(
              visible: _isManagement,
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    AddressRenameDialog(
                        context: context,
                        onClick: (name) async {
                          int code = await SqlManager.updateFieldData(
                              address: user.address,
                              key: "earningsName",
                              value: name);
                          // address: user.address, key: "name", value: name);
                          if (code == 0) {
                            Tools.showToast(
                                context, S.of(context).renamed_failure);
                          } else {
                            list.clear();
                            list.addAll(await SqlManager.queryData());
                            if (mounted) setState(() {});
                            EventBusTools.getEventBus()
                                ?.fire(SendHomeEntity(name: "rename"));
                          }
                        }).show();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7),
                    child: Image.asset(
                      "assets/img/cd_am_sname_icon.png",
                      height: ScreenUtil.getInstance().getWidth(17),
                      fit: BoxFit.fitHeight,
                    ),
                  ))),
          Visibility(
              visible: _isManagement,
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    TextDialogBoard(
                        context: context,
                        confirm: S.of(context).delete,
                        content: Text(
                          S.of(context).confirm_delete,
                          style: TextStyle(
                              color: Color(0XFF353535),
                              fontSize: ScreenUtil.getInstance().getSp(12)),
                        ),
                        okClick: () async {
                          if (Tools.isNull(user.privateKey)) {
                            _deleteAddress(index, address);
                          } else {
                            _inputPaw(index, address);
                          }
                        }).show();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7),
                    child: Image.asset(
                      "assets/img/cd_am_delete_icon.png",
                      height: ScreenUtil.getInstance().getWidth(17),
                      fit: BoxFit.fitHeight,
                    ),
                  ))),
        ],
      ),
    );
    //   secondaryActions: <Widget>[
    //     SlideAction(
    //       // color: Color(0XFFF2CE5B),
    //       decoration: BoxDecoration(
    //         color: Color(0XFF34D07F),
    //         borderRadius: BorderRadius.only(
    //             topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
    //       ),
    //       child: Text(
    //         S.of(context).denunciate,
    //         style: TextStyle(
    //             color: Colors.white,
    //             fontWeight: FontWeight.w600,
    //             fontSize: ScreenUtil.getInstance().getSp(12)),
    //         textAlign: TextAlign.center,
    //       ),
    //       onTap: () async {

    //       },
    //     ),
    //     SlideAction(
    //       color: Color(0XFFFCCC5C),
    //       child: Text(
    //         S.of(context).delete,
    //         style: TextStyle(
    //             color: Colors.white,
    //             fontWeight: FontWeight.w600,
    //             fontSize: ScreenUtil.getInstance().getSp(12)),
    //       ),
    //       onTap: () {
    //
    //       },
    //     ),
    //   ],
    // );
  }

  /// 显示dialog 的方法
  _showDialog() {
    AddAddressDialog(
        context: context,
        onItemClick: (name) async {
          if (S.of(context).observe_address_add == name) {
            // 观察地址
            RouteTools.startActivity(context, RouteTools.OBSERVE_ADDRESS,
                callbackContent: (content) async {
              if (!Tools.isNull(content)) {
                EventBusTools.getEventBus()
                    ?.fire(SendHomeEntity(name: "localRefresh"));
                list.add(json.decode(content));
                _setRightBtn();
                setState(() {});
              }
            });
          } else if (S.of(context).import_wallet == name) {
            // 导入地址
            RouteTools.startActivity(context, RouteTools.IMPORT_ADDRESS,
                callbackContent: (content) {
              if (!Tools.isNull(content)) {
                EventBusTools.getEventBus()
                    ?.fire(SendHomeEntity(name: "localRefresh"));
                list.add(json.decode(content));
                _setRightBtn();
                setState(() {});
              }
            });
          } else if (S.of(context).address_create == name) {
            // 创建地址
            RouteTools.startActivity(context, RouteTools.CREATE_ADDRESS,
                callbackContent: (content) {
              if (!Tools.isNull(content)) {
                EventBusTools.getEventBus()
                    ?.fire(SendHomeEntity(name: "localRefresh"));
                list.add(json.decode(content));
                _setRightBtn();
                setState(() {});
              }
            });
          } else if (S.of(context).valora_authorization == name) {
            Tools.valoraAuthorization(context);
          }
        }).show();
  }

  /// 设置标题右侧按钮
  _setRightBtn() {
    baseTitleKey?.currentState?.setRightBtnList([
      list.isEmpty
          ? Text("")
          : GestureDetector(
              onTap: () {
                _isManagement = !_isManagement;
                _setRightBtn();
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    _isManagement
                        ? S.of(context).done
                        : S.of(context).management,
                    style: TextStyle(
                        color: Color(0X80000000),
                        fontSize: ScreenUtil.getInstance().getSp(14)),
                  ),
                ),
              ),
            )
      // GestureDetector(
      //         onTap: () {
      //           _showDialog();
      //         },
      //         child: Padding(
      //           padding: EdgeInsets.only(right: 15),
      //           child: Icon(
      //             Icons.add_outlined,
      //             color: Colors.black,
      //           ),
      //         ),
      //       )
    ]);
  }

  /// 输入支付密码
  _inputPaw(int index, String address) {
    PinPawDialog(
            context: context,
            onOk: (paw) async {
              _deleteAddress(index, address);
            },
            payPawBehavior:
                SpUtil.getBool(SpUtilConstant.IS_PASSWORD, defValue: false)
                    ? PinPawBehavior.use
                    : PinPawBehavior.open)
        .show();
  }

  /// 删除当前地址信息
  _deleteAddress(int index, String address) async {
    int code = await SqlManager.deleteData(address);
    if (code == 0) {
      Tools.showToast(context, S.of(context).delete_failed);
    } else {
      SqlManager.deleteData(address, name: SqlManager.RECORD);
      list.removeAt(index);
      if (_isManagement && list.isEmpty) {
        _isManagement = false;
      }
      _setRightBtn();
      EventBusTools.getEventBus()?.fire(SendHomeEntity(name: "localRefresh"));
      if (mounted) setState(() {});
    }
  }
}
