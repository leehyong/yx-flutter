import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';

import '../work-task/task-info/controller.dart';
import 'views/header_crud.dart';
import 'views/select_submit_item.dart';

class PublishItemsCrudController extends GetxController {
  final isLoadingSubmitItem = false.obs;
  final expandAll = false.obs;
  final itemsSimpleCrudKey = GlobalKey<PublishItemsViewSimpleCrudState>();
  final selectHeaderItemsKey = GlobalKey<SelectSubmitItemViewState>();
  final submitItemAnimatedTreeData = TreeNode<WorkHeader>.root();

  TaskInfoController get getTaskInfoController =>
      Get.find<TaskInfoController>();

  bool get readOnly => getTaskInfoController.readOnly;

  @override
  void onInit() {
    super.onInit();

    // _buildSubmitItemsMap();
    // 监听taskId， 如有变化，则重新加载表头
    ever(getTaskInfoController.taskId, (taskId) {
      debugPrint("PublishItemsCrudController-getTaskInfoController: $taskId");
      // 不管如何taskId都变化了， 那么就需要把整棵树都清空，再重新构造这棵树
      // WidgetsBinding.instance.addPostFrameCallback((f){
      //   itemsSimpleCrudKey.currentState?.clearAllNodes();
      //   if (taskId > Int64.ZERO) {
      //
      //   }
      // });
    });
  }



  List<Int64> get taskHeaderIds {
    final headerIds = <Int64>[];
    void headerId(ITreeNode<WorkHeader> node) {
      if (node.key != INode.ROOT_KEY) {
        headerIds.add(node.data!.id);
        return;
      }
      // 把节点id加入结果集中
      for (var child in node.childrenAsList) {
        headerId(child as ITreeNode<WorkHeader>);
      }
    }

    headerId(submitItemAnimatedTreeData);
    return headerIds;
  }
}

WorkHeader newEmptyWorkHeader({String? name}) {
  final id = Int64(DateTime.now().microsecondsSinceEpoch);
  final key = "$id$innerNodeKey";
  return WorkHeader(
    name: name == null ? '': "子项-$name",
    id: id,
    contentType: unknownValue,
    open: Random().nextInt(TaskOpenRange.values.length),
    required: Random().nextBool(),
  );
}

TreeNode<WorkHeader> newEmptyHeaderTree({WorkHeader? data}) {
  String key;
  if (data == null) {
    final id = Int64(DateTime.now().microsecondsSinceEpoch);
    key = "$id$innerNodeKey";
    data = newEmptyWorkHeader();
  } else {
    key = "${data.id}$innerNodeKey";
  }
  return TreeNode(key: key, data: data);
}
