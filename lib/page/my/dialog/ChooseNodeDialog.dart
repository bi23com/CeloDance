import 'package:dpos/generated/l10n.dart';
import 'package:dpos/tools/NoScrollBehavior.dart';
import 'package:dpos/tools/SpUtilConstant.dart';
import 'package:dpos/tools/SqlManager.dart';
import 'package:dpos/tools/Tools.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Describe: 选择节点 弹窗
/// Date: 4/14/21 3:38 PM
/// Path: page/my/dialog/ChooseNodeDialog.dart
class ChooseNodeDialog {
  final BuildContext context;
  final Function onItemClick;
  String node;
  List<String> list = List.empty(growable: true);

  ChooseNodeDialog({@required this.context, this.onItemClick});

  Future<void> show() async {
    node = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
    list.add("https://celo.dance/node");
    list.add("https://forno.celo.org");
    List<String> listC = SpUtil.getStringList(SpUtilConstant.NODE_CUSTOM_KEY);
    if (listC != null && listC.length > 0) {
      list.addAll(listC);
    }
    // list.add(S.of(context).custom_node);
    int length = list.length;
    // int position = 0;
    // for (int i = 0; i < length; i++) {
    //   if (list[i] == node) {
    //     position = i;
    //     break;
    //   }
    // }
    // ScrollController scrollController = ScrollController(
    //     initialScrollOffset: position * ScreenUtil.getInstance().getWidth(60));
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            // constraints: BoxConstraints(
            //     maxHeight: ScreenUtil.getInstance().screenHeight / 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: ScrollConfiguration(
                behavior: NoScrollBehavior(),
                child: ListView.builder(
                  itemCount: length,
                  // controller: scrollController,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _item(list[index]);
                  },
                )),
          );
        });
  }

  Widget _item(String name) {
    double size17 = ScreenUtil.getInstance().getWidth(17);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
        onItemClick?.call(name);
      },
      child: Container(
        height: ScreenUtil.getInstance().getWidth(60),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: size17,
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                          color: Color(0XFF404044),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenUtil.getInstance().getSp(15)),
                    ),
                  ),
                  Visibility(
                      visible: name == node,
                      child: Icon(Icons.check_outlined,
                          color: Color(0xFF34D07F),
                          size: ScreenUtil.getInstance().getWidth(20))),
                  SizedBox(
                    width: size17,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: size17),
              height: 0.5,
              color: Color(0XA1DEDEDE),
            ),
          ],
        ),
      ),
    );
  }
}

// class ChooseNode extends StatefulWidget {
//   ChooseNode({Key key, this.onItemClick}) : super(key: key);
//   final Function onItemClick;
//
//   @override
//   _ChooseNodeState createState() => _ChooseNodeState();
// }
//
// class _ChooseNodeState extends State<ChooseNode> {
//   String node;
//   List<String> list = List.empty(growable: true);
//   ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     node = SpUtil.getString(SpUtilConstant.NODE_ADDRESS_KEY);
//     list.add("https://celo.dance/node");
//     list.add("https://forno.celo.org");
//     List<String> listC = SpUtil.getStringList(SpUtilConstant.NODE_CUSTOM_KEY);
//     if (listC != null && listC.length > 0) {
//       list.addAll(listC);
//     }
//     list.add(S.of(context).custom_node);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.jumpTo(value);
//     });
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _scrollController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       child: GestureDetector(
//           onTap: () {
//             Navigator.of(context).pop();
//           },
//           child: Container(
//             constraints: BoxConstraints(
//                 maxHeight: ScreenUtil.getInstance().screenHeight / 2),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10), topRight: Radius.circular(10)),
//             ),
//             child: ScrollConfiguration(
//                 behavior: NoScrollBehavior(),
//                 child: ListView.builder(
//                   itemCount: list.length,
//                   controller: _scrollController,
//                   padding: EdgeInsets.only(
//                       bottom: MediaQuery.of(context).padding.bottom),
//                   // shrinkWrap: true,
//                   // physics: NeverScrollableScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     return _item(list[index], angle: index == 0 ? 10 : 0);
//                   },
//                 )),
//           )),
//       onWillPop: () {
//         Navigator.pop(context);
//         return Future.value(false);
//       },
//     );
//   }
//
//   Widget _item(String name, {double angle = 0}) {
//     double size17 = ScreenUtil.getInstance().getWidth(17);
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () {
//         Navigator.pop(context);
//         widget.onItemClick?.call(name);
//       },
//       child: Container(
//         height: ScreenUtil.getInstance().getWidth(60),
//         child: Column(
//           children: [
//             Expanded(
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: size17,
//                   ),
//                   Expanded(
//                     child: Text(
//                       name,
//                       style: TextStyle(
//                           color: Color(0XFF404044),
//                           fontWeight: FontWeight.w600,
//                           fontSize: ScreenUtil.getInstance().getSp(15)),
//                     ),
//                   ),
//                   Visibility(
//                       visible: name == node,
//                       child: Icon(Icons.check_outlined,
//                           color: Color(0xFF34D07F),
//                           size: ScreenUtil.getInstance().getWidth(20))),
//                   SizedBox(
//                     width: size17,
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               margin: EdgeInsets.only(left: size17),
//               height: 0.5,
//               color: Color(0XA1DEDEDE),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
