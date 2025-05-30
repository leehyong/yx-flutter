import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:yt_dart/cus_content.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/content_api.dart' as content_api;
import 'package:yx/components/work-task/task-info/controller.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

class TaskContentHistoryView extends StatefulWidget {
  const TaskContentHistoryView({super.key, required this.task});

  final WorkTask task;

  @override
  TaskContentHistoryViewState createState() => TaskContentHistoryViewState();
}

class TaskContentHistoryViewState extends State<TaskContentHistoryView> {
  Widget _buildRefresher(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      onLoading: _queryTaskHistory,
      onRefresh: () async {
        setState(() {
          _page = 0;
        });
        _queryTaskHistory();
      },
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("上拉加载更多");
          } else if (mode == LoadStatus.loading) {
            body = LoadingIndicator(
              indicatorType: Indicator.audioEqualizer,

              /// Required, The loading type of the widget
              colors: loadingColors,
              strokeWidth: 2,
            );
          } else if (mode == LoadStatus.failed) {
            body = Text("加载失败，请重试");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("释放加载更多");
          } else {
            return SizedBox.shrink();
          }
          return SizedBox(height: 55.0, child: Center(child: body));
        },
      ),
      controller: _refreshController,
      // controller: controller._refreshController,
      child: _buildTaskHistory(context),
    );
  }

  Widget _buildTaskHistory(BuildContext context) {
    return ListView.builder(
      cacheExtent: 100,
      controller: ScrollController(initialScrollOffset: 0),
      itemCount: contents!.length,
      itemBuilder: (context, index) {
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
                        TaskSubmitAction.detail,
                        contents![index],
                        context,
                      );
                    },
                    icon: Text(
                      '详情',
                      style: TextStyle(
                        color: Colors.blue.withAlpha(120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setTaskCurrentHistory(
                        TaskSubmitAction.modify,
                        contents![index],
                        context,
                      );
                    },
                    icon: Text(
                      '修改',
                      style: TextStyle(
                        color: Colors.blue,
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
    Get.find<TaskInfoController>().submitTasksViewState?.handleTaskSubmitAction(
      action,
      content: content,
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: 200,
        height: 200,
        child: LoadingIndicator(
          indicatorType: Indicator.lineScale,
          colors: loadingColors,
          strokeWidth: 2,
        ),
      );
    } else if (contents == null || contents!.isEmpty) {
      return emptyWidget(context);
    } else {
      return _buildRefresher(context);
    }
  }

  bool _loading = false;
  int _page = 0;
  List<CusYooWorkContent>? contents;
  final _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _queryTaskHistory();
  }

  Future<void> _queryTaskHistory() async {
    setState(() {
      _page++;
      _loading = true;
    });
    content_api.queryWorkTaskContents(widget.task.id, _page, 10).then((v) {
      setState(() {
        _loading = false;
        contents = v?.data;
      });
      if (v!.page == v.totalPages) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    });
  }
}
