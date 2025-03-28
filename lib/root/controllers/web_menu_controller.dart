import 'package:yx/root/controllers/tab_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';


class RootWebMenuController extends RootTabController {
  final menuOpen = false.obs;
  static RootWebMenuController get to => Get.find();
  void toggleMenuOpen() => menuOpen.value = !menuOpen.value;
}
