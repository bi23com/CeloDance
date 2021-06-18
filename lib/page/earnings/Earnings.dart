import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/AppInterface.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/page/address/dialog/PinPawDialog.dart';
import 'package:dpos/page/address/entity/SendHomeEntity.dart';
import 'package:dpos/page/earnings/view/ArrowsSwitch.dart';
import 'package:dpos/page/home/Home.dart';
import 'package:dpos/page/record/SendRecordDetails.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/ValoraTool.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/dialog/BaseLoadingDialog.dart';
import 'package:dpos/tools/dialog/TextDialog.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:dpos/tools/view/RefreshHeadIdle.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialog/ActivateDialog.dart';
import 'dialog/EarningsDialog.dart';
import 'entity/VoteEntity.dart';

/// Describe: 收益页面
/// Date: 3/23/21 5:05 PM
/// Path: page/earnings/Earnings.dart
class Earnings extends StatefulWidget {
  Earnings({Key key, @required this.title, this.type, this.map})
      : super(key: key);
  final String title;
  final int type;
  final Map map;

  @override
  _EarningsState createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> with TickerProviderStateMixin {
  RefreshController _refreshCon = RefreshController(initialRefresh: false);
  StreamSubscription _propertySubscription;
  BaseLoadingDialog _earningsLoadingDialog;

  /// 投票记录列表
  List<VoteEntity> voteList = List.empty(growable: true);

  /// 待取回列表
  List<VoteEntity> withdrawList = List.empty(growable: true);

  String address = "";

  /// 右上角按钮
  String _titleTip = "";
  String _titleUrl = "";

  /// 用于展示 绿色背景上的布局数据
  String smallKey1 = "";
  String smallValue1 = "";
  String smallKey2 = "";
  String smallValue2 = "";
  String smallKey3 = "";
  String smallValue3 = "";
  bool isSmallHead = false;

  // 是否显示头像 图片  默认灰色不显示
  bool isSmallHeadGrey = false;

  /// 数据
  User _user;

  /// celo
  num _available = 0.0;
  num _locked = 0.0;
  num _pending = 0.0; // 解锁待取回
  num _nonvoting = 0.0;
  num _voteActivated = 0.0; // 投票待激活
  num _voteActivatedAll = 0.0; // 投票待激活 总量
  /// 已锁布局 是否打开
  Animation _animationLocked;
  AnimationController _controllerLocked;

  /// 解锁待取回布局 是否打开
  Animation _animationPending;
  AnimationController _controllerPending;

  /// 待取回列表旋转动画
  AnimationController _controllerRotatingPending;

  /// 名称
  String earningsName;
  String earningsLogo = "";

  // 是否显示饼状图
  bool isPieChart = false;

  // 钱的单位
  var moneyUnit = '';

  /// 折线图 选择天数 下标
  int _dayPosition = 0;

  // 折线图天数
  int _day = 7;
  List<Map> recordMap;

  /// 折线图展示的天数
  double _maxY = 1;
  double _minY = 0;
  List<FlSpot> historyList = List.empty(growable: true);
  List<num> numList = List.empty(growable: true);
  List<String> list = List.empty(growable: true);

  String assetsUnit = "";

  // 计算距离
  double size5 = 5;
  double size8 = 8;
  double size12 = 12;
  double size14 = 14;
  double size16 = 16;
  double size23 = 23;
  double size26 = 26;
  num _price = 0; //单资产价格

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
    super.initState();
    var today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime fiftyDaysFromNow = today.add(Duration(days: -i));
      list.add(
          "${fiftyDaysFromNow.month < 10 ? "0" : ""}${fiftyDaysFromNow.month}.${fiftyDaysFromNow.day < 10 ? "0" : ""}${fiftyDaysFromNow.day}");
      historyList.add(FlSpot(i.toDouble(), 0));
    }
    address = widget.map['address'] ?? "";
    _titleTip = widget.map['titleTip'] ?? "";
    _titleUrl = widget.map['titleUrl'] ?? "";
    assetsUnit =
        SpUtil.getString(SpUtilConstant.CHOOSE_ASSETS, defValue: "CNY");
    if (assetsUnit == "CNY") {
      moneyUnit = '¥ ';
    } else {
      moneyUnit = '\$ ';
    }
    _controllerLocked =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animationLocked = Tween(begin: 0.0, end: 0.50).animate(_controllerLocked);
    _controllerPending =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animationPending =
        Tween(begin: 0.0, end: 0.50).animate(_controllerPending);
    _controllerRotatingPending = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    _controllerRotatingPending.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
        //重置起点
        _controllerRotatingPending?.reset();
        //开启
        _controllerRotatingPending?.forward();
      }
    });
    _controllerRotatingPending?.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _propertySubscription = EventBusTools.getEventBus()
          ?.on<RecordEntity>()
          ?.listen((event) async {
        // print("收益页面=1=======${event.name}");
        if ("updateProperty" == event.name) {
          /// 更新数据
          if (mounted) _initData();
        } else if ("goToVoteDetails" == event.name) {
          if (mounted) {
            for (int i = 0; i < Tools.voteList.length; i++) {
              if (Tools.voteList[i].timeStamp == event.time) {
                RouteTools.startActivity(
                    context, RouteTools.SEND_RECORD_DETAILS,
                    address: address,
                    recordEntity: Tools.voteList[i],
                    detailsEnum: DetailsEnum.vote);
                break;
              }
            }
          }
        }
      });
      _earningsLoadingDialog = BaseLoadingDialog(context);
      _initData();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _propertySubscription?.cancel();
    _controllerLocked?.dispose();
    _controllerPending?.dispose();
    _controllerRotatingPending?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int addressLength = address.length;
    return BaseTitle(
      title: widget.title ?? "",
      rightLeading: [
        Visibility(
            visible: !Tools.isNull(_titleTip) && !Tools.isNull(_titleUrl),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (await canLaunch(_titleUrl)) {
                  await launch(_titleUrl);
                }
              },
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Image.asset(
                    "assets/img/cd_earnings_issue_icon.png",
                    width: ScreenUtil.getInstance().getWidth(21),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            )),
        Visibility(
            visible: (widget.type ?? 0) == 1,
            child: GestureDetector(
              onTap: () {
                RouteTools.startActivity(context, RouteTools.VOTE_RECORD,
                    address: address);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Image.asset(
                  "assets/img/cd_transaction_record_icon.png",
                  width: ScreenUtil.getInstance().getWidth(20),
                  height: ScreenUtil.getInstance().getWidth(20),
                ),
              ),
            ))
      ],
      body: ScrollConfiguration(
          behavior: NoScrollBehavior(),
          child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshCon,
              onRefresh: _onRefresh,
              header: RefreshHeadIdle(),
              child: ListView(
                padding: EdgeInsets.only(top: 25),
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (address.length > 10) {
                              Clipboard.setData(ClipboardData(text: address));
                              Tools.showToast(
                                  context, S.of(context).copy_success);
                            }
                          },
                          child: RichText(
                              text: TextSpan(
                                  text: addressLength > 21
                                      ? (address.substring(0, 10) +
                                          "......" +
                                          address.substring(addressLength - 10,
                                              addressLength))
                                      : address,
                                  style: TextStyle(
                                      color: Color(0xFF48515B),
                                      fontSize:
                                          ScreenUtil.getInstance().getSp(12)),
                                  children: [
                                WidgetSpan(
                                    child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, top: 0, bottom: 2),
                                  child: Image.asset(
                                    "assets/img/cd_aa_copy_icon.png",
                                    width:
                                        ScreenUtil.getInstance().getWidth(13),
                                    fit: BoxFit.fitWidth,
                                  ),
                                )),
                              ]))),
                      // Text(
                      //   addressLength > 21
                      //       ? (address.substring(0, 10) +
                      //           "......" +
                      //           address.substring(
                      //               addressLength - 10, addressLength))
                      //       : address,
                      //   style: TextStyle(
                      //       color: Color(0xFF48515B),
                      //       fontSize: ScreenUtil.getInstance().getSp(12)),
                      // ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Text(
                        "",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: Color(0XFFC1C6C9),
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenUtil.getInstance().getSp(13)),
                      )),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size12,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/img/cd_aa_top_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    padding: EdgeInsets.only(top: 13, bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                            visible: !isSmallHead,
                            child: SizedBox(
                              height: 17,
                            )),
                        Visibility(
                            visible: isSmallHead,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                isSmallHeadGrey
                                    // ? Stack(
                                    //     alignment: Alignment.topRight,
                                    //     children: [
                                    //       Image.asset(
                                    //         "assets/img/cd_bi23_icon.png",
                                    //         width: ScreenUtil.getInstance()
                                    //             .getWidth(28),
                                    //         height: ScreenUtil.getInstance()
                                    //             .getWidth(28),
                                    //         fit: BoxFit.fill,
                                    //       ),
                                    //       Image.asset(
                                    //         "assets/img/cd_bi23_top_done_icon.png",
                                    //         width: ScreenUtil.getInstance()
                                    //             .getWidth(10),
                                    //         height: ScreenUtil.getInstance()
                                    //             .getWidth(10),
                                    //         fit: BoxFit.fill,
                                    //       ),
                                    //     ],
                                    //   )
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                        imageUrl: earningsLogo,
                                        fit: BoxFit.fitWidth,
                                        width: ScreenUtil.getInstance()
                                            .getWidth(28),
                                        errorWidget: (context, url, error) =>
                                            SizedBox(
                                          width: ScreenUtil.getInstance()
                                              .getWidth(28),
                                        ),
                                        placeholder: (context, url) => SizedBox(
                                          width: ScreenUtil.getInstance()
                                              .getWidth(28),
                                        ),
                                      ))
                                    : Container(
                                        width: ScreenUtil.getInstance()
                                            .getWidth(28),
                                        height: ScreenUtil.getInstance()
                                            .getWidth(28),
                                        decoration: BoxDecoration(
                                            color: Color(0XB0FFFFFF),
                                            shape: BoxShape.circle),
                                      ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  earningsName ?? "",
                                  style: TextStyle(
                                      color: Color(0XFFD1FFE7),
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          ScreenUtil.getInstance().getSp(11)),
                                )
                              ],
                            )),
                        Visibility(
                            visible: isSmallHead,
                            child: SizedBox(
                              height: 20,
                            )),
                        Row(
                          children: [
                            Visibility(
                                visible: !Tools.isNull(smallKey1),
                                child: Expanded(
                                    flex: 2,
                                    child: _smallItem(
                                      smallKey1,
                                      smallValue1,
                                    ))),
                            Visibility(
                                visible: !Tools.isNull(smallKey1),
                                child: Container(
                                  color: Color(0XFF23B76A),
                                  height: ScreenUtil.getInstance().getWidth(44),
                                  width: 1,
                                )),
                            Expanded(
                                flex: 3,
                                child: _smallItem(smallKey2, smallValue2)),
                            Container(
                              color: Color(0XFF23B76A),
                              height: ScreenUtil.getInstance().getWidth(44),
                              width: 1,
                            ),
                            Expanded(
                                flex: 3,
                                child: _smallItem(smallKey3, smallValue3)),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: isPieChart && Tools.isHint,
                      child: Padding(
                        padding: EdgeInsets.only(left: 25, top: 25, bottom: 10),
                        child: Text(
                          S.of(context).celo_asset_states,
                          style: TextStyle(
                              color: Color(0XFF404044),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil.getInstance().getSp(13)),
                        ),
                      )),
                  Visibility(
                      visible: isPieChart && Tools.isHint,
                      child: Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Column(
                          children: [
                            _celoItem(
                                color: Color(0XFFFF4F41),
                                name: S.of(context).available,
                                number: _available,
                                isClick: _available > 0,
                                isTwoClick: false,
                                btnName: S.of(context).lock_e),
                            _celoItem(
                                color: Color(0XFF44D7B6),
                                name: S.of(context).lock,
                                number: _locked,
                                isClick: _nonvoting > 0,
                                btnName: S.of(context).unlock,
                                animation: _animationLocked,
                                controller: _controllerLocked,
                                isTwoClick: true,
                                isShowArrows: true),
                            _lockedLayout(controller: _controllerLocked),
                            _celoItem(
                                color: Color(0XFFF7B500),
                                name: S.of(context).undetermined,
                                number: _pending,
                                btnName: S.of(context).withdraw,
                                animation: _animationPending,
                                controller: _controllerPending,
                                isShowBtn: false,
                                isClick: _pending > 0,
                                isTwoClick: _pending > 0,
                                isShowArrows: _pending > 0),
                            _pendingLayout(controller: _controllerPending),
                          ],
                        ),
                      )),
                  Visibility(
                      visible: true,
                      child: Padding(
                        padding: EdgeInsets.only(left: 25, top: 15),
                        child: Text(
                          S.of(context).earnings_record,
                          style: TextStyle(
                              color: Color(0XFF404044),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil.getInstance().getSp(13)),
                        ),
                      )),
                  // Visibility(child: Padding(
                  //   padding:EdgeInsets.only(bottom: 15) ,
                  //   child: Row(
                  //     children: [
                  //       SizedBox(
                  //         width: 25,
                  //       ),
                  //       _lineChartDayItem("7D", _dayPosition == 0, 0),
                  //       _lineChartDayItem("15D", _dayPosition == 1, 1),
                  //       _lineChartDayItem("30D", _dayPosition == 2, 2),
                  //     ],
                  //   ),
                  // )),
                  Visibility(
                      visible: true,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(
                            left: 12, bottom: 5, top: 25, right: 30),
                        width: double.infinity,
                        height: 200,
                        child: Tools.lineChart(
                            list: list,
                            maxY: _maxY,
                            minY: _minY,
                            maxX: (historyList.length - 1).toDouble(),
                            lineChartBarDataList: [
                              Tools.lineChartLine(historyList)
                            ]),
                      )),
                  SizedBox(
                    height: 100,
                  )
                ],
              ))),
    );
  }

  /*
   * 下拉刷新用到的方法
   */
  Future<void> _onRefresh() async {
    _rewardsRequest();
  }

  ///Celo代币分布 可用余额
  Widget _celoItem(
      {Color color,
      String name,
      num number,
      String btnName,
      Function onTap,
      AnimationController controller,
      Animation animation,
      bool isShowBtn = true,
      bool isClick = true, // 是否可以点击
      bool isTwoClick = true, // 是否可以点开布局
      bool isShowArrows = false}) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isTwoClick) {
            if (controller?.status == AnimationStatus.completed) {
              controller?.reverse();
              onTap?.call(false);
            } else if (controller?.status == AnimationStatus.dismissed) {
              controller?.forward();
              onTap?.call(true);
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipOval(
                child: Container(
                  width: ScreenUtil.getInstance().getWidth(6),
                  height: ScreenUtil.getInstance().getWidth(6),
                  color: color,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                text: TextSpan(
                    text: name,
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(12),
                        fontWeight: FontWeight.w400,
                        color: Color(0XFF999999)),
                    children: [
                      TextSpan(
                        text: "   ${Tools.formattingNumComma(number)}",
                        style: TextStyle(
                          color: Color(0xFF2E3339),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenUtil.getInstance().getSp(12),
                        ),
                      ),
                      TextSpan(
                        text: " CELO",
                        style: TextStyle(
                          color: Color(0xFFA6A6A6),
                          fontSize: ScreenUtil.getInstance().getSp(11),
                        ),
                      ),
                    ]),
              )),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                  width: ScreenUtil.getInstance().getWidth(55),
                  height: ScreenUtil.getInstance().getWidth(20),
                  child: Visibility(
                    visible: isShowBtn,
                    child: FlatButton(
                      disabledTextColor: Color(0XFFAFAFAF),
                      disabledColor: Color(0XFFE4E4E4),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      //画圆角
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      onPressed:
                          isClick ? () => _goToVote(btnName, number, 0) : null,
                      child: Text(
                        btnName ?? "",
                        style: TextStyle(
                            fontSize: ScreenUtil.getInstance().getSp(11),
                            height: 1.1),
                      ),
                      color: Color(0XFF2BC374),
                      textColor: Colors.white,
                      highlightColor: Colors.green.withAlpha(80),
                    ),
                  )),
              isShowArrows
                  ? Padding(
                      padding: EdgeInsets.only(left: 13, right: 25),
                      child: RotationTransition(
                          alignment: Alignment.center,
                          turns: animation,
                          child: Image.asset(
                            "assets/img/cd_arrows_down_icon.png",
                            width: ScreenUtil.getInstance().getWidth(11),
                            fit: BoxFit.fitWidth,
                          )))
                  : Padding(
                      padding: EdgeInsets.only(left: 13, right: 25),
                      child: SizedBox(
                        width: ScreenUtil.getInstance().getWidth(11),
                      )),
            ],
          ),
        ));
  }

  /// 锁定的其他布局 已锁未投票的  投票中的 投票待激活的
  _lockedLayout({AnimationController controller}) {
    return SizeTransition(
        axis: Axis.vertical,
        sizeFactor: CurvedAnimation(parent: controller, curve: Curves.linear),
        child: Container(
          margin: EdgeInsets.only(right: 25),
          padding: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
              color: Color(0X66EFF3F3), borderRadius: BorderRadius.circular(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    right: ScreenUtil.getInstance().getWidth(11) + 13),
                child: _lockedPendingItem(
                    name: S.of(context).lock_no_vote,
                    number: _nonvoting,
                    isOnClick: _nonvoting > 0,
                    btnName: S.of(context).vote),
              ),
              Tools.getLine(),
              Padding(
                  padding: EdgeInsets.only(
                      right: ScreenUtil.getInstance().getWidth(11) + 13),
                  child: _lockedPendingItem(
                      name: S.of(context).voting,
                      number: _locked - _nonvoting,
                      isOnClick: _locked - _nonvoting > 0,
                      btnName: S.of(context).revoke)),
              Tools.getLine(),
              Padding(
                  padding: EdgeInsets.only(
                      right: ScreenUtil.getInstance().getWidth(11) + 13),
                  child: _activationItem(
                      btnName: S.of(context).activation,
                      isTextAndBg: _voteActivated > 0)),
            ],
          ),
        ));
  }

  /// 取回列表的布局
  _pendingLayout({AnimationController controller}) {
    return SizeTransition(
        axis: Axis.vertical,
        sizeFactor: CurvedAnimation(parent: controller, curve: Curves.linear),
        child: Container(
            margin: EdgeInsets.only(right: 25),
            padding: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
                color: Color(0X66EFF3F3),
                borderRadius: BorderRadius.circular(5)),
            child: withdrawList.length == 0
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotationTransition(
                            alignment: Alignment.center,
                            turns: _controllerRotatingPending,
                            child: Image.asset(
                              "assets/img/cd_withdraw_loading_icon.png",
                              width: ScreenUtil.getInstance().getWidth(12),
                              fit: BoxFit.fitWidth,
                            )),
                        Text(
                          "  ${S.of(context).load_text}",
                          style: TextStyle(
                              color: Color(0xffA6A6A6),
                              fontSize: ScreenUtil.getInstance().getSp(11)),
                        )
                      ],
                    ),
                  )
                : ScrollConfiguration(
                    behavior: NoScrollBehavior(),
                    child: ListView.separated(
                      itemCount: withdrawList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        VoteEntity voteEntity = withdrawList[index];
                        return Padding(
                            padding: EdgeInsets.only(
                                right:
                                    ScreenUtil.getInstance().getWidth(11) + 13),
                            child: _lockedPendingItem(
                                name: voteEntity.time,
                                number: voteEntity.votes,
                                index: voteEntity.index,
                                isOnClick: voteEntity.timeStamp <=
                                    Tools.currentTimeMillis(),
                                btnName: S.of(context).withdraw));
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Tools.getLine(),
                    ))));
  }

  /// 激活 item 布局
  _activationItem({String btnName, bool isTextAndBg}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Text(S.of(context).vote_activated,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(12),
                      color: Color(0XFFA6A6A6)))),
          Text(
            "   ${Tools.formattingNumComma(_voteActivatedAll)}",
            style: TextStyle(
              color: Color(0xFF2E3339),
              fontWeight: FontWeight.w600,
              fontSize: ScreenUtil.getInstance().getSp(12),
            ),
          ),
          Text(
            " CELO",
            style: TextStyle(
              color: Color(0xFFA6A6A6),
              fontSize: ScreenUtil.getInstance().getSp(12),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          SizedBox(
              width: ScreenUtil.getInstance().getWidth(55),
              height: ScreenUtil.getInstance().getWidth(20),
              child: FlatButton(
                disabledTextColor: Color(0XFFAFAFAF),
                disabledColor: Color(0XFFE4E4E4),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //画圆角
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                onPressed: _voteActivatedAll > 0
                    ? () => _goToVote(btnName, 0, 0)
                    : null,
                child: Text(
                  btnName ?? "",
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(11),
                      height: 1.1),
                ),
                color: isTextAndBg ? Color(0XFF2BC374) : Color(0XFFE4E4E4),
                textColor: isTextAndBg ? Colors.white : Color(0XFFAFAFAF),
                highlightColor: isTextAndBg
                    ? Colors.green.withAlpha(80)
                    : Color(0XFFAFAFAF).withAlpha(80),
              )),
        ],
      ),
    );
  }

  /// 已锁item布局  解锁待取回 item 布局
  _lockedPendingItem(
      {String name,
      num number,
      String btnName,
      bool isOnClick = true,
      int index}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Text(name,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(12),
                      color: Color(0XFFA6A6A6)))),
          Text(
            "   ${Tools.formattingNumComma(number)}",
            style: TextStyle(
              color: Color(0xFF2E3339),
              fontWeight: FontWeight.w600,
              fontSize: ScreenUtil.getInstance().getSp(12),
            ),
          ),
          Text(
            " CELO",
            style: TextStyle(
              color: Color(0xFFA6A6A6),
              fontSize: ScreenUtil.getInstance().getSp(12),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          SizedBox(
              width: ScreenUtil.getInstance().getWidth(55),
              height: ScreenUtil.getInstance().getWidth(20),
              child: FlatButton(
                disabledTextColor: Color(0XFFAFAFAF),
                disabledColor: Color(0XFFE4E4E4),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //画圆角
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                onPressed:
                    isOnClick ? () => _goToVote(btnName, number, index) : null,
                child: Text(
                  btnName ?? "",
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(11),
                      height: 1.1),
                ),
                color: Color(0XFF2BC374),
                textColor: Colors.white,
                highlightColor: Colors.green.withAlpha(80),
              )),
        ],
      ),
    );
  }

  /// 取回 的方法
  _recap(num count, int index, String paw) async {
    int timeM = Tools.currentTimeMillis();
    var strtime = DateTime.fromMillisecondsSinceEpoch(timeM);
    RecordEntity recordEntity = RecordEntity(
        rollOutAddress: address,
        count: count,
        coinName: "CELO",
        tag: "vote",
        type: 5,
        time: strtime.toLocal().toString().split(".")[0] ?? "",
        timeStamp: timeM.toString(),
        state: 0);
    Tools.voteList.add(recordEntity);
    EventBusTools.getEventBus()?.fire(SendHomeEntity(
        name: "voteData",
        count: count,
        coinName: "CELO",
        address: address,
        type: 5,
        isValora: _user.isValora,
        index: index,
        apiUrl: SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY),
        privateKey: _user.privateKey,
        paw: paw,
        timeM: timeM.toString()));
    if (_user.isValora == 0) {
      RouteTools.startActivity(context, RouteTools.SEND_RECORD_DETAILS,
          address: address,
          recordEntity: recordEntity,
          detailsEnum: DetailsEnum.vote);
    }
  }

  /// 投票的跳转方法
  _goToVote(String btnName, num number, int index) async {
    if (!Tools.isNull(_user.privateKey) || _user.isValora == 1) {
      /// type 属性 1 锁定  2 解锁  3 投票   4 撤票   5取回  6 激活
      if (S.of(context).lock_e == btnName) {
        // print("开始检测");
        if (_user.isValora == 1) {
          _earningsLoadingDialog?.show(loadText: S.of(context).load_text);
          Respond respond = await isAccount(address);
          if (mounted) _earningsLoadingDialog?.hide();
          if (respond.code == 0) {
            if (respond.data) {
              EarningsDialog(
                      context: context,
                      coinNum: _available,
                      address: address,
                      type: 1,
                      isValora: _user.isValora,
                      walletJson: _user.privateKey,
                      title: S.of(context).address,
                      btnName: btnName)
                  .show();
            } else {
              TextDialogBoard(
                  context: context,
                  content: Text(
                    S.of(context).account_no_hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0XFF353535),
                        fontSize: ScreenUtil.getInstance().getSp(12)),
                  ),
                  okClick: () async {
                    createAccountByValora(address,
                        requestId: "C*E*L*O-time-$address");
                  }).show();
            }
          } else {
            Tools.showToast(context, respond.msg?.toString());
          }
        } else {
          EarningsDialog(
                  context: context,
                  coinNum: _available,
                  address: address,
                  type: 1,
                  isValora: _user.isValora,
                  walletJson: _user.privateKey,
                  title: S.of(context).address,
                  btnName: btnName)
              .show();
        }
      } else if (S.of(context).unlock == btnName) {
        EarningsDialog(
                context: context,
                coinNum: _nonvoting,
                address: address,
                type: 2,
                isValora: _user.isValora,
                walletJson: _user.privateKey,
                title: S.of(context).address,
                btnName: btnName)
            .show();
      } else if (S.of(context).revoke == btnName) {
        RouteTools.startActivity(context, RouteTools.VOTE_LIST,
            address: address,
            type: 1,
            isValora: _user.isValora,
            number: _nonvoting,
            walletJson: _user.privateKey,
            voteList: voteList);
      } else if (S.of(context).vote == btnName) {
        RouteTools.startActivity(context, RouteTools.VOTE_LIST,
            address: address,
            type: 0,
            isValora: _user.isValora,
            number: _nonvoting,
            walletJson: _user.privateKey,
            voteList: voteList);
      } else if (S.of(context).withdraw == btnName) {
        if (_user.isValora == 1) {
          _recap(number, index, "");
        } else {
          PinPawDialog(
                  context: context,
                  onOk: (paw) async {
                    _recap(number, index, paw);
                  },
                  payPawBehavior: SpUtil.getBool(SpUtilConstant.IS_PASSWORD,
                          defValue: false)
                      ? PinPawBehavior.use
                      : PinPawBehavior.open)
              .show();
        }
      } else if (S.of(context).activation == btnName) {
        /// 激活
        if (_voteActivatedAll > 0) {
          ActivateDialog(
                  context: context,
                  voteList: voteList,
                  address: address,
                  isValora: _user.isValora,
                  walletJson: _user.privateKey)
              .show();
        }
      }
    } else {
      if (S.of(context).vote == btnName) {
        RouteTools.startActivity(context, RouteTools.VOTE_LIST,
            address: address,
            type: 0,
            isValora: _user.isValora,
            number: _nonvoting,
            walletJson: _user.privateKey,
            voteList: voteList);
      } else {
        Tools.showToast(context, S.of(context).observe_address_no_trading);
      }
    }
  }

  /// 折线图 天数 布局
  Widget _lineChartDayItem(String name, bool isShowBg, int position) {
    return GestureDetector(
      onTap: () {
        _dayPosition = position;
        if (position == 0) {
          _day = 7;
        } else if (position == 1) {
          _day = 15;
        } else {
          _day = 30;
        }
        _rewardsRequest();
      },
      child: Container(
        alignment: Alignment.center,
        height: ScreenUtil.getInstance().getWidth(18),
        width: ScreenUtil.getInstance().getWidth(45),
        margin: EdgeInsets.only(right: 10),
        decoration: isShowBg
            ? BoxDecoration(
                color: Color(0XFFECFDF4),
                border: Border.all(width: 0.5, color: Color(0xff2BC374)),
                borderRadius: BorderRadius.circular(45))
            : BoxDecoration(),
        child: Text(
          name,
          style: TextStyle(
              fontSize: ScreenUtil.getInstance().getSp(13),
              color: Color(0XFF3BC87B),
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// 布局
  Widget _smallItem(
    String name,
    String num,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Color(0xFFD1FFE7),
              fontWeight: FontWeight.w600,
              fontSize: ScreenUtil.getInstance().getSp(12)),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          num,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Color(0XFFFFFFFF),
              fontWeight: FontWeight.w600,
              fontSize: ScreenUtil.getInstance().getSp(16)),
        ),
      ],
    );
  }

  /// 初始化数据
  _initData() async {
    Tools.keyboardDone = S.of(context).done;
    String unitString = widget.map['unitString'] ?? "";
    switch (widget.type ?? 0) {
      case 1: //投票收益
        if (assetsUnit == "CNY") {
          _price = Tools.prices?.cELO?.cNY ?? 0;
        } else {
          _price = Tools.prices?.cELO?.uSD ?? 0;
        }
        earningsName = "";
        earningsLogo = "";
        smallKey1 = "";
        smallValue1 = "";
        smallKey2 = "${S.of(context).earnings_yesterday}($unitString)";
        smallValue2 = Tools.formattingNumComma(widget.map['last'] ?? 0);
        smallKey3 = "${S.of(context).accumulated_earnings}($unitString)";
        smallValue3 = Tools.formattingNumComma(widget.map['total'] ?? 0);
        isSmallHead = false;
        isSmallHeadGrey = false;
        isPieChart = true;
        List<Map> addressMap = await SqlManager.queryAddressData(address);
        if (addressMap.isNotEmpty) {
          _user = User.fromJson(addressMap[0]);
          _locked = _user.celoLocked;
          _pending = _user.celoPending;
          _available = _user.celoAvailable;
          _nonvoting = _user.celoNonvoting;
        }
        break;
      case 2: // 持有cusd收益
        if (assetsUnit == "CNY") {
          _price = Tools.prices?.cELO?.cNY ?? 0;
        } else {
          _price = Tools.prices?.cELO?.uSD ?? 0;
        }
        earningsName = "";
        earningsLogo = "";
        smallKey1 = "";
        smallValue1 = "";
        smallKey2 = "${S.of(context).week_earnings}($unitString)";
        smallValue2 = Tools.formattingNumComma(widget.map['last'] ?? 0);
        smallKey3 = "${S.of(context).accumulated_earnings}($unitString)";
        smallValue3 = Tools.formattingNumComma(widget.map['total'] ?? 0);
        isSmallHead = false;
        isSmallHeadGrey = false;
        isPieChart = false;
        break;
      case 3: //验证组收益
        if (assetsUnit == "CNY") {
          _price = Tools.prices?.cUSD?.cNY ?? 0;
        } else {
          _price = Tools.prices?.cUSD?.uSD ?? 0;
        }
        // smallKey1 = "${S.of(context).current_node}";
        earningsName = widget.map['earningsName'] ?? "";
        earningsLogo = widget.map['earningsLogo'] ?? "";
        smallKey1 = "";
        smallValue1 = "";
        smallKey2 = "${S.of(context).earnings_yesterday}($unitString)";
        smallValue2 = Tools.formattingNumComma(widget.map['last'] ?? 0);
        smallKey3 = "${S.of(context).accumulated_earnings}($unitString)";
        smallValue3 = Tools.formattingNumComma(widget.map['total'] ?? 0);
        isSmallHead = !Tools.isNull(earningsName);
        isSmallHeadGrey = !Tools.isNull(earningsLogo);
        isPieChart = false;
        break;
      case 4: //验证人收益
        if (assetsUnit == "CNY") {
          _price = Tools.prices?.cUSD?.cNY ?? 0;
        } else {
          _price = Tools.prices?.cUSD?.uSD ?? 0;
        }
        earningsName = widget.map['earningsName'] ?? "";
        earningsLogo = widget.map['earningsLogo'] ?? "";
        smallKey1 = "";
        smallValue1 = "";
        smallKey2 = "${S.of(context).earnings_yesterday}($unitString)";
        smallValue2 = Tools.formattingNumComma(widget.map['last'] ?? 0);
        smallKey3 = "${S.of(context).accumulated_earnings}($unitString)";
        smallValue3 = Tools.formattingNumComma(widget.map['total'] ?? 0);
        isSmallHead = !Tools.isNull(earningsName);
        isSmallHeadGrey = !Tools.isNull(earningsLogo);
        isPieChart = false;
        break;
      case 5: //短信证明收益
        if (assetsUnit == "CNY") {
          _price = Tools.prices?.cUSD?.cNY ?? 0;
        } else {
          _price = Tools.prices?.cUSD?.uSD ?? 0;
        }
        earningsName = widget.map['earningsName'] ?? "";
        earningsLogo = widget.map['earningsLogo'] ?? "";
        smallKey1 = "";
        // smallKey1 = "${S.of(context).success_rate}";
        smallValue1 = "";
        smallKey2 = "${S.of(context).earnings_yesterday}($unitString)";
        smallValue2 = Tools.formattingNumComma(widget.map['last'] ?? 0);
        smallKey3 = "${S.of(context).accumulated_earnings}($unitString)";
        smallValue3 = Tools.formattingNumComma(widget.map['total'] ?? 0);
        isSmallHead = !Tools.isNull(earningsName);
        isSmallHeadGrey = !Tools.isNull(earningsLogo);
        isPieChart = false;
        break;
      case 6: //举报收益
        if (assetsUnit == "CNY") {
          _price = Tools.prices?.cELO?.cNY ?? 0;
        } else {
          _price = Tools.prices?.cELO?.uSD ?? 0;
        }
        smallKey1 = "";
        smallValue1 = "";
        smallKey2 = "${S.of(context).last_earnings}($unitString)";
        smallValue2 = Tools.formattingNumComma(widget.map['last'] ?? 0);
        smallKey3 = "${S.of(context).accumulated_earnings}($unitString)";
        smallValue3 = Tools.formattingNumComma(widget.map['total'] ?? 0);
        isSmallHead = false;
        isSmallHeadGrey = false;
        isPieChart = false;
        break;
      default:
        _price = 0;
        smallKey1 = "";
        smallValue1 = "";
        smallKey2 = "";
        smallValue2 = "";
        smallKey3 = "";
        smallValue3 = "";
        isSmallHead = false;
        isSmallHeadGrey = false;
        isPieChart = false;
    }
    // print("=earningsLogo======$earningsLogo");
    recordMap =
        await SqlManager.queryAddressData(address, name: SqlManager.RECORD);
    // print("==${await SqlManager.queryData(name: SqlManager.RECORD)}");
    if (recordMap.isNotEmpty) {
      String earningsRecord = recordMap[0]["earnings${widget.type}"] ?? "";
      // print("=earningsRecord======$earningsRecord");
      if (!Tools.isNull(earningsRecord)) {
        try {
          _parsingHistory(jsonDecode(earningsRecord));
        } catch (e) {
          print(e);
        }
      }
    }
    List<Map> addressMap = await SqlManager.queryAddressData(address);
    if (addressMap.isNotEmpty) {
      _user = User.fromJson(addressMap[0]);
    }
    setState(() {});
    _getVoteList();
    _rewardsRequest();
    _getWithdrawList();
  }

  /// 获取 投票列表
  _getVoteList() async {
    try {
      Respond value = await getVotedList(address);
      if (mounted) {
        if (value.code == 0) {
          // print("value====${value.data}");
          voteList.clear();
          List list = value.data['voted'];
          if (list != null) {
            _nonvoting =
                num.parse(value.data['unused_locked']?.toString() ?? "0");
            _voteActivated = 0;
            _voteActivatedAll = 0;
            list.forEach((element) {
              VoteEntity voteEntity = VoteEntity.formJson(element);
              if (voteEntity.pendingIsActivatable) {
                _voteActivated += voteEntity.pending;
              }
              _voteActivatedAll += voteEntity.pending;
              voteList.add(voteEntity);
            });
            if (mounted) setState(() {});
          }
        } else {
          //延时500毫秒执行
          Future.delayed(Duration(seconds: 1), () {
            //延时执行的代码
            if (mounted) _getVoteList();
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  /// 待取回列表
  _getWithdrawList() async {
    try {
      getPendingInfo(address).then((value) {
        if (mounted) {
          if (value.code == 0 && value.data != null) {
            withdrawList.clear();
            List listP = value.data;
            if (listP != null) {
              listP.forEach((element) {
                withdrawList.add(VoteEntity.formWithdrawJson(element));
              });
              if (mounted) setState(() {});
            }
          } else {
            //延时500毫秒执行
            Future.delayed(Duration(seconds: 1), () {
              //延时执行的代码
              if (mounted) _getWithdrawList();
            });
          }
        }
      });
    } catch (e) {}
  }

  /// 解析数据
  _parsingHistory(List items) {
    list.clear();
    historyList.clear();
    numList.clear();
    _maxY = 1;
    _minY = 0;
    double position = 0;
    for (int i = items.length - 1; i >= 0; i--) {
      List listA = items[i];
      num allMoney = 0;
      for (int q = 0; q < listA.length; q++) {
        switch (q) {
          case 0:
            String data = listA[q]?.toString() ?? "";
            if (Tools.isNull(data)) {
              list.add(data);
            } else {
              List listB = data.split("-");
              if (listB.length == 3) {
                list.add(listB[1] + "." + listB[2]);
              } else {
                list.add(data);
              }
            }
            break;
          case 1:
            // allMoney += num.parse(listA[q]?.toString() ?? "0") * _price;
            allMoney += num.parse(listA[q]?.toString() ?? "0");
            break;
          default:
            allMoney += 0.0;
            break;
        }
      }
      historyList.add(FlSpot(position, allMoney.toDouble()));
      numList.add(allMoney.toDouble());
      position += 1;
    }
    if (numList.isNotEmpty) {
      numList.sort((a, b) => (b).compareTo(a));
      _maxY = numList[0];
      _minY = numList[numList.length - 1] * 0.99;
    }
  }

  /// 历史收益资产页面请求
  _rewardsRequest() async {
    Map<String, dynamic> json = await HttpTools.requestJSONSyncData(
      AppInterface.REWARDS_INTERFACE,
      data: {
        "address": address,
        "type": widget.type,
        "count": _day,
      },
      context: context,
    );
    try {
      if (json != null && mounted && json['code'] == 1) {
        Map<String, dynamic> result = json['result'];
        HttpTools.timestamp = result['timestamp'];
        List items = result['items'];
        _parsingHistory(items);
        if (_day == 7) {
          if (recordMap == null || recordMap.isEmpty) {
            SqlManager.addRecordData(
                address: address,
                key: "earnings${widget.type}",
                value: jsonEncode(items));
          } else {
            SqlManager.updateMoreFieldData(
                address: address,
                keys: [
                  "earnings${widget.type}",
                ],
                values: [jsonEncode(items)],
                name: SqlManager.RECORD);
          }
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      print(e);
    }
    if (mounted) _refreshCon?.refreshCompleted();
  }
}
