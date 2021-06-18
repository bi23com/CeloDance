import 'dart:async';
import 'dart:convert';
import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/AppInterface.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/page/address/dialog/AddAddressDialog.dart';
import 'package:dpos/page/address/dialog/AddressRenameDialog.dart';
import 'package:dpos/page/address/entity/SendHomeEntity.dart';
import 'package:dpos/page/earnings/entity/VoteEntity.dart';
import 'package:dpos/page/my/My.dart';
import 'package:dpos/page/my/dialog/AssetDialog.dart';
import 'package:dpos/page/my/dialog/ChooseNodeDialog.dart';
import 'package:dpos/page/my/dialog/LanguageDialog.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/ComputeTools.dart';
import 'package:dpos/tools/DialogRouter.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/ValoraTool.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/dialog/APPUpgradeDialog.dart';
import 'package:dpos/tools/dialog/BaseLoadingDialog.dart';
import 'package:dpos/tools/dialog/TextDialog.dart';
import 'package:dpos/tools/entity/HearData.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:dpos/tools/view/RefreshHeadIdle.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

/// Describe: 首页
/// Date: 3/22/21 11:23 AM
/// Path: page/home/Home.dart
bool _isRequest = true;

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
  DateTime lastPopTime;
  StreamSubscription _homeStreamSubscription;
  BaseLoadingDialog _homeLoadingDialog;

  /// app 升级弹窗
  APPUpgradeDialog _appUpgradeDialog;

  ///滚动偏移量
  bool _isShowTitle = false;
  ScrollController _scrollController;

  // 刷新的方法
  RefreshController _refreshCon = RefreshController(initialRefresh: false);

  // 总资产的数量
  double _allMoney = 0;

  String _unit = "";

  // 昨日收益
  double _yesterdayNum = 0;

  // 累计收益
  double _grandTotalNum = 0;

  // 列表数据
  List<User> _listMap = List.empty(growable: true);

  // 是否隐藏数据
  bool _isShowNum = true;
  static num celoPrices = 0;
  static num cusdPrices = 0;
  static num ceurPrices = 0;

  // 计算距离
  double size5 = 5;
  double size8 = 8;
  double size12 = 12;
  double size14 = 14;
  double size16 = 16;
  double size23 = 23;
  double size26 = 26;
  double size140 = ScreenUtil.getInstance().getWidth(140) -
      ScreenUtil.getInstance().appBarHeight +
      ScreenUtil.getInstance().statusBarHeight;

  double spSize11 = 11;
  double spSize10 = 10;
  double spSize22 = 22;
  double spSize24 = 24;

  @override
  void initState() {
    // TODO: implement initState
    size5 = ScreenUtil.getInstance().getWidth(5);
    size8 = ScreenUtil.getInstance().getWidth(8);
    size12 = ScreenUtil.getInstance().getWidth(12);
    size14 = ScreenUtil.getInstance().getWidth(14);
    size16 = ScreenUtil.getInstance().getWidth(16);
    size23 = ScreenUtil.getInstance().getWidth(23);
    size26 = ScreenUtil.getInstance().getWidth(26);
    spSize11 = ScreenUtil.getInstance().getSp(11);
    spSize10 = ScreenUtil.getInstance().getSp(10);
    spSize22 = ScreenUtil.getInstance().getSp(22);
    spSize24 = ScreenUtil.getInstance().getSp(24);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // print("===offset=======${_scrollController.offset}====$size140");
      if (mounted) {
        if (_scrollController.offset > size140) {
          if (!_isShowTitle) {
            _isShowTitle = true;
            if (mounted) setState(() {});
          }
        } else {
          if (_isShowTitle) {
            _isShowTitle = false;
            if (mounted) setState(() {});
          }
        }
      }
    });
    _isShowNum = SpUtil.getBool(SpUtilConstant.IS_SHOW_NUM, defValue: true);
    if (!Tools.isNull(SpUtil.getString(SpUtilConstant.HEART_REWARD_DATA))) {
      Tools.rewardTypes = RewardTypes.fromJson(
          jsonDecode(SpUtil.getString(SpUtilConstant.HEART_REWARD_DATA)));
    }
    if (!Tools.isNull(SpUtil.getString(SpUtilConstant.HEART_ACCOUNT_DATA))) {
      Tools.accountTypes = AccountTypes.fromJson(
          jsonDecode(SpUtil.getString(SpUtilConstant.HEART_ACCOUNT_DATA)));
    }
    if (!Tools.isNull(SpUtil.getString(SpUtilConstant.HEART_PRICES_DATA))) {
      Tools.prices = Prices.fromJson(
          jsonDecode(SpUtil.getString(SpUtilConstant.HEART_PRICES_DATA)));
    }
    _setCoinPrices();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _homeStreamSubscription?.cancel();
    _scrollController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // print("--" + state.toString());
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        _isRequest = true;
        Future.delayed(Duration(seconds: 5), () {
          //延时执行的代码
          if (_isRequest && mounted) heartbeatPacketsRequest();
        });
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        _isRequest = false;
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: [
            Container(
              color: Color(0XFFFAFAFA),
              child: Column(
                children: [
                  Image.asset(
                    "assets/img/cd_refresh_home_bg.png",
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  Image.asset(
                    "assets/img/cd_refresh_home_bg.png",
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  )
                ],
              ),
            ),
            // Container(
            //   color: Color(0XFFFAFAFA),
            //   margin:
            //       EdgeInsets.only(top: ScreenUtil.getInstance().getWidth(200)),
            // ),
            BaseTitle(
              backgroundColor: Colors.transparent,
              isShowAppBar: false,
              // listSize == 0 ? Colors.white : Color(0XFFFAFAFA), Color(0XFF34D07F)
              leftDrawer: My(onItemClick: (String name) async {
                if (name == S.of(context).address_administration) {
                  // 地址管理
                  RouteTools.startActivity(context, RouteTools.ADDRESS_MANAGE);
                } else if (name == S.of(context).asset_administration) {
                  // 资产管理
                  AssetDialog(
                      context: context,
                      update: () {
                        _setCoinPrices();
                        updateData();
                      }).show();
                } else if (name == S.of(context).language_choice) {
                  // 语言设置
                  LanguageDialog(context: context).show();
                } else if (name == S.of(context).node_selection) {
                  // 选择节点
                  RouteTools.startActivity(context, RouteTools.SELECT_NODE);
                } else if (name == S.of(context).privacy_policy) {
                  // 隐私政策
                  await launch("https://celo.dance/Privacypolicy.html");
                }
              }),
              body: Builder(builder: (BuildContext buildContext) {
                return ScrollConfiguration(
                    behavior: NoScrollBehavior(),
                    child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: false,
                        header: RefreshHeadIdle(
                          accomplishTextColor: Colors.white,
                        ),
                        controller: _refreshCon,
                        onRefresh: _onRefresh,
                        // header: Tools.createRefreshHeader(),
                        // footer: Tools.createRefreshFooter(),
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: ClampingScrollPhysics(),
                          slivers: <Widget>[
                            SliverAppBar(
                                backgroundColor: Color(0XFF34D07F),
                                title: Visibility(
                                  visible: _isShowTitle,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        S.of(context).total_assets_title,
                                        style: TextStyle(
                                            fontSize: ScreenUtil.getInstance()
                                                .getSp(14),
                                            fontWeight: FontWeight.w600,
                                            height: 1,
                                            color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _isShowNum ? "≈ " : "",
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil.getInstance()
                                                        .getSp(12),
                                                color: Colors.white),
                                          ),
                                          Text(
                                            _isShowNum
                                                ? "$_unit ${Tools.formattingNumComma(_allMoney)}"
                                                : "******",
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil.getInstance()
                                                        .getSp(16),
                                                height: 1,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                centerTitle: true,
                                elevation: 0,
                                leading: InkWell(
                                    onTap: () {
                                      Scaffold.of(buildContext).openDrawer();
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: Image.asset(
                                        "assets/img/cd_home_my_icon.png",
                                        fit: BoxFit.fitWidth,
                                      ),
                                    )),
                                pinned: true,
                                primary: true,
                                expandedHeight:
                                    ScreenUtil.getInstance().getWidth(200),
                                //必须设定,否则无法显示
                                flexibleSpace: FlexibleSpaceBar(
                                  // collapseMode: CollapseMode.none,
                                  titlePadding: EdgeInsets.zero,
                                  // stretchModes: [StretchMode.fadeTitle],
                                  // centerTitle: true,
                                  title: Visibility(
                                      visible: !_isShowTitle,
                                      child: _setHomeTopLayout()),
                                  background: Image.asset(
                                    "assets/img/cd_home_top_bg.png",
                                    height:
                                        ScreenUtil.getInstance().getWidth(200),
                                    fit: BoxFit.fitHeight,
                                  ),
                                  //   background: Container(
                                  //     decoration: BoxDecoration(
                                  //       gradient: LinearGradient(
                                  //         begin: Alignment.bottomLeft,
                                  //         end: Alignment.topRight,
                                  //         colors: [
                                  //           Color(0xff34D07F),
                                  //           Color(0XFF26BB6E),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                )),
                            SliverToBoxAdapter(
                                child: Visibility(
                              visible: _listMap.length == 0,
                              child: Container(
                                color: Colors.white,
                                width: double.infinity,
                                // height: ScreenUtil.getInstance().screenHeight -
                                //     ScreenUtil.getInstance().getWidth(200),
                                padding: EdgeInsets.only(top: 52),
                                child: Column(
                                  children: [
                                    Tools.noAddressShowLayout(
                                        context: context,
                                        function: () {
                                          _showAddAddressDialog();
                                        })
                                  ],
                                ),
                              ),
                            )),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (content, index) {
                                if (index < _listMap.length) {
                                  return _getHomeItem(_listMap[index]);
                                }
                                return Tools.yesAddressShowLayout(
                                    context: context,
                                    function: () {
                                      _showAddAddressDialog();
                                    });
                              },
                                  childCount: _listMap.length == 0
                                      ? _listMap.length
                                      : _listMap.length + 1),
                            ),
                            SliverFillRemaining(
                                hasScrollBody: false,
                                fillOverscroll: true,
                                child: Container(
                                  color: _listMap.length > 0
                                      ? Color(0XFFFAFAFA)
                                      : Colors.white,
                                )),
                          ],
                        )));
              }),
            )
          ],
        ),
        onWillPop: () async {
          if (lastPopTime == null ||
              DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
            lastPopTime = DateTime.now();
            Tools.showToast(context, S.of(context).exit_app_hint);
          } else {
            lastPopTime = DateTime.now();
            // 退出app
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
          return Future.value(false);
        });
  }

/*
   * 下拉刷新用到的方法
   */
  Future<void> _onRefresh() async {
    await _homeRequest();
  }

  /// 主页面请求
  _homeRequest() async {
    List<Map> _listData = await SqlManager.queryData();
    if (_listData.isNotEmpty) {
      String address = "";
      for (int i = 0; i < _listData.length; i++) {
        address += _listData[i]['address'] + ",";
      }
      address = address.substring(0, address.length - 1);
      _analysisHomeData(
          await HttpTools.requestJSONSyncData(
            AppInterface.SUMMARY_INTERFACE,
            data: {"addresses": address},
            context: context,
          ),
          true);
    } else {
      _listMap.clear();
      _yesterdayNum = 0;
      _grandTotalNum = 0;
      _allMoney = 0;
      setState(() {});
      if (mounted) _refreshCon?.refreshCompleted();
    }
  }

  /// 解析首页 数据
  _analysisHomeData(Map<String, dynamic> json, bool isUpdateTimestamp) async {
    try {
      if (json != null && mounted && json['code'] == 1) {
        Map<String, dynamic> result = json['result'];
        if (isUpdateTimestamp) HttpTools.timestamp = result['timestamp'];
        Map listD = result['list'];
        _listMap.clear();
        // 总收益
        _allMoney = 0;
        // 昨日收益
        _yesterdayNum = 0;
        // 累计收益
        _grandTotalNum = 0;
        List<Map> _listData = await SqlManager.queryData();
        for (int i = 0; i < _listData.length; i++) {
          String address = _listData[i]['address'];
          Map map = listD[address.toLowerCase()];
          if (map != null && map.isNotEmpty) {
            User user = User.fromHomeJson(map);
            // print("==earningsName====${_listData[i]['earningsName']}");
            _allMoney += user.allMoney;
            _grandTotalNum += user.totalNum;
            _yesterdayNum += user.lastNum;
            user.earningsName = Tools.isNull(user.earningsName)
                ? _listData[i]['earningsName'] ?? ""
                : user.earningsName;
            SqlManager.updateMoreFieldData(address: address, keys: [
              "celo",
              "celoAvailable",
              "celoLocked",
              "celoPending",
              "cusd",
              "ceur",
              "rewards",
              "type",
              "earningsName",
              "earningsLogo",
              "celoNonvoting"
            ], values: [
              user?.celo?.toString() ?? "0",
              user?.celoAvailable?.toString() ?? "0",
              user?.celoLocked?.toString() ?? "0",
              user?.celoPending?.toString() ?? "0",
              user?.cusd?.toString() ?? "0",
              user?.ceur?.toString() ?? "0",
              jsonEncode(map['rewards']),
              user.type ?? 0,
              user.earningsName,
              user.earningsLogo ?? "",
              user?.celoNonvoting?.toString() ?? "0",
            ]);
            user.address = address;
            user.name = _listData[i]['name'] ?? "";
            _listMap.add(user);
          }
        }
        // print("==_listMap===$_listMap");
        if (mounted) setState(() {});
      }
    } catch (e) {
      print("解析异常==$e");
    }

    if (mounted) _refreshCon?.refreshCompleted();
  }

  /// item 布局
  Widget _getHomeItem(User user) {
    List _earnings = user.rewardsList ?? List.empty(growable: true);
    int size = _earnings.length;
    String address = user.address;
    int addressLength = address.length;
    // String name = "";
    // if (user.type == 1 || user.type == 2) {
    //   name = user.earningsName;
    // } else {
    //   name = user.name;
    // }
    return InkWell(
        onTap: () async {
          RouteTools.startActivity(context, RouteTools.PROPERTY,
              address: address);
        },
        child: Container(
          color: Color(0XFFFAFAFA),
          child: Container(
            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: size16,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: size8,
                    ),
                    Image.asset(
                      "assets/img/cd_home_item_icon.png",
                      width: size23,
                      height: size23,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(
                      width: size8,
                    ),
                    Expanded(
                        child: Text(
                      addressLength > 11
                          ? (address.substring(0, 5) +
                              "......" +
                              address.substring(
                                  addressLength - 5, addressLength))
                          : address,
                      style: TextStyle(
                          color: Color(0xFF48515B),
                          fontWeight: FontWeight.w600,
                          fontSize: spSize11),
                    )),
                    Text(
                      user.earningsName ?? "",
                      style: TextStyle(
                          color: Color(0xFFA1A1A1),
                          fontWeight: FontWeight.w400,
                          height: 1,
                          fontSize: ScreenUtil.getInstance().getSp(12)),
                    ),
                    SizedBox(
                      width: size12,
                    ),
                  ],
                ),
                SizedBox(
                  height: size16,
                ),
                Text(
                  S.of(context).balance,
                  style: TextStyle(
                      color: Color(0xFFA1A1A1),
                      fontSize: ScreenUtil.getInstance().getSp(12)),
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isShowNum ? "≈ " : "",
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().getSp(18),
                          color: Color(0xFF48515B)),
                    ),
                    Text(
                      _isShowNum
                          ? "$_unit ${Tools.formattingNumComma(user.allMoney)}"
                          : "******",
                      style: TextStyle(
                          color: Color(0xFF48515B),
                          fontWeight: FontWeight.w600,
                          fontSize: spSize22),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      "assets/img/cd_home_right_arrow.png",
                      width: ScreenUtil.getInstance().getWidth(6),
                      height: ScreenUtil.getInstance().getWidth(10),
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
                SizedBox(
                  height: size23,
                ),
                Visibility(
                    visible: size > 0,
                    child: Container(
                      height: 0.5,
                      color: Color(0XFFEFEFEF),
                    )),
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return earningsItem(_earnings[index], index, user);
                  },
                  itemCount: size,
                  separatorBuilder: (BuildContext context, int index) =>
                      Container(
                    height: 0.5,
                    color: Color(0XFFEFEFEF),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  /// 收益的布局
  Widget earningsItem(Map map, int index, User homeMap) {
    map['address'] = homeMap.address;
    String imgName = "";
    String title = "";
    String titleTip = "";
    String titleUrl = "";
    String unitImg = ""; // 单位
    String unitString = ""; // 单位
    String earnings = "";
    String yield = "";
    String language =
        SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE, defValue: "zh");
    num last = map['last'] ?? 0;
    switch (map['type'] ?? 0) {
      case 1:
        imgName = "cd_home_earnings_icon";
        yield =
            "${S.of(context).apr}:${Tools.formattingNumComma(num.parse(map["apr"]?.toString() ?? "0"))}%";
        // title = S.of(context).earnings_vote;
        // titleTwo = S.of(context).earnings_vote_two;
        unitImg = "cd_celo_unit_icon";
        if (language == "zh") {
          unitString = Tools.rewardTypes?.vote_zh?.coinName ?? "";
          title = Tools.rewardTypes?.vote_zh?.title ?? "";
          titleTip = Tools.rewardTypes?.vote_zh?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.vote_zh?.tipUrl ?? "";
        } else if (language == "en") {
          unitString = Tools.rewardTypes?.vote_en?.coinName ?? "";
          title = Tools.rewardTypes?.vote_en?.title ?? "";
          titleTip = Tools.rewardTypes?.vote_en?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.vote_en?.tipUrl ?? "";
        }
        earnings = (last > 0 ? "+ " : "") + Tools.formattingNumComma(last);
        map['celo'] = homeMap.celo;
        map['celoLocked'] = homeMap.celoLocked;
        map['celoPending'] = homeMap.celoPending;
        map['celoAvailable'] = homeMap.celoAvailable;
        map['celoNonvoting'] = homeMap.celoNonvoting;
        map['unitString'] = unitString;
        map['earningsName'] = homeMap.earningsName ?? "";
        break;
      case 2:
        imgName = "cd_home_hold_icon";
        // title = S.of(context).earnings_valora;
        // titleTwo = S.of(context).earnings_valora_two;
        unitImg = "cd_celo_unit_icon";
        yield = "";
        if (language == "zh") {
          unitString = Tools.rewardTypes?.holdCUSD_zh?.coinName ?? "";
          title = Tools.rewardTypes?.holdCUSD_zh?.title ?? "";
          titleTip = Tools.rewardTypes?.holdCUSD_zh?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.holdCUSD_zh?.tipUrl ?? "";
        } else if (language == "en") {
          unitString = Tools.rewardTypes?.holdCUSD_en?.coinName ?? "";
          title = Tools.rewardTypes?.holdCUSD_en?.title ?? "";
          titleTip = Tools.rewardTypes?.holdCUSD_en?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.holdCUSD_en?.tipUrl ?? "";
        }
        earnings = (last > 0 ? "+ " : "") + Tools.formattingNumComma(last);
        break;
      case 3:
        imgName = "cd_home_group_icon";
        // title = S.of(context).earnings_group;
        // titleTwo = S.of(context).earnings_group_two;
        unitImg = "cd_cusd_unit_icon";
        yield = "";
        if (language == "zh") {
          unitString = Tools.rewardTypes?.verifyGroup_zh?.coinName ?? "";
          title = Tools.rewardTypes?.verifyGroup_zh?.title ?? "";
          titleTip = Tools.rewardTypes?.verifyGroup_zh?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.verifyGroup_zh?.tipUrl ?? "";
        } else if (language == "en") {
          unitString = Tools.rewardTypes?.verifyGroup_en?.coinName ?? "";
          title = Tools.rewardTypes?.verifyGroup_en?.title ?? "";
          titleTip = Tools.rewardTypes?.verifyGroup_en?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.verifyGroup_en?.tipUrl ?? "";
        }
        earnings = (last > 0 ? "+ " : "") + Tools.formattingNumComma(last);
        break;
      case 4:
        imgName = "cd_home_person_icon";
        // title = S.of(context).earnings_person;
        // titleTwo = S.of(context).earnings_person_two;
        unitImg = "cd_cusd_unit_icon";
        yield = "";
        if (language == "zh") {
          unitString = Tools.rewardTypes?.verifyPerson_zh?.coinName ?? "";
          title = Tools.rewardTypes?.verifyPerson_zh?.title ?? "";
          titleTip = Tools.rewardTypes?.verifyPerson_zh?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.verifyPerson_zh?.tipUrl ?? "";
        } else if (language == "en") {
          unitString = Tools.rewardTypes?.verifyPerson_en?.coinName ?? "";
          title = Tools.rewardTypes?.verifyPerson_en?.title ?? "";
          titleTip = Tools.rewardTypes?.verifyPerson_en?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.verifyPerson_en?.tipUrl ?? "";
        }
        earnings = (last > 0 ? "+ " : "") + Tools.formattingNumComma(last);
        break;
      case 5:
        imgName = "cd_home_unknown_icon";
        // title = S.of(context).earnings_note;
        // titleTwo = S.of(context).earnings_note_two;
        unitImg = "cd_cusd_unit_icon";
        if (language == "zh") {
          unitString = Tools.rewardTypes?.note_zh?.coinName ?? "";
          title = Tools.rewardTypes?.note_zh?.title ?? "";
          titleTip = Tools.rewardTypes?.note_zh?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.note_zh?.tipUrl ?? "";
        } else if (language == "en") {
          unitString = Tools.rewardTypes?.note_en?.coinName ?? "";
          title = Tools.rewardTypes?.note_en?.title ?? "";
          titleTip = Tools.rewardTypes?.note_en?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.note_en?.tipUrl ?? "";
        }
        earnings = (last > 0 ? "+ " : "") + Tools.formattingNumComma(last);
        yield = "";
        break;
      case 6:
        imgName = "cd_home_punishment_icon";
        // title = S.of(context).earnings_report;
        // titleTwo = S.of(context).earnings_report_two;
        unitImg = "cd_celo_unit_icon";
        yield = "";
        if (language == "zh") {
          unitString = Tools.rewardTypes?.inform_zh?.coinName ?? "";
          title = Tools.rewardTypes?.inform_zh?.title ?? "";
          titleTip = Tools.rewardTypes?.inform_zh?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.inform_zh?.tipUrl ?? "";
        } else if (language == "en") {
          unitString = Tools.rewardTypes?.inform_en?.coinName ?? "";
          title = Tools.rewardTypes?.inform_en?.title ?? "";
          titleTip = Tools.rewardTypes?.inform_en?.tipTitle ?? "";
          titleUrl = Tools.rewardTypes?.inform_en?.tipUrl ?? "";
        }
        earnings = (last > 0 ? "+ " : "") + Tools.formattingNumComma(last);
        break;
      default:
        imgName = "cd_home_punishment_icon";
        title = S.of(context).unknown_earnings;
        titleTip = "";
        titleUrl = "";
        unitImg = "";
        earnings = "";
        yield = "";
    }
    map['unitImg'] = unitImg;
    map['unitString'] = unitString;
    map['titleTip'] = titleTip;
    map['titleUrl'] = titleUrl;
    map['earningsName'] = homeMap.earningsName ?? "";
    map['earningsLogo'] = homeMap.earningsLogo ?? "";
    // print("homeMap.earningsLogo =====${homeMap.earningsLogo }");
    return InkWell(
        onTap: () async {
          RouteTools.startActivity(context, RouteTools.EARNINGS,
              json: map, title: title, type: map['type'] ?? 0);
          // Tools.showToast(context, "哈哈哈哈哈哈");
        },
        // child: Row(
        //   children: [],
        // ),
        child: Container(
            height: ScreenUtil.getInstance().getWidth(50),
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: size8),
            child: Row(
              children: [
                Image.asset(
                  "assets/img/$imgName.png",
                  width: ScreenUtil.getInstance().getWidth(26),
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  width: size8,
                ),
                Expanded(
                    child: Row(
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: Color(0xFFA1A1A1),
                          fontWeight: FontWeight.w400,
                          height: 1,
                          fontSize: ScreenUtil.getInstance().getSp(12),
                        )),
                    Visibility(
                        visible: !Tools.isNull(yield),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                          margin: EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                              color: Color(0x1AF7B500),
                              borderRadius: BorderRadius.circular(2)),
                          child: Text(
                            yield,
                            style: TextStyle(
                              color: Color(0xFFF7B500),
                              height: 1,
                              fontSize: ScreenUtil.getInstance().getSp(10),
                            ),
                          ),
                        ))
                  ],
                )),
                Text(_isShowNum ? earnings : "***",
                    style: TextStyle(
                      color: Color(0xFF48515B),
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil.getInstance().getSp(12),
                    )),
                SizedBox(
                  width: 4,
                ),
                Visibility(
                    visible: !Tools.isNull(unitImg),
                    child: Image.asset(
                      "assets/img/$unitImg.png",
                      width: ScreenUtil.getInstance().getWidth(12),
                      fit: BoxFit.fitWidth,
                    )),
                SizedBox(
                  width: 8,
                ),
                Image.asset(
                  "assets/img/cd_home_right_arrow.png",
                  width: ScreenUtil.getInstance().getWidth(6),
                  height: ScreenUtil.getInstance().getWidth(10),
                  fit: BoxFit.fill,
                ),
              ],
            )));
  }

  /// 显示dialog  用于valora 的 投票操作延时
  BaseLoadingDialog _getHomeDialog() {
    if (_homeLoadingDialog == null) {
      _homeLoadingDialog = BaseLoadingDialog(context);
    }
    return _homeLoadingDialog;
  }

  /// 初始化数据
  _initData() async {
    _homeLoadingDialog = BaseLoadingDialog(context);
    _getCurrentBlock();
    // LogUtil.v(
    //     "onUpgrade===${await SqlManager.queryData(name: SqlManager.RECORD)}");
    MethodChannel("com.winner.celodance/nativeToFlutter")
        .setMethodCallHandler((call) async {
      try {
        // print("call====$call");
        switch (call.method) {
          case "SCHEME_DATA": // 处理scheme 数据
            String arguments = call.arguments;
            print("arguments====$arguments");
            // celodance://valora?type=account_address&status=200&
            // requestId=8888&account=0x23fa394138c261f997585f78f0f94be1f88065ad&phoneNumber=%2B8618710857233
            if (!Tools.isNull(arguments)) {
              List<String> list = arguments.split("?");
              if (list.length == 2) {
                String _type = "";
                String _status = "";
                String _requestId = "";
                String _rawTxs = "";
                String _account = "";
                List<String> parameterList = list[1].split("&");
                for (int i = 0; i < parameterList.length; i++) {
                  String _itemString = parameterList[i];
                  if (!Tools.isNull(_itemString)) {
                    List<String> _item = _itemString.split("=");
                    if (_item.length == 2) {
                      switch (_item[0]) {
                        case "type":
                          _type = _item[1]?.toString() ?? "";
                          break;
                        case "status":
                          _status = _item[1]?.toString() ?? "";
                          break;
                        case "requestId":
                          _requestId = _item[1]?.toString() ?? "";
                          break;
                        case "account":
                          _account = _item[1]?.toString() ?? "";
                          break;
                        case "rawTxs":
                          _rawTxs = _item[1]?.toString() ?? "";
                          break;
                      }
                    }
                  }
                }
                if (("account_address" == _type || "200" == _status) &&
                    !Tools.isNull(_account)) {
                  // Tools.VALORA_REQUEST_ID == _requestId) {
                  Tools.VALORA_REQUEST_ID = "-1";
                  if (isValidAddress(_account)) {
                    List<Map> list =
                        await SqlManager.queryAddressData(_account);
                    if (list == null || list.isEmpty) {
                      User user = User.fromSaveSqlJson(
                          address: _account.toLowerCase(),
                          map: {},
                          privateKey: "",
                          isValora: 1);
                      int code = await SqlManager.addData(user.toSQLJson());
                      if (code > 0) {
                        EventBusTools.getEventBus()
                            ?.fire("AddressManageUpdate");
                        await updateData();
                        _homeRequest();
                      } else {
                        Tools.showToast(
                            context, S.of(context).save_address_err_hint);
                      }
                    } else {
                      Map map = list[0];
                      if (Tools.isNull(map['privateKey']) &&
                          (map['isValora'] ?? 0) == 0) {
                        showUpdateAddressDialog(_account.toLowerCase());
                      } else {
                        Tools.showToast(
                            context, S.of(context).save_address_err_one);
                      }
                    }
                  } else {
                    Tools.showToast(context, S.of(context).import_celo_address);
                  }
                } else if ("sign_tx" == _type || "200" == _status) {
                  // print("_rawTxs=====$_rawTxs");
                  if (_requestId.startsWith("C*E*L*O-")) {
                    List requestIdList = _requestId.split("-");
                    if (requestIdList.length == 3) {
                      EventBusTools.getEventBus()?.fire(RecordEntity(
                          name: "goToVoteDetails", time: requestIdList[1]));
                      await updateCELOVoteSQLData(
                          respond: await sendRawTransaction(_rawTxs),
                          timeM: requestIdList[1],
                          address: requestIdList[2]);
                    }
                  } else {
                    EventBusTools.getEventBus()
                        ?.fire(RecordEntity(name: "exitAddressSend"));
                    await updateSQLData(
                        respond: await sendRawTransaction(_rawTxs),
                        timeM: _requestId);
                  }
                }
              }
            }
            break;
          default:
            break;
        }
      } catch (e) {
        print("home==$e");
      }
      return null;
    });
    _homeStreamSubscription = EventBusTools.getEventBus()
        ?.on<SendHomeEntity>()
        ?.listen((event) async {
      print("home========${event.name}");
      switch (event.name) {
        case "rename": // 更改名称
          await updateData();
          break;
        case "localRefresh": // 刷新本地数据
          await updateData();
          await _homeRequest();
          break;
        case "sendData": // 查询交易结果
          await updateSQLData(
              respond: await compute(sendAddress, event), timeM: event.timeM);
          break;
        case "voteData": // 投票结果查询
          print("respond.data==开始==${event.type}");

          /// 属性 1 锁定  2 解锁  3 投票   4 撤票   5取回 6 激活
          switch (event.type) {
            case 1:
              if (event.isValora == 0) {
                await updateCELOVoteSQLData(
                    respond: await compute(lockResult, event),
                    timeM: event.timeM,
                    address: event.address);
              } else {
                _getHomeDialog().show(loadText: S.of(context).load_text);
                await lockByValora(event.count, event.address,
                    requestId: "C*E*L*O-${event.timeM}-${event.address}");
                _homeLoadingDialog?.hide();
              }
              break;
            case 2:
              if (event.isValora == 0) {
                await updateCELOVoteSQLData(
                    respond: await compute(unlockResult, event),
                    timeM: event.timeM,
                    address: event.address);
              } else {
                _getHomeDialog().show(loadText: S.of(context).load_text);
                await unlockByValora(event.count, event.address,
                    requestId: "C*E*L*O-${event.timeM}-${event.address}");
                _homeLoadingDialog?.hide();
              }
              break;
            case 3:
              if (event.isValora == 0) {
                await updateCELOVoteSQLData(
                    respond: await compute(voteResult, event),
                    timeM: event.timeM,
                    address: event.address);
              } else {
                _getHomeDialog().show(loadText: S.of(context).load_text);
                await voteByValora(event.count, event.toAddress, event.address,
                    requestId: "C*E*L*O-${event.timeM}-${event.address}");
                _homeLoadingDialog?.hide();
              }
              break;
            case 4: //  4 撤票
              if (event.tip == "pending") {
                print("home===撤票=====pending");
                if (event.isValora == 0) {
                  await updateCELOVoteSQLData(
                      respond: await compute(revokePendingResult, event),
                      timeM: event.timeM,
                      address: event.address);
                } else {
                  _getHomeDialog().show(loadText: S.of(context).load_text);
                  await revokePendingByValora(
                      event.count, event.toAddress, event.address,
                      requestId: "C*E*L*O-${event.timeM}-${event.address}");
                  _homeLoadingDialog?.hide();
                }
              } else if (event.tip == "active") {
                print("home===撤票=====active");
                if (event.isValora == 0) {
                  await updateCELOVoteSQLData(
                      respond: await compute(revokeActiveResult, event),
                      timeM: event.timeM,
                      address: event.address);
                } else {
                  _getHomeDialog().show(loadText: S.of(context).load_text);
                  await revokeActiveByValora(
                      event.count, event.toAddress, event.address,
                      requestId: "C*E*L*O-${event.timeM}-${event.address}");
                  _homeLoadingDialog?.hide();
                }
              }
              break;
            case 5:
              if (event.isValora == 0) {
                await updateCELOVoteSQLData(
                    respond: await compute(withdrawResult, event),
                    timeM: event.timeM,
                    address: event.address);
              } else {
                _getHomeDialog().show(loadText: S.of(context).load_text);
                await withdrawByValora(event.index, event.address,
                    requestId: "C*E*L*O-${event.timeM}-${event.address}");
                _homeLoadingDialog?.hide();
              }
              break;
            case 6: // 激活
              if (event.isValora == 0) {
                updateCELOVoteSQLData(
                    respond: await compute(activateResult, event),
                    timeM: event.timeM,
                    address: event.address);
              } else {
                _getHomeDialog().show(loadText: S.of(context).load_text);
                await activateByValora(event.toAddress, event.address,
                    requestId: "C*E*L*O-${event.timeM}-${event.address}");
                _homeLoadingDialog?.hide();
              }
              // Respond respond = await getVotedList(event.address);
              // if (mounted) {
              //   if (respond.code == 0) {
              //     List list = respond.data['voted'];
              //     if (list != null) {
              //       list.forEach((element) {
              //         VoteEntity voteEntity = VoteEntity.formJson(element);
              //         if (voteEntity.pendingIsActivatable) {
              //           int timeM = Tools.currentTimeMillis();
              //           var stime = DateTime.fromMillisecondsSinceEpoch(timeM);
              //           RecordEntity recordEntity = RecordEntity(
              //               rollOutAddress: event.address,
              //               count: voteEntity.pending,
              //               coinName: "CELO",
              //               type: 6,
              //               tag: "vote",
              //               time:
              //                   stime.toLocal().toString().split(".")[0] ?? "",
              //               timeStamp: timeM.toString(),
              //               state: 0);
              //           Tools.voteList.add(recordEntity);
              //           compute(activateResult, event).then((value) {
              //             updateCELOVoteSQLData(
              //                 respond: value,
              //                 timeM: value.timeM,
              //                 address: value.address);
              //           });
              //         }
              //       });
              //     }
              //   }
              // }
              break;
          }

          break;
      }
    });
    MethodChannel("com.winner.celodance/flutterToNative")
        .invokeMethod("inHome");
    await updateData();
    await heartbeatPacketsRequest();
    await _homeRequest();
  }

  /// 获取当前轮询区块
  _getCurrentBlock() {
    compute(
            getNowEpochfirstBlocNumResult,
            SendHomeEntity(
                apiUrl: SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY)))
        .then((value) {
      if (value.code == 0) {
        // print("value.data===${value.data}");
        try {
          num difference = value.data['end'] - value.data['start'];
          // DateTime fiftyDaysFromNow = DateTime.fromMillisecondsSinceEpoch(
          //     );
          // String time = fiftyDaysFromNow.toLocal().toString().split(".")[0];
          // Tools.activationTime = time.substring(5, time.length - 3);
          Tools.activationTime = Tools.currentTimeMillis() + difference * 5000;
          // print("value.1===${Tools.activationTime}");
        } catch (e) {
          print(e);
        }
      } else {
        Future.delayed(Duration(seconds: 5), () {
          //延时执行的代码
          if (mounted) _getCurrentBlock();
        });
      }
    });
  }

  /// 币 投票 更新值
  updateCELOVoteSQLData({Respond respond, String timeM, String address}) async {
    // print("respond.data===${respond.data}");
    // print("respond.code===${respond.code}");
    // print("respond.msg===${respond.msg}");
    if (respond.code == 0) {
      for (int i = 0; i < Tools.voteList.length; i++) {
        if (Tools.voteList[i].timeStamp == timeM) {
          Tools.voteList[i].state = 0;
          Tools.voteList[i].txHash = respond.data;
          break;
        }
      }
      EventBusTools.getEventBus()
          ?.fire(RecordEntity(name: "updateVoteDetails", time: timeM));
      Respond result = await getTransactionReceipt(respond.data);
      // print("result.data===${result.data}");
      // print("result.code===${result.code}");
      // print("result.msg===${result.msg}");
      if (result.code == 0) {
        if (result.data.status) {
          Respond coinData = await getAccountInfo(address);
          // print("coinData.data===${coinData.data}");
          // print("coinData.code===${coinData.code}");
          // print("coinData.msg===${coinData.msg}");
          if (coinData.code == 0) {
            Map map = coinData.data;
            if (map != null) {
              List<Map> list = await SqlManager.queryAddressData(address,
                  name: SqlManager.USER);
              if (list != null && list.isNotEmpty) {
                // var retData = {
                //   "lockedNum": lockedNum,  锁定
                //   "nonvotingLockedNum": nonvotingLockedNum, 空闲锁定 没有投票的
                //   "pendingNum": pendingNum, 待取回
                //   "pendingDetails": pendingList, 待取回列表
                //   "unlockedNum": unlockedNum  可用余额
                // };
                try {
                  num celoAvailable =
                      num.parse(map['unlockedNum']?.toString() ?? "0");
                  num celoLocked =
                      num.parse(map['lockedNum']?.toString() ?? "0");
                  num celoNonvoting =
                      num.parse(map['nonvotingLockedNum']?.toString() ?? "0");
                  num celoPending =
                      num.parse(map['pendingNum']?.toString() ?? "0");
                  await SqlManager.updateMoreFieldData(address: address, keys: [
                    "celo",
                    "celoAvailable",
                    "celoLocked",
                    "celoNonvoting",
                    "celoPending"
                  ], values: [
                    (celoAvailable + celoLocked + celoNonvoting + celoPending)
                        .toString(),
                    celoAvailable.toString(),
                    celoLocked.toString(),
                    celoNonvoting.toString(),
                    celoPending.toString(),
                  ]);
                  //ceur
                  await updateData();
                  for (int i = 0; i < Tools.voteList.length; i++) {
                    if (Tools.voteList[i].timeStamp == timeM) {
                      Tools.voteList[i].state = 1;
                      break;
                    }
                  }
                  EventBusTools.getEventBus()
                      ?.fire(RecordEntity(name: "updateProperty"));
                } catch (e) {
                  print("解析===$e");
                }
              }
            } else {
              for (int i = 0; i < Tools.voteList.length; i++) {
                if (Tools.voteList[i].timeStamp == timeM) {
                  Tools.voteList[i].state = 2;
                  break;
                }
              }
            }
            EventBusTools.getEventBus()
                ?.fire(RecordEntity(name: "updateVoteDetails", time: timeM));
          } else {
            Tools.showToast(context, coinData.msg);
          }
        } else {
          for (int i = 0; i < Tools.voteList.length; i++) {
            if (Tools.voteList[i].timeStamp == timeM) {
              Tools.voteList[i].state = 2;
              break;
            }
          }
          EventBusTools.getEventBus()
              ?.fire(RecordEntity(name: "updateVoteDetails", time: timeM));
        }
      }
    } else if (respond.code == -1) {
      for (int i = 0; i < Tools.voteList.length; i++) {
        if (Tools.voteList[i].timeStamp == timeM) {
          Tools.voteList[i].state = 2;
          break;
        }
      }
      EventBusTools.getEventBus()
          ?.fire(RecordEntity(name: "updateVoteDetails", time: timeM));
      if (respond.msg?.contains(
              "insufficient funds for gas * price + value + gatewayFee") ??
          false) {
        if (mounted) {
          Tools.showToast(
              context, S.of(context).poundage_insufficient_cusd_hint);
        }
      }
    } else if (respond.code == -99) {
      if (mounted) Tools.showValoraDialog(context);
    }
  }

  /// 更新存储币的值
  updateSQLData({Respond respond, String timeM}) async {
    // print("交易结果1===${respond.code}");
    // print("交易结果2===${respond.msg}");
    // print("交易结果3===${respond.data}");
    if (respond.code == 0) {
      for (int i = 0; i < Tools.recordList.length; i++) {
        if (Tools.recordList[i].timeStamp == timeM) {
          Tools.recordList[i].state = 0;
          Tools.recordList[i].txHash = respond.data;
          break;
        }
      }
      getInfoByHash((Respond respond) async {
        // print("===查询结果=1==${respond.code}");
        // print("===查询结果=2==${respond.msg}");
        // print("===查询结果=3==${respond.data}");
        if (respond.code == 0) {
          Map map = respond.data;
          if (map != null && map['state']) {
            String address = map['from'];
            List<Map> list = await SqlManager.queryAddressData(map['from'],
                name: SqlManager.USER);
            if (list != null && list.isNotEmpty) {
              try {
                num celo_bl = num.parse(map['celo_bl']?.toString() ?? "0");
                num cusd_bl = num.parse(map['cusd_bl']?.toString() ?? "0");
                num ceur_bl = num.parse(map['ceur_bl']?.toString() ?? "0");
                User user = User.fromSQLHomeJson(list[0]);
                //         "celo_bl": celoBlRet.data,
                // "cusd_bl": cusdBlRet.data,
                // "ceur_bl": ceurBlRet.data,
                // "from": from.toString(),
                // "state": value.data.status
                await SqlManager.updateMoreFieldData(address: address, keys: [
                  "celo",
                  "celoAvailable",
                  "cusd",
                  "ceur"
                ], values: [
                  celo_bl + user.celoPending + user.celoLocked,
                  celo_bl,
                  cusd_bl,
                  ceur_bl
                ]);
                //ceur
                updateData();
                for (int i = 0; i < Tools.recordList.length; i++) {
                  if (Tools.recordList[i].timeStamp == timeM) {
                    Tools.recordList[i].state = 1;
                    break;
                  }
                }
                EventBusTools.getEventBus()
                    ?.fire(RecordEntity(name: "updateProperty"));
              } catch (e) {
                print("解析===$e");
              }
            }
          } else {
            for (int i = 0; i < Tools.recordList.length; i++) {
              if (Tools.recordList[i].timeStamp == timeM) {
                Tools.recordList[i].state = 2;
                break;
              }
            }
          }
          EventBusTools.getEventBus()
              ?.fire(RecordEntity(name: "updateSendRecord", time: timeM));
          EventBusTools.getEventBus()?.fire(RecordEntity(
              name: "updateVoteDetails", time: timeM, tag: "trading"));
        }
      }, respond.data);
    } else {
      for (int i = 0; i < Tools.recordList.length; i++) {
        if (Tools.recordList[i].timeStamp == timeM) {
          Tools.recordList[i].state = 2;
          break;
        }
      }
    }
    EventBusTools.getEventBus()
        ?.fire(RecordEntity(name: "updateSendRecord", time: timeM));
    EventBusTools.getEventBus()?.fire(
        RecordEntity(name: "updateVoteDetails", time: timeM, tag: "trading"));
  }

  /// 更新 数据
  updateData() async {
    List<Map> _listData = await SqlManager.queryData();
    _listMap.clear();
    _grandTotalNum = 0;
    _yesterdayNum = 0;
    _allMoney = 0;
    for (int i = 0; i < _listData.length; i++) {
      User user = User.fromSQLHomeJson(_listData[i]);
      _allMoney += user.allMoney;
      _grandTotalNum += user.totalNum;
      _yesterdayNum += user.lastNum;
      _listMap.add(user);
    }
    if (mounted && _isRequest) setState(() {});
  }

  /// 显示更新地址 dialog
  showUpdateAddressDialog(String address) {
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
              address: address, keys: ["isValora"], values: [1]);
          if (code > 0) {
            EventBusTools.getEventBus()?.fire("AddressManageUpdate");
            await updateData();
          } else {
            Tools.showToast(context, S.of(context).save_address_err_hint);
          }
        }).show();
  }

  /// 显示 添加地址的dialog
  _showAddAddressDialog() {
    AddAddressDialog(
        context: context,
        onItemClick: (name) async {
          if (S.of(context).observe_address_add == name) {
            // 观察地址
            RouteTools.startActivity(context, RouteTools.OBSERVE_ADDRESS,
                callbackContent: (content) async {
              if (!Tools.isNull(content)) {
                await updateData();
                _refreshCon?.requestRefresh();
              }
            });
          } else if (S.of(context).import_wallet == name) {
            // 导入地址
            RouteTools.startActivity(context, RouteTools.IMPORT_ADDRESS,
                callbackContent: (content) async {
              if (!Tools.isNull(content)) {
                await updateData();
                _refreshCon?.requestRefresh();
              }
            });
          } else if (S.of(context).address_create == name) {
            // 创建地址
            RouteTools.startActivity(context, RouteTools.CREATE_ADDRESS,
                callbackContent: (content) async {
              if (!Tools.isNull(content)) {
                await updateData();
                _refreshCon?.requestRefresh();
              }
            });
          } else if (S.of(context).valora_authorization == name) {
            // print("安装列表==${await DeviceApps.getInstalledApplications()}");
            // co.clabs.valora
            // valora 授权
            Tools.valoraAuthorization(context);
          }
        }).show();
  }

  /// 心跳包请求
  heartbeatPacketsRequest() async {
    Map<String, dynamic> json = await HttpTools.requestJSONSyncData(
      AppInterface.HEART_INTERFACE,
      context: context,
    );
    try {
      // print("=======resumed=11==$_isRequest");
      if (_isRequest && json != null && mounted && json['code'] == 1) {
        Map result = json['result'];
        if (result != null) {
          HttpTools.timestamp = result['timestamp'] ?? 0;
          Tools.isHint = (result['flg'] ?? 0) != 1;
          if (result['reward_types'] != null) {
            Map reward_types = result['reward_types'];
            SpUtil.putString(
                SpUtilConstant.HEART_REWARD_DATA, jsonEncode(reward_types));
            Tools.rewardTypes = RewardTypes.fromJson(reward_types);
          }
          if (result['account_types'] != null) {
            Map account_types = result['account_types'];
            SpUtil.putString(
                SpUtilConstant.HEART_ACCOUNT_DATA, jsonEncode(account_types));
            Tools.accountTypes = AccountTypes.fromJson(account_types);
          }
          Map prices = result['prices'];
          if (prices != null) {
            SpUtil.putString(
                SpUtilConstant.HEART_PRICES_DATA, jsonEncode(prices));
            Tools.prices = Prices.fromJson(prices);
          }
        }
        _setCoinPrices();
        await updateData();
        Map tip = result['tip'];
        if (tip != null &&
            tip.isNotEmpty &&
            mounted &&
            _appUpgradeDialog == null) {
          String language =
              SpUtil.getString(SpUtilConstant.CHOOSE_LANGUAGE, defValue: "zh");
          if (language == "zh") {
            _appUpgradeDialog = APPUpgradeDialog(
              list: result['tip']['cn'],
            );
            Navigator.of(context).push(DialogRouter(_appUpgradeDialog));
          } else if (language == "en") {
            _appUpgradeDialog = APPUpgradeDialog(
              list: result['tip']['en'],
            );
            Navigator.of(context).push(DialogRouter(_appUpgradeDialog));
          }
        }
      }
    } catch (e) {
      print(e);
    }
    //延时500毫秒执行
    Future.delayed(Duration(seconds: 5), () {
      //延时执行的代码
      if (mounted && _isRequest) heartbeatPacketsRequest();
    });
  }

  /// 设置币的金额缓存
  void _setCoinPrices() {
    if (SpUtil.getString(SpUtilConstant.CHOOSE_ASSETS, defValue: "CNY") ==
        "CNY") {
      celoPrices = Tools.prices?.cELO?.cNY ?? 0;
      cusdPrices = Tools.prices?.cUSD?.cNY ?? 0;
      ceurPrices = Tools.prices?.cEUR?.cNY ?? 0;
      _unit = "¥";
    } else {
      celoPrices = Tools.prices?.cELO?.uSD ?? 0;
      cusdPrices = Tools.prices?.cUSD?.uSD ?? 0;
      ceurPrices = Tools.prices?.cEUR?.uSD ?? 0;
      _unit = "\$";
    }
  }

  /// 设置头部布局
  Widget _setHomeTopLayout() {
    return Container(
      // color: Color(0XFF34D07F),
      padding: EdgeInsets.only(bottom: ScreenUtil.getInstance().getWidth(18)),
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/img/cd_home_top_bg.png"),
      //     fit: BoxFit.fill,
      //   ),
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).total_assets,
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(9),
                    fontWeight: FontWeight.w600,
                    color: Color(0XFFD1FFE7)),
              ),
              SizedBox(
                width: 5,
              ),
              InkWell(
                  onTap: () {
                    _isShowNum = !_isShowNum;
                    SpUtil.putBool(SpUtilConstant.IS_SHOW_NUM, _isShowNum);
                    setState(() {});
                  },
                  child: Image.asset(
                    _isShowNum
                        ? "assets/img/cd_home_eye_icon.png"
                        : "assets/img/cd_home_eye_close_icon.png",
                    width: ScreenUtil.getInstance().getWidth(12),
                    fit: BoxFit.fitWidth,
                  )),
            ],
          ),
          SizedBox(
            height: 6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isShowNum ? "≈ " : "",
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(12),
                    color: Colors.white),
              ),
              Text(
                _isShowNum
                    ? "$_unit ${Tools.formattingNumComma(_allMoney)}"
                    : "******",
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getWidth(15),
          ),
          Row(
            children: [
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).yesterday_profit,
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(9),
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: Color(0XFFD1FFE7)),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                      padding: EdgeInsets.only(right: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isShowNum
                                ? Tools.formattingNumComma(_yesterdayNum)
                                : "******",
                            style: TextStyle(
                                height: 1,
                                fontSize: ScreenUtil.getInstance().getSp(10),
                                fontWeight: FontWeight.w600,
                                color: Color(0XFFD1FFE7)),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Image.asset(
                            "assets/img/cd_celo_unit_icon.png",
                            width: ScreenUtil.getInstance().getWidth(8),
                            fit: BoxFit.fitWidth,
                          ),
                        ],
                      )),
                ],
              )),
              Container(
                width: 0.5,
                height: 25,
                color: Color(0X540F914D),
              ),
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).accumulated_earnings,
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(9),
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: Color(0XFFD1FFE7)),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                      padding: EdgeInsets.only(right: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isShowNum
                                ? Tools.formattingNumComma(_grandTotalNum)
                                : "******",
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().getSp(10),
                                fontWeight: FontWeight.w600,
                                height: 1,
                                color: Color(0XFFD1FFE7)),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Image.asset(
                            "assets/img/cd_celo_unit_icon.png",
                            width: ScreenUtil.getInstance().getWidth(8),
                            fit: BoxFit.fitWidth,
                          ),
                        ],
                      )),
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //       right: ScreenUtil.getInstance().getWidth(8) + 5),
                  //   child: Text(
                  //     _isShowNum
                  //         ? Tools.formattingNumComma(_grandTotalNum)
                  //         : "******",
                  //     style: TextStyle(
                  //         fontSize: ScreenUtil.getInstance().getSp(10),
                  //         fontWeight: FontWeight.w600,
                  //         height: 1,
                  //         color: Color(0XFFD1FFE7)),
                  //   ),
                  // ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }
}
