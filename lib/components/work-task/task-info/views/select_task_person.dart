import 'dart:collection';
import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:yt_dart/cus_user_organization.pbserver.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/user_api.dart' as user_api;
import 'package:yx/root/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';

import '../data.dart';

class SelectTaskPersonView extends StatefulWidget {
  const SelectTaskPersonView({super.key});

  @override
  State<StatefulWidget> createState() => SelectTaskUserState();
}

class SelectTaskUserState extends State<SelectTaskPersonView> {
  final TreeNode<CheckableOrganizationOrUser> _checkableTreeRoot =
      TreeNode<CheckableOrganizationOrUser>.root();

  // 某任务已选中用户
  LinkedHashMap<Int64, User>? _taskSelectedUsers;
  final _searchNameController = TextEditingController();
  bool _loading = false;

  List<User> get curTaskSelectedUsers {
    final users = <User>[];

    void findCheckableUsersByDfs(TreeNode<CheckableOrganizationOrUser> node) {
      final data = node.data!;
      final instance = data.data;
      if (instance is User) {
        if (data.checked) users.add(instance);
      } else if (instance is Organization) {
        for (var child in node.childrenAsList) {
          findCheckableUsersByDfs(
            child as TreeNode<CheckableOrganizationOrUser>,
          );
        }
      }
    }

    // 找到所有勾选的用户
    for (var node in _checkableTreeRoot.childrenAsList) {
      findCheckableUsersByDfs(node as TreeNode<CheckableOrganizationOrUser>);
    }
    return users;
  }

  @override
  void initState() {
    super.initState();
    _taskSelectedUsers = LinkedHashMap.fromEntries(
      (Get.find<RootTabController>()
                  .taskInfoViewState
                  .currentState
                  ?.checkedTaskUsers ??
              [])
          .map((u) => MapEntry(u.id, u)),
    );
    setState(() {
      _loading = true;
    });
    user_api.getOrganizationUsers().then((userOrg) {
      if (userOrg != null) {
        _buildCheckableUserOrganization(_checkableTreeRoot, userOrg);
      } else {
        _checkableTreeRoot.clear();
      }
      setState(() {
        _loading = false;
      });
    });
  }

  void _buildCheckableUserOrganization(
    TreeNode<CheckableOrganizationOrUser> parent,
    CusUserOrganization userOrg,
  ) {
    final id = userOrg.organization.id;
    final orgData = CheckableOrganizationOrUser(
      userOrg.organization,
      checked:
          // 组织下的全部用户都选中时，该组织就显示为勾选状态，反之则不会
          userOrg.users
              .where((u) => _taskSelectedUsers?.containsKey(u.id) ?? false)
              .toList()
              .length ==
          userOrg.users.length,
    );
    final parentOrgNode = TreeNode(
      key: "org-${treeNodeKey(id)}",
      data: orgData,
    );
    // 添加组织
    parent.add(parentOrgNode);
    // 添加该组织下的用户
    for (var user in userOrg.users) {
      final id = user.id;
      parentOrgNode.add(
        TreeNode(
          key: "user-${treeNodeKey(id)}",
          data: CheckableOrganizationOrUser(
            user,
            checked: _taskSelectedUsers?.containsKey(id) ?? false,
          ),
        ),
      );
    }
    //  递归构建下级组织及其所属用户
    for (var uo in userOrg.children) {
      _buildCheckableUserOrganization(parentOrgNode, uo);
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
    final hidden =
        search.isEmpty ? false : (!(node.data?.name.contains(search) ?? false));
    if (node.isLeaf) {
      setState(() {
        if (node.data != null) {
          node.data!.hidden = hidden;
        }
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
      if (node.data != null) {
        node.data!.hidden = hiddenNum == 0;
      }
    });
    return hiddenNum;
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: LoadingIndicator(
              indicatorType: Indicator.ballGridBeat,

              /// Required, The loading type of the widget
              colors: loadingColors,
              strokeWidth: 2,
            ),
          ),
        )
        : Column(
          children: [
            _buildSearchableTask(context),
            SizedBox(height: 8),
            Expanded(child: _buildSelectableTaskTree(context)),
          ],
        );
  }

  Widget _buildSearchableTask(BuildContext context) {
    // return maybeOneThirdCenterHorizontal(
    return Row(
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
              _checkableTreeRoot,
              _searchNameController.text.trim(),
            );
          },
          label: Row(children: [const Icon(Icons.search), const Text("搜索")]),
        ),
        ElevatedButton.icon(
          onPressed: () {
            //   重置用户
            _searchNameController.text = '';
            _recursiveSearchUserNameByDfs(_checkableTreeRoot, '');
          },
          label: Row(children: [const Icon(Icons.search), const Text("重置")]),
        ),
      ],
    );
  }

  Widget _buildSelectableTaskTree(BuildContext context) {
    return TreeView.simpleTyped<
      CheckableOrganizationOrUser,
      TreeNode<CheckableOrganizationOrUser>
    >(
      showRootNode: false,
      tree: _checkableTreeRoot,
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
              child: _buildReadonlyItem(context, node),
            );
      },
      onItemTap: (node) {
        debugPrint("${node.level}");
      },
    );
  }

  Widget _buildReadonlyItem(
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
                  node.data!.data is User ? Icons.person : Icons.table_chart,
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
              (e as TreeNode<CheckableOrganizationOrUser>).data!.hidden ? 0 : 1,
        )
        .fold(0, (prev, cur) => prev + cur);
    return cnt == 0
        ? item
        : Badge.count(alignment: Alignment.topLeft, count: cnt, child: item);
  }
}
