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
  final tabChanging = false.obs;

  final pageReq = PageReq();
  final smartRefreshKey = GlobalKey<SmartRefresherState>();
  final parentId = 0.obs;

  void reset() {
    pageReq.hasMore.value = true;
    pageReq.page.value = 1;
    tasks.value = [];
  }

  void setTaskListInfo({
    int parentId = 0,
    TaskListCategory defaultCat = TaskListCategory.allPublished,
  }) {
    curCat.value = {defaultCat};
    this.parentId.value = parentId;
  }

  Future<void> loadTaskList() async {
    // 初始化 multiDutyMap，确保每个任务类型都有一个空列表
    final cat =
        parentId.value < 1 ? curCat.first : TaskListCategory.childrenTaskInfo;
    final refreshController = smartRefreshKey.currentState?.widget.controller;
    if (!pageReq.hasMore.value) {
      warnToast("没有更多数据了");
      refreshController?.loadNoData();
    } else {
      isLoading.value = true;
      final data = await task_api.queryWorkTasks(
        cat,
        pageReq.page.value,
        pageReq.limit,
        parentId.value,
      );
      if (data.error == null) {
        tasks.value.addAll(data.data!.map((e) => e.task));
        isLoading.value = false;
        assert(pageReq.limit == data.limit);
        pageReq.hasMore.value = pageReq.page < data.totalPages;
        if (pageReq.page.value == 1) {
          refreshController?.refreshCompleted(resetFooterState: true);
        }
        if (tasks.value.isEmpty) {
          refreshController?.loadNoData();
        } else {
          refreshController?.loadComplete();
        }
        pageReq.page.value++;
      } else {
        if (pageReq.page.value == 1) {
          refreshController?.refreshFailed();
        } else {
          refreshController?.loadFailed();
        }
      }
    }
  }
}

class CommonTaskListView extends GetView<TaskListController> {
  CommonTaskListView({super.key, required this.cats}) {
    assert(cats.isNotEmpty);
    controller.curCat.value = {cats.first};
  }

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
                  controller.tabChanging.value = true;
                  controller.curCat.value = s;
                  controller.reset();
                  controller.loadTaskList().then((v) {
                    Future.delayed(Duration(milliseconds: 100), () {
                      controller.tabChanging.value = false;
                    });
                  });
                },
                selected: controller.curCat.value,
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

void commonSetTaskListInfo({
  int parentId = 0,
  TaskListCategory defaultCat = TaskListCategory.allPublished,
}) {
  Get.find<TaskListController>().setTaskListInfo(
    parentId: parentId,
    defaultCat: defaultCat,
  );
}
