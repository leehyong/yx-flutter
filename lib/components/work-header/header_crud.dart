import 'dart:math';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';

import 'controller.dart';

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

  // 所有新增的节点需要跟当前任务进行绑定
  Set<Int64> binds = {};

  void addChildrenToRoot(Iterable<WorkHeader> children) {
    if (widget.readOnly) {
      return;
    }
    widget.submitItemAnimatedTreeData.addAll(
      children.map((item) => newEmptyHeaderTree(data: item)),
    );
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

  void deleteNode(TreeNode<WorkHeader> node) {
    if (widget.readOnly) {
      return;
    }
    // todo： 调用接口去删除节点
    // 只有叶节点才能删除
    assert(node.isLeaf);
    node.delete();
  }

  // 遍历整棵树
  void traverseTree() {
    void innerTraverseTree(ITreeNode<WorkHeader> node) {
      if (node.key != INode.ROOT_KEY) {
        binds.add(node.data!.id);
      }
      for (final child in node.childrenAsList) {
        innerTraverseTree(child as ITreeNode<WorkHeader>);
      }
    }

    innerTraverseTree(widget.submitItemAnimatedTreeData);
    debugPrint("allbinds:${binds.join(",")}");
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

  void _confirmEditing(TreeNode<WorkHeader> node) {
    if (widget.readOnly) {
      return;
    }
    // 把修改的数据保存到node上
    node.data = _deepCopyNodeData(_isEditingNodeData!);
    if (node == _isNewNode) {
      final parent = node.parent!;
      // todo: 调用新增接口， 把数据存下来,删除新当前节点，并重新再父节点上增加一个新节点
      node.delete();
      final newNode = newEmptyHeaderTree(name: "lhytest");
      parent.add(newNode);
      // 滚动到新节点，以便进行进行查看
      treeViewController!.scrollToItem(newNode);
    } else {
      // todo: 确认时，会调用修改接口的把信息进行保存
    }
    _resetNodeState();
    traverseTree();
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
      focusToNewNode: true,
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
                  icon: Icon(Icons.text_snippet_outlined),
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
                deleteNode(node);
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
        if (node.level <= maxSubmitItemDepth)
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
