import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../controllers/tab_controller.dart';

class RootBottomTabView extends GetView<RootTabController> {
  const RootBottomTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // const title =  Get.routing; "112233";
    var title = Get.routing.route?.settings.name ?? 'default';
    return Container(
      color: Colors.red,
      width: MediaQuery.of(context).size.width,
      child: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.curTab.value,
          // 点击事件,获取当前点击的标签下标
          onTap: (index) {
            RootTabController.to.setTabIdx(index);
          },
          iconSize: 30.0,
          fixedColor: Colors.red,
          type: BottomNavigationBarType.fixed,
          items: List.from(
            RootTabController.menus.map(
              (ele) => BottomNavigationBarItem(
                icon: ele['icon'],
                label: ele['label'],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
