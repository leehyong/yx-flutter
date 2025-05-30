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

  SubmitTasksView({required this.readOnly})
    : super(key: Get.find<TaskInfoController>().submitTasksViewStateKey);

  @override
  SubmitTasksViewState createState() => SubmitTasksViewState();
}

class SubmitTasksViewState extends State<SubmitTasksView> {
  bool get canWrite {
    switch (_action) {
      case TaskSubmitAction.add:
        return true;
      case TaskSubmitAction.modifyHistory:
        return true;
      case TaskSubmitAction.detailHistory:
        return false;
      default:
        return widget.readOnly;
    }
  }

  TaskSubmitAction _action = TaskSubmitAction.add;

  bool _isSaving = false;
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  DataLoadingStatus isLoadingSubmitItem = DataLoadingStatus.none;

  List<CusYooHeader>? taskSubmitItems = (null as List<CusYooHeader>?);
  final _leafTaskSubmitItemsTextEditingControllers =
      HashMap<Int64, TextEditingController>();

  final _contentNameTextEditingController = TextEditingController();

  TaskInfoController get taskInfoController => Get.find<TaskInfoController>();
  CusYooWorkContent? _content;

  TextEditingController getLeafTextEditingController(Int64 headerId) =>
      _leafTaskSubmitItemsTextEditingControllers[headerId]!;

  @override
  void initState() {
    super.initState();
    _contentNameTextEditingController.text = _defaultContentName;
    _initTaskSubmitItems();
  }

  Future<void> handleTaskSubmitAction(
    TaskSubmitAction action, {
    CusYooWorkContent? content,
  }) async {
    switch (action) {
      case TaskSubmitAction.add:
        _action = action;
        _content = null;
        // 新增新的内容的时候，清空所有的填报项
        _clearAllTxtInput();
        setState(() {}); //通知有更新
        await _initTaskSubmitItems();
        break;
      case TaskSubmitAction.save:
        await _saveTaskContent();
        _action = action;
        break;
      case TaskSubmitAction.modifyHistory:
      case TaskSubmitAction.detailHistory:
        assert(content != null);
        _action = action;
        _content = content!;
        // 填充原始数据
        _buildLeafSubmitItemTextEditingController(
          content!.headers,
          oldContents: content.contentItems,
        );
        setState(() {}); //通知有更新
      default:
        setState(() {
          _action = action;
        });
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
      taskSubmitItems = headers ?? [];
      isLoadingSubmitItem = DataLoadingStatus.loaded;
      _buildLeafSubmitItemTextEditingController(headers ?? []);
      setState(() {});
    });
  }

  void _buildLeafSubmitItemTextEditingController(
    List<CusYooHeader> headers, {
    Map<Int64, WorkContentItem>? oldContents,
  }) {
    for (var entry in headers) {
      if (entry.children.isEmpty) {
        _leafTaskSubmitItemsTextEditingControllers[entry
            .node
            //  给 TextEditingController 填充初始值
            .id] = TextEditingController(
          text: oldContents?[entry.node.id]?.content,
        );
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

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: LoadingIndicator(
          indicatorType: Indicator.ballScaleRippleMultiple,

          /// Required, The loading type of the widget
          colors: loadingColors,
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingSubmitItem != DataLoadingStatus.loaded) {
      return _buildLoadingIndicator(context);
    }
    final cnt = taskSubmitItems?.length ?? 0;

    final children = <Widget>[];
    if (cnt == 0) {
      children.add(emptyWidget(context));
    } else {
      children.addAll([
        Row(
          children: [
            Expanded(
              child: TextFormField(
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
                  icon: Icon(Icons.text_snippet),
                  enabled: canWrite,
                  suffixIcon: IconButton(
                    onPressed: () {
                      _contentNameTextEditingController.clear();
                    },
                    icon: Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ),
            ),
            if (_action == TaskSubmitAction.detailHistory)
              IconButton(
                onPressed: () {
                  handleTaskSubmitAction(TaskSubmitAction.modifyHistoryContent);
                },
                icon: Tooltip(message: '修改', child: Icon(Icons.edit)),
              ),
            if (_action == TaskSubmitAction.modifyHistoryContent)
              IconButton(
                onPressed: () {
                  setState(() {
                    _action = TaskSubmitAction.detailHistory;
                  });
                },
                icon: Tooltip(
                  message: '详情',
                  child: Icon(Icons.info_outline_rounded),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildTaskSubmitItems(context, cnt)),
      ]);
    }
    final target = Column(children: children);

    return _isSaving
        ? Stack(
          children: [
            target,
            Positioned.fill(child: Container(
              color: Colors.black.withAlpha(80),
              child: _buildLoadingIndicator(context),
            )),
          ],
        )
        : target;
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

  Future<void> _saveTaskContent() async {
    // 不能写时，禁止提交修改
    if (!canWrite) return;
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });
    // 调用存储内容相关接口
    if (_content == null) {
      // 新增
      content_api.newWorkTaskContent(
        taskInfoController.task.value!.id,
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
      ).then((_){
        // 新增成功后，清空所有信息
        _clearAllTxtInput();
      });
    } else {
      // 修改
      content_api.updateWorkTaskContent(
        _content!.content.id,
        UpdateCusYooWorkContentReq(
          content: UpdateWorkContent(
            name: _contentNameTextEditingController.text,
            taskId: taskInfoController.task.value!.id,
          ),
          contentItems:
              _leafTaskSubmitItemsTextEditingControllers.entries
                  .map(
                    (entry) => UpdateWorkContentItem(
                      contentId: _content!.content.id,
                      headerId: entry.key,
                      content: entry.value.text,
                    ),
                  )
                  .toList(),
        ),
      );
    }
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _isSaving = false;
    });
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

  SubmitTasksViewState get submitTasksViewState =>
      Get.find<TaskInfoController>().submitTasksViewState!;

  const _AbstractSubmitWorkHeaderItemView(this.rootHeader, {super.key});

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
    final ctrl = submitTasksViewState.getLeafTextEditingController(
      node.head?.id ?? rootHeader.id,
    );
    children.add(
      Expanded(
        flex: h != null ? 3 : 1,
        child:
            submitTasksViewState.canWrite
                // 文本内容为对应填报的内容
                ? TextFormField(
                  controller: ctrl,
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
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text(ctrl.text)],
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
      final ctrl = submitTasksViewState.getLeafTextEditingController(
        rootHeader.id,
      );
      return submitTasksViewState.canWrite
          ? TextFormField(
            controller: ctrl,
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
          )
          : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text(ctrl.text)],
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
      final ctrl = submitTasksViewState.getLeafTextEditingController(
        rootHeader.id,
      );
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
          submitTasksViewState.canWrite
              ? TextFormField(
                controller: ctrl,
                textInputAction: TextInputAction.done,
                autofocus: true,
                maxLines: 4,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.top,
                validator: (v) {
                  if (node.node.required && v!.trim().isEmpty) {
                    return "该项不能空";
                  }
                  // 保存变更，以便提示
                  submitTasksViewState.saveModification();
                  return null;
                },
              )
              : IntrinsicWidth(child: Text(ctrl.text)),
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
