import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/types.dart';

class PublishTaskController extends GetxController {
  final GlobalKey formKey = GlobalKey<FormState>();
  final taskNameController = TextEditingController();
  final taskContentController = TextEditingController();
  final taskPlanStartDtController = TextEditingController();
  final taskPlanEndDtController = TextEditingController();
  final taskReceiveDeadlineController = TextEditingController();
  final taskReceiverQuotaLimitedController = TextEditingController();
  final taskContactorController = TextEditingController();
  final taskContactPhoneController = TextEditingController();
  final taskCreditsController = TextEditingController();
  final taskReceiveStrategy = ReceiveTaskStrategy.twoWaySelection.obs;
  final taskCreditStrategy = TaskCreditStrategy.latest.obs;
  final selectedAttrSet = {TaskAttributeCategory.basic}.obs;
  final   selectedPersons = <String>[].obs;
  PublishTaskController() {
  }

  @override
  void onClose() {
    // _timer.cancel(); // 在控制器销毁时取消定时器
    super.onClose();
  }

  // 定时器


  // final selections = ['参与的','历史的', '委派的', '发布的'];
  // final actions = ['已发布','我的发布', '我的草稿',];
}
