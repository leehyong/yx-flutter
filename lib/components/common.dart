import 'package:fixnum/fixnum.dart';
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
  final parentId = Int64.ZERO.obs;

  void reset() {
    pageReq.hasMore.value = true;
    pageReq.page.value = 1;
    tasks.value = [];
  }

  @override
  void onInit() {
    super.onInit();
    ever(curCat, (v) {
      if (v.isNotEmpty) {
        tabChanging.value = true;
        reset();
        loadTaskList().then((v) {
          Future.delayed(Duration(milliseconds: 100), () {
            tabChanging.value = false;
          });
        });
      }
    });
  }

  void setTaskListInfo({
    Int64 parentId = Int64.ZERO,
    TaskListCategory defaultCat = TaskListCategory.allPublished,
  }) {
    curCat.value = {defaultCat};
    this.parentId.value = parentId;
  }

  Future<void> deleteOneTask(Int64 id) async {
    final err = await task_api.deleteWorkTask(id);
    if (err == null) {
      // 剔除对应id的任务，保留其余的任务
      tasks.value = tasks.value.where((e) => e.id != id).toList();
      // final refreshController = smartRefreshKey.currentState?.widget.controller;
      // refreshController?.requestLoading();
    }
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
              () => SizedBox(
                width: 400,
                child: SegmentedButton(
                  expandedInsets: EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 6.0,
                  ),
                  segments:
                      cats
                          .map(
                            (e) => ButtonSegment(
                              value: e,
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  e.i18name,
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onSelectionChanged: (s) {
                    controller.curCat.value = s;
                  },
                  selected: controller.curCat.value,
                  multiSelectionEnabled: false,
                ),
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
  Int64 parentId = Int64.ZERO,
  TaskListCategory defaultCat = TaskListCategory.allPublished,
}) {
  Get.find<TaskListController>().setTaskListInfo(
    parentId: parentId,
    defaultCat: defaultCat,
  );
}
