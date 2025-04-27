import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/types.dart';

import '../work-task/task-list/view.dart';
import 'controller.dart';

class TaskHallView extends GetView<TaskHallController> {
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
              Get.toNamed(
                WorkTaskRoutes.hallTaskPublish,
                id: NestedNavigatorKeyId.hallId,

                arguments: const HallPublishTaskParams(
                  Int64.ZERO,
                  NestedNavigatorKeyId.hallId,
                  null,
                ),
              );
            },
            child: Row(children: [const Text('发布'), Icon(Icons.add)]),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 3, right: 3),
        child: Obx(
          () => Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: SegmentedButton(
                  segments:
                      TaskListCategoryExtension.hallTaskList
                          .map(
                            (e) =>
                                ButtonSegment(value: e, label: Text(e.i18name)),
                          )
                          .toList(),
                  onSelectionChanged: (s) {
                    controller.selectedSet.value = s;
                  },
                  selected: controller.selectedSet,
                  multiSelectionEnabled: false,
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: controller.initTaskList(),
                  builder: (context, snapshot) {
                    // if (controller.isLoading.value) {
                    //   return Center(child: CircularProgressIndicator());
                    // }
                    return TaskListView(
                      tasks: controller.tasks.value,
                      taskCategory: controller.selectedSet.first,
                      routeId: NestedNavigatorKeyId.hallId,
                      isLoading: controller.isLoading.value,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
