import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:yx/components/common.dart';

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
  OneTaskCardController({required this.deadline}) {
    final nowTs = DateTime.now().toLocal().millisecondsSinceEpoch ~/ 1000;
    final _deadline = deadline;
    final _left = (_deadline - nowTs);
    left.value = _left;
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel(); // 在控制器销毁时取消定时器
    super.onClose();
  }

  // 定时器

  Timer? _timer;
  late final int deadline;
  final RxInt left = 0.obs;

  final isDeleting = false.obs;

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

  Future<void> deleteTask(Int64 id) async {
    isDeleting.value = true;
    await Get.find<TaskListController>().deleteOneTask(id);
    await Future.delayed(Duration(seconds: 1), () {
      isDeleting.value = false;
    });
  }

  // final selections = ['参与的','历史的', '委派的', '发布的'];
  // final actions = ['已发布','我的发布', '我的草稿',];
}
