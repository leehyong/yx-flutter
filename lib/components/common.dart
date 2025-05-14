import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/components/work-task/task-list/view.dart';

import '../types.dart';

class PageReq {
  final page = 1.obs;

  int limit;

  final hasMore = true.obs;

  PageReq({this.limit = 10});
}

class CommonTaskListCatController extends GetxController {
  final RxSet<TaskListCategory> cat = <TaskListCategory>{}.obs;

  CommonTaskListCatController(TaskListCategory defaultCat) {
    cat.value = {defaultCat};
  }
}

abstract class CommonTaskListView extends GetView<CommonTaskListCatController> {
  CommonTaskListView({super.key, required this.cats}) {
    Get.put(CommonTaskListCatController(cats.first));
  }

  final List<TaskListCategory> cats;

  Widget buildTasks(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 3, right: 3),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Obx(
              () => SegmentedButton(
                segments:
                    cats
                        .map(
                          (e) =>
                              ButtonSegment(value: e, label: Text(e.i18name)),
                        )
                        .toList(),
                onSelectionChanged: (s) {
                  controller.cat.value = s;
                },
                selected: controller.cat.value,
                multiSelectionEnabled: false,
              ),
            ),
          ),
          Expanded(child: TaskListView()),
        ],
      ),
    );
  }
}
