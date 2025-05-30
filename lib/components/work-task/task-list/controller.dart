import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/components/common.dart';
import 'package:yx/types.dart';

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

class OneTaskCardController extends GetxController {
  OneTaskCardController({required this.deadline, required int action}) {
    final nowTs = DateTime.now().toLocal().millisecondsSinceEpoch ~/ 1000;
    final _deadline = deadline;
    final _left = (_deadline - nowTs);
    left.value = _left;
    this.action.value = action;
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel(); // 在控制器销毁时取消定时器
    super.onClose();
  }

  // 定时器

  final action = (-1).obs;

  bool get accepted => [
    UserTaskAction.claim.index,
    UserTaskAction.accept.index,
  ].contains(action.value);

  Timer? _timer;
  late final int deadline;
  final RxInt left = 0.obs;

  final isHandling = false.obs;

  Future<void> handleTaskAction(Int64 taskId, UserTaskAction action) async {
    final success = await task_api.handleActionWorkTaskHeader(taskId, action);
    if (success) {
      this.action.value = action.index;
    }
  }

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
        _timer?.cancel(); // 倒计时结束，取消定时器
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

  Future<void> _commonDialog(
    BuildContext context,
    String title,
    String content, {
    required VoidFutureCallBack leftBtnAction,
    required VoidFutureCallBack rightBtnAction,
  }) async {
    showGeneralDialog(
      context: context,
      pageBuilder: (
        BuildContext buildContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return TDAlertDialog(
          title: title,
          contentWidget: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: warningColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          leftBtnAction: leftBtnAction,
          rightBtnAction: rightBtnAction,
        );
      },
    );
  }

  Future<void> handleTaskStatusAction(
    BuildContext context,
    WorkTask task,
    UserTaskAction action,
  ) async {
    String title;
    switch (action) {
      case UserTaskAction.start:
        title = '启动';
        break;
      case UserTaskAction.pause:
        title = '暂停';
        break;
      case UserTaskAction.finish:
        title = '结束';
        break;
      default:
        throw UnimplementedError();
    }
    isHandling.value = true;
    _commonDialog(
      context,
      "确定$title}吗？",
      task.name,
      leftBtnAction: () async {
        isHandling.value = false;
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      rightBtnAction: () async {
        // 弹窗确认之后，再调用接口进行实际操作
        await task_api.handleActionWorkTaskHeader(task.id, action);
        // delayed 延迟以便体现效果
        await Future.delayed(Duration(milliseconds: 200), () {
          isHandling.value = false;
        });
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Future<void> deleteTask(WorkTask task, BuildContext context) async {
    isHandling.value = true;
    _commonDialog(
      context,
      "确定删除吗？",
      task.name,
      leftBtnAction: () async {
        isHandling.value = false;
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      rightBtnAction: () async {
        // 弹窗确认之后，再调用接口进行删除
        await Get.find<TaskListController>().deleteOneTask(task.id);
        // delayed 延迟以便体现效果
        await Future.delayed(Duration(milliseconds: 200), () {
          isHandling.value = false;
        });
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  // final selections = ['参与的','历史的', '委派的', '发布的'];
  // final actions = ['已发布','我的发布', '我的草稿',];
}
