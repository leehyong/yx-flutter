import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';

import 'controller.dart';
import 'header_tree.dart';

class PublishItemsViewSimpleCrud extends StatefulWidget {
  const PublishItemsViewSimpleCrud({super.key});

  @override
  _PublishItemsViewSimpleCrud createState() => _PublishItemsViewSimpleCrud();
}

class _PublishItemsViewSimpleCrud extends State<PublishItemsViewSimpleCrud> {
  final TreeNode<WorkHeader> submitItemAnimatedTreeData =
      TreeNode<WorkHeader>.root();
  TreeViewController? treeViewController;

  _PublishItemsViewSimpleCrud() {
    buildAnimatedTreeViewData();
  }

  void buildAnimatedTreeViewData() {
    // dfs 遍历获取所有的 TreeNode
    TreeNode<WorkHeader> innerBuildAnimatedTreeViewData(WorkHeaderTree tree) {
      final node = TreeNode(key: tree.task.id.toString(), data: tree.task);
      node.addAll(
        tree.children.map((child) => innerBuildAnimatedTreeViewData(child)),
      );
      return node;
    }

    submitItemAnimatedTreeData.addAll(
      submitItems.map((item) => innerBuildAnimatedTreeViewData(item)),
    );
    debugPrint("1111buildAnimatedTreeViewData");
  }

  @override
  Widget build(BuildContext context) {
    return TreeView.simpleTyped<WorkHeader, TreeNode<WorkHeader>>(
      showRootNode: false,
      tree: submitItemAnimatedTreeData,
      expansionBehavior: ExpansionBehavior.collapseOthersAndSnapToTop,
      expansionIndicatorBuilder:
          (ctx, node) => NoExpansionIndicator(tree: node),
      shrinkWrap: true,
      indentation: const Indentation(style: IndentStyle.roundJoint),
      builder: (context, node) {
        if (node.key == INode.ROOT_KEY) {
          return SizedBox.shrink();
        }
        final colorIdx =
            (Random().nextInt(1000) + node.level) % loadingColors.length;
        // 把颜色做成随机透明的
        final ra = 20 + Random().nextInt(230);
        final expandIcon =
            node.isExpanded ? Icons.arrow_drop_down : Icons.arrow_right;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: loadingColors[colorIdx].withAlpha(ra),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!node.isLeaf)
                    Icon(expandIcon, color: Colors.red, size: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // spacing: 8,
                    children: [
                      Tooltip(
                        message: node.data!.name,
                        child: Text(
                          node.data!.name.substring(
                            0,
                            min(14, node.data!.name.length),
                          ),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 4,),
                      buildTaskOpenRangeAndContentType(node.data!, isRow: true),

                    ],
                  ),
                ],
              ),

              Positioned(
                top: 0,
                bottom: 0,
                right: 4,
                child: Row(children: [
                  _buildItemAction(context, node),
                ],),
              ),
            ],
          ),
        );
      },
      onItemTap: (node) {
        debugPrint("${node.level}");
        // if (node.isExpanded) {
        //   treeViewController?.collapseNode(node);
        // } else {
        //   treeViewController?.expandAllChildren(node);
        // }
      },
      onTreeReady: (treeController) {
        treeViewController = treeController;
      },
    );
  }

  Widget _buildItemAction(BuildContext ctx, TreeNode<WorkHeader> node) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // addNewHeaderTree(root.children, "", controller);
            debugPrint("删除当前节点");
            if (node.isLeaf) {
              // 删除当前节点
              node.delete();
            } else {
              // todo 等待删除确认
              node.delete();
            }
          },
          icon: Icon(Icons.delete, size: 22, color: Colors.red),
        ),
        IconButton(
          onPressed: () {
            debugPrint("新增子节点成功");
            node.add(newEmptyHeaderTree());
          },
          icon: Icon(Icons.add, size: 22, color: Colors.purple),
        ),
      ],
    );
  }
}
