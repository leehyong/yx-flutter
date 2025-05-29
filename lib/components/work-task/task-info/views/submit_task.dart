import 'dart:collection';
import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:yt_dart/cus_content.pb.dart';
import 'package:yt_dart/cus_header.pb.dart';
import 'package:yt_dart/generate_sea_orm_new.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yt_dart/generate_sea_orm_update.pb.dart';
import 'package:yx/api/content_api.dart' as content_api;
import 'package:yx/api/header_api.dart' as header_api;
import 'package:yx/root/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import '../controller.dart';
import '../data.dart';

// 填报任务项的时候使用它
class SubmitTasksView extends StatefulWidget {
  final bool readOnly;

  const SubmitTasksView({super.key, required this.readOnly});

  @override
  SubmitTasksViewState createState() => SubmitTasksViewState();
}

class SubmitTasksViewState extends State<SubmitTasksView> {
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  DataLoadingStatus isLoadingSubmitItem = DataLoadingStatus.none;

  List<CusYooHeader>? taskSubmitItems = (null as List<CusYooHeader>?);
  final _leafTaskSubmitItemsTextEditingControllers =
      HashMap<Int64, TextEditingController>();

  final _contentNameTextEditingController = TextEditingController();

  TaskInfoController get taskInfoController => Get.find<TaskInfoController>();
  CusYooWorkContent? content;

  TextEditingController getLeafTextEditingController(Int64 headerId) =>
      _leafTaskSubmitItemsTextEditingControllers[headerId]!;

  @override
  void initState() async {
    super.initState();
    await _initTaskSubmitItems();
  }

  @override
  void dispose() {
    super.dispose();
    // 重置动作
    // taskInfoController.taskSubmitAction.value = null;
  }

  Future<void> handleTaskSubmitAction(
    TaskSubmitAction action, {
    CusYooWorkContent? content,
  }) async {
    if (widget.readOnly) return;
    switch (action) {
      case TaskSubmitAction.add:
        // 新增新的内容的时候，清空所有的填报项
        _clearAllTxtInput();
        await _initTaskSubmitItems();
        break;
      case TaskSubmitAction.save:
        return _saveTaskContent();
      case TaskSubmitAction.modify:
        // 查询待修改的原始数据
        assert(content != null);
        setState(() {
          this.content = content!;
        });
        // 填充原始数据
        _buildLeafSubmitItemTextEditingController(
          content!.headers,
          oldContents: content.contentItems,
        );
      default:
        break;
    }
  }

  String get _defaultContentName {
    final task = taskInfoController.task.value!;
    final cycle = TaskSubmitCycleStrategy.values[task.submitCycle];
    final now = DateTime.now();
    switch (cycle) {
      case TaskSubmitCycleStrategy.week:
        final weekRange_ = weekRange(now);
        return '${task.name}-${defaultDateFormat.format(weekRange_.$1)}-${defaultDateFormat.format(weekRange_.$2)}';
      case TaskSubmitCycleStrategy.year:
        // 年报一般是今年填去年的
        return '${task.name}-${now.year + 1}';
      case TaskSubmitCycleStrategy.month:
        // 月报一般是本月填上月的
        return '${task.name}-${(now.month + 1) % 12}';
      case TaskSubmitCycleStrategy.halfMonth:
        // 一般是下半月填上半月的半月报
        String n, m;
        if (now.day > 15) {
          n = '上半月';
          m = now.month.toString().padLeft(2, '0');
        } else {
          n = '下半月';
          m = ((now.month - 1) % 12).toString().padLeft(2, '0');
        }
        return '${task.name}-$m-$n';
      case TaskSubmitCycleStrategy.day:
        return '${task.name}-${defaultDateFormat.format(now)}';
      case TaskSubmitCycleStrategy.halfDay:
        final n = now.hour <= 13 ? '上午' : '下午';
        return '${task.name}-${defaultDateFormat.format(now)}-$n';
      case TaskSubmitCycleStrategy.hour:
        return '${task.name}-${defaultDateTimeFormat3.format(now)}';
      case TaskSubmitCycleStrategy.halfHour:
        final n = now.minute + 10 <= 40 ? '上' : '下';
        return '${task.name}-${defaultDateTimeFormat3.format(now)}-$n';
    }
  }

  void _clearAllTxtInput() {
    _contentNameTextEditingController.text = _defaultContentName;
    for (var ctrl in _leafTaskSubmitItemsTextEditingControllers.values) {
      ctrl.clear();
    }
  }

  Future<void> _initTaskSubmitItems() async {
    if (isLoadingSubmitItem == DataLoadingStatus.loaded) {
      // 避免重复加载
      return;
    }
    setState(() {
      isLoadingSubmitItem = DataLoadingStatus.loading;
    });
    header_api.queryWorkHeaders(taskInfoController.taskId.value).then((
      headers,
    ) {
      setState(() {
        taskSubmitItems = headers ?? [];
        isLoadingSubmitItem = DataLoadingStatus.loaded;
      });
      _buildLeafSubmitItemTextEditingController(headers ?? []);
    });
  }

  void _buildLeafSubmitItemTextEditingController(
    List<CusYooHeader> headers, {
    Map<Int64, WorkContentItem>? oldContents,
  }) {
    if (widget.readOnly) {
      return;
    }
    for (var entry in headers) {
      if (entry.children.isEmpty) {
        setState(() {
          _leafTaskSubmitItemsTextEditingControllers[entry
              .node
              //  给 TextEditingController 填充初始值
              .id] = TextEditingController(
            text: oldContents?[entry.node.id]?.content,
          );
        });
      } else {
        _buildLeafSubmitItemTextEditingController(entry.children);
      }
    }
  }

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
    if (isLoadingSubmitItem != DataLoadingStatus.loaded) {
      return Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: LoadingIndicator(
            indicatorType: Indicator.ballScaleRippleMultiple,

            /// Required, The loading type of the widget
            colors: loadingColors,
            strokeWidth: 3,
          ),
        ),
      );
    }
    final cnt = taskSubmitItems?.length ?? 0;

    final children = <Widget>[];
    if (cnt == 0) {
      children.add(emptyWidget(context));
    } else {
      children.addAll([
        TextFormField(
          controller: _contentNameTextEditingController,
          validator: (v) {
            if (v!.isEmpty) {
              return '名字不能为空';
            }
            saveModification();
            return null;
          },
          decoration: InputDecoration(
            labelText: '名字',
            enabled: !widget.readOnly,
            suffixIcon: IconButton(
              onPressed: () {
                _contentNameTextEditingController.clear();
              },
              icon: Icon(Icons.close, color: Colors.red),
            ),
          ),
        ),
        _buildTaskSubmitItems(context, cnt),
      ]);
    }

    return Column(children: children);
  }

  Widget _buildTaskSubmitItems(BuildContext context, int cnt) =>
      ListView.builder(
        cacheExtent: 100,
        controller: scrollController,
        itemCount: cnt,
        itemBuilder: (ctx, idx) {
          final headerTree = taskSubmitItems![idx];
          final oneItem = [_buildRootHeaderNameTable(context, headerTree)];
          oneItem.add(
            isBigScreen(context)
                ? _WebSubmitWorkHeaderItemView(
                  headerTree.node,
                  headerTree.children,
                  widget.readOnly,
                )
                : _MobileSubmitWorkHeaderItemView(
                  headerTree.node,
                  headerTree.children,
                  widget.readOnly,
                ),
          );
          return commonCard(
            Column(children: oneItem),
            borderRadius: 0,
            margin: EdgeInsets.only(bottom: 16),
          );
        },
      );

  Future<void> _saveTaskContent() async {
    // 调用存储内容相关接口
    if (content == null) {
      // 新增
      content_api.newWorkTaskContent(
        NewCusYooWorkContentReq(
          content: NewWorkContent(
            name: _contentNameTextEditingController.text,
            taskId: taskInfoController.task.value!.id,
          ),
          contentItems:
              _leafTaskSubmitItemsTextEditingControllers.entries
                  .map(
                    (entry) => NewWorkContentItem(
                      headerId: entry.key,
                      content: entry.value.text,
                    ),
                  )
                  .toList(),
        ),
      );
    } else {
      // 修改
      content_api.updateWorkTaskContent(
        content!.content.id,
        UpdateCusYooWorkContentReq(
          content: UpdateWorkContent(
            name: _contentNameTextEditingController.text,
            taskId: taskInfoController.task.value!.id,
          ),
          contentItems:
              _leafTaskSubmitItemsTextEditingControllers.entries
                  .map(
                    (entry) => UpdateWorkContentItem(
                      contentId: content!.content.id,
                      headerId: entry.key,
                      content: entry.value.text,
                    ),
                  )
                  .toList(),
        ),
      );
    }
  }

  void saveModification() {
    Get.find<RootTabController>().addModification(
      _saveTaskContent,
      ModifyWarningCategory.submitContent,
    );
  }
}

abstract class _AbstractSubmitWorkHeaderItemView<T extends GetxController>
    extends GetView<T> {
  final WorkHeader rootHeader;
  final bool readOnly;

  SubmitTasksViewState get submitTasksViewState =>
      Get.find<TaskInfoController>().submitTasksViewState!;

  const _AbstractSubmitWorkHeaderItemView(
    this.rootHeader,
    this.readOnly, {
    super.key,
  });

  @override
  String get tag => rootHeader.id.toString();
}

class _MobileSubmitWorkHeaderItemView
    extends
        _AbstractSubmitWorkHeaderItemView<
          MobileSubmitOneTaskHeaderItemController
        > {
  _MobileSubmitWorkHeaderItemView(
    super.rootHeader,
    List<CusYooHeader> children,
    super.readOnly, {
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
                  controller: submitTasksViewState.getLeafTextEditingController(
                    node.head?.id ?? rootHeader.id,
                  ),
                  textInputAction: TextInputAction.done,
                  maxLines: 5,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (v) {
                    if (rootHeader.required && v!.trim().isEmpty) {
                      return "该项不能空";
                    }
                    submitTasksViewState.saveModification();
                    // 保存变更，以便提示
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
    List<CusYooHeader> children,
    super.readOnly, {
    super.key,
  }) {
    Get.put(WebSubmitOneTaskHeaderItemController(children), tag: tag);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.children.isEmpty) {
      return submitTasksViewState.widget.readOnly
          ? Text("112233")
          : TextFormField(
            controller: submitTasksViewState.getLeafTextEditingController(
              rootHeader.id,
            ),
            textInputAction: TextInputAction.done,
            autofocus: true,
            maxLines: 4,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.top,
            validator: (v) {
              if (rootHeader.required && v!.trim().isEmpty) {
                return "该项不能空";
              }
              // 保存变更，以便提示
              submitTasksViewState.saveModification();
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
          submitTasksViewState.widget.readOnly
              ? Text("112233")
              : TextFormField(
                controller: submitTasksViewState.getLeafTextEditingController(
                  node.node.id,
                ),
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
                onChanged: (_) {
                  // 保存变更，以便提示
                  submitTasksViewState.saveModification();
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
