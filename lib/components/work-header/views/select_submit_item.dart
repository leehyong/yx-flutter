import 'dart:collection';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:yt_dart/cus_tree.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/header_api.dart' as header_api;
import 'package:yx/root/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import '../data.dart';

class SelectSubmitItemView extends StatefulWidget {
  SelectSubmitItemView(this.taskId)
    : super(key: Get.find<RootTabController>().taskInfoViewState.currentState!.selectSubmitItemViewState);

  final Int64 taskId;

  @override
  State<StatefulWidget> createState() => SelectSubmitItemViewState();
}

class SelectSubmitItemViewState extends State<SelectSubmitItemView> {
  final TreeNode<CheckableWorkHeader> _checkableTree =
      TreeNode<CheckableWorkHeader>.root();

  bool _loading = false;

  Iterable<TreeNode<WorkHeader>> get allCheckedNode sync* {
    final queue = Queue.from(_checkableTree.childrenAsList);
    TreeNode<CheckableWorkHeader> node;
    TreeNode<CheckableWorkHeader> childNode;
    final nodeParents = <String, TreeNode<WorkHeader>?>{};

    // 层序遍历， 方便记录所有节点的父节点
    while (queue.isNotEmpty) {
      node = queue.first as TreeNode<CheckableWorkHeader>;
      TreeNode<WorkHeader>? parent;
      if (node.data!.checked) {
        // 只有选中的节点才会返回
        parent =
            nodeParents.containsKey(node.key) ? nodeParents[node.key] : null;
        if (parent == null) {
          parent = TreeNode<WorkHeader>(
            data: node.data!.header,
            key: node.key,
            parent: parent,
          );
          // 只返回根级节点，避免子节点与根节点平级
          yield parent;
        } else {
          parent.add(
            TreeNode<WorkHeader>(
              data: node.data!.header,
              key: node.key,
              parent: parent,
            ),
          );
        }
      }
      for (var child in node.childrenAsList) {
        childNode = child as TreeNode<CheckableWorkHeader>;
        nodeParents[childNode.key] = parent;
        queue.add(child);
      }
      queue.removeFirst();
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _loading = true;
    });
    final taskHeaders =
        Get.find<RootTabController>()
        .taskInfoViewState.currentState!
            .publishSubmitItemsCrudViewState
            .currentState
            ?.taskHeaderIds
            .toSet() ??
        {};
    // 递归构建树节点
    header_api.queryWorkHeaders().then((headers) {
      for (var header in (headers ?? <CusYooHeaderTree>[])) {
        _buildTree(_checkableTree, header, taskHeaders);
      }
      setState(() {
        _loading = false;
      });
    });
  }

  void _buildTree(
    TreeNode<CheckableWorkHeader> parent,
    CusYooHeaderTree header,
    Set<Int64> taskHeaders,
  ) {
    final headerId = header.node.id;
    final checked = taskHeaders.contains(headerId);
    final node = TreeNode(
      key: treeNodeKey(headerId),
      data: CheckableWorkHeader(
        header: header.node,
        db: checked,
        checked: checked,
      ),
    );
    parent.add(node);
    for (var child in header.children) {
      _buildTree(node, child, taskHeaders);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: LoadingIndicator(
              indicatorType: Indicator.ballSpinFadeLoader,

              /// Required, The loading type of the widget
              colors: loadingColors,
              strokeWidth: 2,
            ),
          ),
        )
        : TreeView.simpleTyped<
          CheckableWorkHeader,
          TreeNode<CheckableWorkHeader>
        >(
          showRootNode: false,
          tree: _checkableTree,
          expansionBehavior: ExpansionBehavior.collapseOthersAndSnapToTop,
          expansionIndicatorBuilder:
              (ctx, node) => ChevronIndicator.rightDown(
                tree: node,
                alignment: Alignment.centerLeft,
                color: Colors.red,
              ),
          shrinkWrap: true,
          indentation: const Indentation(style: IndentStyle.roundJoint),
          builder: (context, node) {
            // 不显示根节点
            if (node.key == INode.ROOT_KEY) {
              return SizedBox.shrink();
            }
            return buildRandomColorfulBox( _buildReadonlyItemHeader(context, node),
                node.data!.header.id.toInt()
            );
          },
          onItemTap: (node) {
            debugPrint("${node.level}");
          },
        );
  }

  void _recursiveSelectNodes(TreeNode<CheckableWorkHeader> node, bool checked) {
    node.data!.checked = checked;
    TreeNode<CheckableWorkHeader> childNode;
    // 递归更改其子节点的状态
    for (var child in node.childrenAsList) {
      childNode = child as TreeNode<CheckableWorkHeader>;
      childNode.data!.checked = checked;
      _recursiveSelectNodes(child, checked);
    }
  }

  Widget _buildReadonlyItemHeader(
    BuildContext ctx,
    TreeNode<CheckableWorkHeader> node,
  ) {
    final item = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 20),
        Checkbox(
          value: node.data!.checked,
          onChanged: (v) {
            setState(() {
              _recursiveSelectNodes(node, v!);
            });
          },
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            // spacing: 8,
            children: [
              Tooltip(
                message: node.data!.header.name,
                child: Row(
                  spacing: 4,
                  children: [
                    Text(
                      node.data!.header.name,
                      style: TextStyle(
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (node.data!.db)
                      TDBadge(
                        TDBadgeType.message,
                        color: Colors.blue,
                        textColor: Colors.white,
                        message: "已有的",
                      ),
                  ],
                ),
              ),
              SizedBox(height: 6),
              buildTaskOpenRangeAndContentType(node.data!.header, isRow: true),
            ],
          ),
        ),
      ],
    );
    final cnt = node.children.length;
    return cnt == 0
        ? item
        : Badge.count(
          alignment: Alignment.topLeft,
          count: node.children.length,
          child: item,
        );
  }
}
