import 'package:easy_refresh/easy_refresh.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:yt_dart/cus_task.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/root/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/toast.dart';

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

mixin CommonEasyRefresherMixin {
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final MIProperties _headerProperties = MIProperties(name: 'Header');
  final MIProperties _footerProperties = MIProperties(name: 'Footer');

  Widget buildRefresherChildDataBox(BuildContext context);

  Future<void> loadData();

  Future<void> refreshData();

  Widget buildEasyRefresher(BuildContext context) {
    return EasyRefresh(
      header: MaterialHeader(
        clamping: _headerProperties.clamping,
        showBezierBackground: _headerProperties.background,
        bezierBackgroundAnimation: _headerProperties.animation,
        bezierBackgroundBounce: _headerProperties.bounce,
        infiniteOffset: _headerProperties.infinite ? 100 : null,
        springRebound: _headerProperties.listSpring,
      ),
      footer: MaterialFooter(
        clamping: _footerProperties.clamping,
        showBezierBackground: _footerProperties.background,
        bezierBackgroundAnimation: _footerProperties.animation,
        bezierBackgroundBounce: _footerProperties.bounce,
        infiniteOffset: _footerProperties.infinite ? 100 : null,
        springRebound: _footerProperties.listSpring,
      ),
      clipBehavior: Clip.none,
      controller: refreshController,
      // header: WaterDropHeader(),
      onLoad: loadData,
      onRefresh: refreshData,
      // controller: controller.refreshController,
      child: buildRefresherChildDataBox(context),
    );
  }
}
