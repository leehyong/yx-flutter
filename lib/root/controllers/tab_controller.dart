import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/dashboard_view.dart';
import '../views/hall_view.dart';
import '../views/home_view.dart';
import '../views/profile_view.dart';

class RootTabController extends GetxController {
  final curTab = 1.obs;

  static RootTabController get to => Get.find();
  static List menus = [
    {"icon": Icon(Icons.home), "label": "首页"},
    {"icon": Icon(Icons.corporate_fare), "label": "任务大厅"},
    {"icon": Icon(Icons.window), "label": "工作台"},
    // todo: 增加设置页，用于组织、数据字典等的管理操作
    {"icon": Icon(Icons.person), "label": "个人中心"},
  ];
  List bodyPageList = [HomeView(), HallView(), DashboardView(), ProfileView()];

  Widget get curTabView => bodyPageList[curTab.value];

  @override
  void onClose() {}

  void setTabIdx(int idx) => curTab.value = idx;
}
