import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

import 'header_crud.dart';
import 'header_data.dart';
import 'select_submit_item.dart';

const maxSubmitItemDepth = 3;
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

class PublishItemsDetailController extends GetxController {
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  final isLoadingSubmitItem = false.obs;
}

const innerNodeKey = "::__inner";

class PublishItemsCrudController extends GetxController {
  final isLoadingSubmitItem = false.obs;
  final expandAll = false.obs;
  final itemsSimpleCrudKey = GlobalKey<PublishItemsViewSimpleCrudState>();
  final selectHeaderItemsKey = GlobalKey<SelectSubmitItemStateView>();
  final submitItemAnimatedTreeData = TreeNode<WorkHeader>.root();
  late final Int64 curTaskId;

  PublishItemsCrudController(this.curTaskId);

  @override
  void onInit() {
    super.onInit();
    // _buildSubmitItemsMap();
    _buildAnimatedTreeViewData();
  }

  void _buildAnimatedTreeViewData() {
    // dfs 遍历获取所有的 TreeNode
    TreeNode<WorkHeader> innerBuildAnimatedTreeViewData(WorkHeaderTree tree) {
      // ::__inner加上这个字符串，以免节点删除时，可能出现整体消失的情况
      final node = TreeNode(
        key: "${tree.task.id}$innerNodeKey",
        data: tree.task,
      );
      node.addAll(
        tree.children.map((child) => innerBuildAnimatedTreeViewData(child)),
      );
      return node;
    }

    submitItemAnimatedTreeData.addAll(
      submitItems.map((item) => innerBuildAnimatedTreeViewData(item)),
    );
  }
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

WorkHeader newEmptyWorkHeader({String? name}) {
  final id = Int64(DateTime.now().microsecondsSinceEpoch);
  final key = "$id$innerNodeKey";
  return WorkHeader(
    name: "子项-${name ?? key}",
    id: id,
    contentType: unknownValue,
    open: Random().nextInt(TaskOpenRange.values.length),
    required: Random().nextBool(),
  );
}

TreeNode<WorkHeader> newEmptyHeaderTree({String? name, WorkHeader? data}) {
  String key;
  if (data == null) {
    final id = Int64(DateTime.now().microsecondsSinceEpoch);
    key = "$id$innerNodeKey";
    data = newEmptyWorkHeader(name: name);
  } else {
    key = "${data.id}$innerNodeKey";
  }
  return TreeNode(key: key, data: data);
}
