import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Describe: 二维码展示
/// Date: 3/27/21 9:09 AM
/// Path: page/property/dialog/QrCodeDialog.dart
class QrCodeDialog {
  final BuildContext context;
  final String address;

  QrCodeDialog({@required this.context, this.address = ""});

  Future<bool> show() async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return QrCode(
          address: address,
        );
      },
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      // 设置背景颜色
      transitionDuration: Duration(milliseconds: 400),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          ScaleTransition(
        scale: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
        child: child,
      ),
    );
  }
}

class QrCode extends StatefulWidget {
  QrCode({Key key, this.address}) : super(key: key);
  final String address;

  @override
  _QrCodeState createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  GlobalKey _globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: ScreenUtil.getInstance().getWidth(200),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RepaintBoundary(
                            key: _globalKey,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              color: Colors.white,
                              child: QrImage(
                                data: widget.address ?? "1",
                                version: QrVersions.auto,
                                padding: EdgeInsets.zero,
                                size: ScreenUtil.getInstance().getWidth(150),
                              ),
                            )),
                        // Text(
                        //   widget.address ?? "1",
                        //   maxLines: 2,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: TextStyle(
                        //     fontSize: ScreenUtil.getInstance().getSp(14),
                        //     color: Color(0xFF48515B),
                        //   ),
                        // ),
                        SizedBox(
                          height: 5,
                        ),
                        FlatButton(
                          disabledTextColor: Color(0XFFFFFFFF),
                          disabledColor: Color(0XFFA6A6A6),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          minWidth: ScreenUtil.getInstance().getWidth(120),
                          height: ScreenUtil.getInstance().getWidth(35),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          //画圆角
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ScreenUtil.getInstance().getWidth(5)),
                          ),
                          onPressed: () async {
                            if (await Tools.requestStoragePermissions(context,
                                S.of(context).storage_permissions_hint)) {
                              Tools.screenshotsSave(_globalKey, context);
                            }
                            // Share.share(widget.address);
                          },
                          child: Text(
                            S.of(context).save_to_album,
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().getSp(12),
                                height: 1,
                                fontWeight: FontWeight.w600),
                          ),
                          color: Color(0XFF34D07F),
                          textColor: Color(0XFFFFFFFF),
                          highlightColor: Colors.green.withAlpha(80),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
    );
  }
}
