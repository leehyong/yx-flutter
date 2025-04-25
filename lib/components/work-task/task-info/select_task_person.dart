import 'dart:collection';
import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';

import 'task_data.dart';

class SelectTaskPersonView extends StatefulWidget {
  const SelectTaskPersonView({super.key});

  @override
  State<StatefulWidget> createState() => SelectTaskPersonState();
}

class SelectTaskPersonState extends State<SelectTaskPersonView> {
  final TreeNode<CheckableOrganizationOrUser> _checkableTree =
      TreeNode<CheckableOrganizationOrUser>.root(
        data: CheckableOrganizationOrUser(newFakeEmptyOrg()),
      );

  // 每个组织对应的用户
  final _orgUsers = HashMap<Int64, List<User>>();

  // 已选择中用户
  final selectedUsers = <User>[];
  final _searchNameController = TextEditingController();

  SelectTaskPersonState() {
    // 初始化数据
    var idx = 0;
    TreeNode<CheckableOrganizationOrUser> cur = _checkableTree;
    while (idx < 100) {
      final isOrg = Random().nextBool();
      Object data;
      if (isOrg) {
        data = newFakeEmptyOrg(name: idx.toString());
      } else {
        data = newFakeEmptyUser(name: idx.toString());
        if (!_orgUsers.containsKey(cur.data!.id)) {
          _orgUsers[cur.data!.id] = [];
        }
        // 记录每个组织的用户
        _orgUsers[cur.data!.id]!.add(data as User);
      }
      final node = TreeNode(data: CheckableOrganizationOrUser(data));
      cur.add(node);
      if (isOrg) {
        if (Random().nextBool()) {
          // 随机改变下次节点的父节点
          cur = node;
        } else {
          cur = _checkableTree;
        }
      }
      ++idx;
    }
  }

  void _recursiveCheckOneNodeByDfs(
    ITreeNode<CheckableOrganizationOrUser> node,
    bool check,
  ) {
    setState(() {
      node.data!.checked = check;
    });
    for (var child in node.childrenAsList) {
      _recursiveCheckOneNodeByDfs(
        child as ITreeNode<CheckableOrganizationOrUser>,
        check,
      );
    }
  }

  int _recursiveSearchUserNameByDfs(
    ITreeNode<CheckableOrganizationOrUser> node,
    String search,
  ) {
    final hidden = search.isEmpty ? false : !node.data!.name.contains(search);
    if (node.isLeaf) {
      setState(() {
        node.data!.hidden = hidden;
      });
      return hidden ? 0 : 1;
    }
    final hiddenNum = node.childrenAsList
        .map(
          (e) => _recursiveSearchUserNameByDfs(
            e as ITreeNode<CheckableOrganizationOrUser>,
            search,
          ),
        )
        .fold(0, (prev, cur) => prev + cur);
    setState(() {
      node.data!.hidden = hiddenNum == 0;
    });
    return hiddenNum;
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
              decoration: InputDecoration(
                labelText: "请输入用户名称",
                icon: Icon(Icons.people),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              //   搜索用户
              _recursiveSearchUserNameByDfs(
                _checkableTree,
                _searchNameController.text.trim(),
              );
            },
            label: Row(children: [const Icon(Icons.search), const Text("搜索")]),
          ),
          ElevatedButton.icon(
            onPressed: () {
              //   重置用户
              _searchNameController.text = '';
              _recursiveSearchUserNameByDfs(_checkableTree, '');
            },
            label: Row(children: [const Icon(Icons.search), const Text("重置")]),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableTaskTree(BuildContext context) {
    return TreeView.simpleTyped<
      CheckableOrganizationOrUser,
      TreeNode<CheckableOrganizationOrUser>
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
            Random(node.data!.id.toInt()).nextInt(10000) % loadingColors.length;
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
    TreeNode<CheckableOrganizationOrUser> node,
  ) {
    final item = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 20),
        // if (node.data!.data is User)
        Checkbox(
          value: node.data!.checked,
          onChanged: (v) {
            _recursiveCheckOneNodeByDfs(node, v!);
          },
        ),

        Expanded(
          child: Tooltip(
            message: node.data!.name,
            child: Row(
              children: [
                Icon(
                  node.data!.data is User ? Icons.person : Icons.insert_chart,
                ),
                Text(
                  node.data!.name,
                  style: TextStyle(
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    final cnt = node.childrenAsList
        .map(
          (e) =>
              (e as TreeNode<CheckableOrganizationOrUser>).data!.hidden
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
