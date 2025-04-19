import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';

import 'controller.dart';
import 'header_tree.dart';

class PublishItemsViewSimpleCrud extends StatefulWidget {
  const PublishItemsViewSimpleCrud({super.key});

  @override
  PublishItemsViewSimpleCrudState createState() =>
      PublishItemsViewSimpleCrudState();
}

class PublishItemsViewSimpleCrudState
    extends State<PublishItemsViewSimpleCrud> {
  final TreeNode<WorkHeader> _submitItemAnimatedTreeData =
      TreeNode<WorkHeader>.root();
  TreeViewController? treeViewController;

  Int64 _isEditingNodeId = Int64.ZERO;

  PublishItemsViewSimpleCrudState() {
    _buildAnimatedTreeViewData();
  }

  void addChildToNode([TreeNode<WorkHeader>? node]) {
    if (_isEditingNodeId != Int64.ZERO) {
      errToast("已添加了新节点，请先完成新节点的信息修改");
    } else {
      final newNode = newEmptyHeaderTree();
      (node ?? _submitItemAnimatedTreeData).add(newNode);
      // 修改状态
      setState(() {
        _isEditingNodeId = newNode.data!.id;
      });
    }
  }

  void _exitEditing() {
    setState(() {
      _isEditingNodeId = Int64.ZERO;
    });
  }

  void _buildAnimatedTreeViewData() {
    // dfs 遍历获取所有的 TreeNode
    TreeNode<WorkHeader> innerBuildAnimatedTreeViewData(WorkHeaderTree tree) {
      final node = TreeNode(key: tree.task.id.toString(), data: tree.task);
      node.addAll(
        tree.children.map((child) => innerBuildAnimatedTreeViewData(child)),
      );
      return node;
    }

    _submitItemAnimatedTreeData.addAll(
      submitItems.map((item) => innerBuildAnimatedTreeViewData(item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TreeView.simpleTyped<WorkHeader, TreeNode<WorkHeader>>(
      showRootNode: false,
      tree: _submitItemAnimatedTreeData,
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
        final colorIdx = node.data!.id.toInt() % loadingColors.length;
        // 把颜色做成随机透明的
        final ra = 20 + Random().nextInt(40);
        // 区分编辑和只读
        return Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: loadingColors[colorIdx].withAlpha(ra),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              (node.data!.contentType == unknownValue ||
                      _isEditingNodeId == node.data!.id)
                  ? _buildWritingItemHeader(context, node)
                  : _buildReadonlyItemHeader(context, node),
        );
      },
      onItemTap: (node) {
        debugPrint("${node.level}");
      },
      onTreeReady: (treeController) {
        treeViewController = treeController;
      },
    );
  }

  Widget _buildReadonlyItemHeader(BuildContext ctx, TreeNode<WorkHeader> node) {
    return Stack(
      children: [
        _buildItemHeader(context, node),
        Positioned(
          top: 0,
          bottom: 0,
          right: 4,
          child: Row(children: [_buildItemAction(context, node)]),
        ),
      ],
    );
  }

  Widget _buildWritingItemHeader(
    BuildContext context,
    TreeNode<WorkHeader> node,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController()..text = node.data!.name,
            decoration: InputDecoration(
              labelText: "填报项名称",
              icon: Icon(Icons.text_snippet_outlined),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                _exitEditing();
              },
              icon: Tooltip(
                message: "取消修改",
                child: Icon(Icons.cancel_outlined),
              ),
            ),
            IconButton(
              onPressed: () {
                _exitEditing();
              },
              icon: Tooltip(
                message: "确认修改",
                child: Icon(Icons.check, color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemHeader(BuildContext context, TreeNode<WorkHeader> node) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 20),
        // if (!node.isLeaf)
        //   Icon(expandIcon, color: Colors.red, size: 24),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          // spacing: 8,
          children: [
            Tooltip(
              message: node.data!.name,
              child: Text(
                node.data!.name,
                style: TextStyle(fontSize: 18, overflow: TextOverflow.ellipsis),
              ),
            ),
            SizedBox(height: 4),
            buildTaskOpenRangeAndContentType(node.data!, isRow: true),
          ],
        ),
      ],
    );
  }

  Widget _buildItemAction(BuildContext ctx, TreeNode<WorkHeader> node) {
    return Row(
      children: [
        if (node.isLeaf)
          IconButton(
            onPressed: () {
              debugPrint("删除当前节点");
              node.delete();
              // if (node.isLeaf) {
              //   // 删除当前节点
              // }
            },
            icon: Tooltip(
              message: "删除当前项",
              child: Icon(Icons.delete, size: 22, color: Colors.red),
            ),
          ),
        IconButton(
          onPressed: () {
            setState(() {
              _isEditingNodeId = node.data!.id;
            });
          },
          icon: Tooltip(
            message: "修改",
            child: Icon(Icons.edit, size: 22, color: Colors.purple),
          ),
        ),
        IconButton(
          onPressed: () {
            debugPrint("新增子节点成功");
            addChildToNode(node);
          },
          icon: Tooltip(
            message: "新增子项",
            child: Icon(Icons.add, size: 22, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
