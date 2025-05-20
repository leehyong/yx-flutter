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
  // static GlobalKey<NavigatorState> rootTabKey = GlobalKey<NavigatorState>();
  final rootTabKey = GlobalKey<ScaffoldState>();
  final curTab = 1.obs;
  final menuOpen = false.obs;
  final _modifyCategories = <ModifyWarningCategory>{}.obs;

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
    final cats = _modifyCategories.map((m) => m.index).toList();
    cats.sort();
    return cats.map((i) => ModifyWarningCategory.values[i].i18name).toList();
  }

  @override
  void onClose() {}

  void setTabIdx(int idx) {
    warnConfirmModifying(() async {
      curTab.value = idx;
      clearModifications();
    });
  }

  void clearModifications() {
    _modifyCategories.value = {};
  }

  void addModification(ModifyWarningCategory modification) {
    _modifyCategories.value.add(modification);
  }

  Future<void> warnConfirmModifying(VoidFutureCallBack cb) async {
    if (modifyCategories.isEmpty) {
      return cb();
    }
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
            mainAxisAlignment: MainAxisAlignment.center,
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
          leftBtnAction: () {
            Navigator.of(buildContext).pop();
          },
          rightBtnAction: () async {
            await cb();
            if (buildContext.mounted) {
              Navigator.of(buildContext).pop();
            }
          },
        );
      },
    );
  }
}
