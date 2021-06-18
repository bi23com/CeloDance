import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/page/record/entity/RecordEntity.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/ValoraTool.dart';
import 'package:dpos/tools/WalletTool.dart';
import 'package:dpos/tools/dialog/BaseLoadingDialog.dart';
import 'package:dpos/tools/dialog/TextDialog.dart';
import 'package:dpos/tools/view/RefreshHeadIdle.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dialog/EarningsDialog.dart';
import 'dialog/SortingDialog.dart';
import 'entity/VoteEntity.dart';

/// Describe: 投票记录列表
/// Date: 4/21/21 3:59 PM
/// Path: page/earnings/VoteList.dart
class VoteList extends StatefulWidget {
  VoteList(
      {Key key,
      @required this.address,
      this.type,
      this.walletJson,
      this.nonvoting,
      this.isValora,
      this.voteList})
      : super(key: key);
  final String address;
  final String walletJson;
  final int type; // 0 投票  1 撤票
  final int isValora; // 0 不是   1 是
  final num nonvoting; // 已锁未投票
  final List<VoteEntity> voteList;

  @override
  _VoteListState createState() => _VoteListState();
}

class _VoteListState extends State<VoteList> {
  // 刷新的方法
  RefreshController _refreshCon = RefreshController(initialRefresh: false);
  BaseLoadingDialog _baseLoadingDialog;

  // 显示view 1 显示主布局
  int _isShowView = 0;
  List<VoteEntity> _list = List.empty(growable: true);
  List<VoteEntity> _voteList = List.empty(growable: true);

  /// 排序 true 按照总票数排序  false 按照我的投票数
  bool _isSorting = false;

  /// 按钮背景颜色
  Color btnColor;
  Color btnTextColor;

  /// 按钮名称
  String btnName;
  String title;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.voteList != null) _voteList.addAll(widget.voteList);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 0) {
      btnColor = Color(0XFF34D07F);
      btnTextColor = Colors.white;
      btnName = S.of(context).vote;
      title = S.of(context).select_validation_group;
    } else {
      // btnColor = Color(0XFFEEEEEE);
      // btnTextColor = Color(0XFF2E3339);
      btnColor = Color(0XFF34D07F);
      btnTextColor = Colors.white;
      btnName = S.of(context).revoke;
      title = S.of(context).revoke;
    }
    return BaseTitle(
      title: title,
      backgroundColor: Color(0XFFFAFAFA),
      appBarBackgroundColor: Color(0XFFFAFAFA),
      rightLeading: [
        GestureDetector(
          onTap: () {
            SortingDialog(
                context: context,
                sortingName: _isSorting
                    ? S.of(context).vote_sort_one
                    : S.of(context).vote_sort_two,
                sortingClick: (isSorting) {
                  _isSorting = isSorting;
                  if (_list.length > 1) {
                    _list.sort((a, b) => _isSorting
                        ? (b.votes).compareTo(a.votes)
                        : (b.pending + b.active)
                            .compareTo(a.pending + a.active));
                    if (mounted) setState(() {});
                  }
                }).show();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              "assets/img/cd_sr_screening_icon.png",
              width: ScreenUtil.getInstance().getWidth(20),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ],
      body: ScrollConfiguration(
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
              child: _getHomeLayout())),
    );
  }

  /*
   * 下拉刷新用到的方法
   */
  Future<void> _onRefresh() async {
    if (widget.type == 0) {
      _getGroupList();
    } else {
      _getVoteList();
    }
  }

  Widget _getHomeLayout() {
    if (_isShowView == 1) {
      return _list.length == 0
          ? Padding(
              padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil.getInstance().getWidthPx(190)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    "assets/img/cd_no_address_record_icon.png",
                    width: ScreenUtil.getInstance().getWidth(283),
                    fit: BoxFit.fitWidth,
                  ),
                  Text(
                    S.of(context).no_record,
                    style: TextStyle(
                        color: Color(0XFFA6A6A6),
                        fontSize: ScreenUtil.getInstance().getSp(15)),
                  )
                ],
              ),
            )
          : ListView.separated(
              // physics: NeverScrollableScrollPhysics(), //禁用滑动事件
              padding: EdgeInsets.only(bottom: 15),
              itemCount: _list.length,
              itemBuilder: (cont, index) {
                return _item(_list[index]);
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 15,
                );
              },
            );
    } else {
      return Text("");
    }
  }

  /// 列表布局
  Widget _item(VoteEntity voteEntity) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil.getInstance().getWidth(10),
        vertical: ScreenUtil.getInstance().getWidth(15),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
              color: Color(0X80DBDBDB),
              offset: Offset(0.0, 2.0), //阴影y轴偏移量
              blurRadius: 3, //阴影模糊程度
              spreadRadius: 1 //阴影扩散程度
              )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipOval(
                  child: CachedNetworkImage(
                imageUrl: voteEntity.logo ?? "",
                fit: BoxFit.fitWidth,
                width: ScreenUtil.getInstance().getWidth(20),
                errorWidget: (context, url, error) => SizedBox(
                  width: ScreenUtil.getInstance().getWidth(20),
                  child: Image.asset(
                    "assets/img/cd_validation_group_logo.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
                placeholder: (context, url) => SizedBox(
                  width: ScreenUtil.getInstance().getWidth(20),
                ),
              )),
              SizedBox(
                width: 6,
              ),
              Text(
                voteEntity.name.length > 25
                    ? voteEntity.name.substring(0, 20) + "..."
                    : Tools.isNull(voteEntity.name)
                        ? S.of(context).unnamed
                        : voteEntity.name,
                style: TextStyle(
                    color: Color(0xFF2E3339),
                    fontWeight: FontWeight.w600,
                    fontSize: ScreenUtil.getInstance().getSp(13)),
              ),
              Expanded(
                  child: Text(
                voteEntity.address.length > 12
                    ? (voteEntity.address.substring(0, 6) +
                        "....." +
                        voteEntity.address.substring(
                            voteEntity.address.length - 6,
                            voteEntity.address.length))
                    : voteEntity.address,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenUtil.getInstance().getSp(12)),
              ))
            ],
          ),
          SizedBox(
            height: ScreenUtil.getInstance().getWidth(10),
          ),
          Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        text: S.of(context).total_vote,
                        style: TextStyle(
                            color: Color(0xFFA4A4A4),
                            fontSize: ScreenUtil.getInstance().getSp(12)),
                        children: [
                          TextSpan(
                            text:
                                "  ${Tools.formattingNumComma(voteEntity.votes)}",
                            style: TextStyle(
                              color: Color(0xFF2E3339),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil.getInstance().getSp(12),
                            ),
                          ),
                          TextSpan(
                            text: " CELO",
                            style: TextStyle(
                              color: Color(0xFFB4B4B4),
                              fontSize: ScreenUtil.getInstance().getSp(10),
                            ),
                          ),
                        ]),
                  ),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        text: S.of(context).have_vote,
                        style: TextStyle(
                            color: Color(0xFFA4A4A4),
                            fontSize: ScreenUtil.getInstance().getSp(12)),
                        children: [
                          TextSpan(
                            text:
                                "  ${Tools.formattingNumComma(voteEntity.active + voteEntity.pending)}",
                            style: TextStyle(
                              color: Color(0xFF2E3339),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil.getInstance().getSp(12),
                            ),
                          ),
                          TextSpan(
                            text: " CELO",
                            style: TextStyle(
                              color: Color(0xFFB4B4B4),
                              fontSize: ScreenUtil.getInstance().getSp(10),
                            ),
                          ),
                        ]),
                  ),
                ],
              )),
              SizedBox(
                  width: ScreenUtil.getInstance().getWidth(80),
                  height: ScreenUtil.getInstance().getWidth(24),
                  child: FlatButton(
                    disabledTextColor: Color(0XFFFFFFFF),
                    disabledColor: Color(0XFFA6A6A6),
                    padding: EdgeInsets.zero,
                    //画圆角
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    onPressed: () async {
                      /// type 属性 1 锁定  2 解锁  3 投票   4 撤票   5取回  6 激活
                      if (Tools.isNull(widget.walletJson) &&
                          widget.isValora == 0) {
                        Tools.showToast(
                            context, S.of(context).observe_address_no_trading);
                      } else {
                        _ticketVote(voteEntity);
                      }
                    },
                    child: Text(
                      btnName,
                      style: TextStyle(
                        fontSize: ScreenUtil.getInstance().getSp(13),
                      ),
                    ),
                    color: btnColor,
                    textColor: btnTextColor,
                    highlightColor: btnColor.withAlpha(80),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  /// 撤票 投票方法
  _ticketVote(VoteEntity voteEntity) async {
    if (widget.type == 0) {
      if (widget.isValora == 1) {
        if (widget.voteList == null || widget.voteList.isEmpty) {
          _baseLoadingDialog?.show(loadText: S.of(context).load_text);
          Respond respond = await isAccount(widget.address);
          if (mounted) _baseLoadingDialog?.hide();
          if (respond.code == 0) {
            if (respond.data) {
              _voteDialog(voteEntity.address);
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
                    createAccountByValora(widget.address);
                  }).show();
            }
          } else {
            Tools.showToast(context, respond.msg?.toString());
          }
        } else {
          _voteDialog(voteEntity.address);
        }
      } else {
        _voteDialog(voteEntity.address);
      }
    } else {
      EarningsDialog(
              context: context,
              coinNum: voteEntity.active + voteEntity.pending,
              address: widget.address,
              type: 4,
              toAddress: voteEntity.address,
              pending: voteEntity.pending,
              active: voteEntity.active,
              isValora: widget.isValora,
              walletJson: widget.walletJson,
              title: S.of(context).revoke_from,
              exitDialog: () {
                Navigator.of(context).pop();
              },
              btnName: btnName)
          .show();
    }
  }

  /// 投票弹窗
  _voteDialog(String address) {
    EarningsDialog(
            context: context,
            coinNum: widget.nonvoting,
            address: widget.address,
            type: 3,
            toAddress: address,
            isValora: widget.isValora,
            walletJson: widget.walletJson,
            title: S.of(context).vote_to,
            exitDialog: () {
              Navigator.of(context).pop();
            },
            btnName: btnName)
        .show();
  }

  /// 初始化数据
  _initData() async {
    _baseLoadingDialog = BaseLoadingDialog(context);
    if (widget.type == 0) {
      if (Tools.isNull(SpUtil.getString(SpUtilConstant.VOTING_GROUP_KEY))) {
        _refreshCon?.requestRefresh();
      } else {
        // _parsingData(
        //     jsonDecode(SpUtil.getString(SpUtilConstant.VOTING_GROUP_KEY))['list'],
        //     false);
        _onRefresh();
      }
    } else {
      /// 撤票
      if (widget.voteList.length > 0) {
        _isShowView = 1;
        _list.clear();
        if (widget.voteList != null) _list.addAll(widget.voteList);
        if (_list.length > 1)
          _list.sort((a, b) => _isSorting
              ? (b.votes).compareTo(a.votes)
              : (b.pending + b.active).compareTo(a.pending + a.active));
        if (mounted) setState(() {});
        _refreshCon?.refreshCompleted();
      } else {
        _refreshCon?.requestRefresh();
      }
    }
  }

  /// 获取 验证组列表
  _getGroupList() async {
    Respond respond = await getEligibleValidatorGroups();
    if (mounted) {
      if (respond.code == 0) {
        LogUtil.v("验证组====${respond.data}");
        _parsingData(respond.data, true);
        _refreshCon?.refreshCompleted();
      } else {
        if (_list.isNotEmpty) {
          _refreshCon?.refreshFailed();
        } else {
          _getGroupList();
        }
      }
    }
  }

  /// 获取 投票列表
  _getVoteList() async {
    Respond value = await getVotedList(widget.address);
    if (mounted) {
      if (value.code == 0) {
        print("value====${value.data}");
        _list.clear();
        _isShowView = 1;
        List list = value.data['voted'];
        if (list != null) {
          list.forEach((element) {
            _list.add(VoteEntity.formJson(element));
          });
          _list.sort((a, b) => _isSorting
              ? (b.votes).compareTo(a.votes)
              : (b.pending + b.active).compareTo(a.pending + a.active));
          setState(() {});
        }
        _refreshCon?.refreshCompleted();
      } else {
        _getVoteList();
      }
    }
  }

  /// 解析 数据
  _parsingData(List list, bool isStorage) {
    _isShowView = 1;
    _list.clear();
    if (isStorage) {
      // LogUtil.v("2======${jsonEncode({"list": list})}");
      // SpUtil.putString(
      //     SpUtilConstant.VOTING_GROUP_KEY, jsonEncode({"list": list}));
    }

    ///  type; // 0 投票  1 撤票
    if (widget.type == 0) {
      if (widget.voteList != null) _voteList.addAll(widget.voteList);
      list.forEach((element) {
        // print("element===$element");
        VoteEntity voteEntity = VoteEntity.formGroupJson(element);
        for (int i = 0; i < _voteList.length; i++) {
          if (_voteList[i].address?.toLowerCase() ==
              voteEntity.address?.toLowerCase()) {
            voteEntity.active = _voteList[i].active ?? 0;
            voteEntity.pending = _voteList[i].pending ?? 0;
            _voteList.removeAt(i);
            break;
          }
        }
        _list.add(voteEntity);
      });
    } else {
      if (widget.voteList != null) _list.addAll(widget.voteList);
    }
    if (_list.length > 1)
      _list.sort((a, b) => _isSorting
          ? (b.votes).compareTo(a.votes)
          : (b.pending + b.active).compareTo(a.pending + a.active));
    if (mounted) setState(() {});
  }
}
