import 'dart:collection';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

import 'header_tree.dart';

class PublishItemsController extends GetxController {
  final isLoadingSubmitItem = false.obs;
  final listKey = GlobalKey();
  final submitItems =
      <Rx<WorkHeaderTree>>[
        WorkHeaderTree(
          WorkHeader(name: "抖动点", id: Int64(14), contentType: 0, open: 0).obs,
          <Rx<WorkHeaderTree>>[
            WorkHeaderTree(
              WorkHeader(
                name: "抖",
                id: Int64(222),
                contentType: 0,
                open: 0,
              ).obs,
              <Rx<WorkHeaderTree>>[].obs,
            ).obs,
          ].obs,
        ).obs,
        WorkHeaderTree(
          WorkHeader(name: "进度", id: Int64(1), contentType: 0, open: 0).obs,
          <Rx<WorkHeaderTree>>[
            WorkHeaderTree(
              WorkHeader(
                name: "虚拟进度",
                id: Int64(2),
                contentType: 0,
                open: 0,
              ).obs,
              <Rx<WorkHeaderTree>>[
                WorkHeaderTree(
                  WorkHeader(
                    name: "虚1",
                    id: Int64(3),
                    contentType: 0,
                    open: 1,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "虚2",
                    id: Int64(4),
                    contentType: 0,
                    open: 1,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "虚3",
                    id: Int64(5),
                    contentType: 0,
                    open: 1,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
              ].obs,
            ).obs,
            WorkHeaderTree(
              WorkHeader(
                name: "前期进度",
                id: Int64(6),
                contentType: 0,
                open: 1,
              ).obs,
              <Rx<WorkHeaderTree>>[].obs,
            ).obs,
            WorkHeaderTree(
              WorkHeader(
                name: "中期进度",
                id: Int64(7),
                contentType: 0,
                open: 1,
              ).obs,
              <Rx<WorkHeaderTree>>[].obs,
            ).obs,
            WorkHeaderTree(
              WorkHeader(
                name: "后期进度",
                id: Int64(8),
                contentType: 0,
                open: 0,
              ).obs,
              <Rx<WorkHeaderTree>>[].obs,
            ).obs,
            WorkHeaderTree(
              WorkHeader(
                name: "实际进度",
                id: Int64(9),
                contentType: 0,
                open: 0,
              ).obs,
              <Rx<WorkHeaderTree>>[
                WorkHeaderTree(
                  WorkHeader(
                    name: "实1",
                    id: Int64(10),
                    contentType: 0,
                    open: 0,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "实2",
                    id: Int64(11),
                    contentType: 0,
                    open: 0,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "实3",
                    id: Int64(12),
                    contentType: 0,
                    open: 0,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "实4",
                    id: Int64(13),
                    contentType: 0,
                    open: 0,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
              ].obs,
            ).obs,
          ].obs,
        ).obs,

        WorkHeaderTree(
          WorkHeader(name: "困难点", id: Int64(14), contentType: 0, open: 0).obs,
          <Rx<WorkHeaderTree>>[
            WorkHeaderTree(
              WorkHeader(
                name: "虚拟困难",
                id: Int64(15),
                contentType: 0,
                open: 0,
              ).obs,
              <Rx<WorkHeaderTree>>[
                WorkHeaderTree(
                  WorkHeader(
                    name: "虚困1",
                    id: Int64(16),
                    contentType: 0,
                    open: 1,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "虚困2",
                    id: Int64(17),
                    contentType: 0,
                    open: 1,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "虚困3",
                    id: Int64(18),
                    contentType: 0,
                    open: 1,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
              ].obs,
            ).obs,
            WorkHeaderTree(
              WorkHeader(
                name: "前期困难",
                id: Int64(19),
                contentType: 0,
                open: 1,
              ).obs,
              <Rx<WorkHeaderTree>>[].obs,
            ).obs,
            WorkHeaderTree(
              WorkHeader(
                name: "中期困难",
                id: Int64(20),
                contentType: 0,
                open: 1,
              ).obs,
              <Rx<WorkHeaderTree>>[].obs,
            ).obs,
            WorkHeaderTree(
              WorkHeader(
                name: "后期困难",
                id: Int64(21),
                contentType: 0,
                open: 0,
              ).obs,
              <Rx<WorkHeaderTree>>[].obs,
            ).obs,
            WorkHeaderTree(
              WorkHeader(
                name: "实际困难",
                id: Int64(22),
                contentType: 0,
                open: 0,
              ).obs,
              <Rx<WorkHeaderTree>>[
                WorkHeaderTree(
                  WorkHeader(
                    name: "实困1",
                    id: Int64(23),
                    contentType: 0,
                    open: 0,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "实困2",
                    id: Int64(24),
                    contentType: 0,
                    open: 0,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "实困3",
                    id: Int64(25),
                    contentType: 0,
                    open: 0,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
                WorkHeaderTree(
                  WorkHeader(
                    name: "实困4",
                    id: Int64(26),
                    contentType: 0,
                    open: 0,
                  ).obs,
                  <Rx<WorkHeaderTree>>[].obs,
                ).obs,
              ].obs,
            ).obs,
          ].obs,
        ).obs,
        WorkHeaderTree(
          WorkHeader(name: "测试点", id: Int64(144), contentType: 0, open: 0).obs,
          <Rx<WorkHeaderTree>>[].obs,
        ).obs,
      ].obs;

  final submitItemsMap = HashMap<Int64, Rx<WorkHeaderTree>>().obs;

  void _buildSubmitItemsMap() {
    void buildMap(RxList<Rx<WorkHeaderTree>> tree) {
      for (var item in tree) {
        submitItemsMap.value[item.value.task.value.id] = item;
        buildMap(item.value.children);
      }
    }

    buildMap(submitItems);
  }

  @override
  void onInit() {
    super.onInit();
    _buildSubmitItemsMap();
  }
}

class WorkHeaderController extends GetxController {
  final RxList<Rx<WorkHeaderTree>> children;
  final opsCount = 0.obs;

  WorkHeaderController(this.children);

  int get maxColumns {
    // dfs 求最大列数
    return 0;
  }

  int get maxRows {
    // dfs 求最大行数
    int calculateMaxRows(List<Rx<WorkHeaderTree>> children) {
      return children.fold(
        0,
        (acc, cur) =>
            acc +
            (cur.value.children.isEmpty
                ? 1
                : calculateMaxRows(cur.value.children)),
      );
    }

    return calculateMaxRows(children);
  }
}

class OneWorkHeaderItemController extends GetxController {
  final globalKey = GlobalKey();
  final RxList<Rx<WorkHeaderTree>> children;
  final Rx<WorkHeader> task;
  final opsCount = 0.obs;

  OneWorkHeaderItemController(this.task, this.children);

  @override
  void onInit() {
    super.onInit();
    ever(children, (v) {
      debugPrint("OneWorkHeaderItemController ss $v");
    });
  }
}

Rx<WorkHeaderTree> _newEmptyHeaderTree(String name) {
  return WorkHeaderTree(
    WorkHeader(
      name: "子项-$name",
      id: Int64(DateTime.now().microsecondsSinceEpoch),
      contentType: TaskTextType.text.index,
      open: TaskOpenRange.private.index,
    ).obs,
    <Rx<WorkHeaderTree>>[].obs,
  ).obs;
}


void addNewHeaderTree(RxList<Rx<WorkHeaderTree>> tree, String name){
  // tree.value.add(_newEmptyHeaderTree(name));
  tree.value = [...tree.value, _newEmptyHeaderTree(name)];
  // final controller = Get.find<PublishItemsController>();
}