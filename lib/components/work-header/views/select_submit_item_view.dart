import 'dart:collection';
import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/utils/common_widget.dart';

import '../../../types.dart';
import '../controller.dart';
import '../data.dart';

class SelectSubmitItemView extends StatefulWidget {
  const SelectSubmitItemView(this.taskId, {super.key});

  final Int64 taskId;

  @override
  State<StatefulWidget> createState() => SelectSubmitItemStateView();
}

class SelectSubmitItemStateView extends State<SelectSubmitItemView> {
  final TreeNode<CheckableWorkHeader> _checkableTree =
      TreeNode<CheckableWorkHeader>.root();

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

  SelectSubmitItemStateView() {
    // 初始化数据
    var idx = 0;
    WorkHeader header;
    TreeNode<CheckableWorkHeader> cur = _checkableTree;
    while (idx < 100) {
      header = newEmptyWorkHeader(name: idx.toString());
      final node = TreeNode(data: CheckableWorkHeader(header));
      cur.add(node);
      if (Random().nextBool()) {
        // 随机改变下次节点的父节点
        cur = node;
      } else {
        cur = _checkableTree;
      }
      ++idx;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TreeView.simpleTyped<
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
        final colorIdx =
            Random(node.data!.header.id.toInt()).nextInt(10000) %
            loadingColors.length;
        // 把颜色做成随机透明的
        // 区分编辑和只读
        return Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: loadingColors[colorIdx].withAlpha(40),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildReadonlyItemHeader(context, node),
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
                child: Text(
                  node.data!.header.name,
                  style: TextStyle(
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
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
