import 'dart:collection';
import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';

import 'header_crud.dart';
import 'header_tree.dart';

const maxSubmitItemDepthExclusive = 1;
final submitItems = <WorkHeaderTree>[
  WorkHeaderTree(
    WorkHeader(name: "抖动点", id: Int64(114), contentType: 0, open: 0),
    <WorkHeaderTree>[
      WorkHeaderTree(
        WorkHeader(name: "抖", id: Int64(222), contentType: 0, open: 0),
        <WorkHeaderTree>[],
      ),
    ],
  ),
  WorkHeaderTree(
    WorkHeader(name: "进度", id: Int64(1), contentType: 0, open: 0),
    <WorkHeaderTree>[
      WorkHeaderTree(
        WorkHeader(name: "虚拟进度", id: Int64(2), contentType: 0, open: 0),
        <WorkHeaderTree>[
          WorkHeaderTree(
            WorkHeader(name: "虚1", id: Int64(3), contentType: 0, open: 1),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "虚2", id: Int64(4), contentType: 0, open: 1),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "虚3", id: Int64(5), contentType: 0, open: 1),
            <WorkHeaderTree>[],
          ),
        ],
      ),
      WorkHeaderTree(
        WorkHeader(name: "前期进度", id: Int64(6), contentType: 0, open: 1),
        <WorkHeaderTree>[],
      ),
      WorkHeaderTree(
        WorkHeader(name: "中期进度", id: Int64(7), contentType: 0, open: 1),
        <WorkHeaderTree>[],
      ),
      WorkHeaderTree(
        WorkHeader(name: "后期进度", id: Int64(8), contentType: 0, open: 0),
        <WorkHeaderTree>[],
      ),
      WorkHeaderTree(
        WorkHeader(name: "实际进度", id: Int64(9), contentType: 0, open: 0),
        <WorkHeaderTree>[
          WorkHeaderTree(
            WorkHeader(name: "实1", id: Int64(10), contentType: 0, open: 0),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "实2", id: Int64(11), contentType: 0, open: 0),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "实3", id: Int64(12), contentType: 0, open: 0),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "实4", id: Int64(13), contentType: 0, open: 0),
            <WorkHeaderTree>[],
          ),
        ],
      ),
    ],
  ),

  WorkHeaderTree(
    WorkHeader(name: "困难点", id: Int64(14), contentType: 0, open: 0),
    <WorkHeaderTree>[
      WorkHeaderTree(
        WorkHeader(name: "虚拟困难", id: Int64(15), contentType: 0, open: 0),
        <WorkHeaderTree>[
          WorkHeaderTree(
            WorkHeader(name: "虚困1", id: Int64(16), contentType: 0, open: 1),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "虚困2", id: Int64(17), contentType: 0, open: 1),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "虚困3", id: Int64(18), contentType: 0, open: 1),
            <WorkHeaderTree>[],
          ),
        ],
      ),
      WorkHeaderTree(
        WorkHeader(name: "前期困难", id: Int64(19), contentType: 0, open: 1),
        <WorkHeaderTree>[],
      ),
      WorkHeaderTree(
        WorkHeader(name: "中期困难", id: Int64(20), contentType: 0, open: 1),
        <WorkHeaderTree>[],
      ),
      WorkHeaderTree(
        WorkHeader(name: "后期困难", id: Int64(21), contentType: 0, open: 0),
        <WorkHeaderTree>[],
      ),
      WorkHeaderTree(
        WorkHeader(name: "实际困难", id: Int64(22), contentType: 0, open: 0),
        <WorkHeaderTree>[
          WorkHeaderTree(
            WorkHeader(name: "实困1", id: Int64(23), contentType: 0, open: 0),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "实困2", id: Int64(24), contentType: 0, open: 0),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "实困3", id: Int64(25), contentType: 0, open: 0),
            <WorkHeaderTree>[],
          ),
          WorkHeaderTree(
            WorkHeader(name: "实困4", id: Int64(26), contentType: 0, open: 0),
            <WorkHeaderTree>[],
          ),
        ],
      ),
    ],
  ),
  WorkHeaderTree(
    WorkHeader(name: "测试点", id: Int64(144), contentType: 0, open: 0),
    <WorkHeaderTree>[],
  ),
];

class PublishItemsController extends GetxController {
  final isLoadingSubmitItem = false.obs;
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  final isEditing = false.obs;
  final itemsSimpleCrudKey = GlobalKey<PublishItemsViewSimpleCrudState>();

  final Rx<TreeNode<WorkHeader>> submitItemAnimatedTreeData =
      TreeNode<WorkHeader>.root(data: WorkHeader.create()).obs;
  final Rx<TreeViewController?> treeViewController =
      (null as TreeViewController?).obs;
  final submitItemsMap = HashMap<Int64, WorkHeaderTree>().obs;

  void _buildSubmitItemsMap() {
    void buildMap(List<WorkHeaderTree> tree) {
      for (var item in tree) {
        submitItemsMap.value[item.task.id] = item;
        buildMap(item.children);
      }
    }

    buildMap(submitItems);
  }

  Function debounceBuildSubmitItemsMap() {
    // 500毫秒内避免重复构建 submitItemsMap
    return commonDebounceByTimer(
      _buildSubmitItemsMap,
      Duration(milliseconds: 500),
    );
  }

  @override
  void onInit() {
    super.onInit();
    // _buildSubmitItemsMap();
    // buildAnimatedTreeViewData();
  }

  // void buildAnimatedTreeViewData() {
  //   // dfs 遍历获取所有的 TreeNode
  //   TreeNode<WorkHeader> innerBuildAnimatedTreeViewData(WorkHeaderTree tree) {
  //     final node = TreeNode(key: tree.task.id.toString(), data: tree.task);
  //     node.addAll(
  //       tree.children.map((child) => innerBuildAnimatedTreeViewData(child)),
  //     );
  //     return node;
  //   }
  //
  //   submitItemAnimatedTreeData.value.addAll(
  //     submitItems.map((item) => innerBuildAnimatedTreeViewData(item)),
  //   );
  //   debugPrint("1111buildAnimatedTreeViewData");
  // }
}

class WorkHeaderController extends GetxController {
  final List<WorkHeaderTree> children;

  WorkHeaderController(this.children);

  int get maxColumns {
    // dfs 求最大列数
    return 0;
  }

  int get maxRows {
    // dfs 求最大行数
    // int calculateMaxRows(List<WorkHeaderTree> children) {
    //   return children.fold(
    //     0,
    //     (acc, cur) =>
    //         acc +
    //         (cur.children.isEmpty
    //             ? 1
    //             : calculateMaxRows(cur.value.children)),
    //   );
    // }

    // return calculateMaxRows(children);
    return 0;
  }
}

class OneWorkHeaderItemController extends GetxController {
  final List<WorkHeaderTree> children;
  final Rx<WorkHeader> task;

  OneWorkHeaderItemController(this.task, this.children);

  // @override
  // void onInit() {
  //   super.onInit();
  // }
}

TreeNode<WorkHeader> newEmptyHeaderTree([String? name]) {
  final id = Int64(DateTime.now().microsecondsSinceEpoch);
  final key = id.toString();
  return TreeNode(
    key: key,
    data: WorkHeader(
      name: "子项-${name ?? key}",
      id: id,
      contentType: Random().nextInt(TaskTextType.values.length),
      open: Random().nextInt(TaskOpenRange.values.length),
      required: Random().nextBool(),
    ),
  );
}