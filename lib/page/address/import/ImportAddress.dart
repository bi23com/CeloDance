import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/AppInterface.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/page/address/dialog/PinPawDialog.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/dialog/BaseLoadingDialog.dart';
import 'package:dpos/tools/dialog/TextDialog.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'dart:html' as html;
import 'dart:isolate' as iso;

/// Describe: 导入地址
/// Date: 3/22/21 6:04 PM
/// Path: page/address/import/ImportAddress.dart

class ImportAddress extends StatefulWidget {
  const ImportAddress({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImportAddressState();
}

class ImportAddressState extends State<ImportAddress>
    with AutomaticKeepAliveClientMixin<ImportAddress> {
  // 更改按钮样式 和 禁用
  GlobalKey<BtnState> btnKey = GlobalKey();
  BaseLoadingDialog _baseLoadingDialog;

  /// 填写助记词数据
  List<String> _listWord = new List<String>();
  List<FocusNode> _listWordFocusNode = new List<FocusNode>();

  // 监听 输入下一个助记词
  TextEditingController _controller;
  FocusNode _focusNode;

  int _position = 0;

  /// 获取助记词
  String getWord() {
    String word = "";
    for (int i = 0; i < _listWord.length; i++) {
      word += _listWord[i] + " ";
    }
    if (!Tools.isNull(word)) {
      word = word.substring(0, word.length - 1);
    }
    return word;
  }

  /// 获取输入框
  Widget _getInputBox(FocusNode focusNode, TextEditingController controller,
      Function onSubmitted,
      {Function onTap}) {
    return Container(
      alignment: Alignment.center,
      //边框设置
      decoration: BoxDecoration(
        //背景
        color: Color(0XFFF5F5F5),
        //设置四周圆角 角度
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.text,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        focusNode: focusNode,
        controller: controller,
        style: TextStyle(
          fontSize: ScreenUtil.getInstance().getSp(14),
          height: 1.1,
          color: Color(0XFF4A4A4A),
        ),
        cursorColor: Color(0XFF353535),
        showCursor: true,
        onSubmitted: onSubmitted,
        onTap: () {
          onTap?.call();
        },
        decoration: InputDecoration(
          // filled: true,
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.zero,
          counterText: "",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 获取 输入框 和 显示文字的item
  Widget _getInputItem(int index) {
    return Tools.isNull(_listWord[index])
        ? _getInputBox(_listWordFocusNode[index], null, (value) async {
            if (!Tools.isNull(value)) {
              if (value.length > 80 && value.split(" ").length == 24) {
                _listWord.clear();
                _listWord.addAll(value.split(" "));
                _position = 24;
                if (_listWordFocusNode.length != 24) {
                  _listWordFocusNode.clear();
                  for (int i = 0; i < 24; i++) {
                    _listWordFocusNode.add(FocusNode());
                  }
                }
                setState(() {});
              } else {
                _listWord[index] = value;
                bool isNull = false;
                for (int i = 0; i < _listWord.length; i++) {
                  if (Tools.isNull(_listWord[i])) {
                    isNull = true;
                    _position = i;
                    break;
                  }
                }
                if (isNull) {
                  setState(() {});
                  await Future.delayed(Duration(milliseconds: 200));
                  FocusScope.of(context)
                      .requestFocus(_listWordFocusNode[_position]);
                } else {
                  _position = _listWord.length;
                  setState(() {});
                  if (_listWord.length < 24) {
                    await Future.delayed(Duration(milliseconds: 200));
                    FocusScope.of(context).requestFocus(_focusNode);
                  }
                }
              }
            } else {
              await Future.delayed(Duration(milliseconds: 200));
              FocusScope.of(context).requestFocus(_listWordFocusNode[index]);
            }
          }, onTap: () {
            _position = index;
            setState(() {});
          })
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              _position = index;
              _listWord[index] = "";
              setState(() {});
              await Future.delayed(Duration(milliseconds: 300));
              FocusScope.of(context).requestFocus(_listWordFocusNode[index]);
            },
            child: Container(
              alignment: Alignment.center,
              //边框设置
              decoration: BoxDecoration(
                //背景
                color: Color(0XFF34D07F),
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: Text(
                _listWord[index],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().getSp(14),
                  height: 1.1,
                  color: Colors.white,
                ),
              ),
            ));
  }

  @override
  void initState() {
    _focusNode = FocusNode();
    _controller = TextEditingController();
    super.initState();
    // _controller?.text = "panda era wire address crumble wrestle cup olive then rhythm lock addict dune report label observe rather blame stand spider brick fantasy hint barely";
    // _listWord.add('jelly');
    // _listWord.add('flush');
    // _listWord.add('close');
    // _listWord.add('mobile');
    // _listWord.add('best');
    // _listWord.add('insane');
    // _listWord.add('own');
    // _listWord.add('ladder');
    // _listWord.add('shell');
    // _listWord.add('lake');
    // _listWord.add('coyote');
    // _listWord.add('gravity');
    // _listWord.add('divert');
    // _listWord.add('copy');
    // _listWord.add('planet');
    // _listWord.add('cabbage');
    // _listWord.add('scheme');
    // _listWord.add('antenna');
    // _listWord.add('immense');
    // _listWord.add('pill');
    // _listWord.add('giggle');
    // _listWord.add('student');
    // _listWord.add('misery');
    // _listWord.add('lady');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _baseLoadingDialog = BaseLoadingDialog(context);
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    int listSize = _listWord.length;
    return BaseTitle(
        title: S.of(context).import_wallet,
        resizeToAvoidBottomInset: true,
        centerTitle: true,
        goBackCallback: () {
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.of(context).pop();
        },
        rightLeading: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              var clipboardData =
                  await Clipboard.getData(Clipboard.kTextPlain); //获取粘贴板中的文本
              if (clipboardData != null) {
                print(clipboardData.text); //打印内容
                if (!Tools.isNull(clipboardData.text) &&
                    clipboardData.text.length > 80 &&
                    clipboardData.text.split(" ").length == 24) {
                  _listWord.clear();
                  _listWord.addAll(clipboardData.text.split(" "));
                  _position = 24;
                  if (_listWordFocusNode.length != 24) {
                    _listWordFocusNode.clear();
                    for (int i = 0; i < 24; i++) {
                      _listWordFocusNode.add(FocusNode());
                    }
                  }
                  setState(() {});
                } else {
                  Tools.showToast(context, S.of(context).mnemonic_ree);
                }
              } else {
                Tools.showToast(context, S.of(context).mnemonic_ree);
              }
            },
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  S.of(context).paste_all,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(12),
                      color: Color(0XFF8F8F8F)),
                ),
              ),
            ),
          )
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Text(
                S.of(context).import_wallet_hint(
                    _position < 24 ? _position + 1 : _position),
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(14.3),
                    color: Color(0XFFBABABA)),
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                  behavior: NoScrollBehavior(),
                  child: ListView(
                    children: [
                      GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        childAspectRatio: 2.5,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        mainAxisSpacing: 23,
                        shrinkWrap: true,
                        crossAxisSpacing: 11,
                        children: List.generate(
                            listSize < 24 ? listSize + 1 : listSize, (index) {
                          if (index < listSize) {
                            return _getInputItem(index);
                          } else {
                            return _getInputBox(_focusNode, _controller,
                                (value) async {
                              if (!Tools.isNull(value)) {
                                print("value====$value");
                                if (value.length > 80 &&
                                    value.split(" ").length == 24) {
                                  print("value====${value.split(" ")}");
                                  _listWord.clear();
                                  _listWord.addAll(value.split(" "));
                                  _position = 24;
                                  if (_listWordFocusNode.length != 24) {
                                    _listWordFocusNode.clear();
                                    for (int i = 0; i < 24; i++) {
                                      _listWordFocusNode.add(FocusNode());
                                    }
                                  }
                                  setState(() {});
                                } else {
                                  _listWord.add(value);
                                  _listWordFocusNode.add(FocusNode());
                                  _controller.text = "";
                                  _position = _listWord.length;
                                  setState(() {});
                                }
                              }
                              await Future.delayed(Duration(milliseconds: 300));
                              FocusScope.of(context).requestFocus(_focusNode);
                            });
                          }
                        }),
                      ),
                      Visibility(
                        visible: _listWord.length == 24,
                        child: BtnBgSolid(
                          btnStatus: true,
                          btnString: S.of(context).immediately_import,
                          key: btnKey,
                          btnCallback: () => _ok(),
                          paddingTop: 100,
                        ),
                      ),
                    ],
                  )),
            )
          ],
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  /// 确定方法回调
  _ok() async {
    // if (html.Worker.supported) {
    //   print('会支持了');
    //   var myWorker = new html.Worker("ww.dart.js");
    //   myWorker.onMessage.listen((event) {
    //     print("main:receive: ${event.data}");
    //   });
    //   myWorker.postMessage("Hello!!");
    // } else {
    //   print('Your browser doesn\'t support web workers.');
    // }
    // iso.ReceivePort receivePort = iso.ReceivePort();
    // iso.Isolate.spawn(workerMain, receivePort.sendPort);
    //
    // receivePort.listen((message) {
    //   print("host: ${message}");
    // });
    _baseLoadingDialog?.show(loadText: S.of(context).load_text);
    Uint8List uint8List = await compute(getAddressUint8List, getWord());
    _baseLoadingDialog?.hide();
    if (uint8List != null) {
      PinPawDialog(
              context: context,
              onOk: (paw) async {
                // print("===密码====$paw");
                _inputPawOK(paw, uint8List);
              },
              payPawBehavior:
                  SpUtil.getBool(SpUtilConstant.IS_PASSWORD, defValue: false)
                      ? PinPawBehavior.use
                      : PinPawBehavior.open)
          .show();
    } else {
      Tools.showToast(context, S.of(context).address_import_err);
    }
  }

  /// 输入密码 之后的方法
  _inputPawOK(String paw, Uint8List uint8List) async {
    _baseLoadingDialog?.show(loadText: S.of(context).load_text);
    CeloWallet celoWallet = await compute(
        syncFibonacci, CeloWallet("", "", paw: paw, uint8list: uint8List));
    if (Tools.isNull(celoWallet.address) ||
        Tools.isNull(celoWallet.walletJson)) {
      _baseLoadingDialog?.hide();
      Tools.showToast(context, S.of(context).address_import_err);
    } else {
      String address = celoWallet.address.toLowerCase();
      List<Map> list = await SqlManager.queryAddressData(address);
      User user = User.fromSaveSqlJson(
          address: address,
          map: {},
          privateKey: celoWallet.walletJson,
          isValora: 0);
      if (list == null || list.isEmpty) {
        int code = await SqlManager.addData(user.toSQLJson());
        _baseLoadingDialog?.hide();
        if (code > 0) {
          if (Tools.isNull(
                  SpUtil.getString(SpUtilConstant.PAW_ENCRYPTION_KEY)) ||
              Tools.isNull(SpUtil.getString(SpUtilConstant.PAW_ADDRESS_KEY))) {
            SpUtil.putString(
                SpUtilConstant.PAW_ENCRYPTION_KEY, celoWallet.walletJson);
            SpUtil.putString(
                SpUtilConstant.PAW_ADDRESS_KEY, celoWallet.address);
          }
          Navigator.of(context).pop(jsonEncode(user.toSQLJson()));
        } else {
          Tools.showToast(context, S.of(context).save_address_err_hint);
        }
      } else {
        _baseLoadingDialog?.hide();
        showUpdateAddressDialog(address, celoWallet.walletJson, user);
      }
    }
  }

  /// 显示更新地址 dialog
  showUpdateAddressDialog(String address, String privateKey, User user) {
    TextDialogBoard(
        context: context,
        content: Text(
          S.of(context).update_address_hint,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0XFF353535),
              fontSize: ScreenUtil.getInstance().getSp(12)),
        ),
        okClick: () async {
          int code = await SqlManager.updateMoreFieldData(
              address: address,
              keys: ["privateKey", "isValora"],
              values: [privateKey, 0]);
          if (code > 0) {
            if (Tools.isNull(
                    SpUtil.getString(SpUtilConstant.PAW_ENCRYPTION_KEY)) ||
                Tools.isNull(
                    SpUtil.getString(SpUtilConstant.PAW_ADDRESS_KEY))) {
              SpUtil.putString(SpUtilConstant.PAW_ENCRYPTION_KEY, privateKey);
              SpUtil.putString(SpUtilConstant.PAW_ADDRESS_KEY, address);
            }
            EventBusTools.getEventBus()?.fire("AddressManageUpdate");
            Navigator.of(context).pop();
          } else {
            Tools.showToast(context, S.of(context).save_address_err_hint);
          }
        }).show();
  }
}

// class ImportAddressState extends State<ImportAddress> {
//   /// 填写助记词数据
//   List<String> _listWord = List.empty(growable: true);
//   BaseLoadingDialog _baseLoadingDialog;
//
//   // 监听 输入下一个助记词
//   TextEditingController _controller;
//   FocusNode _focusNode;
//   ScrollController _scrollController;
//   int _position = 0;
//
//   @override
//   void initState() {
//     _focusNode = FocusNode();
//     _controller = TextEditingController();
//     _scrollController = ScrollController();
//     super.initState();
//     // _listWord.add('jelly');
//     // _listWord.add('flush');
//     // _listWord.add('close');
//     // _listWord.add('mobile');
//     // _listWord.add('best');
//     // _listWord.add('insane');
//     // _listWord.add('own');
//     // _listWord.add('ladder');
//     // _listWord.add('shell');
//     // _listWord.add('lake');
//     // _listWord.add('coyote');
//     // _listWord.add('gravity');
//     // _listWord.add('divert');
//     // _listWord.add('copy');
//     // _listWord.add('planet');
//     // _listWord.add('cabbage');
//     // _listWord.add('scheme');
//     // _listWord.add('antenna');
//     // _listWord.add('immense');
//     // _listWord.add('pill');
//     // _listWord.add('giggle');
//     // _listWord.add('student');
//     // _listWord.add('misery');
//     // _listWord.add('lady');
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _baseLoadingDialog = BaseLoadingDialog(context);
//       FocusScope.of(context).requestFocus(_focusNode);
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     _focusNode?.dispose();
//     _scrollController?.dispose();
//     _baseLoadingDialog = null;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     int listSize = _listWord.length;
//     double size69 = ScreenUtil.getInstance().getWidthPx(69);
//     return BaseTitle(
//         resizeToAvoidBottomInset: true,
//         title: S.of(context).import_wallet,
//         goBackCallback: () {
//           FocusScope.of(context).requestFocus(FocusNode());
//           Navigator.of(context).pop();
//         },
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: size69, right: 2),
//               child: TextField(
//                 controller: _controller,
//                 keyboardType: TextInputType.text,
//                 style: TextStyle(
//                   color: Color(0xFF48515B),
//                   fontSize: ScreenUtil.getInstance().getSp(14),
//                 ),
//                 cursorColor: Color(0xFF353535),
//                 autocorrect: true,
//                 textAlignVertical: TextAlignVertical.center,
//                 decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     hintStyle: TextStyle(
//                       color: Color(0xFFC1C6C9),
//                       fontSize: ScreenUtil.getInstance().getSp(14),
//                     ),
//                     contentPadding: EdgeInsets.all(0),
//                     hintText: S.of(context).input_mnemonic_word,
//                     counterText: "",
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Color(0xA6DEDEDE),
//                           width: ScreenUtil.getInstance().getWidthPx(1)),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Color(0xA6DEDEDE),
//                           width: ScreenUtil.getInstance().getWidthPx(1)),
//                     ),
//                     suffixIcon: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           width: 10,
//                         ),
//                         SizedBox(
//                             width: ScreenUtil.getInstance().getWidth(80),
//                             height: ScreenUtil.getInstance().getWidth(25),
//                             child: FlatButton(
//                               disabledTextColor: Color(0XFFFFFFFF),
//                               disabledColor: Color(0XFFA6A6A6),
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               //画圆角
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                     ScreenUtil.getInstance().getWidth(3)),
//                               ),
//                               onPressed: () {
//                                 if (!Tools.isNull(
//                                     _controller.text.toString())) {
//                                   if (_controller.text.toString().length > 80 &&
//                                       _controller.text
//                                               .toString()
//                                               .split(" ")
//                                               .length ==
//                                           24) {
//                                     _listWord.clear();
//                                     _listWord.addAll(
//                                         _controller.text.toString().split(" "));
//                                     _controller.text = "";
//                                     _position = 24;
//                                     FocusScope.of(context)
//                                         .requestFocus(FocusNode());
//                                   } else {
//                                     if (_position < _listWord.length) {
//                                       if (Tools.isNull(_listWord[_position])) {
//                                         _listWord[_position] =
//                                             _controller.text.toString();
//                                       } else {
//                                         _listWord
//                                             .add(_controller.text.toString());
//                                       }
//                                     } else {
//                                       if (_listWord.length < 24)
//                                         _listWord
//                                             .add(_controller.text.toString());
//                                     }
//                                     int positionB = -1;
//                                     for (int i = 0; i < _listWord.length; i++) {
//                                       if (Tools.isNull(_listWord[i])) {
//                                         positionB = i;
//                                         break;
//                                       }
//                                     }
//                                     if (positionB == -1) {
//                                       _position = _listWord.length;
//                                     } else
//                                       _position = positionB;
//                                     if (_position != _listWord.length) {
//                                       _controller.text = "";
//                                     } else {
//                                       _controller.text = "";
//                                       if (_listWord.length == 24)
//                                         FocusScope.of(context)
//                                             .requestFocus(FocusNode());
//                                     }
//                                   }
//                                   setState(() {});
//                                 }
//                               },
//                               child: Text(
//                                 S.of(context).confirm,
//                                 style: TextStyle(
//                                     fontSize:
//                                         ScreenUtil.getInstance().getSp(11),
//                                     height: 1),
//                               ),
//                               color: Color(0XFF35CF7E),
//                               textColor: Colors.white,
//                               height: 1,
//                               highlightColor: Colors.grey.withAlpha(80),
//                             )),
//                         SizedBox(
//                           width: 23,
//                         ),
//                       ],
//                     )),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: size69, top: 10, bottom: 10),
//               child: Text(
//                 S.of(context).import_wallet_hint(
//                     _position < 24 ? _position + 1 : _position),
//                 style: TextStyle(
//                     fontSize: ScreenUtil.getInstance().getSp(12),
//                     color: Color(0XFFBABABA)),
//               ),
//             ),
//             Expanded(
//               child: ScrollConfiguration(
//                   behavior: NoScrollBehavior(),
//                   child: ListView(
//                     controller: _scrollController,
//                     children: [
//                       GridView.count(
//                         physics: NeverScrollableScrollPhysics(),
//                         crossAxisCount: 4,
//                         childAspectRatio: 2.5,
//                         padding: EdgeInsets.symmetric(
//                             vertical: 12, horizontal: size69),
//                         mainAxisSpacing: 23,
//                         shrinkWrap: true,
//                         crossAxisSpacing: 11,
//                         children: List.generate(listSize, (index) {
//                           return _getInputItem(index);
//                         }),
//                       ),
//                       Visibility(
//                         visible: listSize == 24,
//                         child: BtnBgSolid(
//                           btnStatus: true,
//                           btnString: S.of(context).immediately_import,
//                           btnCallback: () => _ok(),
//                           paddingTop: 30,
//                         ),
//                       ),
//                     ],
//                   )),
//             ),
//           ],
//         ));
//   }
//

//
//   /// 获取助记词
//   String getWord() {
//     String word = "";
//     for (int i = 0; i < _listWord.length; i++) {
//       word += _listWord[i] + " ";
//     }
//     if (!Tools.isNull(word)) {
//       word = word.substring(0, word.length - 1);
//     }
//     return word;
//   }
//
//   /// 获取显示文字的item
//   Widget _getInputItem(int index) {
//     return GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: () async {
//           _position = index;
//           _listWord[index] = "";
//           setState(() {});
//         },
//         child: Container(
//           alignment: Alignment.center,
//           //边框设置
//           decoration: BoxDecoration(
//             //背景
//             color: Color(0XFF34D07F),
//             //设置四周圆角 角度
//             borderRadius: BorderRadius.all(Radius.circular(100)),
//           ),
//           child: Text(
//             _listWord[index],
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: ScreenUtil.getInstance().getSp(12),
//               height: 1.1,
//               color: Colors.white,
//             ),
//           ),
//         ));
//   }
// }

Future<CeloWallet> syncFibonacci(CeloWallet celoWallet) async {
  return await ImportWallet(celoWallet.uint8list, celoWallet.paw);
}

Uint8List getAddressUint8List(String word) {
  return getSeedByMnemonic(word);
}

// workerMain(sendPort) async {
//   for (var message in ["01", "02", "03"]) {
//     (sendPort as iso.SendPort).send(message);
//     await Future.delayed(Duration(seconds: 1));
//   }
// }
