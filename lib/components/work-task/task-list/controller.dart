import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/types.dart';
import 'package:yx/utils/toast.dart';

import '../../common.dart';

class TimeLeftDetail {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final int left;

  TimeLeftDetail({
    required this.left,
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  });
}

const left30Minutes = 1800;

class TaskListController extends GetxController {
  final tasks = <WorkTask>[].obs;
  final isLoading = false.obs;
  final pageReq = PageReq();

  // final refreshController = RefreshController(initialRefresh: true);
  final int parentId;

  TaskListController({this.parentId = 0});

  RxSet<TaskListCategory> get curCategory =>
      Get.find<CommonTaskListCatController>().cat;

  @override
  void onInit() {
    super.onInit();
    // 监听切换了cat ，则重新加载数据
    ever(curCategory, (c) {
      debugPrint("curCategory:${c}");
      // if (c.isNotEmpty) refreshController.requestRefresh();
    });
  }

  void reset() {
    pageReq.hasMore.value = true;
    pageReq.page.value = 1;
    tasks.value = [];
  }

  Future<void> loadTaskList() async {
    // 初始化 multiDutyMap，确保每个任务类型都有一个空列表
    if (!pageReq.hasMore.value) {
      warnToast("没有更多数据了");
      // refreshController.loadNoData();
    } else {
      isLoading.value = true;
      final data = await task_api.queryWorkTasks(
        parentId < 1 ? curCategory.first : TaskListCategory.childrenTaskInfo,
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
          // refreshController.loadNoData();
        } else {
          // refreshController.loadComplete();
        }
      } else {
        // refreshController.loadFailed();
      }
    }
  }
}

class OneTaskController extends GetxController {
  OneTaskController({required this.deadline}) {
    final nowTs = DateTime.now().toLocal().millisecondsSinceEpoch ~/ 1000;
    final _deadline = deadline;
    final _left = (_deadline - nowTs);
    left.value = _left;
    _startTimer();
  }

  @override
  void onClose() {
    _timer.cancel(); // 在控制器销毁时取消定时器
    super.onClose();
  }

  // 定时器

  late Timer _timer;
  late final int deadline;
  final RxInt left = 0.obs;

  // 启动倒计时
  void _startTimer() {
    if (left.value < 1) {
      return;
    }
    // 大于30分钟时，倒计时间隔 60秒，否则间隔1秒
    final interval = left.value > left30Minutes ? 60 : 1;
    _timer = Timer.periodic(Duration(seconds: interval), (timer) {
      if (left.value > 0) {
        left.value -= interval;
        update(); // 更新界面
      } else {
        _timer.cancel(); // 倒计时结束，取消定时器
      }
    });
  }

  TimeLeftDetail get leftDetail {
    if (left.value > 0) {
      var left2 = left.value;
      var days = left2 ~/ (24 * 60 * 60);
      left2 -= days * (24 * 60 * 60);
      var hours = left2 ~/ (60 * 60);
      left2 -= hours * (60 * 60);
      var minutes = left2 ~/ 60;
      left2 -= minutes * 60;
      return TimeLeftDetail(
        left: left.value,
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: left2,
      );
    }
    return TimeLeftDetail(left: 0);
  }

  // final selections = ['参与的','历史的', '委派的', '发布的'];
  // final actions = ['已发布','我的发布', '我的草稿',];
}
