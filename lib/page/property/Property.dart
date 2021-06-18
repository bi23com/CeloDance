import 'dart:async';
import 'dart:convert';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/http/AppInterface.dart';
import 'package:dpos/http/HttpTools.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/entity/HearData.dart';
import 'package:dpos/tools/entity/User.dart';
import 'package:dpos/tools/view/RefreshHeadIdle.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dialog/QrCodeDialog.dart';

/// Describe: 单资产详情页
/// Date: 3/23/21 6:52 PM
/// Path: page/property/Property.dart
class Property extends StatefulWidget {
  Property({Key key, this.address}) : super(key: key);
  final String address;

  @override
  _PropertyState createState() => _PropertyState();
}

class _PropertyState extends State<Property> {
  StreamSubscription _propertySubscription;
  RefreshController _refreshCon = RefreshController(initialRefresh: false);

  /// 数据
  User _user;
  num celoPrices = 0;
  num cusdPrices = 0;
  num ceurPrices = 0;

  /// 折线图展示的天数
  int _count = 7;
  double _maxY = 1;
  double _minY = 0;
  List<FlSpot> recordList = List.empty(growable: true);
  List<FlSpot> cELOList = List.empty(growable: true);
  List<FlSpot> cUSDList = List.empty(growable: true);
  List<FlSpot> cEURList = List.empty(growable: true);
  List<num> cELONumList = List.empty(growable: true);
  List<num> cUSDNumList = List.empty(growable: true);
  List<num> cEURNumList = List.empty(growable: true);
  List<String> list = List.empty(growable: true);

  /// 币种的属性
  num _celoNum = 0;
  num _cusdNum = 0;
  num _ceurNum = 0;
  num _available = 0.0;
  num _locked = 0.0;
  num _pending = 0.0;

  /// 折线图 选择天数 下标
  int _dayPosition = 0;

  /// 折线图 选择币种 下标
  int _connTypePosition = 0;

  // 环形图的数据集合
  List<PieChartSectionData> _sections = List.empty(growable: true);
  List<Map> recordMap;

  // 计算距离
  double size5 = 5;
  double size8 = 8;
  double size12 = 12;
  double size14 = 14;
  double size16 = 16;
  double size23 = 23;
  double size26 = 26;

  // 钱的单位
  var moneyUnit = '';

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
    if (SpUtil.getString(SpUtilConstant.CHOOSE_ASSETS, defValue: "CNY") ==
        "CNY") {
      moneyUnit = '¥ ';
      celoPrices = Tools.prices?.cELO?.cNY ?? 0;
      cusdPrices = Tools.prices?.cUSD?.cNY ?? 0;
      ceurPrices = Tools.prices?.cEUR?.cNY ?? 0;
    } else {
      moneyUnit = '\$ ';
      celoPrices = Tools.prices?.cELO?.uSD ?? 0;
      cusdPrices = Tools.prices?.cUSD?.uSD ?? 0;
      ceurPrices = Tools.prices?.cEUR?.uSD ?? 0;
    }
    _sections.add(PieChartSectionData(
      value: 1,
      color: Color(0XFF34D07F),
      radius: 20,
      showTitle: false,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _propertySubscription = EventBusTools.getEventBus()
          ?.on<RecordEntity>()
          ?.listen((event) async {
        // print("单资产页面=1=======$event");
        if ("updateProperty" == event.name) {
          /// 更新数据
          if (mounted) _initData();
        }
      });
      _initData();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _propertySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int addressLength = widget.address.length;
    return BaseTitle(
      title: S.of(context).address_asset,
      rightLeading: [
        GestureDetector(
          onTap: () {
            RouteTools.startActivity(context, RouteTools.SEND_RECORD,
                address: widget.address);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Image.asset(
              "assets/img/cd_transaction_record_icon.png",
              width: ScreenUtil.getInstance().getWidth(20),
              height: ScreenUtil.getInstance().getWidth(20),
            ),
          ),
        )
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
                padding: EdgeInsets.only(top: 10),
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        addressLength > 21
                            ? (widget.address.substring(0, 10) +
                                "......" +
                                widget.address.substring(
                                    addressLength - 10, addressLength))
                            : widget.address,
                        style: TextStyle(
                            color: Color(0xFF48515B),
                            fontSize: ScreenUtil.getInstance().getSp(12)),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!Tools.isNull(widget.address)) {
                            Clipboard.setData(
                                ClipboardData(text: widget.address));
                            Tools.showToast(
                                context, S.of(context).copy_success);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: size12),
                          child: Image.asset(
                            "assets/img/cd_aa_copy_icon.png",
                            width: size16,
                            height: size16,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          QrCodeDialog(
                                  context: context, address: widget.address)
                              .show();
                        },
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: 15, top: size12, bottom: size12),
                            child: Image.asset(
                              "assets/img/cd_aa_code_icon.png",
                              width: size16,
                              height: size16,
                              fit: BoxFit.fill,
                            )),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/img/cd_aa_top_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: _smallItem(
                                    "CELO",
                                    Tools.formattingNumComma(_celoNum),
                                    moneyUnit +
                                        Tools.formattingNumComma(
                                            _celoNum * celoPrices))),
                            Container(
                              color: Color(0XFF23B76A),
                              height: ScreenUtil.getInstance().getWidth(44),
                              width: 1,
                            ),
                            Expanded(
                                child: _smallItem(
                                    "cUSD",
                                    Tools.formattingNumComma(_cusdNum),
                                    moneyUnit +
                                        Tools.formattingNumComma(
                                            _cusdNum * cusdPrices))),
                            Container(
                              color: Color(0XFF23B76A),
                              height: ScreenUtil.getInstance().getWidth(44),
                              width: 1,
                            ),
                            Expanded(
                                child: _smallItem(
                                    "cEUR",
                                    Tools.formattingNumComma(_ceurNum),
                                    moneyUnit +
                                        Tools.formattingNumComma(
                                            _ceurNum * ceurPrices))),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Visibility(
                            visible: Tools.isHint,
                            child: SizedBox(
                                width: ScreenUtil.getInstance().getWidth(104),
                                height: ScreenUtil.getInstance().getWidth(26),
                                child: FlatButton(
                                  disabledTextColor: Color(0XFFFFFFFF),
                                  disabledColor: Color(0XFFA6A6A6),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  //画圆角
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  onPressed: () => _sendOK(),
                                  child: Text(
                                    S.of(context).send,
                                    style: TextStyle(
                                        fontSize:
                                            ScreenUtil.getInstance().getSp(11),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  color: Color(0X7314A55A),
                                  textColor: Color(0XFFFFFFFF),
                                  highlightColor: Colors.green.withAlpha(80),
                                ))),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: true,
                      child: Padding(
                        padding: EdgeInsets.only(left: 25, top: 25, bottom: 10),
                        child: Text(
                          S.of(context).total_asset_valuation,
                          style: TextStyle(
                              color: Color(0XFF404044),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil.getInstance().getSp(13)),
                        ),
                      )),
                  Visibility(
                      visible: true,
                      child: Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 15),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 25,
                            ),
                            _lineChartCoinTypeItem(
                                "CELO", _connTypePosition == 0, 0),
                            _lineChartCoinTypeItem(
                                "cUSD", _connTypePosition == 1, 1),
                            _lineChartCoinTypeItem(
                                "cEUR", _connTypePosition == 2, 2),
                          ],
                        ),
                      )),
                  Visibility(
                      visible: true,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(
                            left: 12, bottom: 5, top: 30, right: 30),
                        width: double.infinity,
                        height: 200,
                        child: Tools.lineChart(
                            list: list,
                            maxY: _maxY,
                            minY: _minY,
                            maxX: (recordList.length - 1).toDouble(),
                            lineChartBarDataList: [
                              Tools.lineChartLine(recordList),
                            ]),
                      )),
                  // Padding(
                  //   padding: EdgeInsets.only(left: 25, top: 35, bottom: 30),
                  //   child: Text(
                  //     S.of(context).celo_asset_states,
                  //     style: TextStyle(
                  //         color: Color(0XFF404044),
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: ScreenUtil.getInstance().getSp(13)),
                  //   ),
                  // ),
                  // Row(
                  //   children: [
                  //     SizedBox(
                  //       width: 50,
                  //     ),
                  //     Expanded(
                  //         child: Container(
                  //       alignment: Alignment.centerRight,
                  //       child: SizedBox(
                  //         width: ScreenUtil.getInstance().getWidth(140),
                  //         height: ScreenUtil.getInstance().getWidth(140),
                  //         child: Stack(
                  //           alignment: Alignment.center,
                  //           children: <Widget>[
                  //             PieChart(PieChartData(
                  //                 sections: _sections,
                  //                 sectionsSpace: 0,
                  //                 borderData: FlBorderData(show: false))),
                  //             Column(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 Text(
                  //                   "CELO",
                  //                   textAlign: TextAlign.center,
                  //                   style: TextStyle(
                  //                       color: Color(0xFF404044),
                  //                       fontWeight: FontWeight.w600,
                  //                       fontSize:
                  //                           ScreenUtil.getInstance().getSp(15)),
                  //                 ),
                  //                 Text(
                  //                   Tools.formattingNumComma(_celoNum),
                  //                   textAlign: TextAlign.center,
                  //                   style: TextStyle(
                  //                       color: Color(0xFF747474),
                  //                       fontSize:
                  //                           ScreenUtil.getInstance().getSp(11)),
                  //                 )
                  //               ],
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     )),
                  //     SizedBox(
                  //       width: 50,
                  //     ),
                  //     Expanded(
                  //         child: Column(
                  //       children: [
                  //         _pieChartItem(
                  //             "${S.of(context).available}  ${Tools.formattingNumComma(_available)}",
                  //             Color(0XFF34D07F)),
                  //         SizedBox(
                  //           height: 12,
                  //         ),
                  //         _pieChartItem(
                  //             "${S.of(context).lock}  ${Tools.formattingNumComma(_locked)}",
                  //             Color(0XFFFFC106)),
                  //         SizedBox(
                  //           height: 12,
                  //         ),
                  //         _pieChartItem(
                  //             "${S.of(context).undetermined}  ${Tools.formattingNumComma(_pending)}",
                  //             Color(0XFF3CB1F2)),
                  //       ],
                  //     ))
                  //   ],
                  // ),
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
    _historyRequest();
  }

  /// 折线图 币种 布局
  Widget _lineChartCoinTypeItem(String name, bool isShowBg, int position) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_connTypePosition != position) {
          recordList.clear();
          _connTypePosition = position;
          _setRecordData();
          if (mounted) setState(() {});
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: ScreenUtil.getInstance().getWidth(18),
        width: ScreenUtil.getInstance().getWidth(50),
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
              fontSize: ScreenUtil.getInstance().getSp(12),
              color: Color(0XFF3BC87B),
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// 发送执行方法
  _sendOK() {
    if (_user.isValora == 1) {
      RouteTools.startActivity(
        context,
        RouteTools.ADDRESS_SEND,
        address: widget.address,
      );
    } else {
      if (Tools.isNull(_user.privateKey)) {
        Tools.showToast(context, S.of(context).observe_address_no_trading);
      } else {
        RouteTools.startActivity(
          context,
          RouteTools.ADDRESS_SEND,
          address: widget.address,
        );
      }
    }
  }

  /// 折线图 天数 布局
  Widget _lineChartDayItem(String name, bool isShowBg, int position) {
    return GestureDetector(
      onTap: () {
        if (_dayPosition != position) {
          _dayPosition = position;
          if (position == 0) {
            _count = 7;
          } else if (position == 1) {
            _count = 15;
          } else {
            _count = 30;
          }
          _historyRequest();
        }
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

  /// 饼图的 右侧item 布局
  Widget _pieChartItem(String name, Color color) {
    return Row(
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
        Text(
          name,
          style: TextStyle(
              fontSize: ScreenUtil.getInstance().getSp(11),
              color: Color(0xFF48515B)),
        )
      ],
    );
  }

  /// 布局
  Widget _smallItem(String name, String num, String money) {
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
          height: 10,
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
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "≈ ",
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().getSp(13),
                  color: Color(0xFFD1FFE7)),
            ),
            Text(
              money,
              style: TextStyle(
                  color: Color(0xFFD1FFE7),
                  fontWeight: FontWeight.w600,
                  fontSize: ScreenUtil.getInstance().getSp(11)),
            ),
          ],
        )
      ],
    );
  }

  /// 初始化数据
  _initData() async {
    List<Map> addressMap = await SqlManager.queryAddressData(widget.address);
    if (addressMap.isNotEmpty) {
      _user = User.fromJson(addressMap[0]);
      _celoNum = _user.celo;
      _cusdNum = _user.cusd;
      _ceurNum = _user.ceur;
      _available = _user.celoAvailable;
      _locked = _user.celoLocked;
      _pending = _user.celoPending;
      _sections.clear();
      _sections.add(PieChartSectionData(
        value: _available / _celoNum,
        color: Color(0XFF34D07F),
        title: "",
        radius: 20,
        showTitle: false,
      ));
      _sections.add(PieChartSectionData(
        value: _locked / _celoNum,
        color: Color(0XFFFFC106),
        title: "",
        radius: 20,
        showTitle: false,
      ));
      _sections.add(PieChartSectionData(
        value: _pending / _celoNum,
        color: Color(0XFF3CB1F2),
        title: "",
        radius: 20,
        showTitle: false,
      ));
    }
    recordMap = await SqlManager.queryAddressData(widget.address,
        name: SqlManager.RECORD);
    if (recordMap.isNotEmpty) {
      String assetsRecord = recordMap[0]["assetsRecord"] ?? "";
      // print("==$assetsRecord");
      if (!Tools.isNull(assetsRecord)) {
        try {
          _parsingHistory(jsonDecode(assetsRecord));
        } catch (e) {
          print(e);
        }
      }
    }
    setState(() {});
    _historyRequest();
  }

  /// 解析数据
  _parsingHistory(List items) {
    list.clear();
    recordList.clear();
    cELOList.clear();
    cEURList.clear();
    cUSDList.clear();
    cELONumList.clear();
    cEURNumList.clear();
    cUSDNumList.clear();
    _maxY = 1;
    _minY = 0;
    double position = 0;
    for (int i = items.length - 1; i >= 0; i--) {
      List listA = items[i];
      // num allMoney = 0;
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
            // allMoney += num.parse(listA[q]?.toString() ?? "0") * celoPrices;
            num coinNum = num.parse(listA[q]?.toString() ?? "0") * 1.0;
            cELOList.add(FlSpot(position, coinNum.toDouble()));
            cELONumList.add(coinNum);
            break;
          case 2:
            // allMoney += num.parse(listA[q]?.toString() ?? "0") * cusdPrices;
            num coinNum = num.parse(listA[q]?.toString() ?? "0");
            cUSDList.add(FlSpot(position, coinNum.toDouble()));
            cUSDNumList.add(coinNum);
            break;
          case 3:
            num coinNum = num.parse(listA[q]?.toString() ?? "0");
            cEURList.add(FlSpot(position, coinNum.toDouble()));
            cEURNumList.add(coinNum);
            break;
          // default:
          //   allMoney += 1;
          //   break;
        }
      }
      position += 1;
    }
    if (cELONumList.isNotEmpty) {
      cELONumList.sort((a, b) => (b).compareTo(a));
      // print("numList====$cELONumList");
    }
    if (cUSDNumList.isNotEmpty) {
      cUSDNumList.sort((a, b) => (b).compareTo(a));
      // print("numList====$cUSDNumList");
    }
    if (cEURNumList.isNotEmpty) {
      cEURNumList.sort((a, b) => (b).compareTo(a));
      // print("numList====$cEURNumList");
    }
    _setRecordData();
  }

  /// 设置折线图 数据
  _setRecordData() {
    switch (_connTypePosition) {
      case 0:
        _maxY = cELONumList[0].toDouble();
        _minY = cELONumList[cELONumList.length - 1] * 0.99;
        recordList.addAll(cELOList);
        break;
      case 1:
        _maxY = cUSDNumList[0].toDouble();
        _minY = cUSDNumList[cUSDNumList.length - 1] * 0.99;
        recordList.addAll(cUSDList);
        break;
      case 2:
        _maxY = cEURNumList[0].toDouble();
        _minY = cEURNumList[cEURNumList.length - 1] * 0.99;
        recordList.addAll(cEURList);
        break;
    }
  }

  /// 历史资产页面请求
  _historyRequest() async {
    Map<String, dynamic> json = await HttpTools.requestJSONSyncData(
      AppInterface.HISTORY_INTERFACE,
      data: {"address": widget.address, "count": _count},
      context: context,
    );
    try {
      if (json != null && mounted && json['code'] == 1) {
        Map<String, dynamic> result = json['result'];
        HttpTools.timestamp = result['timestamp'];
        List items = result['items'];
        _parsingHistory(items);
        if (_count == 7) {
          if (recordMap == null || recordMap.isEmpty) {
            SqlManager.addRecordData(
                address: widget.address,
                key: "assetsRecord",
                value: jsonEncode(items));
          } else {
            SqlManager.updateMoreFieldData(
                address: widget.address,
                keys: [
                  "assetsRecord",
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
