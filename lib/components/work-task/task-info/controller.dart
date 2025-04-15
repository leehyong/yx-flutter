import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

import '../../work-header/header_tree.dart';


class PublishTaskController extends GetxController {
  final GlobalKey formKey = GlobalKey<FormState>();
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

  final isLoadingSubmitItem = false.obs;
  PublishTaskController() {}

  final submitItems = <WorkHeaderTree>[
    WorkHeaderTree(
        WorkHeader(name: "进度", id: Int64(1), contentType: 0, open: 0).obs,
        [
          WorkHeaderTree(WorkHeader(name: "虚拟进度", id: Int64(2), contentType: 0, open: 0).obs, <WorkHeaderTree>[
            WorkHeaderTree(WorkHeader(name: "虚1", id: Int64(3), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "虚2", id: Int64(4), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "虚3", id: Int64(5), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),

          ].obs),
          WorkHeaderTree(WorkHeader(name: "前期进度", id: Int64(6), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),
          WorkHeaderTree(WorkHeader(name: "中期进度", id: Int64(7), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),
          WorkHeaderTree(WorkHeader(name: "后期进度", id: Int64(8), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
          WorkHeaderTree(WorkHeader(name: "实际进度", id: Int64(9), contentType: 0, open: 0).obs, <WorkHeaderTree>[
            WorkHeaderTree(WorkHeader(name: "实1", id: Int64(10), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "实2", id: Int64(11), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "实3", id: Int64(12), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "实4", id: Int64(13), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
          ].obs),
        ].obs,
    ),

    WorkHeaderTree(
        WorkHeader(name: "困难点", id: Int64(14), contentType: 0, open: 0).obs,
        [
          WorkHeaderTree(WorkHeader(name: "虚拟困难", id: Int64(15), contentType: 0, open: 0).obs, <WorkHeaderTree>[
            WorkHeaderTree(WorkHeader(name: "虚困1", id: Int64(16), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "虚困2", id: Int64(17), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "虚困3", id: Int64(18), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),

          ].obs),
          WorkHeaderTree(WorkHeader(name: "前期困难", id: Int64(19), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),
          WorkHeaderTree(WorkHeader(name: "中期困难", id: Int64(20), contentType: 0, open: 1).obs, <WorkHeaderTree>[].obs),
          WorkHeaderTree(WorkHeader(name: "后期困难", id: Int64(21), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
          WorkHeaderTree(WorkHeader(name: "实际困难", id: Int64(22), contentType: 0, open: 0).obs, <WorkHeaderTree>[
            WorkHeaderTree(WorkHeader(name: "实困1", id: Int64(23), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "实困2", id: Int64(24), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "实困3", id: Int64(25), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
            WorkHeaderTree(WorkHeader(name: "实困4", id: Int64(26), contentType: 0, open: 0).obs, <WorkHeaderTree>[].obs),
          ].obs),
        ].obs,
    ),
    WorkHeaderTree(
        WorkHeader(name: "测试点", id: Int64(14), contentType: 0, open: 0).obs,
      <WorkHeaderTree>[].obs
    ),

  ].obs;

  @override
  void onClose() {
    // _timer.cancel(); // 在控制器销毁时取消定时器
    super.onClose();
  }

  // 定时器

  // final selections = ['参与的','历史的', '委派的', '发布的'];
  // final actions = ['已发布','我的发布', '我的草稿',];
}
