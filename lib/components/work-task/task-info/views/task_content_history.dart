import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_dart/cus_content.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/content_api.dart' as content_api;
import 'package:yx/components/common.dart';
import 'package:yx/root/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

class TaskContentHistoryView extends StatefulWidget {
  const TaskContentHistoryView({super.key, required this.task});

  final WorkTask task;

  @override
  TaskContentHistoryViewState createState() => TaskContentHistoryViewState();
}

class TaskContentHistoryViewState extends State<TaskContentHistoryView>
    with CommonEasyRefresherMixin {

  @override
  TaskContentHistoryViewState get widgetState => this;

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Future<void> loadData() async {
    _queryTaskHistory().then((more) {
      refreshController.finishLoad(
        more ? IndicatorResult.success : IndicatorResult.noMore,
      );
    });
  }

  @override
  Future<void> refreshData() async {
    setState(() {
      _page = 0;
    });
    _queryTaskHistory().then((more) {
      refreshController.finishRefresh(
        more ? IndicatorResult.success : IndicatorResult.noMore,
      );
    });
  }

  @override
  Widget buildRefresherChildDataBox(BuildContext context) {
    return ListView.builder(
      cacheExtent: 100,
      controller: scrollController,
      itemCount: contents!.length + 1,
      itemBuilder: (context, index) {
        if(index == contents!.length){
          return buildLoadMoreTipAction(context, _hasMore, loadData);
        }
        final thisContent = contents![index];
        final colorIdx =
            Random(thisContent.content.id.toInt()).nextInt(10000) %
            loadingColors.length;
        // 把颜色做成随机透明的
        // 区分编辑和只读
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: loadingColors[colorIdx].withAlpha(50),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            // spacing: 8,
            children: [
              Tooltip(
                message: thisContent.content.name,
                child: Text(
                  thisContent.content.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setTaskCurrentHistory(
                        TaskSubmitAction.detailHistory,
                        contents![index],
                        context,
                      );
                    },
                    icon: Text(
                      '详情',
                      style: TextStyle(
                        color: Colors.purple.withAlpha(220),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setTaskCurrentHistory(
                        TaskSubmitAction.modifyHistory,
                        contents![index],
                        context,
                      );
                    },
                    icon: Text(
                      '修改',
                      style: TextStyle(
                        color: Colors.blue.withAlpha(220),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),

                  const Text('创建时间:', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    defaultDateTimeFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                        contents![index].content.createdAt.toInt(),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.purple.withAlpha(120),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void setTaskCurrentHistory(
    TaskSubmitAction action,
    CusYooWorkContent content,
    BuildContext context,
  ) {
    Get.find<RootTabController>()
        .taskInfoViewState
        .currentState!
        .submitTasksViewState
        ?.handleTaskSubmitAction(action, content: content);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return buildLoading(context);
    } else if (contents == null || contents!.isEmpty) {
      return emptyWidget(context);
    } else {
      return buildEasyRefresher(context);
    }
  }

  bool _loading = false;
  int _page = 0;
  bool _hasMore = true;
  List<CusYooWorkContent>? contents;

  @override
  void initState() {
    super.initState();
    _queryTaskHistory();
  }

  Future<bool> _queryTaskHistory() async {
    setState(() {
      _page++;
      _loading = true;
    });
    return content_api.queryWorkTaskContents(widget.task.id, _page, 10).then((
      v,
    ) {
      setState(() {
        _loading = false;
        contents = v?.data;
        _hasMore = v!.page < v.totalPages;
      });
      return v!.page == v.totalPages;
    });
  }
}
