import 'package:dpos/page/address/AddressManage.dart';
import 'package:dpos/page/address/AddressSend.dart';
import 'package:dpos/page/address/ObserveAddress.dart';
import 'package:dpos/page/address/create/CreateAddress.dart';
import 'package:dpos/page/address/import/ImportAddress.dart';
import 'package:dpos/page/earnings/Earnings.dart';
import 'package:dpos/page/earnings/VoteList.dart';
import 'package:dpos/page/earnings/VoteRecord.dart';
import 'package:dpos/page/earnings/entity/VoteEntity.dart';
import 'package:dpos/page/guide/Guide.dart';
import 'package:dpos/page/home/Home.dart';
import 'package:dpos/page/my/view/SelectNode.dart';
import 'package:dpos/page/property/Property.dart';
import 'package:dpos/page/record/SendRecord.dart';
import 'package:dpos/page/record/SendRecordDetails.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/page/scan/QRCodePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 页面跳转公共类
/// Date: 2020/11/20 3:47 PM
class RouteTools {
  // 首页
  static const String HOME = "HOME";

  // 引导页
  static const String GUIDE_PAGE = "GUIDE_PAGE";

  /// 创建地址
  static const String CREATE_ADDRESS = "CREATE_ADDRESS";

  /// 导入地址
  static const String IMPORT_ADDRESS = "IMPORT_ADDRESS";

  /// 地址管理
  static const String ADDRESS_MANAGE = "ADDRESS_MANAGE";

  /// 收益界面
  static const String EARNINGS = "EARNINGS";

  /// 资产界面
  static const String PROPERTY = "PROPERTY";

  /// 观察地址
  static const String OBSERVE_ADDRESS = "OBSERVE_ADDRESS";

  /// 地址 发送数量界面
  static const String ADDRESS_SEND = "ADDRESS_SEND";

  ///二维码扫码
  static const String QR_CODE = "QR_CODE";

  /// 发送记录
  static const String SEND_RECORD = "SEND_RECORD";

  /// 发送记录详情
  static const String SEND_RECORD_DETAILS = "SEND_RECORD_DETAILS";

  /// 投票  撤票记录 详情
  static const String VOTE_LIST = "VOTE_LIST";

  /// 投票的历史记录
  static const String VOTE_RECORD = "VOTE_RECORD";

  /// 自定义节点
  static const String SELECT_NODE = "SELECT_NODE";

  /*
   * 用于跳转哪个页面的标签
   * 不传参数的
   */
  static void startActivity(
    BuildContext context,
    String tag, {
    CallbackContent callbackContent,
    String title = "",
    String address = "",
    String id = "",
    int type = -1,
    String webUrl = "",
    String walletJson = "",
    num number = 0,
    int isValora = 0,
    bool isBool = false,
    RecordEntity recordEntity,
    double orderMoney = 0.0,
    double couponMoney = 0.0,
    Map json,
    DetailsEnum detailsEnum = DetailsEnum.normal,
    List<VoteEntity> voteList,
  }) {
    switch (tag) {
      case HOME: // 首页
        _startActivityModel(
            context: context,
            page: Home(),
            isDestroy: false,
            callbackContent: callbackContent);
        break;
      case GUIDE_PAGE: // 引导页面
        _startActivityModel(
            context: context,
            page: Guide(),
            isDestroy: false,
            callbackContent: callbackContent);
        break;
      case CREATE_ADDRESS: // 创建页面
        _startActivityModel(
            context: context,
            page: CreateAddress(),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case IMPORT_ADDRESS: // 导入地址
        _startActivityModel(
            context: context,
            page: ImportAddress(),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case ADDRESS_MANAGE: // 地址管理
        _startActivityModel(
            context: context,
            page: AddressManage(),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case EARNINGS: // 收益界面
        _startActivityModel(
            context: context,
            page: Earnings(
              title: title,
              map: json,
              type: type,
            ),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case PROPERTY: // 资产界面
        _startActivityModel(
            context: context,
            page: Property(
              address: address,
            ),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case OBSERVE_ADDRESS: // 观察地址
        _startActivityModel(
            context: context,
            page: ObserveAddress(),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case ADDRESS_SEND: // 地址 发送页面
        _startActivityModel(
            context: context,
            page: AddressSend(
              address: address,
            ),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case QR_CODE: // 二维码扫描
        _startActivityModel(
            context: context,
            page: QRCodePage(),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case SEND_RECORD: // 发送记录
        _startActivityModel(
            context: context,
            page: SendRecord(
              address: address,
            ),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case SEND_RECORD_DETAILS: // 发送记录 详情
        _startActivityModel(
            context: context,
            page: SendRecordDetails(
              address: address,
              recordEntity: recordEntity,
              detailsEnum: detailsEnum,
              typeName: title,
            ),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case VOTE_LIST: // 投票  撤票记录
        _startActivityModel(
            context: context,
            page: VoteList(
                address: address,
                type: type,
                voteList: voteList,
                walletJson: walletJson,
                isValora: isValora,
                nonvoting: number),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case VOTE_RECORD: // 投票历史记录
        _startActivityModel(
            context: context,
            page: VoteRecord(
              address: address,
            ),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
      case SELECT_NODE: // 自定义节点
        _startActivityModel(
            context: context,
            page: SelectNode(),
            isDestroy: true,
            callbackContent: callbackContent);
        break;
    }
  }

  /*
   * @Description:
   * @param {isDestroy} 是否销毁这个页面之前的页面 false 销毁  true 不销毁
   */
  static void _startActivityModel(
      {BuildContext context,
      Widget page,
      bool isDestroy,
      CallbackContent callbackContent}) {
    if (context != null) {
      Navigator.of(context)
          .pushAndRemoveUntil(
              // AnimationPageRoute(
              CupertinoPageRoute(
                builder: (context) => page,
              ),
              (Route<dynamic> route) => isDestroy)
          .then((value) =>
              {callbackContent?.call(value == null ? "" : value.toString())});
    }
  }
}

typedef void CallbackContent(String content);
