import 'dart:math';

import 'package:dpos/base/BaseTitle.dart';
import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:dpos/tools/view/BtnBgSolid.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 助记词验证界面
/// Date: 3/31/21 4:20 PM
/// Path: page/address/create/view/CreateAddressVerify.dart
class CreateAddressVerify extends StatefulWidget {
  CreateAddressVerify({
    Key key,
    this.onTap,
    this.wordData,
  }) : super(key: key);

  final Function onTap;

  /// 助记词数据
  final String wordData;

  @override
  CreateAddressVerifyState createState() => CreateAddressVerifyState();
}

class CreateAddressVerifyState extends State<CreateAddressVerify>
    with AutomaticKeepAliveClientMixin<CreateAddressVerify> {
  // 更改按钮样式 和 禁用
  GlobalKey<BtnState> btnKey = GlobalKey();

  // 标题的key
  GlobalKey<BaseTitleState> baseTitleKey = GlobalKey();

  /// 填写助记词数据
  List<String> _listWord = new List<String>();

  /// 助记词 24个数据
  List<String> _listWordData = new List<String>();

  /// 随机7个助记词  第四个助记词不显示
  List<String> _listRandomWord = new List<String>();

  /// 位置
  int position = 0;

  //随机数生成类
  Random rng = new Random();

  refresh(String wordData) {
    if (!Tools.isNull(wordData)) {
      _listWordData = wordData.split(" ");
      _listRandomWord = wordData.split(" ");
      _initDate();
      setState(() {});
    }
  }

  /// 随机 7个单词
  _randomWord() {
    _listRandomWord.shuffle();
    String word = _listWordData[position];
    bool isContain = true;
    for (int i = 0; i < 7; i++) {
      if (_listRandomWord[i] == word) {
        isContain = (i == 4);
        break;
      }
    }
    if (isContain) {
      int index = rng.nextInt(7);
      _listRandomWord[index == 4 ? 3 : index] = word;
    }
  }

  /// 设置右上角 按钮
  _setRightBtn() {
    baseTitleKey?.currentState?.setRightBtnList([
      FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: () {
          baseTitleKey?.currentState?.setRightBtnList([Text("")]);
          _initDate();
          setState(() {});
        },
        child: Text(
          S.of(context).all_delete,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ScreenUtil.getInstance().getSp(14),
            height: 1,
            color: Color(0XFF353535),
          ),
        ),
        color: Colors.white,
        highlightColor: Colors.white,
      )
    ]);
  }

  /// 初始化数据
  _initDate() {
    position = 0;
    _listWord.clear();
    _randomWord();
  }

  @override
  void initState() {
    // TODO: implement initState
    if (!Tools.isNull(widget.wordData)) {
      _listWordData = widget.wordData.split(" ");
      _listRandomWord = widget.wordData.split(" ");
    }
    _initDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseTitle(
      key: baseTitleKey,
      title: S.of(context).backup_doc,
      centerTitle: true,
      goBackCallback: () => widget?.onTap?.call(0),
      body: ListView(
        children: [
          GridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: ScreenUtil.getInstance().getWidthPx(69)),
            mainAxisSpacing: 23,
            shrinkWrap: true,
            crossAxisSpacing: 11,
            children: List.generate(24, (index) {
              String name = index < _listWord.length ? _listWord[index] : "";
              bool isSelect = !Tools.isNull(name);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (index < _listWord.length &&
                      !Tools.isNull(_listWord[index])) {
                    position = index;
                    if (index < _listWord.length) {
                      _listWord[index] = "";
                    }
                    _randomWord();
                    setState(() {});
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  //边框设置
                  decoration: BoxDecoration(
                    //背景
                    color: isSelect ? Color(0XFF34D07F) : Color(0XFFF5F5F5),
                    //设置四周圆角 角度
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().getSp(14),
                      color: isSelect ? Colors.white : Color(0XFF4A4A4A),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(
            height: 81,
          ),
          Visibility(
              visible: position < 24,
              child: Text(
                S.of(context).backup_doc_hint_seven(position + 1),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().getSp(14),
                    height: 1.1,
                    color: Color(0XFF252525),
                    fontWeight: FontWeight.w600),
              )),
          Visibility(
              visible: position < 24,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 2.5,
                padding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: ScreenUtil.getInstance().getWidthPx(69)),
                mainAxisSpacing: 23,
                shrinkWrap: true,
                crossAxisSpacing: 11,
                children: List.generate(7, (index) {
                  return index == 4
                      ? SizedBox()
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (position < 24) {
                              if (position < _listWord.length) {
                                _listWord[position] = _listRandomWord[index];
                              } else {
                                _listWord.add(_listRandomWord[index]);
                              }
                              bool isNull = false;
                              for (int i = 0; i < _listWord.length; i++) {
                                if (Tools.isNull(_listWord[i])) {
                                  position = i;
                                  isNull = true;
                                  break;
                                }
                              }
                              if (!isNull) position = _listWord.length;
                              if (position < 24) {
                                _randomWord();
                              }
                              setState(() {});
                            }
                            if (position == 1)
                              _setRightBtn();
                            else if (position == 24) {
                              if (_listWord.length == 24) {
                                bool isEquality = false;
                                for (int i = 0; i < _listWordData.length; i++) {
                                  if (_listWordData[i] != _listWord[i]) {
                                    isEquality = true;
                                    break;
                                  }
                                }
                                if (isEquality) {
                                  Tools.showToast(context,
                                      S.of(context).backup_doc_no_equality);
                                } else {
                                  widget?.onTap?.call(4);
                                }
                              }
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            //边框设置
                            decoration: BoxDecoration(
                              //背景
                              color: Color(0XFFF6F6F6),
                              //设置四周圆角 角度
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                            child: Text(
                              _listRandomWord[index],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ScreenUtil.getInstance().getSp(12),
                                color: Color(0XFF4A4A4A),
                              ),
                            ),
                          ),
                        );
                }),
              )),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
