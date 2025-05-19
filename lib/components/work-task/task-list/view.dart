import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/root/controller.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import '../../common.dart';
import '../task-info/controller.dart';
import 'controller.dart';

class TaskListView extends GetView<TaskListController> {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = GetPlatform.isMobile ? 80.0 : 200.0;
    return RepaintBoundary(
      child: Obx(
        () =>
            controller.tabChanging.value
                ? Center(
                  child: SizedBox(
                    height: s,
                    width: s,
                    child: LoadingIndicator(
                      indicatorType: Indicator.lineSpinFadeLoader,
                      colors: loadingColors,
                      strokeWidth: 2,
                    ),
                  ),
                )
                : LayoutBuilder(
                  builder: (ctx, constraints) {
                    final crossCount = constraints.maxWidth >= 720 ? 3 : 1;
                    return SmartRefresher(
                      key: controller.smartRefreshKey,
                      enablePullDown: true,
                      enablePullUp: true,
                      header: WaterDropHeader(),
                      onLoading: controller.loadTaskList,
                      onRefresh: () async {
                        controller.reset();
                        await controller.loadTaskList();
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
                          return SizedBox(
                            height: 55.0,
                            child: Center(child: body),
                          );
                        },
                      ),
                      controller: RefreshController(initialRefresh: false),
                      // controller: controller.refreshController,
                      child: GridView.builder(
                        primary: true,
                        shrinkWrap: true,
                        itemCount: controller.tasks.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossCount,
                          crossAxisSpacing: crossCount == 1 ? 0 : 6,
                          mainAxisSpacing: 1,
                          childAspectRatio: crossCount == 1 ? 2 : 1.6,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return OneTaskView(
                            task: controller.tasks[index],
                            taskCategory: controller.curCat.first,
                          );
                        },
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class OneTaskView extends GetView<OneTaskController> {
  OneTaskView({super.key, required this.task, required this.taskCategory}) {
    Get.put(
      OneTaskController(deadline: task.receiveDeadline.toInt()),
      tag: '${task.id}',
    );
  }

  @override
  String? get tag => '${task.id}';

  final WorkTask task;
  final TaskListCategory taskCategory;

  @override
  Widget build(BuildContext context) {
    return commonCard(
      GestureDetector(
        onTap: () {
          TaskOperationCategory op;
          switch (taskCategory) {
            // 这些是查看任务详情的
            case TaskListCategory.allPublished:
            case TaskListCategory.myPublished:
              op = TaskOperationCategory.detailTask;
              break;
            case TaskListCategory.delegatedToMe:
              op = TaskOperationCategory.delegateTask;
              break;
            // 这些是在填报任务项的时候的
            case TaskListCategory.finished:
              op = TaskOperationCategory.submitDetailTask;
              break;
            case TaskListCategory.myParticipant:
              op = TaskOperationCategory.submitTask;
              break;
            //   我的草稿状态的任务
            case TaskListCategory.myManuscript:
              op = TaskOperationCategory.updateTask;
              break;
            //   在任务详情里的父任务信息
            case TaskListCategory.parentTaskInfo:
              return;
            // op = TaskOperationCategory.detailTask;
            // break;
            //   在任务详情里的子任务信息
            case TaskListCategory.childrenTaskInfo:
              return;
            // op = TaskOperationCategory.detailTask;
            // break;
          }
          final routeId = Get.find<RootTabController>().curRouteId;
          final args = WorkTaskPageParams(
            Int64(Get.find<TaskListController>().parentId.value),
            task,
            opCat: op,
          );
          String page;
          switch (routeId) {
            case NestedNavigatorKeyId.hallId:
              page = WorkTaskRoutes.hallTaskDetail;
              break;
            case NestedNavigatorKeyId.homeId:
              // 默认是跳到任务提交页
              switch (taskCategory) {
                case TaskListCategory.delegatedToMe:
                  page = WorkTaskRoutes.homeTaskDetail;
                  break;
                case TaskListCategory.finished:
                  //   todo: 此时要展示任务的填报内容
                  page = WorkTaskRoutes.homeTaskDetail;
                  break;
                default:
                  page = WorkTaskRoutes.homeTaskSubmit;
              }
              break;
            default:
              throw UnsupportedError("不支持的操作:$routeId");
          }
          setCurTaskInfo(args);
          Get.toNamed(page, arguments: args, id: routeId);
        },
        child: Column(
          children: [
            _buildTaskName(context),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 5, child: _buildTaskLeft(context)),
                  SizedBox(width: 2),
                  Expanded(
                    flex: 4,
                    // child: Obx(() => _buildTaskRight(context)),
                    child: _buildTaskRight(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskName(BuildContext context) {
    const r = Radius.circular(16);
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue, // 设置背景色
        borderRadius: BorderRadius.only(topLeft: r, topRight: r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 4),
                  child: Text(
                    task.name,
                    style: TextStyle(
                      fontSize: 22,
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
                ),
                Positioned(
                  top: 0, // top == bottom 时可以居中显示
                  bottom: 0,
                  right: 4,
                  child: Row(
                    children: [
                      Text(
                        twoValidNumber.format(task.credits.toDouble()),
                        style: TextStyle(fontSize: 16, color: Colors.yellow),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.diamond_outlined,
                        size: 20,
                        color: Colors.yellow,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildCountDown(BuildContext context) {
    final ignores = [
      TaskListCategory.myManuscript,
      // TaskListCategory.parentTaskInfo,
      // TaskListCategory.childrenTaskInfo,
    ];
    if (ignores.contains(taskCategory)) {
      return null;
    } else {
      final left = controller.leftDetail;
      final countdownNumberStyle = defaultNumberStyle.copyWith(fontSize: 18);
      final children = <Widget>[];
      // 截止时间的秒数
      if (left.left > left30Minutes) {
        //还超过30分钟的话
        children.addAll([
          const Text("剩余"),
          if (left.days > 0) Text('${left.days}', style: countdownNumberStyle),
          if (left.days > 0) const Text('天'),
          if (left.hours > 0 || left.days > 0)
            Text('${left.hours}', style: countdownNumberStyle),
          if (left.hours > 0 || left.hours > 0) const Text('小时'),
          Text('${left.minutes}', style: countdownNumberStyle),
          const Text('分'),
        ]);
      } else if (left.left == 0) {
        children.add(Text("报名已截止", style: countdownNumberStyle));
      } else {
        children.addAll([
          const Text("剩余"),
          Text('${left.minutes}', style: countdownNumberStyle),
          const Text(":"),
          Text('${left.seconds}', style: countdownNumberStyle),
        ]);
      }
      // return Obx(() => Row(children: children));
      return Row(children: children);
    }
  }

  Widget _buildPlanDt(BuildContext context) {
    final children = <Widget>[];
    if (task.planStartDt > 0) {
      children.add(
        Row(
          spacing: 2,
          children: [
            Icon(Icons.alarm, color: Colors.blue),
            const Text("开始日期"),
            Text(
              localDateFromSeconds(task.planStartDt.toInt()),
              style: defaultDtStyle,
            ),
          ],
        ),
      );
    }
    if (task.planEndDt > 0) {
      children.add(
        Row(
          spacing: 2,
          children: [
            Icon(Icons.alarm, color: Colors.blue),
            const Text("结束日期"),
            Text(
              localDateFromSeconds(task.planEndDt.toInt()),
              style: defaultDtStyle,
            ),
          ],
        ),
      );
    }
    return children.isNotEmpty ? Column(children: children) : Spacer();
  }

  Widget _buildTaskLeft(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4, right: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              task.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildPlanDt(context),
        ],
      ),
    );
  }

  Widget _buildTaskRight(BuildContext context) {
    final children = <Widget>[
      Row(
        spacing: 4,
        children: [
          const Text("联系人:"),
          Text(task.contactor, style: defaultNumberStyle),
        ],
      ),
      Row(
        spacing: 4,
        children: [
          const Text("联系电话:"),
          Text(task.contactPhone, style: defaultNumberStyle),
        ],
      ),
      Row(
        spacing: 4,
        children: [
          const Text("名额:"),
          Text('${task.maxReceiverCount}', style: defaultNumberStyle),
        ],
      ),
    ];

    final countDownWidget = _buildCountDown(context);
    if (countDownWidget != null) {
      children.add(countDownWidget);
    }
    final actionsWidget = _buildAction(context);
    if (actionsWidget != null) {
      children.add(actionsWidget);
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.greenAccent.shade100,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget? _buildAction(BuildContext context) {
    List<Widget> children;
    switch (taskCategory) {
      case TaskListCategory.allPublished:
        children = [
          const Text("剩余名额"),
          Text('0', style: defaultNumberStyle),
          const Text("人"),
          SizedBox(width: 4),
          InkWell(
            onTap: () {
              debugPrint("领取${task.name}成功！");
            },
            child: const Text(
              "领取",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
        break;

      case TaskListCategory.myPublished:
        children = [
          Text('3', style: defaultNumberStyle.copyWith(fontSize: 16)),
          const Text("人领取，剩余"),
          // fixme: 需要 任务剩余名额的字段
          Text('7', style: defaultNumberStyle.copyWith(fontSize: 16)),
          const Text("人"),
        ];
        break;
      case TaskListCategory.myManuscript:
        children = [
          InkWell(
            onTap: () {
              debugPrint("发布${task.name}的子任务成功！");
            },
            child: const Text(
              "创建子任务",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () {
              debugPrint("发布${task.name}成功！");
            },
            child: const Text(
              "发布",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
        break;
      case TaskListCategory.myParticipant:
      case TaskListCategory.finished:
        final routeId = Get.find<RootTabController>().curRouteId;

        children = [
          // InkWell(
          //   onTap: () {
          //     debugPrint("${task.name}任务详情！");
          //     Get.toNamed(
          //       '/task_detail',
          //       arguments: WorkTaskPageParams(Int64.ZERO, task),
          //       id: routeId,
          //     );
          //   },
          //   child: const Text(
          //     "点击查看详情",
          //     style: TextStyle(color: Colors.blue, fontSize: 16),
          //   ),
          // ),
        ];
        break;
      case TaskListCategory.delegatedToMe:
        children = [
          InkWell(
            onTap: () {
              debugPrint("拒绝${task.name}的子任务成功！");
            },
            child: Row(
              children: [
                const Icon(Icons.close),
                const Text("拒绝", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () {
              debugPrint("接受${task.name}成功！");
            },
            child: Row(
              children: [
                const Text(
                  "接受",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                const Icon(Icons.done, color: Colors.green),
              ],
            ),
          ),
        ];
        break;
      case TaskListCategory.parentTaskInfo:
      case TaskListCategory.childrenTaskInfo:
        return null;
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: children,
      ),
    );
  }
}
