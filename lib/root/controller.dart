import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:yx/types.dart';

import 'nest_nav_key.dart' show NestedNavigatorKeyId;
import 'views/dashboard_view.dart';
import 'views/hall_view.dart';
import 'views/home_view.dart';
import 'views/profile_view.dart';

class RootTabController extends GetxController {
  // GlobalKey， 使用GlobalKey， 可以让showGeneralDialog不需要每次都传递BuildContext对象
  final rootTabKey = GlobalKey<ScaffoldState>();
  final curTab = 1.obs;
  final menuOpen = false.obs;
  // LinkedHashMap 保证插入顺序，以便函数按照正确的顺序执行
  final _modifyCategories =
      (LinkedHashMap<VoidFutureCallBack, HashSet<ModifyWarningCategory>>())
          .obs;

  static RootTabController get to => Get.find();
  static List menus = [
    {
      "icon": Icon(Icons.home),
      "label": "首页",
      "routeId": NestedNavigatorKeyId.homeId,
    },
    {
      "icon": Icon(Icons.corporate_fare),
      "label": "任务大厅",
      "routeId": NestedNavigatorKeyId.hallId,
    },
    {
      "icon": Icon(Icons.window),
      "label": "工作台",
      "routeId": NestedNavigatorKeyId.dashboardId,
    },
    // todo: 增加设置页，用于组织、数据字典等的管理操作
    {
      "icon": Icon(Icons.person),
      "label": "个人中心",
      "routeId": NestedNavigatorKeyId.userCenterId,
    },
  ];
  List bodyPageList = [HomeView(), HallView(), DashboardView(), ProfileView()];

  Widget get curTabView => bodyPageList[curTab.value];

  int get curRouteId => menus[curTab.value]['routeId'];

  void toggleMenuOpen() => menuOpen.value = !menuOpen.value;

  List<String> get modifyCategories {
    final cats =
        _modifyCategories.value.values.fold(<ModifyWarningCategory>{}, (
          prev,
          item,
        ) {
          prev.addAll(item);
          return prev;
        }).toList();
    cats.sort((a, b) => a.index.compareTo(b.index));
    return cats.map((i) => i.i18name).toList();
  }

  @override
  void onClose() {}

  void setTabIdx(int idx) {
    // bugfix： 确认和取消时， 不知道 具体业务逻辑是什么。
    warnConfirmModifying(
      finalCb: () async {
        curTab.value = idx;
        clearModifications();
      },
    );
  }

  void clearModifications() {
    _modifyCategories.value.clear();
  }

  void addModification(
    VoidFutureCallBack cb,
    ModifyWarningCategory modification,
  ) {
    _modifyCategories.value.putIfAbsent(cb, () => HashSet()).add(modification);
  }

  Future<void> warnConfirmModifying({
    VoidFutureCallBack? cancelCb,
    VoidFutureCallBack? finalCb,
  }) async {
    if (modifyCategories.isEmpty) {
      // if (confirmCb != null) {
      //   await confirmCb();
      // }
      if (finalCb != null) {
        await finalCb();
      }
    } else {
      showGeneralDialog(
        context: rootTabKey.currentContext!,
        pageBuilder: (
          BuildContext buildContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return TDAlertDialog(
            title: "以下信息有修改, 确定保存吗？",
            contentWidget: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  modifyCategories
                      .map(
                        (cat) => Text(
                          cat,
                          style: TextStyle(
                            fontSize: 16,
                            color: warningColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      .toList(),
            ),
            leftBtnAction: () async {
              if (cancelCb != null) {
                await cancelCb();
              }
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
              if (finalCb != null) {
                await finalCb();
              }
            },
            rightBtnAction: () async {
              // 逐个调用所有确认时的函数
              for (var fn in _modifyCategories.value.keys) {
                await fn.call();
              }
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
              if (finalCb != null) {
                await finalCb();
              }
            },
          );
        },
      );
    }
  }
}
