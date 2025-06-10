import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:yt_dart/cus_task.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/root/controller.dart';
import 'package:yx/utils/toast.dart';

import '../types.dart';

class PageReq {
  int page = 1;

  int limit;

  bool hasMore = true;

  PageReq({this.limit = 10});
}

class TaskListLayer {
  Set<TaskListCategory> curCat = <TaskListCategory>{};
  List<UserTaskHistory> tasks = <UserTaskHistory>[];
  bool tabChanging = false;
  PageReq pageReq = PageReq();
  Int64 parentId = Int64.ZERO;

  bool get hasMore => pageReq.hasMore;

  void reset() {
    pageReq.hasMore = true;
    pageReq.page = 1;
    tasks.clear();
  }


  Future<bool> loadTaskList() async {
    // 初始化 multiDutyMap，确保每个任务类型都有一个空列表
    final cat = parentId < 1 ? curCat.first : TaskListCategory.childrenTaskInfo;
    if (!pageReq.hasMore) {
      warnToast("没有更多数据了");
      return true;
    } else {
      final data = await task_api.queryWorkTasks(
        cat,
        pageReq.page,
        pageReq.limit,
        parentId,
      );
      if (data.error == null || data.error!.isEmpty) {
        tasks.addAll(data.data as List<UserTaskHistory>);
        assert(pageReq.limit == data.limit);
        pageReq.hasMore = pageReq.page < data.totalPages;
        pageReq.page++;
        return true;
      }
      return false;
    }
  }
}

void commonSetTaskListInfo({
  Int64 parentId = Int64.ZERO,
  TaskListCategory defaultCat = TaskListCategory.allPublished,
}) {
  Get.find<RootTabController>().taskListViewState.currentState
      ?.setSecondLayerTaskListInfo(parentId: parentId, defaultCat: defaultCat);
}
