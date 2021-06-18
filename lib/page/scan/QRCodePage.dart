import 'dart:io';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:recognition_qrcode/recognition_qrcode.dart';

const flash_on = "FLASH ON";
const flash_off = "FLASH OFF";
const front_camera = "FRONT CAMERA";
const back_camera = "BACK CAMERA";

/// Describe: 扫一扫界面
/// Date: 3/25/21 11:57 AM
/// Path: pages/home/QRCodePage.dart
class QRCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return QRCodeState();
  }
}

class QRCodeState extends State<QRCodePage>
    with SingleTickerProviderStateMixin {
  var flashState = flash_off;
  var cameraState = front_camera;
  QRViewController _qrController;
  GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  AnimationController _animationController;
  Animation _animation;
  bool _isQRCodeView = false;

  //二维码框高度
  double sHeight = ScreenUtil.getInstance().getWidth(260);

  //线条y值
  int sy = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
    _animation =
        Tween(begin: 0.0, end: sHeight - 20).animate(_animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _animationController.forward();
            }
          });
    _animationController.forward();
    if (Platform.isAndroid) {
      _isQRCodeView = true;
    } else if (Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //延时500毫秒执行
        Future.delayed(Duration(milliseconds: 600), () {
          //延时执行的代码
          if (mounted)
            setState(() {
              _isQRCodeView = true;
            });
        });
      });
    }
  }

  @override
  void dispose() {
    _qrController?.dispose();
    _animationController?.dispose();
    _animation?.removeListener(() {});
    super.dispose();
  }

  //闪光灯
  _isFlashOn(String current) {
    return flash_on == current;
  }

  //二维码创建
  void _onQRViewCreated(QRViewController controller) {
    this._qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      _qrController?.pauseCamera();
      controller?.dispose();
      if (mounted) Navigator.of(context).pop(scanData.code);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size _screenSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Visibility(
              visible: _isQRCodeView,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlayMargin: EdgeInsets.only(top: 30),
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderLength: 15,
                  borderWidth: 4,
                  cutOutSize: sHeight,
                ),
              )),
          Positioned(
            left: (_screenSize.width - sHeight) / 2.0 + 10,
            right: (_screenSize.width - sHeight) / 2.0 + 10,
            top:
                (_screenSize.height - sHeight - kToolbarHeight / 3 + 30) / 2.0 +
                    _animation.value,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/img/cd_icon_scan_line.png'),
                      fit: BoxFit.fill)),
              height: 2,
              width: sHeight - 20,
            ),
          ),
          Positioned(
              top: (_screenSize.height - sHeight - kToolbarHeight / 3 + 20) /
                      2.0 +
                  sHeight,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: Text(
                  S.of(context).scan_hint,
                  style: TextStyle(
                      inherit: false,
                      color: Colors.white,
                      fontSize: ScreenUtil.getInstance().getSp(12)),
                ),
              )),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                alignment: Alignment.center,
                splashRadius: ScreenUtil.getInstance().getWidth(20),
                padding: EdgeInsets.all(3),
                icon: Icon(
                  Icons.arrow_back_ios_sharp,
                  color: Colors.black,
                  size: ScreenUtil.getInstance().getWidth(20),
                ),
                onPressed: () {
                  if (mounted) Navigator.pop(context);
                },
              ),
              title: Text(S.of(context).scan,
                  style: TextStyle(
                      color: Color(0XFF1A2636),
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil.getInstance().getSp(16))),
            ),
            body: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  top: (_screenSize.height - sHeight - kToolbarHeight) / 2.0 +
                      sHeight),
              child: Row(
                children: [
                  SizedBox(
                    width: (_screenSize.width - sHeight) / 2,
                  ),
                  GestureDetector(
                      child: Image.asset(
                        flashState != flash_off
                            ? "assets/img/cd_flashlight_yes_icon.png"
                            : "assets/img/cd_flashlight_no_icon.png",
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                      onTap: () {
                        if (_qrController != null) {
                          _qrController.toggleFlash();
                          if (_isFlashOn(flashState)) {
                            setState(() {
                              flashState = flash_off;
                            });
                          } else {
                            setState(() {
                              flashState = flash_on;
                            });
                          }
                        }
                      }),
                  Expanded(child: SizedBox()),
                  GestureDetector(
                      child: Image.asset(
                        "assets/img/cd_album_icon.png",
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                      onTap: () async {
                        File pickedFile = await ImagePicker.pickImage(
                            source: ImageSource.gallery);
                        if (pickedFile != null) {
                          Map map = await RecognitionQrcode.recognition(
                              pickedFile.path);
                          if (map != null) {
                            _qrController?.pauseCamera();
                            if (mounted)
                              Navigator.of(context).pop(map['value']);
                          }
                        }

                        // setState(() {
                        //   if (pickedFile != null) {
                        //     _image = File();
                        //   } else {
                        //     print('No image selected.');
                        //   }
                        // });
                      }),
                  SizedBox(
                    width: (_screenSize.width - sHeight) / 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrController?.pauseCamera();
    } else if (Platform.isIOS) {
      _qrController?.resumeCamera();
    }
  }
}
