import 'package:flutter/material.dart';

enum DataLoadingStatus { none, loading, loaded }

// class
//
typedef ResponseHandler = String Function();

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

final defaultDtStyle = TextStyle(color: Colors.purpleAccent, fontSize: 12);
final  defaultNumberStyle = TextStyle(
  color: Colors.red,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);
const userStorage = "user-info";
const accessStorageKey = "accessToken";
const refreshStorageKey = "refreshToken";
const userStorageKey = "user";

enum TaskListCategory {
  allPublished, // 所有发布的
  myPublished, //我发布的
  myManuscript, // 我的草稿
  myLeading, // 我牵头的
  myParticipant, // 我参与的
  finished, //已完成的
  delegatedToMe, //委派我的
}

extension TaskListCategoryExtension on TaskListCategory {
  String get i18name {
    switch (this) {
      case TaskListCategory.allPublished:
        return "全部";
      case TaskListCategory.myPublished:
        return "我发布的";
      case TaskListCategory.myManuscript:
        return "我的草稿";
      case TaskListCategory.myLeading:
        return "牵头的";
      case TaskListCategory.myParticipant:
        return "参与的";
      case TaskListCategory.finished:
        return "完成的";
      case TaskListCategory.delegatedToMe:
        return "委派的";
    }
  }

  static List<TaskListCategory>  get hallTaskList => [
    TaskListCategory.allPublished,
    TaskListCategory.myPublished,
    TaskListCategory.myManuscript,
  ];

  static List<TaskListCategory> get homeTaskList => [
    TaskListCategory.myLeading,
    TaskListCategory.myParticipant,
    TaskListCategory.finished,
    TaskListCategory.delegatedToMe,
    TaskListCategory.myPublished,
  ];
}
