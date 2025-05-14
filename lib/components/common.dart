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
  final Rx<TaskListCategory?> oldCat = null.obs;
  final cat = {TaskListCategory.allPublished}.obs;

  // bool get needRefresh => oldCat.value != cat.first;
}

abstract class CommonTaskListView extends GetView<CommonTaskListCatController> {
  const CommonTaskListView({super.key, required this.cats});

  final List<TaskListCategory> cats;

  Widget buildTasks(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 3, right: 3),
      child: Obx(
        () => Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: SegmentedButton(
                segments:
                    cats
                        .map(
                          (e) =>
                              ButtonSegment(value: e, label: Text(e.i18name)),
                        )
                        .toList(),
                onSelectionChanged: (s) {
                  controller.oldCat.value = controller.cat.value.first;
                  controller.cat.value = s;
                },
                selected: controller.cat,
                multiSelectionEnabled: false,
              ),
            ),
            Expanded(child: TaskListView()),
          ],
        ),
      ),
    );
  }
}
