import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          GetPlatform.isWeb
              ? Row(
                children: [
                  RootWebMenuView(),
                  Expanded(child: Obx(() => RootTabController.to.curTabView)),
                ],
              )
              : Obx(() => RootTabController.to.curTabView),
      bottomNavigationBar:
          GetPlatform.isMobile ? RootMobileBottomTabView() : null,
    );
  }
}

class RootWebMenuView extends GetView<RootTabController> {
  const RootWebMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => NavigationRail(
        selectedLabelTextStyle: TextStyle(color: Colors.red),
        // leading: const Icon(Icons.menu_open,color: Colors.grey,),
        leading: IconButton(
          tooltip: '菜单',
          onPressed: () => controller.toggleMenuOpen(),
          icon:
              controller.menuOpen.value
                  ? const Icon(Icons.menu_open, color: Colors.red)
                  : const Icon(Icons.menu, color: Colors.grey),
        ),
        destinations: List.from(
          RootTabController.menus.map(
            (ele) => NavigationRailDestination(
              icon: ele['icon'],
              label: Text(ele['label']),
            ),
          ),
        ),
        //[
        // extended: true,
        elevation: 2,
        extended: controller.menuOpen.value,
        selectedIndex: RootTabController.to.curTab.value,
        onDestinationSelected: (idx) => RootTabController.to.setTabIdx(idx),
      ),
    );
  }
}

class RootMobileBottomTabView extends GetView<RootTabController> {
  const RootMobileBottomTabView({super.key});

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
