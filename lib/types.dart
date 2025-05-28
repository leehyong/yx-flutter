import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';

enum DataLoadingStatus { none, loading, loaded }

// class
//
typedef ResponseHandler = String Function();
typedef VoidFutureCallBack = Future<void> Function();

const userCaptchaCode = 0;
const phoneCaptchaCode = 1;
const emailCaptchaCode = 2;

const loadingColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

final defaultTitleStyle = TextStyle(
  color: Colors.red,
  fontWeight: FontWeight.w300,
);
final defaultDtStyle = TextStyle(color: Colors.purpleAccent, fontSize: 12);
final defaultNumberStyle = TextStyle(
  color: Colors.red,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);
const userStorage = "user-info";
const accessStorageKey = "accessToken";
const refreshStorageKey = "refreshToken";
const userStorageKey = "user";

const innerNodeKey = "::__inner";

enum TaskListCategory {
  allPublished, // 所有发布的
  myPublished, //我发布的
  myManuscript, // 我的草稿
  myParticipant, // 我参与的
  finished, //已完成的
  delegatedToMe, //委派我的
  parentTaskInfo, //父任务
  childrenTaskInfo, //子任务
}

extension TaskListCategoryExtension on TaskListCategory {
  String get i18name {
    switch (this) {
      case TaskListCategory.allPublished:
        return "任务列表";
      case TaskListCategory.myPublished:
        return "我发布的";
      case TaskListCategory.myManuscript:
        return "我的草稿";
      case TaskListCategory.myParticipant:
        return "参与的";
      case TaskListCategory.finished:
        return "完成的";
      case TaskListCategory.delegatedToMe:
        return "委派的";
      case TaskListCategory.parentTaskInfo:
        return "父任务信息";
      case TaskListCategory.childrenTaskInfo:
        return "子任务信息";
    }
  }

  static List<TaskListCategory> get hallTaskList => [
    TaskListCategory.allPublished,
    TaskListCategory.myPublished,
    TaskListCategory.delegatedToMe,
    TaskListCategory.myManuscript,
  ];

  static List<TaskListCategory> get homeTaskList => [
    TaskListCategory.myParticipant,
    TaskListCategory.finished,
  ];
}

enum TaskOperationCategory {
  detailTask,
  publishTask,
  submitTask,
  submitDetailTask,
  delegateTask,
  updateTask,
}

extension TaskOperationCategoryExtension on TaskOperationCategory {
  String get i18name {
    switch (this) {
      case TaskOperationCategory.detailTask:
        return '任务详情';
      case TaskOperationCategory.publishTask:
        return '新建任务';
      case TaskOperationCategory.submitTask:
        return '填报任务';
      case TaskOperationCategory.submitDetailTask:
        return '填报详情';
      case TaskOperationCategory.delegateTask:
        return '委派任务';
      case TaskOperationCategory.updateTask:
        return '修改任务';
    }
  }
}

enum TaskAttributeCategory { basic, submitItem, parentTask, childrenTask }

extension TaskAttributeCategoryExtension on TaskAttributeCategory {
  String get i18name {
    switch (this) {
      case TaskAttributeCategory.basic:
        return '基础项';
      case TaskAttributeCategory.submitItem:
        return '填报项';
      case TaskAttributeCategory.parentTask:
        return '父任务';
      case TaskAttributeCategory.childrenTask:
        return '子任务';
    }
  }
}

enum ReceiveTaskStrategy { freeSelection, forceDelegation, twoWaySelection, onlyForceDelegation, onlyTwoWaySelection }

extension ReceiveTaskStrategyExtension on ReceiveTaskStrategy {
  String get i18name {
    switch (this) {
      case ReceiveTaskStrategy.freeSelection:
        return '自由选择';
      case ReceiveTaskStrategy.forceDelegation:
        return '强制委派'; // 除了强制委派的人，其他人还可以领取
      case ReceiveTaskStrategy.twoWaySelection:
        return '双向选择';// 除了双向选择的人，其他人还可以领取
      case ReceiveTaskStrategy.onlyForceDelegation:
        return '只允许强制委派的人';
      case ReceiveTaskStrategy.onlyTwoWaySelection:
        return '只允许双向选择的人';
    }
  }
}

enum TaskCreditStrategy { latest, first }

extension TaskCreditStrategyExtension on TaskCreditStrategy {
  String get i18name {
    switch (this) {
      case TaskCreditStrategy.latest:
        return '最新值';
      case TaskCreditStrategy.first:
        return '首次值';
    }
  }
}

class WorkTaskPageParams {
  const WorkTaskPageParams(
    this.parentId,
    this.task,
    this.catList, {
    this.opCat,
  });

  final Int64 parentId;
  final WorkTask? task;
  final TaskListCategory catList;
  final TaskOperationCategory? opCat;
}

enum TaskSubmitCycleStrategy {
  week,
  year,
  month,
  halfMonth,
  day,
  halfDay,
  hour,
  halfHour,
}

extension TaskSubmitCycleStrategyExtension on TaskSubmitCycleStrategy {
  String get i18name {
    switch (this) {
      case TaskSubmitCycleStrategy.week:
        return '每周';
      case TaskSubmitCycleStrategy.year:
        return '每年';
      case TaskSubmitCycleStrategy.month:
        return '每月';
      case TaskSubmitCycleStrategy.halfMonth:
        return '每半月';
      case TaskSubmitCycleStrategy.day:
        return '每天';
      case TaskSubmitCycleStrategy.halfDay:
        return '每12小时';
      case TaskSubmitCycleStrategy.hour:
        return '每小时';
      case TaskSubmitCycleStrategy.halfHour:
        return '每30分钟';
    }
  }
}

enum TaskOpenRange { public, private, range }

extension TaskOpenRangeExtension on TaskOpenRange {
  String get i18name {
    switch (this) {
      case TaskOpenRange.public:
        return '公开';
      case TaskOpenRange.private:
        return '私有';
      case TaskOpenRange.range:
        return '指定范围';
    }
  }

  static TaskOpenRange fromInt(int idx) {
    return TaskOpenRange.values.firstWhere(
      (v) => v.index == idx,
      orElse: () => TaskOpenRange.public,
    );
  }
}

const unknownValue = -1;

enum TaskTextType { text, int, float, phone, email }

extension TaskTextTypeExtension on TaskTextType {
  String get i18name {
    switch (this) {
      case TaskTextType.text:
        return '文本';
      case TaskTextType.int:
        return '整数';
      case TaskTextType.float:
        return '小数';
      case TaskTextType.phone:
        return '手机';
      case TaskTextType.email:
        return '邮箱';
    }
  }

  static TaskTextType fromInt(int idx) {
    return TaskTextType.values.firstWhere(
      (v) => v.index == idx,
      orElse: () => TaskTextType.text,
    );
  }
}

enum TaskInfoAction { detail, write, submit, delegate, submitDetail }

// 顺序跟服务端的保持一致
enum SystemTaskStatus {
  // 初始
  initial,
  // 已启动
  started,
  // 进行中
  running,
  //已完成
  finished,
  //未完成
  unfinished,
  //已暂停
  suspended,
  //已发布
  published,
}

enum ModifyWarningCategory {
  basic,
  dateTime,
  date,
  participant,
  options,
  parent,
  header,
  submitContent,
}

extension ExtensionModifyWarningCategory on ModifyWarningCategory {
  String get i18name {
    switch (this) {
      case ModifyWarningCategory.basic:
        return "基本信息";
      case ModifyWarningCategory.options:
        return "选项";
      case ModifyWarningCategory.dateTime:
        return "时间";
      case ModifyWarningCategory.date:
        return "日期";
      case ModifyWarningCategory.header:
        return "填报项";
      case ModifyWarningCategory.parent:
        return "父任务";
      case ModifyWarningCategory.submitContent:
        return "内容";
      case ModifyWarningCategory.participant:
        return "参与人员";
    }
  }
}

enum UserTaskAction {
  claim,     // 领取
  accept,      // 接受
  refuse,     // 拒绝
  unconfirmed, // 待确认
}