import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/task_controller.dart';

class TaskDetailView1 extends GetView<TaskDetailController> {
  const TaskDetailView1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("detail")),
      body: Text("detail1"),
    );
  }
}
