import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';

import 'task_data.dart';

class SelectParentTaskView extends StatefulWidget {
  const SelectParentTaskView({super.key});

  @override
  State<StatefulWidget> createState() => SelectParentTaskState();
}

class SelectParentTaskState extends State<SelectParentTaskView> {
  final TreeNode<CheckableWorkTask> _checkableTree =
      TreeNode<CheckableWorkTask>.root(data: CheckableWorkTask(newFakeEmptyWorkTask()));

  WorkTask? curCheckedTask;

  final _searchNameController = TextEditingController();

  int _recursiveSearchTaskNameByDfs(
    ITreeNode<CheckableWorkTask> node,
    String search,
  ) {
    final show = search.isEmpty ? true : node.data!.task.name.contains(search);
    if (node.isLeaf) {
      setState(() {
        node.data!.hidden = !show;
      });
      return show ? 1 : 0;
    }
    final checkNum = node.childrenAsList
        .map(
          (e) => _recursiveSearchTaskNameByDfs(
            e as ITreeNode<CheckableWorkTask>,
            search,
          ),
        )
        .fold(0, (prev, cur) => prev + cur);
    setState(() {
      node.data!.hidden = checkNum == 0;
    });
    return checkNum;
  }

  SelectParentTaskState() {
    // 初始化数据
    var idx = 0;
    TreeNode<CheckableWorkTask> cur = _checkableTree;
    while (idx < 100) {
      final node = TreeNode(
        data: CheckableWorkTask(newFakeEmptyWorkTask(name: idx.toString())),
      );
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
    return Column(
      children: [
        _buildSearchableTask(context),
        SizedBox(height: 8),
        Expanded(child: _buildSelectableTaskTree(context)),
      ],
    );
  }

  Widget _buildSearchableTask(BuildContext context) {
    return maybeOneThirdCenterHorizontal(
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchNameController,
              onChanged: (v) {
                if (v.isEmpty) {
                  _recursiveSearchTaskNameByDfs(
                    _checkableTree,
                    _searchNameController.text.trim(),
                  );
                }
              },
              decoration: InputDecoration(
                labelText: "请输入任务名称",
                icon: Icon(Icons.password),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _recursiveSearchTaskNameByDfs(
                _checkableTree,
                _searchNameController.text.trim(),
              );
            },
            label: Row(children: [const Icon(Icons.search), const Text("搜索")]),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _searchNameController.text = '';
              _recursiveSearchTaskNameByDfs(_checkableTree, '');
            },
            label: Row(children: [const Icon(Icons.search), const Text("重置")]),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableTaskTree(BuildContext context) {
    return TreeView.simpleTyped<CheckableWorkTask, TreeNode<CheckableWorkTask>>(
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
            Random(node.data!.task.id.toInt()).nextInt(10000) %
            loadingColors.length;
        // 把颜色做成随机透明的
        return node.data!.hidden
            ? SizedBox.shrink()
            : Container(
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

  Widget _buildReadonlyItemHeader(
    BuildContext ctx,
    TreeNode<CheckableWorkTask> node,
  ) {
    final item = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 20),
        Checkbox(
          value: curCheckedTask == node.data!.task,
          onChanged: (v) {
            setState(() {
              curCheckedTask = node.data!.task;
            });
          },
        ),

        Expanded(
          child: Tooltip(
            message: node.data!.task.name,
            child: Text(
              node.data!.task.name,
              style: TextStyle(fontSize: 18, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
    final cnt = node.childrenAsList
        .map(
          (e) =>
      (e as TreeNode<CheckableWorkTask>).data!.hidden
          ? 0
          : 1,
    )
        .fold(0, (prev, cur) => prev + cur);
    return cnt == 0
        ? item
        : Badge.count(
          alignment: Alignment.topLeft,
          count: cnt,
          child: item,
        );
  }
}
