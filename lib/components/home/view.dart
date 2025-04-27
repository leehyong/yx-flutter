import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/types.dart';

import '../work-task/task-list/view.dart';
import 'controller.dart';

class TaskHomeView extends GetView<TaskHomeController> {
  const TaskHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("任务清单", style: defaultTitleStyle)),
      body: Padding(
        padding: EdgeInsets.only(left: 3, right: 3),
        child: Obx(
          () => Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: SegmentedButton(
                  segments:
                      TaskListCategoryExtension.homeTaskList
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
