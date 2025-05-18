import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/work-task/task-info/controller.dart';

import '../common.dart';

class TaskHallBinding implements Bindings {
  @override
  void dependencies() {
    debugPrint("TaskHallBinding");
    Get.put(TaskListController(), permanent: true);
    Get.lazyPut(() => SubmitTasksController());
    Get.lazyPut(() => TaskInfoController());
  }
}
