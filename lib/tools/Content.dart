import 'package:cool_ui/cool_ui.dart';
import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'NoScrollBehavior.dart';
import 'Tools.dart';

class Content extends StatelessWidget {
  KeyboardController controller; //用于控制键盘输出的Controller

  @override
  Widget build(BuildContext context) {
    Tools.keyboardDone = S.of(context).done;
    return KeyboardMediaQuery(//用于键盘弹出的时候页面可以滚动到输入框的位置
        child: Builder(builder: (ctx) {
      return BaseTitle(
        body: ListView(
          children: [
            TextField(
              maxLength: 100,
              // controller: _numController,
              keyboardType: NumberKeyboard.inputType,
              // focusNode: _numFocusNode,
              // keyboardType: TextInputType.number,
              inputFormatters: [
                //只允许输入小数
                FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
              ],
              style: TextStyle(
                color: Color(0xFF48515B),
                fontSize: ScreenUtil.getInstance().getSp(16),
              ),
              cursorColor: Color(0xFF353535),
              autocorrect: true,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                // filled: true,
                helperText: "0 CELO",
                helperStyle: TextStyle(
                  color: Color(0xFF9B9EA2),
                  fontSize: ScreenUtil.getInstance().getSp(11),
                ),
                border: OutlineInputBorder(),
                hintStyle: TextStyle(
                  color: Color(0xFFC1C6C9),
                  fontSize: ScreenUtil.getInstance().getSp(12),
                ),
                contentPadding: EdgeInsets.all(0),
                hintText: S.of(context).input_num_hint,
                counterText: "",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xA6DEDEDE),
                      width: ScreenUtil.getInstance().getWidthPx(1)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF48515B),
                      width: ScreenUtil.getInstance().getWidthPx(1)),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "CELO",
                              style: TextStyle(
                                  color: Color(0XFF363F4D),
                                  fontSize: ScreenUtil.getInstance().getSp(11)),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              "assets/img/cd_send_arrows_down_icon.png",
                              width: 14,
                              height: 14,
                            ),
                          ],
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: ScreenUtil.getInstance().getWidth(58),
                        height: 20,
                        child: FlatButton(
                          disabledTextColor: Color(0XFFFFFFFF),
                          disabledColor: Color(0XFFA6A6A6),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          //画圆角
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          onPressed: () {},
                          child: Text(
                            S.of(context).all,
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().getSp(11),
                                height: 1),
                          ),
                          color: Color(0XFFECECEC),
                          textColor: Color(0XFF363F4D),
                          highlightColor: Colors.grey.withAlpha(80),
                        )),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ); //返回当前页面
    }));
  }
}

class NumKeyBoard extends StatefulWidget {
  NumKeyBoard({Key key, @required this.controller}) : super(key: key);
  final KeyboardController controller; //用于控制键盘输出的Controller

  @override
  NumKeyBoardState createState() => NumKeyBoardState();
}

class NumKeyBoardState extends State<NumKeyBoard> {
  static const CKTextInputType inputType =
      const CKTextInputType(name: 'CKNumberKeyboard'); //定义InputType类型
  static double getHeight(BuildContext ctx) {
    //编写获取高度的方法
    return 250 + MediaQuery.of(ctx).padding.bottom;
    // return size44 * 4 + size5 * 5 + MediaQuery.of(ctx).padding.bottom;
  }

  static register() {
    //注册键盘的方法
    CoolKeyboard.addKeyboard(
        NumKeyBoardState.inputType,
        KeyboardConfig(
            builder: (context, controller, params) {
              // 可通过CKTextInputType传参数到键盘内部
              return NumKeyBoard(
                controller: controller,
              );
            },
            getHeight: NumKeyBoardState.getHeight));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: getHeight(context),
        minHeight: getHeight(context),
      ),
      child: ScrollConfiguration(
          behavior: NoScrollBehavior(),
          child: ListView(
            reverse: true,
            padding: EdgeInsets.only(bottom: 0),
            children: [
              Container(
                color: Colors.white,
                width: double.infinity,
                height: MediaQuery.of(context).padding.bottom,
              ),
              Container(
                color: Color(0XD4F7F7F7),
                padding: EdgeInsets.only(top: 5, right: 5, bottom: 1),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("1")),
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("2")),
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("3")),
                                _spacingHorizontal(),
                              ],
                            ),
                            _spacingVertical(),
                            Row(
                              children: [
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("4")),
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("5")),
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("6")),
                                _spacingHorizontal(),
                              ],
                            ),
                            _spacingVertical(),
                            Row(
                              children: [
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("7")),
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("8")),
                                _spacingHorizontal(),
                                Expanded(child: _keyboardItem("9")),
                                _spacingHorizontal(),
                              ],
                            ),
                            _spacingVertical(),
                            Row(
                              children: [
                                _spacingHorizontal(),
                                Expanded(flex: 2, child: _keyboardItem("0")),
                                _spacingHorizontal(),
                                Expanded(flex: 1, child: _keyboardItem(".")),
                                _spacingHorizontal(),
                              ],
                            ),
                            _spacingVertical(),
                          ],
                        )),
                    Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _keyboardItem("删除"),
                            SizedBox(
                              height: 4,
                            ),
                            _keyboardDone(
                                Tools.keyboardDone ?? "Done", context),
                            _spacingVertical(),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  _spacingHorizontal() {
    return SizedBox(
      width: 5,
    );
  }

  _spacingVertical() {
    return SizedBox(
      height: 2,
    );
  }

  _keyboardDone(String data, BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      color: Color(0XFF34D07F),
      minWidth: double.infinity,
      height: 144,
      highlightColor: Color(0XFF34D07F).withAlpha(50),
      disabledColor: Colors.white,
      child: Text(
        data,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      onPressed: () {
        // Navigator.of(context).pop();
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  /// 常规按钮 item
  _keyboardItem(String data) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      color: Colors.white,
      minWidth: double.infinity,
      height: 44,
      highlightColor: Color(0XFFF3F2F3),
      disabledColor: Colors.white,
      child: data == "删除"
          ? Icon(
              Icons.backspace,
              size: 24,
              color: Color(0xff333333),
            )
          : Text(
              data,
              style: TextStyle(color: Color(0XFF1A2636), fontSize: 20),
            ),
      onPressed: () {
        print("data====$data");
        if ("删除" == data) {
          widget.controller?.deleteOne();
        } else {
          // 正常输入键
          if (data == "." && widget.controller.text.contains(".")) {
          } else {
            widget.controller?.addText(data);
          }
        }
      },
    );
  }
}
// class NumKeyBoard extends StatelessWidget {
//
//
//   NumKeyBoard({this.controller});
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     //键盘的具体内容
//
//     // return Container(
//     //     height: getHeight(context),
//     //     child: Column(
//     //       mainAxisSize: MainAxisSize.min,
//     //       children: [
//     //         Container(
//     //           color: Color(0XA1DEDEDE),
//     //           padding: EdgeInsets.only(bottom: 1, top: 1),
//     //           child: ScrollConfiguration(
//     //               behavior: NoScrollBehavior(),
//     //               child: GridView.count(
//     //                 crossAxisSpacing: 1,
//     //                 padding: EdgeInsets.zero,
//     //                 mainAxisSpacing: 1,
//     //                 crossAxisCount: 3,
//     //                 childAspectRatio: 2.3,
//     //                 shrinkWrap: true,
//     //                 physics: NeverScrollableScrollPhysics(),
//     //                 children: List.generate(moneyBtn.length, (index) {
//     //                   String data = moneyBtn[index];
//     //                   return FlatButton(
//     //                     padding: EdgeInsets.all(0),
//     //                     color: Colors.white,
//     //                     highlightColor: Color(0XFFF3F2F3),
//     //                     disabledColor: Colors.white,
//     //                     child: data == "删除"
//     //                         ? Icon(
//     //                             Icons.backspace,
//     //                             size: 24,
//     //                             color: Color(0xff333333),
//     //                           )
//     //                         : Text(
//     //                             data,
//     //                             style: TextStyle(
//     //                                 color: Color(0XFF1A2636), fontSize: 20),
//     //                           ),
//     //                     onPressed: () {
//     //                       print("data====$data");
//     //                       if ("删除" == data) {
//     //                         controller?.deleteOne();
//     //                       } else {
//     //                         // 正常输入键
//     //                         if (data == "." && controller.text.contains(".")) {
//     //                         } else {
//     //                           controller?.addText(data);
//     //                         }
//     //                       }
//     //                     },
//     //                   );
//     //                 }),
//     //               )),
//     //         ),
//     //       ],
//     //     ));
//   }
//
//
// }
