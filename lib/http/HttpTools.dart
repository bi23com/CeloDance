import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/dialog/BaseLoadingDialog.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'dart:async';

import 'package:package_info/package_info.dart';

/// Describe: 网络请求工具类
/// Date: 3/26/21 4:12 PM
/// Path: http/HttpTools.dart
class HttpTools {
  /// global dio object
  static Dio dio;

  // 程序版本号
  static String _version = "";

  // Android 或者 ios
  static String _celodance_os = "";

  //设备标识id
  static String _devId = "";

  static int timestamp = 0;

  static const String API_PREFIX = 'https://celo.dance/api/';

  // static const String API_PREFIX = 'https://celo.dance/';
  static const int CONNECT_TIMEOUT = 30000;
  static const int RECEIVE_TIMEOUT = 30000;

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  /*
   *  jsonData 表单方式提交请求
   */
  static Future<Map<String, dynamic>> requestJSONSyncData(String url,
      {Map<String, dynamic> data, // 请求参数
      BuildContext context, // 用于显示dialog 弹窗
      String method = GET, // 请求方法是get 还是post 默认post
      bool isShowLoad = false, //显示加载进度框
      String loadText = "",
      HttpCallback httpCallback}) async {
    BaseLoadingDialog _baseLoadingDialog;
    bool isOK = false;
    if (isShowLoad && context != null) {
      Future.delayed(Duration(milliseconds: 1500), () {
        if (!isOK) {
          _baseLoadingDialog = BaseLoadingDialog(context);
          _baseLoadingDialog?.show(loadText: loadText);
        }
      });
    }
    data = data ?? <String, dynamic>{};
    // 获取公共参数
    await getPublicParameter();
    setHeaders();

    /// 打印请求相关信息：请求地址、请求方式、请求参数
    // print('请求地址：【' + API_PREFIX + url + '】');
    // print('请求头：' + createInstance().options.headers.toString());
    // print('请求参数：' + data.toString());
    try {
      Response response;
      if (method == GET) {
        response = await createInstance().get(
          url,
          queryParameters: data,
        );
      } else {
        response =
            await createInstance().post(url, data: FormData.fromMap(data));
      }
      isOK = true;
      if (context != null && isShowLoad) _baseLoadingDialog?.hide();
      // print('请求结果：' + response.toString());
      // LogUtil.v('请求结果：' + response.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = json.decode(response.toString());
        return responseJson;
      } else {
        if (context != null && isShowLoad) _baseLoadingDialog?.hide();
        return null;
      }
    } on DioError catch (e) {
      /// 打印请求失败相关信息
      print('请求出错：' + e.toString());
      if (context != null && isShowLoad) _baseLoadingDialog?.hide();
      return null;
    }
  }

  /*
   * 获取公共参数
   */
  static getPublicParameter() async {
    if (Tools.isNull(_version)) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
    }
    if (Tools.isNull(_devId)) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _devId = androidInfo.androidId.toString();
        _celodance_os = "android";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _devId = iosInfo.identifierForVendor.toString();
        _celodance_os = "ios";
      }
    }
  }

  // 获取版本号
  static String getVerName() {
    return _version;
  }

  // 获取版本号
  static setVerName(String version) {
    _version = version;
  }

  /// 设置请求头
  static setHeaders() {
    createInstance().options.headers = {
      "celodance-lan": SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE),
      "celodance-ver": "v$_version",
      "celodance-os": _celodance_os,
      "celodance-uuid": _devId,
      "celodance-timestamp": timestamp
    };
  }

  /// 创建 dio 实例对象
  static Dio createInstance() {
    if (dio == null) {
      /// 全局属性：请求前缀、连接超时时间、响应超时时间
      BaseOptions options = new BaseOptions(
        baseUrl: API_PREFIX,
        connectTimeout: CONNECT_TIMEOUT,
        receiveTimeout: RECEIVE_TIMEOUT,
        responseType: ResponseType.json,
        contentType: "application/json; charset=utf-8",
      );
      dio = new Dio(options);
    }
    return dio;
  }

  /// 清空 dio 对象
  static clear() {
    dio = null;
  }
}

/// Describe: 回调接口
/// Date: 3/26/21 4:11 PM
/// Path: http/HttpTools.dart
abstract class HttpCallback {
  void succeed(Map<String, dynamic> responseJson, int result, String message,
      String url);

  void failure(String url);
}
