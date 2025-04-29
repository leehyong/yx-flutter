import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_widget.dart';

import '../../../work-header/controller.dart';
import '../../../work-header/data.dart';
import '../controller.dart';
import '../data.dart';

// 填报任务项的时候使用它
// todo： title 展示任务名， 并且可以查看任务的信息
class SubmitTasksView extends GetView<SubmitTasksController> {
  SubmitTasksView(bool readOnly, {super.key}) {
    Get.put(SubmitTasksController(readOnly));
  }

  Widget _buildRootHeaderNameTable(BuildContext context, WorkHeaderTree root) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(150), // 设置背景色
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Tooltip(
                message: root.header.name,
                child: Row(
                  spacing: 4,
                  children: [
                    Text(
                      root.header.name,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            // 阴影颜色
                            offset: Offset(1, 0),
                            // Y 轴偏移量
                            blurRadius: 1, // 阴影模糊程度
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    buildTaskOpenRangeAndContentType(root.header, isRow: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // final crossCount = constraints.maxWidth >= 720 ? 4 : 1;
        final cnt = submitItems.length;
        final isBigScreen = MediaQuery.of(ctx).size.width > 720;
        return Obx(
          () => ListView.builder(
            cacheExtent: 100,
            controller: controller.scrollController,
            // addRepaintBoundaries:t,
            itemCount: controller.isLoadingSubmitItem.value ? cnt + 1 : cnt,
            itemBuilder: (ctx, idx) {
              final headerTree = submitItems[idx];
              final oneItem = [_buildRootHeaderNameTable(context, headerTree)];
              oneItem.add(
                isBigScreen
                    ? _WebSubmitWorkHeaderItemView(
                      headerTree.header.id.toString(),
                      headerTree.children,
                    )
                    : _MobileSubmitWorkHeaderItemView(
                      headerTree.header.id.toString(),
                      headerTree.children,
                    ),
              );
              return commonCard(
                Column(children: oneItem),
                borderRadius: 0,
                margin: EdgeInsets.only(bottom: 16),
              );
            },
          ),
        );
      },
    );
  }
}

class _MobileSubmitWorkHeaderItemView
    extends GetView<MobileSubmitOneTaskHeaderItemController> {
  _MobileSubmitWorkHeaderItemView(
    this.rootHeaderTreeId,
    List<WorkHeaderTree> children, {
    super.key,
  }) {
    Get.put(
      MobileSubmitOneTaskHeaderItemController(children),
      tag: rootHeaderTreeId,
    );
  }

  final String rootHeaderTreeId;

  @override
  String get tag => rootHeaderTreeId;

  bool get readOnly => Get.find<SubmitTasksController>().readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          controller.children.map((e) => _buildSubmitItem(context, e)).toList(),
    );
  }

  Widget? _buildSubmitHeaders(
    BuildContext context,
    SubmitOneWorkTaskHeader node,
  ) {
    if (node.head == null) {
      return null;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(width: 1.0, color: Colors.white),
        ),
        color: Colors.yellow.withAlpha(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...node.parentHeads.map(
            (e) => Row(
              children: [
                Text(
                  e.name,
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
                const Text(
                  "/",
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                node.head!.name,
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                softWrap: true,
                // overflow: TextOverflow.ellipsis,
              ),
              if (node.head!.required)
                const Text(
                  "*",
                  style: TextStyle(
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitItem(BuildContext context, SubmitOneWorkTaskHeader node) {
    final h = _buildSubmitHeaders(context, node);
    final children = <Widget>[];
    if (h != null) {
      children.add(Expanded(flex: 1, child: h));
    }
    children.add(
      Expanded(
        flex: h != null ? 3 : 1,
        child:
            readOnly
                // todo 文本内容为对应填报的内容
                ? Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Text('iuiuuuu', softWrap: true),
                )
                : TextField(
                  controller: node.textEditingController,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  maxLines: 5,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.top,
                ),
      ),
    );
    final w = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
    return w;
  }
}

class _WebSubmitWorkHeaderItemView
    extends GetView<WebSubmitOneTaskHeaderItemController> {
  _WebSubmitWorkHeaderItemView(
    this.rootHeaderTreeId,
    List<WorkHeaderTree> children, {
    super.key,
  }) {
    Get.put(
      WebSubmitOneTaskHeaderItemController(children),
      tag: rootHeaderTreeId,
    );
  }

  final String rootHeaderTreeId;

  @override
  String get tag => rootHeaderTreeId;

  bool get readOnly => Get.find<SubmitTasksController>().readOnly;

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Column(
        children:
        controller.children
            .asMap()
            .entries
            .map(
              (e) => _buildHeaderTreeByDfs(context, e.key, 0,  e.value),
        )
            .toList(),
      ),
    );
  }

  Widget _buildHeaderTreeByDfs(
      BuildContext context,
      int idx,
      int depth,
      WorkHeaderTree node,
      ) {
    final w;
    if (node.children.isEmpty) {
      // 没有子节点时，独占一行
      return Column(
        children: [
          Row(
            children: [
              if (node.header.required)
              const Text("*"), // 是否必填
              Text(
                node.header.name,
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          TextFormField(
            textInputAction: TextInputAction.done,
            autofocus: true,
            maxLines: 4,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.top,
          ),
        ],
      );
    } else {
      w = Row(
        // spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
        node.children.asMap().entries.map((e) {
          return _buildHeaderTreeByDfs(
            context,
            e.key,
            depth + 1,
            e.value,
          );
        }).toList(),
      );
    }

    final colorIdx = (idx + depth) % loadingColors.length;
    // 把颜色做成随机透明的
    final ra = 20 + 230 * Random().nextDouble().toInt();
    return Container(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(width: 1.0, color: Colors.black),
        ),
        color: loadingColors[colorIdx].withAlpha(ra),
      ),
      child: w,
    );
  }
}