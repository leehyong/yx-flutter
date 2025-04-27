import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'nest_nav_key.dart' show NestedNavigatorKeyId;
import 'views/dashboard_view.dart';
import 'views/hall_view.dart';
import 'views/home_view.dart';
import 'views/profile_view.dart';

class RootController extends GetxController {}

class RootTabController extends GetxController {
  final curTab = 1.obs;
  final menuOpen = false.obs;

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

  @override
  void onClose() {}

  void setTabIdx(int idx) => curTab.value = idx;
}
