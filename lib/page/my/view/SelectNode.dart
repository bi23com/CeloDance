import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/page/address/dialog/AddressRenameDialog.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/dialog/TextDialog.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 选择节点
/// Date: 4/25/21 6:45 PM
/// Path: page/my/view/SelectNode.dart
class SelectNode extends StatefulWidget {
  @override
  SelectNodeState createState() => SelectNodeState();
}

class SelectNodeState extends State<SelectNode> {
  String node;
  List<String> list = List.empty(growable: true);
  bool _isManagement = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int length = list.length;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
        title: Text(
          S.of(context).node_selection,
          style: TextStyle(
              color: Color(0XFF1A2636),
              fontWeight: FontWeight.w600,
              fontSize: ScreenUtil.getInstance().getSp(16)),
        ),
        centerTitle: true,
        leadingWidth: 41,
        leading: IconButton(
          alignment: Alignment.center,
          splashRadius: ScreenUtil.getInstance().getWidth(18),
          padding: EdgeInsets.all(3),
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.black,
            size: ScreenUtil.getInstance().getWidth(18),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isManagement = !_isManagement;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  _isManagement ? S.of(context).done : S.of(context).management,
                  style: TextStyle(
                      color: Color(0X80000000),
                      fontSize: ScreenUtil.getInstance().getSp(14)),
                ),
              ),
            ),
          )
        ],
      ),
      body: ScrollConfiguration(
          behavior: NoScrollBehavior(),
          child: ListView.builder(
            itemCount: _isManagement ? length : length + 1,
            // controller: scrollController,
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index < length) {
                return _item(list[index]);
              } else {
                return _item(S.of(context).custom_node);
              }
            },
          )),
    );
    // return BaseTitle(
    //   title: ,
    //   rightLeading: [
    //
    //   ],
    //   body: ScrollConfiguration(
    //       behavior: NoScrollBehavior(),
    //       child: ListView.builder(
    //         itemCount: list.length,
    //         // controller: scrollController,
    //         padding:
    //             EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
    //         shrinkWrap: true,
    //         physics: NeverScrollableScrollPhysics(),
    //         itemBuilder: (context, index) {
    //           return _item(list[index]);
    //         },
    //       )),
    // );
  }

  _initData() {
    list.clear();
    node = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    list.add("https://celo.dance/node");
    list.add("https://forno.celo.org");
    List<String> listC = SpUtil.getStringList(SpUtilConstant.NODE_CUSTOM_KEY);
    if (listC != null && listC.length > 0) {
      list.addAll(listC);
    }
    setState(() {});
  }

  Widget _item(String name) {
    double size17 = ScreenUtil.getInstance().getWidth(17);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (name == S.of(context).custom_node) {
          _showNodeRenameDialog();
        } else {
          SpUtil.putString(SpUtilConstant.NODE_ADDRESS_KEY, name);
          node = name;
          setState(() {});
        }
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
                  Visibility(
                      visible: name == S.of(context).custom_node,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Color(0XFFC1C6C9),
                      )),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                          color: _isManagement
                              ? Color(0XFF404044)
                              : (name == node
                                  ? Color(0XFF404044)
                                  : Color(0XFFC1C6C9)),
                          fontWeight: name != S.of(context).custom_node
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: ScreenUtil.getInstance().getSp(15)),
                    ),
                  ),
                  Visibility(
                    visible: !_isManagement && name == node,
                    child: Icon(Icons.check_outlined,
                        color: Color(0xFF34D07F),
                        size: ScreenUtil.getInstance().getWidth(20)),
                  ),
                  Visibility(
                      visible: _isManagement &&
                          name != S.of(context).custom_node &&
                          name != "https://celo.dance/node" &&
                          name != "https://forno.celo.org",
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          TextDialogBoard(
                              context: context,
                              content: Text(
                                S.of(context).rpc_url_delete_hint,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0XFF353535),
                                    fontSize:
                                        ScreenUtil.getInstance().getSp(12)),
                              ),
                              okClick: () async {
                                List<String> listC = SpUtil.getStringList(
                                    SpUtilConstant.NODE_CUSTOM_KEY);
                                if (listC == null) {
                                  listC = List.empty(growable: true);
                                }
                                for (int i = 0; i < listC.length; i++) {
                                  if (listC[i] == name) {
                                    listC.removeAt(i);
                                    break;
                                  }
                                }
                                if (name == node) {
                                  node = "https://celo.dance/node";
                                  SpUtil.putString(
                                      SpUtilConstant.NODE_ADDRESS_KEY, node);
                                }
                                SpUtil.putStringList(
                                    SpUtilConstant.NODE_CUSTOM_KEY, listC);
                                for (int i = 0; i < list.length; i++) {
                                  if (list[i] == name) {
                                    list.removeAt(i);
                                    break;
                                  }
                                }
                                setState(() {});
                              }).show();
                        },
                        child: Image.asset(
                          "assets/img/cd_delete_icon.png",
                          width: ScreenUtil.getInstance().getWidth(16),
                          fit: BoxFit.fitWidth,
                        ),
                      )),
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
    );
  }

  /// 显示 自定义 节点弹窗
  _showNodeRenameDialog() {
    AddressRenameDialog(
        context: context,
        rules: "url",
        list: list,
        onClick: (name) {
          List<String> listC =
              SpUtil.getStringList(SpUtilConstant.NODE_CUSTOM_KEY);
          if (listC == null || listC.isEmpty) {
            listC = List.empty(growable: true);
          }
          listC.add(name);
          SpUtil.putStringList(SpUtilConstant.NODE_CUSTOM_KEY, listC);
          SpUtil.putString(SpUtilConstant.NODE_ADDRESS_KEY, name);
          _initData();
        }).show();
  }
}
