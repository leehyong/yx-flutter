import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/work-task/task-list/view.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/types.dart';


class TaskHallView extends StatelessWidget {
  const TaskHallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("任务大厅", style: defaultTitleStyle),
        actions: [
          ElevatedButton(
            onPressed: () {
              debugPrint("发布了");
              // Get.find<TaskInfoController>().reset();
              const args = WorkTaskPageParams(
                Int64.ZERO,
                null,
                TaskListCategory.allPublished,
              );
              Get.toNamed(
                WorkTaskRoutes.hallTaskPublish,
                id: NestedNavigatorKeyId.hallId,
                arguments: args,
              );
            },
            child: Row(children: [const Text('新建'), Icon(Icons.add)]),
          ),
        ],
      ),
      body: TaskListView(cats: TaskListCategoryExtension.hallTaskList),
    );
  }
}
