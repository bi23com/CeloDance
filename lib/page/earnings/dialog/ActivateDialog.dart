import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_ui/cool_ui.dart';
import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/page/address/dialog/PinPawDialog.dart';
import 'package:dpos/page/address/entity/SendHomeEntity.dart';
import 'package:dpos/page/earnings/entity/VoteEntity.dart';
import 'package:dpos/page/record/SendRecordDetails.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/Content.dart';
import 'package:dpos/tools/EventBusTools.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/RouteTools.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

/// Describe: 激活 dialog
/// Date: 4/27/21 1:32 PM
/// Path: page/earnings/dialog/ActivateDialog.dart
class ActivateDialog {
  final BuildContext context;

  /// 投票记录列表
  final List<VoteEntity> voteList;
  final String address;
  final String walletJson;
  final int isValora;

  ActivateDialog(
      {@required this.context,
      this.voteList,
      this.address,
      this.walletJson,
      this.isValora});

  Future<void> show() async {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true, //一：设为true，此时为全屏展示
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SizedBox(
            height: ScreenUtil.getInstance().screenHeight * 0.5,
            child: Activate(
              voteList: voteList,
              isValora: isValora,
              address: address,
              walletJson: walletJson,
            ),
          );
        });
  }
}

class Activate extends StatefulWidget {
  Activate(
      {Key key,
      @required this.voteList,
      this.address,
      this.walletJson,
      this.isValora})
      : super(key: key);
  final List<VoteEntity> voteList;
  final String address;
  final String walletJson;
  final int isValora;

  @override
  _ActivateState createState() => _ActivateState();
}

class _ActivateState extends State<Activate> {
  List<VoteEntity> _voteList = List.empty(growable: true);
  int hours = 0;
  int minutes = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Tools.activationTime > 0) {
      int time = Tools.activationTime - Tools.currentTimeMillis();
      hours = time ~/ (60 * 60 * 1000);
      minutes = (time - hours * 3600000) ~/ 60000;
    }
    // print("value.1===${Tools.activationTime}");
    // var today = DateTime.now();
    // DateTime fiftyDaysFromNow = today.add(Duration(days: 1));
    // time =
    //     "${fiftyDaysFromNow.month < 10 ? "0" : ""}${fiftyDaysFromNow.month}-${fiftyDaysFromNow.day < 10 ? "0" : ""}${fiftyDaysFromNow.day} 00:00";
    if (widget.voteList != null) {
      widget.voteList.forEach((element) {
        if (element.pending > 0) _voteList.add(element);
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                S.of(context).activation,
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(14),
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF4A4A4A)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.getInstance().getWidth(12),
                          vertical: ScreenUtil.getInstance().getWidth(13)),
                      child: Image.asset(
                        "assets/img/cd_close_icon.png",
                        height: ScreenUtil.getInstance().getWidth(13),
                        fit: BoxFit.fitHeight,
                      ),
                    )),
              )
            ],
          ),
          Expanded(
              child: ScrollConfiguration(
                  behavior: NoScrollBehavior(),
                  child: ListView.separated(
                    itemCount: _voteList.length,
                    // shrinkWrap: true,
                    // physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _item(_voteList[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Tools.getLine(left: 14),
                  )))
        ],
      ),
    );
  }

  _item(VoteEntity voteEntity) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 18,
          ),
          ClipOval(
              child: CachedNetworkImage(
            imageUrl: voteEntity.logo ?? "",
            fit: BoxFit.fitWidth,
            width: ScreenUtil.getInstance().getWidth(29),
            errorWidget: (context, url, error) => SizedBox(
              width: ScreenUtil.getInstance().getWidth(29),
              child: Image.asset(
                "assets/img/cd_validation_group_logo.png",
                fit: BoxFit.fitWidth,
              ),
            ),
            placeholder: (context, url) => SizedBox(
              width: ScreenUtil.getInstance().getWidth(29),
            ),
          )),
          SizedBox(
            width: 12,
          ),
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                voteEntity.name.length > 15
                    ? voteEntity.name.substring(0, 15) + "..."
                    : voteEntity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenUtil.getInstance().getSp(12)),
              ),
              Text(
                voteEntity.address.length > 12
                    ? voteEntity.address.replaceRange(
                        8, voteEntity.address.length - 8, "......")
                    : voteEntity.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0xFFC1C6C9),
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenUtil.getInstance().getSp(11)),
              ),
            ],
          )),
          Column(
            children: [
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                text: TextSpan(
                    text: " ${Tools.formattingNumComma(voteEntity.pending)}",
                    style: TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenUtil.getInstance().getSp(12)),
                    children: [
                      TextSpan(
                        text: " CELO",
                        style: TextStyle(
                            color: Color(0xFFA6A6A6),
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenUtil.getInstance().getSp(12)),
                      ),
                    ]),
              ),
              Visibility(
                  visible: !voteEntity.pendingIsActivatable &&
                      voteEntity.pending > 0 &&
                      hours > 0 &&
                      minutes > 0,
                  child: Text(
                    S.of(context).activate_remaining_time_one(hours) +
                        S.of(context).activate_remaining_time_two(minutes),
                    style: TextStyle(
                        color: Color(0xFFC1C6C9),
                        fontSize: ScreenUtil.getInstance().getSp(10)),
                  )),
            ],
          ),
          SizedBox(
            width: 15,
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
                    voteEntity.pendingIsActivatable && voteEntity.pending > 0
                        ? () {
                            if (widget.isValora == 1) {
                              btnOk(voteEntity, "");
                            } else {
                              PinPawDialog(
                                      context: context,
                                      onOk: (paw) async {
                                        btnOk(voteEntity, paw);
                                      },
                                      payPawBehavior: SpUtil.getBool(
                                              SpUtilConstant.IS_PASSWORD,
                                              defValue: false)
                                          ? PinPawBehavior.use
                                          : PinPawBehavior.open)
                                  .show();
                            }
                          }
                        : null,
                child: Text(
                  S.of(context).activation,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(11),
                      height: 1.1),
                ),
                color: Color(0XFF2BC374),
                textColor: Colors.white,
                highlightColor: Colors.green.withAlpha(80),
              )),
          SizedBox(
            width: 12,
          ),
        ],
      ),
    );
  }

  btnOk(VoteEntity voteEntity, String paw) {
    int timeM = Tools.currentTimeMillis();
    var strtime = DateTime.fromMillisecondsSinceEpoch(timeM);
    RecordEntity recordEntity = RecordEntity(
        rollOutAddress: widget.address,
        receiveAddress: voteEntity.address,
        count: voteEntity.pending,
        coinName: "CELO",
        type: 6,
        tag: "vote",
        time: strtime.toLocal().toString().split(".")[0] ?? "",
        timeStamp: timeM.toString(),
        state: 0);
    Tools.voteList.add(recordEntity);
    EventBusTools.getEventBus()?.fire(SendHomeEntity(
        name: "voteData",
        count: voteEntity.pending,
        coinName: "CELO",
        address: widget.address,
        tip: "vote",
        isValora: widget.isValora,
        voteEntity: voteEntity,
        toAddress: voteEntity.address,
        pending: voteEntity.pending,
        type: 6,
        apiUrl: SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY),
        privateKey: widget.walletJson,
        paw: paw,
        timeM: timeM.toString()));
    Navigator.of(context).pop();
    if (widget.isValora == 0) {
      RouteTools.startActivity(context, RouteTools.SEND_RECORD_DETAILS,
          address: widget.address,
          recordEntity: recordEntity,
          detailsEnum: DetailsEnum.vote);
    }
  }
}
