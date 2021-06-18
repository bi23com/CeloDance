import 'dart:io';

import 'package:cool_ui/cool_ui.dart';
import 'package:dpos/tools/Content.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'generated/l10n.dart';
import 'http/HttpTools.dart';
import 'page/start/AppStart.dart';
import 'tools/CupertinoLocalizationsDelegate.dart';
import 'tools/MaxScaleTextWidget.dart';
import 'tools/SqlManager.dart';
import 'tools/Tools.dart';
import 'tools/Content.dart';

void main() async {
  LogUtil.init(isDebug: true, tag: "DPos");
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  // print("kIsWeb===$kIsWeb");
  if (kIsWeb) {
  } else {
    await SqlManager.init();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    HttpTools.setVerName(packageInfo.version);
    if (Tools.isNull(SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY))) {
      SpUtil.putString(
          SpUtilConstant.NODE_ADDRESS_KEY, "https://celo.dance/node");
    }
    NumKeyBoardState.register(); //注册键盘
  }
  runApp(KeyboardRootWidget(child: MyApp()));
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

ValueChanged<String> localeChange;

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // 是否是初始加载
  bool initialLoad = true;

  @override
  void initState() {
    super.initState();
    localeChange = (language) {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(context, width: 1080, height: 1920);
    // print(
    //     "==========main========build======${SpUtil.getString(SpUtilConstant.SET_LANGUAGE)}");
    return MaterialApp(
      builder: (ctx, w) {
        return MaxScaleTextWidget(
          max: 1.0,
          child: w,
        );
      },
      routes: <String, WidgetBuilder>{
        "AppStart": (BuildContext context) => AppStart(), // 启动页
      },
      localeResolutionCallback: (local, support) {
        ///support 当前软件支行的语言 也就是[supportedLocales] 中配制的语种
        print('==========main========support=1=  ${local.languageCode}');
        if (Tools.isNull(SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE))) {
          switch (local.languageCode) {
            case "en":
              SpUtil.putString(SpUtilConstant.CHOOSE_LANGUAGE, "en");
              SpUtil.putString(SpUtilConstant.CHOOSE_ASSETS, "USD");
              break;
            case "zh":
              SpUtil.putString(SpUtilConstant.CHOOSE_LANGUAGE, "zh");
              SpUtil.putString(SpUtilConstant.CHOOSE_ASSETS, "CNY");
              break;
            default:
              SpUtil.putString(SpUtilConstant.CHOOSE_LANGUAGE, "zh");
              SpUtil.putString(SpUtilConstant.CHOOSE_ASSETS, "CNY");
              break;
          }
        }

        ///如果当前软件运行的手机环境不在 [supportedLocales] 中配制的语种范围内
        ///返回一种默认的语言环境，这里使用的是中文
        return Locale(
            SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE, defValue: "zh"),
            '');
      },
      locale: Locale(
          SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE, defValue: "zh"), ''),
      localizationsDelegates: [
        S.delegate,
        RefreshLocalizations.delegate,
        CupertinoLocalizationsDelegate(),
        // 本地化的代理类fl
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: "AppStart",
    );
  }
}
