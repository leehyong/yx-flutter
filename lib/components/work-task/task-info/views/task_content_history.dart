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
          page = 0;
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
            return emptyWidget(context);
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
        return Column(
          children: [
            Text(contents![index].content.name),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    localFromSeconds(
                      contents![index].content.createdAt.toInt(),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setTaskCurrentHistory(
                      TaskSubmitAction.detail,
                      contents![index],
                    );
                  },
                  child: Text('详情'),
                ),
                InkWell(
                  onTap: () {
                    setTaskCurrentHistory(
                      TaskSubmitAction.modify,
                      contents![index],
                    );
                  },
                  child: Text('修改'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void setTaskCurrentHistory(
    TaskSubmitAction action,
    CusYooWorkContent content,
  ) {
    Get.find<TaskInfoController>().submitTasksViewState?.handleTaskSubmitAction(
      TaskSubmitAction.modify,
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return LoadingIndicator(
        indicatorType: Indicator.lineScale,
        colors: loadingColors,
        strokeWidth: 2,
      );
    } else if (contents == null || contents!.isEmpty) {
      return emptyWidget(context);
    }
    return _buildRefresher(context);
  }

  bool _loading = false;
  int page = 0;
  int limit = 10;
  List<CusYooWorkContent>? contents;
  final _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _queryTaskHistory();
  }

  Future<void> _queryTaskHistory() async {
    setState(() {
      page++;
      _loading = true;
    });
    content_api.queryWorkTaskContents(widget.task.id, page, limit).then((v) {
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
