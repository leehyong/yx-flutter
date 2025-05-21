import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/cus_header.pbserver.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yt_dart/generate_sea_orm_update.pb.dart';
import 'package:yx/api/header_api.dart' as header_api;
import 'package:yx/components/work-task/task-info/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';

import '../controller.dart';

class PublishItemsViewSimpleCrud extends StatefulWidget {
  const PublishItemsViewSimpleCrud(
    this.submitItemAnimatedTreeData,
    this.readOnly, {
    super.key,
  });

  final bool readOnly;
  final TreeNode<WorkHeader> submitItemAnimatedTreeData;

  @override
  PublishItemsViewSimpleCrudState createState() =>
      PublishItemsViewSimpleCrudState();
}

class PublishItemsViewSimpleCrudState
    extends State<PublishItemsViewSimpleCrud> {
  // late final TreeNode<WorkHeader>  widget.submitItemAnimatedTreeData ;
  TreeViewController? treeViewController;

  TreeNode<WorkHeader>? _isEditingNode;
  WorkHeader? _isEditingNodeData;
  TreeNode<WorkHeader>? _isNewNode;

  void _buildAnimatedTreeViewData(List<CusYooHeader> headers) {
    // dfs 遍历获取所有的 TreeNode
    TreeNode<WorkHeader> innerBuildAnimatedTreeViewData(CusYooHeader tree) {
      final node = TreeNode(key: treeNodeKey(tree.node.id), data: tree.node);
      node.addAll(
        tree.children.map((child) => innerBuildAnimatedTreeViewData(child)),
      );
      return node;
    }

    addNodesToRoot(headers.map((item) => innerBuildAnimatedTreeViewData(item)));
  }

  void addNodesToRoot(Iterable<TreeNode<WorkHeader>> nodes) {
    if (widget.readOnly) {
      return;
    }
    widget.submitItemAnimatedTreeData.addAll(nodes.toList());
  }

  void clearAllNodes() {
    if (widget.readOnly) {
      return;
    }
    widget.submitItemAnimatedTreeData.clear();
  }

  void addChildToNode([TreeNode<WorkHeader>? node]) {
    if (widget.readOnly) {
      return;
    }
    if (_isEditingNode != null) {
      errToast("请先完成节点信息修改，再操作");
      treeViewController?.scrollToItem(_isEditingNode!);
    } else {
      final newNode = newEmptyHeaderTree();
      (node ?? widget.submitItemAnimatedTreeData).add(newNode);
      // 修改状态
      setState(() {
        _isEditingNode = newNode;
        // bugfix: 复制 newNode 的数据，避免在取消编辑的时候也会修改原来的数据
        _isEditingNodeData = _deepCopyNodeData(newNode.data!);
        _isNewNode = newNode;
      });
    }
  }

  void _deleteNode(TreeNode<WorkHeader> node) {
    if (widget.readOnly) {
      return;
    }
    // 只有叶节点才能删除
    // 调用接口去删除节点
    assert(node.isLeaf);
    centerLoadingModal(context, () async {
      header_api.deleteWorkHeader(curTaskId, node.data!.id).then((err) {
        // 数据库返回删除成功时，才删除改节点
        if (err?.isEmpty ?? true) {
          node.delete();
        }
      });
    });
  }

  void _cancelEditing(TreeNode<WorkHeader> node) {
    if (widget.readOnly) {
      return;
    }
    //取消时，不需要改变 node.data
    if (node == _isNewNode) {
      node.delete();
    }
    _resetNodeState();
  }

  void _resetNodeState() {
    if (widget.readOnly) {
      return;
    }
    setState(() {
      _isEditingNodeData = null;
      _isNewNode = null;
      _isEditingNode = null;
    });
  }

  WorkHeader _deepCopyNodeData(WorkHeader data) =>
      WorkHeader.fromJson(data.writeToJson());

  Int64 get curTaskId => Get.find<TaskInfoController>().taskId.value;

  void _confirmEditing(TreeNode<WorkHeader> node) {
    if (widget.readOnly) {
      return;
    }
    // 把修改的数据保存到node上
    node.data = _deepCopyNodeData(_isEditingNodeData!);
    final parent = node.parent!;
    final parentId =
        parent.key == INode.ROOT_KEY
            ? Int64.ZERO
            : (parent as TreeNode<WorkHeader>).data!.id;
    if (node == _isNewNode) {
      final data = NewWorkHeader(
        name: node.data!.name,
        contentType: node.data!.contentType,
        open: node.data!.open,
        required: node.data!.required,
      );
      // 新增时保存变更，以后弹窗提醒
      if (curTaskId <= Int64.ZERO){
        Get.find<TaskInfoController>().saveModification(
          ModifyWarningCategory.header,
        );
      }
      // 调用新增接口， 把数据存下来, 删除新当前节点，并重新在父节点上增加一个新节点
      centerLoadingModal(context, () async {
        header_api.newWorkHeader(curTaskId, parentId, data).then((headerId) {
          final newNode = TreeNode(
            key: treeNodeKey(headerId),
            data: WorkHeader(
              id: headerId,
              name: node.data!.name,
              contentType: node.data!.contentType,
              open: node.data!.open,
              required: node.data!.required,
            ),
          );
          node.delete();
          parent.add(newNode);
          // 滚动到新节点，以便进行进行查看
          treeViewController!.scrollToItem(newNode);
        });
      });
    } else {
      final headerId = node.data!.id;
      final data = UpdateWorkHeader(
        name: node.data!.name,
        contentType: node.data!.contentType,
        open: node.data!.open,
        required: node.data!.required,
      );
      // 确认时，会调用修改接口的把信息进行保存
      centerLoadingModal(context, () async {
        header_api.updateWorkHeader(headerId, data).then((_) {
          // 滚动到新节点，以便进行进行查看
          treeViewController!.scrollToItem(node);
        });
      });
    }
    _resetNodeState();
  }

  void _setCurEditingNode(TreeNode<WorkHeader> node) {
    if (widget.readOnly) {
      return;
    }
    setState(() {
      _isEditingNodeData = _deepCopyNodeData(node.data!);
      _isEditingNode = node;
    });
  }

  void expandAllChildren() {
    treeViewController?.expandAllChildren(widget.submitItemAnimatedTreeData);
  }

  void collapseAllChildren() {
    if (treeViewController != null) {
      for (var node in widget.submitItemAnimatedTreeData.children.values) {
        treeViewController?.collapseNode(node as ITreeNode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TreeView.simpleTyped<WorkHeader, TreeNode<WorkHeader>>(
      showRootNode: false,
      // focusToNewNode: true,
      tree: widget.submitItemAnimatedTreeData,
      expansionBehavior: ExpansionBehavior.collapseOthersAndSnapToTop,
      expansionIndicatorBuilder:
          (ctx, node) =>
              _isEditingNode == node
                  ? NoExpansionIndicator(tree: node)
                  : ChevronIndicator.rightDown(
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
        // 区分编辑和只读
        return Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: loadingColors[colorIdx].withAlpha(40),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              _isEditingNode == node
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
    final item = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 18),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            // spacing: 8,
            children: [
              Tooltip(
                message: node.data!.name,
                child: Text(
                  node.data!.name,
                  style: TextStyle(
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(height: 6),
              buildTaskOpenRangeAndContentType(node.data!, isRow: true),
            ],
          ),
        ),
        if (!widget.readOnly) _buildItemAction(context, node),
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

  Widget _buildWritingItemHeader(
    BuildContext context,
    TreeNode<WorkHeader> node,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller:
                    TextEditingController()..text = _isEditingNodeData!.name,
                decoration: InputDecoration(
                  labelText: "填报项名称",
                  hintText: '请输入填报项名称',
                  icon: Icon(Icons.text_snippet_outlined),
                  suffixIcon: InkWell(
                    onTap: () {
                      _isEditingNodeData!.name = '';
                    },
                    child: Tooltip(
                      message: "内容清除",
                      child: Icon(
                        Icons.remove,
                        color: Colors.red.withAlpha(180),
                      ),
                    ),
                  ),
                ),
                onChanged: (v) {
                  _isEditingNodeData!.name = v;
                },
              ),
              _buildWritingItemHeaderRequiredAttributes(context, node),
            ],
          ),
        ),
        _buildWritingItemHeaderActions(context, node),
      ],
    );
  }

  Widget _buildWritingItemHeaderRequiredAttributes(
    BuildContext context,
    TreeNode<WorkHeader> node,
  ) {
    // 只支持改名、范围、文本类型及 是否必填项操作了 ，
    // 必填项操作， 每项单独设置， 不依赖于父节点
    return Row(
      spacing: 4,
      children: [
        Expanded(
          child: DropdownButtonFormField(
            value: _isEditingNodeData!.required,
            items: [
              DropdownMenuItem(value: true, child: Text("是")),
              DropdownMenuItem(value: false, child: Text("否")),
            ],
            decoration: InputDecoration(labelText: "是否必填项"),
            onChanged: (v) {
              _isEditingNodeData!.required = v!;
            },
          ),
        ),
        Expanded(
          child: DropdownButtonFormField(
            value: _isEditingNodeData!.contentType,
            items: [
              DropdownMenuItem(value: unknownValue, child: const Text("未知")),
              ...TaskTextType.values.map(
                (v) => DropdownMenuItem(value: v.index, child: Text(v.i18name)),
              ),
            ],
            decoration: InputDecoration(
              errorText:
                  _isEditingNodeData!.contentType == unknownValue
                      ? "请选择文本类型"
                      : null,
              label: Row(
                spacing: 2,
                children: [
                  Icon(Icons.format_color_text, size: 14),
                  const Text("文本类型"),
                ],
              ),
            ),
            onChanged: (v) {
              setState(() {
                _isEditingNodeData!.contentType = v!;
              });
            },
          ),
        ),
        Expanded(
          child: DropdownButtonFormField(
            value: _isEditingNodeData!.open,
            items:
                TaskOpenRange.values
                    .map(
                      (v) => DropdownMenuItem(
                        value: v.index,
                        child: Text(v.i18name),
                      ),
                    )
                    .toList(),
            decoration: InputDecoration(
              label: Row(
                spacing: 2,
                children: [Icon(Icons.share, size: 14), const Text("开放范围")],
              ),
            ),
            onChanged: (v) {
              _isEditingNodeData!.open = v!;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWritingItemHeaderActions(
    BuildContext context,
    TreeNode<WorkHeader> node,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            _cancelEditing(node);
          },
          icon: Tooltip(message: "取消修改", child: Icon(Icons.cancel_outlined)),
        ),
        IconButton(
          onPressed: () {
            if (_isEditingNodeData!.contentType != unknownValue) {
              _confirmEditing(node);
            } else {
              errToast("请选择文本类型");
            }
          },
          icon: Tooltip(
            message: "确认修改",
            child: Icon(Icons.check, color: Colors.blue),
          ),
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
              debugPrint("删除当前节点 ${node.key}");
              if (node.isLeaf) {
                _deleteNode(node);
              }
            },
            icon: Tooltip(
              message: "删除当前项",
              child: Icon(Icons.delete, size: 22, color: Colors.red),
            ),
          ),
        if (_isEditingNode == null)
          IconButton(
            onPressed: () {
              _setCurEditingNode(node);
            },
            icon: Tooltip(
              message: "修改",
              child: Icon(Icons.edit, size: 22, color: Colors.purple),
            ),
          ),
        if (node.level <= 3)
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

  @override
  void initState() {
    super.initState();
    debugPrint("PublishItemsViewSimpleCrudState initState");
    final taskInfoController = Get.find<TaskInfoController>();
    widget.submitItemAnimatedTreeData.clear();
    if (taskInfoController.taskId.value > Int64.ZERO) {
      header_api.queryWorkHeaders(taskInfoController.taskId.value).then((v) {
        if (v?.isNotEmpty ?? false) {
          _buildAnimatedTreeViewData(v!);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("PublishItemsViewSimpleCrudState dispose");
    // 避免存在空节点
    if (_isEditingNode != null && _isEditingNode?.data?.name == '') {
      _isEditingNode!.delete();
    }
  }
}
