import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/components/work-task/task-list/view.dart';
import 'package:yx/utils/toast.dart';

import '../types.dart';

class PageReq {
  final page = 1.obs;

  int limit;

  final hasMore = true.obs;

  PageReq({this.limit = 10});
}

class TaskListController extends GetxController {
  final curCat = <TaskListCategory>{}.obs;
  final tasks = <WorkTask>[].obs;
  final isLoading = false.obs;
  final pageReq = PageReq();
  final smartRefreshKey = GlobalKey<SmartRefresherState>();
  final int parentId;

  TaskListController({this.parentId = 0});

  void reset() {
    pageReq.hasMore.value = true;
    pageReq.page.value = 1;
    tasks.value = [];
  }

  Future<void> loadTaskList() async {
    // 初始化 multiDutyMap，确保每个任务类型都有一个空列表
    final cat = parentId < 1 ? curCat.first : TaskListCategory.childrenTaskInfo;
    final refreshController = smartRefreshKey.currentState?.widget.controller;
    if (!pageReq.hasMore.value) {
      warnToast("没有更多数据了");
      // refreshController.loadNoData();
    } else {
      isLoading.value = true;
      final data = await task_api.queryWorkTasks(
        cat,
        pageReq.page.value,
        pageReq.limit,
        parentId,
      );
      if (data.error == null) {
        tasks.value.addAll(data.data!.map((e) => e.task));
        pageReq.page.value++;
        isLoading.value = false;
        assert(pageReq.limit == data.limit);
        pageReq.hasMore.value = pageReq.page < data.totalPages;
        if (data.data!.isEmpty) {
          refreshController?.loadNoData();
        } else {
          refreshController?.loadComplete();
        }
      } else {
        refreshController?.loadFailed();
      }
    }
  }
}

class CommonTaskListView extends GetView<TaskListController> {
  const CommonTaskListView({super.key, required this.cats});

  final List<TaskListCategory> cats;

  @override
  Widget build(BuildContext context) {
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
                  controller.curCat.value = s;
                  controller.reset();
                  controller.loadTaskList();
                },
                selected: controller.curCat.value,
                multiSelectionEnabled: false,
              ),
            ),
          ),
          Expanded(child: TaskListView(defaultCat: cats.first)),
        ],
      ),
    );
  }
}
