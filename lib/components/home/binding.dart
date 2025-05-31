import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/work-task/task-info/controller.dart';


class TaskHomeBinding implements Bindings {
  @override
  void dependencies() {
    debugPrint("TaskHomeBinding");
    Get.put(TaskInfoController(), permanent: true);
  }
}
