import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';


class PublishTaskController extends GetxController {
  final GlobalKey formKey = GlobalKey<FormState>();
  late final Int64 taskId;
  late final Int64 parentId;
  PublishTaskController( this.parentId, this.taskId);
  final taskNameController = TextEditingController();
  final taskContentController = TextEditingController();
  final taskPlanStartDtController = TextEditingController();
  final taskPlanEndDtController = TextEditingController();
  final taskReceiveDeadlineController = TextEditingController();
  final taskReceiverQuotaLimitedController = TextEditingController();
  final taskContactorController = TextEditingController();
  final taskContactPhoneController = TextEditingController();
  final taskCreditsController = TextEditingController();
  final taskReceiveStrategy = ReceiveTaskStrategy.twoWaySelection.obs;
  final taskSubmitCycleStrategy = TaskSubmitCycleStrategy.week.obs;
  final taskCreditStrategy = TaskCreditStrategy.latest.obs;
  final selectedAttrSet = {TaskAttributeCategory.basic}.obs;
  final selectedPersons = <String>["1恶趣味", "恶趣味www", "恶趣味", "2dad服"].obs;

  final childrenTask =
      <WorkTask>[
        WorkTask(
          id: Int64(2),
          name: '大模型11',
          content: "22dadafwqeqweqf是生生世世",
          planStartDt: Int64(1744525638),
          planEndDt: Int64(1744612038),
          receiveDeadline: Int64(1744439238),
          contactor: "赵生",
          contactPhone: "15522900013",
          credits: 88,
          receiveStrategy: 0,
        ),
        WorkTask(
          id: Int64(2),
          name: '大模型huahu2',
          content: "22dadafwqeqweqf是生生信息世世",
          planStartDt: Int64(1744957638),
          planEndDt: Int64(1745821638),
          receiveDeadline: Int64(1745303238),
          contactor: "马六生",
          contactPhone: "15521020013",
          credits: 1028,
          receiveStrategy: 1,
        ),
        WorkTask(
          id: Int64(3),
          name: '大模型huahu密码',
          content: "22dadafwqeqweqf是生生信息世世",
          planStartDt: Int64(1746080838),
          planEndDt: Int64(1746944838),
          receiveDeadline: Int64(1745216838),
          contactor: "马六",
          contactPhone: "15521020011",
          credits: 328,
          receiveStrategy: 2,
        ),
      ].obs;
  final parentTask =
      WorkTask(
        id: Int64(1),
        name: '大模型11',
        content: "22dadafwqeqweqf是生生世世",
        planStartDt: Int64(1744525638),
        planEndDt: Int64(1744612038),
        receiveDeadline: Int64(1744439238),
        contactor: "赵生",
        contactPhone: "15522900013",
        credits: 88,
        receiveStrategy: 0,
      ).obs;

  @override
  void onClose() {
    // _timer.cancel(); // 在控制器销毁时取消定时器
    super.onClose();
  }

  // 定时器

  // final selections = ['参与的','历史的', '委派的', '发布的'];
  // final actions = ['已发布','我的发布', '我的草稿',];
}
