import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:yt_dart/cus_header.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import '../controller.dart';
import '../data.dart';

// 填报任务项的时候使用它
// todo： title 展示任务名， 并且可以查看任务的信息
class SubmitTasksView extends GetView<SubmitTasksController> {
  const SubmitTasksView({super.key});

  Widget _buildRootHeaderNameTable(BuildContext context, CusYooHeader root) {
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
                message: root.node.name,
                child: Row(
                  spacing: 4,
                  children: [
                    Text(
                      root.node.name,
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
                    buildTaskOpenRangeAndContentType(root.node, isRow: true),
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
    return FutureBuilder(
      future: controller.initTaskSubmitItems(),
      builder: (context, snapshot) {
        return Obx(() {
          if (controller.isLoadingSubmitItem.value !=
              DataLoadingStatus.loaded) {
            return Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballScaleRipple,

                  /// Required, The loading type of the widget
                  colors: loadingColors,
                  strokeWidth: 3,
                ),
              ),
            );
          }
          final cnt = controller.taskSubmitItems.value!.length;

          return ListView.builder(
            cacheExtent: 100,
            controller: controller.scrollController,
            itemCount: cnt,
            itemBuilder: (ctx, idx) {
              final headerTree = controller.taskSubmitItems.value![idx];
              final oneItem = [_buildRootHeaderNameTable(context, headerTree)];
              oneItem.add(
                isBigScreen(context)
                    ? _WebSubmitWorkHeaderItemView(
                      headerTree.node,
                      headerTree.children,
                    )
                    : _MobileSubmitWorkHeaderItemView(
                      headerTree.node,
                      headerTree.children,
                    ),
              );
              return commonCard(
                Column(children: oneItem),
                borderRadius: 0,
                margin: EdgeInsets.only(bottom: 16),
              );
            },
          );
        });
      },
    );
  }
}

abstract class _AbstractSubmitWorkHeaderItemView<T extends GetxController>
    extends GetView<T> {
  final WorkHeader rootHeader;

  const _AbstractSubmitWorkHeaderItemView(this.rootHeader, {super.key});

  @override
  String get tag => rootHeader.id.toString();

  bool get readOnly => Get.find<SubmitTasksController>().readOnly;
}

class _MobileSubmitWorkHeaderItemView
    extends
        _AbstractSubmitWorkHeaderItemView<
          MobileSubmitOneTaskHeaderItemController
        > {
  _MobileSubmitWorkHeaderItemView(
    super.rootHeader,
    List<CusYooHeader> children, {
    super.key,
  }) {
    Get.put(MobileSubmitOneTaskHeaderItemController(children), tag: tag);
  }

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
                : TextFormField(
                  controller: controller.submitTasksController
                      .getLeafTextEditingController(
                        node.head?.id ?? rootHeader.id,
                      ),
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  maxLines: 5,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (v) {
                    if (rootHeader.required && v!.trim().isEmpty) {
                      return "该项不能空";
                    }
                    return null;
                  },
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
    extends
        _AbstractSubmitWorkHeaderItemView<
          WebSubmitOneTaskHeaderItemController
        > {
  _WebSubmitWorkHeaderItemView(
    super.rootHeaderTreeId,
    List<CusYooHeader> children, {
    super.key,
  }) {
    Get.put(WebSubmitOneTaskHeaderItemController(children), tag: tag);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.children.isEmpty) {
      return controller.submitTasksController.readOnly
          ? Text("112233")
          : TextFormField(
            controller: controller.submitTasksController
                .getLeafTextEditingController(rootHeader.id),
            textInputAction: TextInputAction.done,
            autofocus: true,
            maxLines: 4,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.top,
            validator: (v) {
              if (rootHeader.required && v!.trim().isEmpty) {
                return "该项不能空";
              }
              return null;
            },
          );
    }
    return Column(
      children:
          controller.children
              .asMap()
              .entries
              .map(
                (e) => _buildHeaderTreeByDfs(context, e.key, 0, e.value, null),
              )
              .toList(),
    );
  }

  Widget _buildHeaderTreeByDfs(
    BuildContext context,
    int idx,
    int depth,
    CusYooHeader node,
    Color? parentColor,
  ) {
    if (node.children.isEmpty) {
      final headerColor = node.node.required ? Colors.red : Colors.black;
      // 没有子节点时，独占一行
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: headerColor,
                  width: 1, // 下划线粗细
                ),
              ),
            ),
            child: Row(
              spacing: 4,
              children: [
                Icon(Icons.swipe_right_alt, color: headerColor),
                Text(
                  node.node.name,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: headerColor,
                  ),
                ),
                buildTaskOpenRangeAndContentType(node.node, isRow: true),
              ],
            ),
          ),
          controller.submitTasksController.readOnly
              ? Text("112233")
              : TextFormField(
                controller: controller.submitTasksController
                    .getLeafTextEditingController(node.node.id),
                textInputAction: TextInputAction.done,
                autofocus: true,
                maxLines: 4,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                validator: (v) {
                  if (node.node.required && v!.trim().isEmpty) {
                    return "该项不能空";
                  }
                  return null;
                },
              ),
        ],
      );
    } else {
      if (parentColor == null) {
        parentColor = Colors.blue;
      } else {
        // 把颜色做成随机透明的
        int alpha = min(255, (idx + depth + 1) * 10);
        if (alpha == 255) {
          alpha = 20 + 230 * Random().nextDouble().toInt();
        }
        parentColor = parentColor.withAlpha(alpha);
      }

      return IntrinsicHeight(
        child: Row(
          // spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // margin: EdgeInsets.symmetric(vertical: depth == 0 ? 4 : 0),
              decoration: BoxDecoration(color: parentColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(node.node.name),
                  buildTaskOpenRangeAndContentType(node.node, isRow: true),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  ...node.children.asMap().entries.map((e) {
                    return _buildHeaderTreeByDfs(
                      context,
                      e.key,
                      depth + 1,
                      e.value,
                      parentColor,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
