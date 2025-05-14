import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common.dart';

class TaskHomeBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => UserProvider());
    // Get.lazyPut(() => DutyProvider());
    debugPrint("TaskHomeBinding");
    Get.put(TaskListController(), permanent: true);
    // Get.lazyPut(()=> CommonTaskListCatController());
    // Get.lazyPut(()=> TaskListController());
  }
}
