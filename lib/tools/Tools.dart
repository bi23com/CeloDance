import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ToastUtils.dart';
import 'dialog/TextDialog.dart';
import 'package:flutter/cupertino.dart';
import "package:intl/intl.dart";
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'entity/HearData.dart';

/// Describe: 工具类
/// Date: 3/22/21 10:44 AM
/// Path: tools/Tools.dart
class Tools {
  /// 分页数据大小
  static const int PAGE_SIZE = 20;
  static String VALORA_REQUEST_ID = "-1";

  /// 首页 价格 收益组 数据
  static RewardTypes rewardTypes;
  static AccountTypes accountTypes;
  static Prices prices;
  static String keyboardDone = "";

  /// 激活时间戳
  // static String activationTime = "";
  static int activationTime;

  //屏蔽四处：
  //
  // 1、发送
  //
  // 2、链接到Valora
  //
  // 3、锁定&投票
  //
  // 4、切换节点  false 隐藏 true 显示
  static bool isHint = false;

  /// 转出地址 临时变量
  static List<RecordEntity> recordList = List.empty(growable: true);

  /// 1 锁定  2 解锁  3 投票   4 撤票   5取回 等的 临时变量
  static List<RecordEntity> voteList = List.empty(growable: true);

  /*
   * 显示toast
   */
  static showToast(BuildContext context, String content) {
    if (!isNull(content)) {
      ToastUtils.toast(context,
          textSize: ScreenUtil.getInstance().getSp(12),
          msg: content,
          position: 'top',
          bgColor: Color(0XF2353535));
      // Fluttertoast.cancel();
      // Fluttertoast.showToast(
      //     msg: content,
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Color(0XFF353535),
      //     textColor: Colors.white,
      //     fontSize: ScreenUtil.getInstance().getSp(11.6));
    }
  }

  /*
   * 判断字符串是不是 空的 true 空的  fasle 不是空的
   */
  static bool isNull(String content) {
    return content == null ||
        content.length == 0 ||
        "null" == content.toLowerCase();
  }

  /*
   * 存储权限检测
   */
  static Future<bool> requestStoragePermissions(
      BuildContext context, String hint) async {
    //请求权限
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else {
        if (await Permission.storage.isPermanentlyDenied) {
          TextDialogBoard(
              context: context,
              confirm: S.of(context).setting,
              content: Text(
                hint,
                style: TextStyle(
                    color: Color(0XFF353535),
                    fontSize: ScreenUtil.getInstance().getSp(12)),
              ),
              okClick: () async {
                openAppSettings();
              }).show();
        }
        return false;
      }
    } else {
      var status = await Permission.storage.status;
      if (status == PermissionStatus.granted) {
        return true;
      }
      return false;
    }
  }

  /*
   * 进入系统设置
   */
  static void jumpToAppSettings() {
    try {
      openAppSettings();
    } catch (e) {}
  }

  // static bool contrastVer(String networkVer) {
  //   int compareSize = 0;
  //   try {
  //     List<String> networkVerList = networkVer.split('.');
  //     List<String> appVerList = HttpTools.getVerName().split('.');
  //     //从第一位开始比较，出现大于情况返回1，出现小于情况返回-1，后面的就不用再比较了，
  //     // 如果没有出现大于和小于的情况，那只剩下等于了，for循环走完，返回0
  //     for (int i = 0; i < appVerList.length; i++) {
  //       if (int.parse(appVerList[i]) > int.parse(networkVerList[i])) {
  //         compareSize = 1;
  //         break;
  //       } else if (int.parse(appVerList[i]) < int.parse(networkVerList[i])) {
  //         compareSize = -1;
  //         break;
  //       }
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  //   return compareSize == -1;
  // }

  // /// 格式化数字 以,分割
  // static String formattingNumComma(double num) {
  //   var formatComma = NumberFormat('#,##0.00');
  //   return formatComma.format(num);
  // }

  /// 正则验证电话号码
  static bool checkPhone(String mobile) {
    RegExp exp = RegExp(
        r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    bool matched = exp.hasMatch(mobile);
    return !matched;
  }

  ///手机号码中间4位用星号
  static String getEncryptPhone(String phone) {
    return phone.replaceRange(3, 7, "****");
  }

  /// 获取时间戳
  static int currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  ///格式化文件大小
  static String renderSize(double value) {
    if (null == value) {
      return "MB";
    }
    List<String> unitArr = []..add('B')..add('KB')..add('MB')..add('GB');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  /// 常用的button 按钮
  static Widget getBtn({Widget child, Function onPressed}) {
    return TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
              TextStyle(fontSize: ScreenUtil.getInstance().getSp(14))),
          shape: MaterialStateProperty.all(StadiumBorder()),
          //设置按钮的大小
          minimumSize: MaterialStateProperty.all(Size(200, 40)),
          //设置水波纹颜色
          overlayColor: MaterialStateProperty.all(Colors.yellow),
          //背景颜色
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            // if (states.contains(MaterialState.pressed)) {
            //   return Colors.blue[200];
            // }
            //默认不使用背景颜色
            return Colors.black;
          }),
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) {
              // if (states.contains(MaterialState.focused) &&
              //     !states.contains(MaterialState.pressed)) {
              //   //获取焦点时的颜色
              //   return Colors.blue;
              // } else if (states.contains(MaterialState.pressed)) {
              //   //按下时的颜色
              //   return Colors.deepPurple;
              // }
              //默认状态使用灰色
              return Colors.white;
            },
          ),
        ),
        child: child);
  }

  /// 格式化数字 以,分割
  static String formattingNumComma(num data) {
    var formatComma = NumberFormat('#,##0.00');
    // var formatComma = NumberFormat('#,##0.##');
    return formatComma.format(data);
  }

  /// 格式化数字 以,分割 保留8位小数
  static String formattingNumCommaEight(num data) {
    var formatComma = NumberFormat('#,##0.########');
    // var formatComma = NumberFormat('#,##0.##');
    return formatComma.format(data);
  }

  /// 格式化数字 以,分割 以k做结尾
  static String formattingNumCommaK(num data) {
    var formatComma = NumberFormat('#,##0');
    // var formatComma = NumberFormat('#,##0.##');
    return formatComma.format(data) + "K";
  }

  /// 密码规则匹配
  static bool isPass(String paw) {
    bool isPaw = false;
    if (getLength(paw, "0") > 3) {
      isPaw = false;
    } else if (getLength(paw, "1") > 3) {
      isPaw = false;
    } else if (getLength(paw, "2") > 3) {
      isPaw = false;
    } else if (getLength(paw, "3") > 3) {
      isPaw = false;
    } else if (getLength(paw, "4") > 3) {
      isPaw = false;
    } else if (getLength(paw, "5") > 3) {
      isPaw = false;
    } else if (getLength(paw, "6") > 3) {
      isPaw = false;
    } else if (getLength(paw, "7") > 3) {
      isPaw = false;
    } else if (getLength(paw, "8") > 3) {
      isPaw = false;
    } else if (getLength(paw, "9") > 3) {
      isPaw = false;
    } else if (paw.contains("0123")) {
      isPaw = false;
    } else if (paw.contains("1234")) {
      isPaw = false;
    } else if (paw.contains("2345")) {
      isPaw = false;
    } else if (paw.contains("3456")) {
      isPaw = false;
    } else if (paw.contains("4567")) {
      isPaw = false;
    } else if (paw.contains("5678")) {
      isPaw = false;
    } else if (paw.contains("6789")) {
      isPaw = false;
    } else if (paw.contains("7890")) {
      isPaw = false;
    } else if (paw.contains("0987")) {
      isPaw = false;
    } else if (paw.contains("9876")) {
      isPaw = false;
    } else if (paw.contains("8765")) {
      isPaw = false;
    } else if (paw.contains("7654")) {
      isPaw = false;
    } else if (paw.contains("6543")) {
      isPaw = false;
    } else if (paw.contains("5432")) {
      isPaw = false;
    } else if (paw.contains("4321")) {
      isPaw = false;
    } else if (paw.contains("3210")) {
      isPaw = false;
    } else {
      isPaw = true;
    }
    return isPaw;
  }

  static int getLength(String paw, String num) {
    int length = 0;
    for (int i = 0; i < paw.length; i++) {
      if (num == paw[i].toString()) {
        length++;
      }
    }
    return length;
  }

  /*
   * 相机权限检测
   */
  static Future<bool> requestCameraPermissions(
      BuildContext context, String hint) async {
    //请求权限
    if (Platform.isAndroid) {
      if (await Permission.camera.request().isGranted) {
        return true;
      } else {
        if (await Permission.storage.isPermanentlyDenied) {
          TextDialogBoard(
              context: context,
              confirm: S.of(context).setting,
              content: Text(
                hint,
                style: TextStyle(
                    color: Color(0XFF353535),
                    fontSize: ScreenUtil.getInstance().getSp(12)),
              ),
              okClick: () async {
                openAppSettings();
              }).show();
        }
        return false;
      }
    } else {
      var status = await Permission.camera.status;
      print("status===$status");
      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        return true;
      } else if (status == PermissionStatus.restricted) {
        TextDialogBoard(
            context: context,
            confirm: S.of(context).setting,
            content: Text(
              hint,
              style: TextStyle(
                  color: Color(0XFF353535),
                  fontSize: ScreenUtil.getInstance().getSp(12)),
            ),
            okClick: () async {
              openAppSettings();
            }).show();
        return false;
      } else
        return true;
    }
  }

  /// 截图 并保存到本地
  static void screenshotsSave(GlobalKey globalKey, BuildContext context) async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      var result = await ImageGallerySaver.saveImage(
          byteData.buffer.asUint8List(),
          quality: 100,
          name: currentTimeMillis().toString());
      print("保存结果===$result");
      if (result != null && result['isSuccess']) {
        showToast(context, S.of(context).save_success);
      } else {
        showToast(context, S.of(context).save_failed);
      }
    } catch (e) {
      print(e);
      showToast(context, S.of(context).save_failed);
    }
  }

  /// valora 授权
  static valoraAuthorization(BuildContext context) async {
    // celo://wallet/dappkit?type=account_address&requestId=1&callback=celodance://valora&dappName=CeloDance
    bool isAppInstalled = false;
    if (Platform.isAndroid) {
      isAppInstalled = await DeviceApps.isAppInstalled('co.clabs.valora');
    } else if (Platform.isIOS) {
      isAppInstalled = await canLaunch("celo://wallet/dappkit");
    }
    if (isAppInstalled) {
      //延时500毫秒执行
      Future.delayed(const Duration(milliseconds: 500), () async {
        Tools.VALORA_REQUEST_ID = Random().nextInt(1000).toString();
        await launch(
            "celo://wallet/dappkit?type=account_address&requestId=${Tools.VALORA_REQUEST_ID}&callback=celodance://valora&dappName=CeloDance");
      });
    } else {
      showValoraDialog(context);
    }
  }

  /// 显示
  static showValoraDialog(BuildContext context) {
    TextDialogBoard(
        context: context,
        content: Text(
          S.of(context).valora_no_installation,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(0XFF353535),
              fontSize: ScreenUtil.getInstance().getSp(12)),
        ),
        okClick: () async {
          await launch("https://valoraapp.com/");
          // if (Platform.isAndroid) {
          //   await launch(
          //       "https://play.google.com/store/apps/details?id=co.clabs.valora");
          // } else if (Platform.isIOS) {
          //   await launch(
          //       "https://apps.apple.com/hk/app/valora-celo-payments-app/id1520414263");
          // }
        }).show();
  }

  /// 折线图
  static Widget lineChart(
      {List<String> list,
      double maxY = 0,
      double minY = 0,
      double maxX = 1,
      List<LineChartBarData> lineChartBarDataList}) {
    num interval = (maxY - minY) / 4;
    if (maxY == minY) {
      maxY = 1;
      minY = 0;
    } else {
      maxY += interval;
      if (interval < minY) {
        minY -= interval;
      }
    }
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
          List<LineTooltipItem> lineTooltipList = List.empty(growable: true);
          for (int i = 0; i < touchedSpots.length; i++) {
            lineTooltipList.add(LineTooltipItem(
              // touchedSpots[i].y.toString(),
              Tools.formattingNumCommaEight(touchedSpots[i].y),
              TextStyle(
                  color: Color(0XFF2E3339),
                  fontSize: ScreenUtil.getInstance().getSp(10)),
            ));
          }
          return lineTooltipList;
        }), getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          List<TouchedSpotIndicatorData> lisra = List.empty(growable: true);
          for (int i = 0; i < spotIndexes.length; i++) {
            lisra.add(TouchedSpotIndicatorData(
                FlLine(
                  color: Color(0xffE9E9E9),
                  strokeWidth: 1,
                ),
                FlDotData(
                    show: true,
                    getDotPainter: (FlSpot flSpot, double q,
                        LineChartBarData lineChartBarData, int i) {
                      return FlDotCirclePainter(
                        color: Color(0xff34D07F),
                        radius: 4,
                        strokeColor: Color(0xff34D07F),
                        strokeWidth: 0,
                      );
                    })));
          }
          return lisra;
        }),
        borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Color(0XFFE9E9E9), width: 0.5),
              right: BorderSide(color: Color(0XFFE9E9E9), width: 0.5),
            )),
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 10,
            getTextStyles: (value) => TextStyle(
                color: Color(0xff28BD70),
                fontSize: ScreenUtil.getInstance().getSp(11)),
            getTitles: (value) {
              return list[value.toInt()] ?? "";
            },
            margin: 20,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            interval: interval > 0 ? interval : 1,
            getTextStyles: (value) => TextStyle(
              color: Color(0xffC1C6C9),
              fontSize: ScreenUtil.getInstance().getSp(10),
            ),
            getTitles: (value) {
              if (value >= 1000) {
                return Tools.formattingNumCommaK(value / 1000);
              }
              return Tools.formattingNumComma(value);
            },
            reservedSize: 30,
            margin: 8,
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: false,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Color(0xffE9E9E9),
              strokeWidth: 0.5,
            );
          },
        ),
        lineBarsData: lineChartBarDataList,
      ),
      swapAnimationDuration: Duration(milliseconds: 0),
    );
  }

  /// 折线图的线的数据
  static LineChartBarData lineChartLine(List<FlSpot> historyList) {
    return LineChartBarData(
      isCurved: true,
      colors: [Color(0XFF45C381)],
      barWidth: 1,
      isStrokeCapRound: false,
      dotData: FlDotData(
          show: true,
          // checkToShowDot: (FlSpot spot,
          //     LineChartBarData barData) {
          //   return true;
          // },
          getDotPainter: (FlSpot flSpot, double q,
              LineChartBarData lineChartBarData, int i) {
            return FlDotCirclePainter(
              color: Color(0xff34D07F),
              radius: 2,
              strokeColor: Color(0xff34D07F),
              strokeWidth: 0.5,
            );
          }),
      belowBarData: BarAreaData(
        show: true,
        gradientFrom: Offset(0.5, 0),
        gradientTo: Offset(0.5, 1),
        colors: [Color(0xffB3FDD7), Color(0xffFFFFFF)]
            .map((color) => color.withOpacity(0.65))
            .toList(),
      ),
      spots: historyList,
    );
  }

  /// 获取分割线
  static Widget getLine({double left = 0, double right = 0}) {
    return Container(
      margin: EdgeInsets.only(left: left, right: right),
      width: double.infinity,
      height: 0.5,
      color: Color(0XFFDEDEDE),
    );
  }

  /// 没有地址时 显示添加布局
  static Widget noAddressShowLayout({BuildContext context, Function function}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
          ),
          Image.asset(
            "assets/img/cd_home_add_logo.png",
            width: ScreenUtil.getInstance().getWidth(213),
            fit: BoxFit.fitWidth,
          ),
          SizedBox(
            width: 7,
          ),
          InkWell(
              onTap: () async {
                function?.call();
              },
              child: Container(
                  width: ScreenUtil.getInstance().getWidth(181),
                  height: ScreenUtil.getInstance().getWidth(40),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color(0XFF34D07F)),
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).home_add_title,
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(14),
                        color: Color(0XFFFFFFFF),
                        height: 1,
                        fontWeight: FontWeight.w600),
                  ))),
          SizedBox(
            height: 49,
          ),
        ],
      ),
    );
  }

  /// 有地址时 显示添加布局
  static Widget yesAddressShowLayout(
      {BuildContext context,
      Function function,
      Color bgColor = const Color(0XFFFAFAFA)}) {
    return InkWell(
      onTap: () {
        function?.call();
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          color: bgColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: ScreenUtil.getInstance().getWidth(241),
                  height: ScreenUtil.getInstance().getWidth(40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color(0XFF34D07F)),
                  child: Text(
                    S.of(context).home_add_title,
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(14),
                        color: Color(0XFFFFFFFF),
                        height: 1,
                        fontWeight: FontWeight.w600),
                  ))
            ],
          )),
    );
  }
}
