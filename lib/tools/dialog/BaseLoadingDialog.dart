import 'package:dpos/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../DialogRouter.dart';
import '../Tools.dart';
import 'BaseLoadAnimation.dart';

/// Describe: 网络请求加载弹窗
/// Date: 4/2/21 10:26 AM
/// Path: tools/dialog/BaseLoadingDialog.dart
class BaseLoadingDialog {
  BuildContext context;
  bool _isDestruction;

  BaseLoadingDialog(BuildContext context) {
    this.context = context;
  }

  void show({String loadText = ""}) {
    if (Tools.isNull(loadText)) loadText = S.of(context).load_text;
    _isDestruction = true;
    Navigator.of(context).push(DialogRouter(LoadingDialog(
      loadText: loadText, destruction: () {
      _isDestruction = false;
    },
    )));
  }

  void hide() {
    if (_isDestruction)
      Navigator.of(context).pop();
  }
}

class LoadingDialog extends Dialog {
  LoadingDialog({this.loadText = "", this.destruction}) : super();

  final String loadText;
  final Function destruction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        destruction?.call();
        Navigator.of(context).pop();
      },
      child: WillPopScope(
          child: Material(
            //创建透明层
              type: MaterialType.transparency, //透明类型
              child: Center(
                //保证控件居中效果
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Color(0x80000000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          BaseLoadAnimation(),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                            ),
                            child: Text(
                              loadText,
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          onWillPop: () async {
            destruction?.call();
            Navigator.of(context).pop();
            return Future.value(false);
          }),
    );
  }
}
