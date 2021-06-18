/// Describe: 广播工具类
/// Date: 3/29/21 11:02 AM
/// Path: tools/EventBusTools.dart

import 'package:event_bus/event_bus.dart';

class EventBusTools {
  static EventBus _eventBus;

  static EventBus getEventBus() {
    if (_eventBus == null) {
      _eventBus = EventBus();
    }
    return _eventBus;
  }
}

/// 登录成功事件
class LoginSuccessEvent {
  final bool isFromMine;

  LoginSuccessEvent(this.isFromMine);
}

/// 设置默认,解除绑定银行卡之后通知事件
class RefreshBankCardEvent {
  final int id;
  final bool isDel; //判断是否是删除
  RefreshBankCardEvent(this.id, this.isDel);
}

///切换主页面事件
class SwitchMainPageEvent {
  final int index;

  SwitchMainPageEvent(this.index);
}

///刷新用户信息
class RefreshUserInfoEvent {}

///刷新小红点事件
class RefreshRedDotEvent {}

///刷新tabbar小红点
class RefreshTabBarRedEvent {}

/// 支付通知 事件
class PayNotificationEvent {
  bool payResults; // 支付是否成功
  int payCode; // 银联支付code
  String hint; // 提示

  PayNotificationEvent({this.payResults, this.payCode, this.hint});

  PayNotificationEvent.fromJson(Map<dynamic, dynamic> json) {
    payResults = json['payResults'] ?? false;
    payCode = json['payCode'] ?? 0;
    hint = json['hint'] ?? "";
  }
}
