import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:yt_dart/cus_task.pb.dart';
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

class TaskListLayer {
  final curCat = <TaskListCategory>{}.obs;
  final tasks = <UserTaskHistory>[].obs;
  final isLoading = false.obs;
  final tabChanging = false.obs;
  final pageReq = PageReq();
  final parentId = Int64.ZERO.obs;
  final smartRefreshKey = GlobalKey<SmartRefresherState>();

  void reset() {
    pageReq.hasMore.value = true;
    pageReq.page.value = 1;
    tasks.value = [];
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
        tasks.value.addAll(data.data as List<UserTaskHistory>);
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

class TaskListController extends GetxController {
  final _layers = <TaskListLayer>[TaskListLayer()].obs;

  bool isSecondLayer(TaskListCategory cat) => {
    TaskListCategory.parentTaskInfo,
    TaskListCategory.childrenTaskInfo,
  }.contains(cat);

  // 不是第一层就是第二层
  bool isFirstLayer(TaskListCategory cat) => !isSecondLayer(cat);

  int layerIdx(TaskListCategory cat) => isFirstLayer(cat) ? 0 : 1;

  TaskListLayer get curLayer => _layers.last;

  bool get inSecondLayer => _layers.length == 2;

  @override
  void onInit() {
    super.onInit();
    ever(curLayer.curCat, (v) {
      if (v.isNotEmpty) {
        curLayer.tabChanging.value = true;
        curLayer.reset();
        curLayer.loadTaskList().then((v) {
          Future.delayed(Duration(milliseconds: 100), () {
            curLayer.tabChanging.value = false;
          });
        });
      }
    });
  }


  void setSecondLayerTaskListInfo({
    Int64 parentId = Int64.ZERO,
    TaskListCategory defaultCat = TaskListCategory.allPublished,
  }) {
    if (!isSecondLayer(defaultCat)) {
      return;
    }
    if (_layers.length == 1) {
      _layers.add(TaskListLayer());
    }
    curLayer.curCat.value = {defaultCat};
    curLayer.parentId.value = parentId;
  }

  void removeSecondLayer(){
    if (inSecondLayer) {
      _layers.removeLast();
    }
  }

  Future<void> deleteOneTask(Int64 id) async {
    final err = await task_api.deleteWorkTask(id);
    if (err == null) {
      // 剔除对应id的任务，保留其余的任务
      curLayer.tasks.value = curLayer.tasks.value.where((e) => e.task.id != id).toList();
    }
  }
}

class CommonTaskListView extends GetView<TaskListController> {
  CommonTaskListView({super.key, required this.cats}) {
    assert(cats.isNotEmpty);
    controller.curLayer.curCat.value = {cats.first};
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
                    controller.curLayer.curCat.value = s;
                  },
                  selected: controller.curLayer.curCat.value,
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
  Get.find<TaskListController>().setSecondLayerTaskListInfo(
    parentId: parentId,
    defaultCat: defaultCat,
  );
}
