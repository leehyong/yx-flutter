import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/types.dart';

import '../common.dart';

class TaskHallView extends CommonTaskListView {
  TaskHallView({super.key})
    : super(cats: TaskListCategoryExtension.hallTaskList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("任务大厅", style: defaultTitleStyle),
        actions: [
          ElevatedButton(
            onPressed: () {
              debugPrint("发布了");
              Get.toNamed(
                WorkTaskRoutes.hallTaskPublish,
                id: NestedNavigatorKeyId.hallId,

                arguments: const WorkTaskPageParams(Int64.ZERO, null),
              );
            },
            child: Row(children: [const Text('发布'), Icon(Icons.add)]),
          ),
        ],
      ),
      body: buildTasks(context),
    );
  }
}
