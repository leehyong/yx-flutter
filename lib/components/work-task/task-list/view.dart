import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:yt_dart/cus_task.pb.dart';
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
    return Obx(
      () =>
          controller.curLayer.tabChanging.value
              ? _buildLoading(context)
              : LayoutBuilder(
                builder: (ctx, constraints) {
                  final crossCount = constraints.maxWidth >= 720 ? 3 : 1;
                  return _buildRefresher(context, crossCount);
                },
              ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final s = GetPlatform.isMobile ? 80.0 : 200.0;
    return Center(
      child: SizedBox(
        height: s,
        width: s,
        child: LoadingIndicator(
          indicatorType: Indicator.lineSpinFadeLoader,
          colors: loadingColors,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildRefresher(BuildContext context, int crossCount) {
    return SmartRefresher(
      key: controller.curLayer.smartRefreshKey,
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      onLoading: controller.curLayer.loadTaskList,
      onRefresh: () async {
        controller.curLayer.reset();
        await controller.curLayer.loadTaskList();
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
      controller: RefreshController(initialRefresh: false),
      // controller: controller.refreshController,
      child: _buildTaskList(context, crossCount),
    );
  }

  Widget _buildTaskList(BuildContext context, int crossCount) {
    return Obx(
      () =>
          controller.curLayer.tasks.isEmpty
              ? Column(children: [emptyWidget(context)])
              : GridView.builder(
                primary: true,
                shrinkWrap: true,
                itemCount: controller.curLayer.tasks.value.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: crossCount == 1 ? 0 : 6,
                  mainAxisSpacing: 1,
                  childAspectRatio: crossCount == 1 ? 2 : 1.6,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final userTaskHis = controller.curLayer.tasks.value[index];
                  return OneTaskCardView(
                    key: ValueKey(userTaskHis.task.id),
                    userTaskHis: userTaskHis,
                    taskCategory: controller.curLayer.curCat.value.first,
                  );
                },
              ),
    );
  }
}

class OneTaskCardView extends GetView<OneTaskCardController> {
  OneTaskCardView({
    super.key,
    required this.userTaskHis,
    required this.taskCategory,
  }) {
    Get.put(
      OneTaskCardController(
        deadline: task.receiveDeadline.toInt(),
        action: taskOriginAction,
      ),
      tag: '${task.id}',
    );
  }

  @override
  String? get tag => '${task.id}';

  WorkTask get task => userTaskHis.task;
  final UserTaskHistory userTaskHis;
  final TaskListCategory taskCategory;

  // 是否已接受，已接受了的任务不会再显示 接受拒绝按钮
  int get taskOriginAction {
    if (userTaskHis.history.isEmpty) {
      return -1;
    }
    return userTaskHis.history.last.action;
  }

  String get left =>
      task.receiveStrategy == ReceiveTaskStrategy.freeSelection.index
          ? '${task.maxReceiverCount - userTaskHis.total}'
          : '无限制';

  double get taskCredits {
    final creditsStrategy = task.creditsStrategy;
    // 如果任务积分
    if (controller.accepted) {
      // 接受了的任务，返回接受时的积分大小
      if (userTaskHis.history.isNotEmpty) {
        return creditsStrategy == TaskCreditStrategy.latest.index
            ? userTaskHis.history.last.credits
            : userTaskHis.history.first.credits;
      }
    }
    // fixme： 没有接受的直接返回任务的当前积分 ， 而不管任务拒绝之后，某个任务的积分有更新，使其与当前任务的积分不一致
    return task.credits;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final card = _buildCard(context);
      if (controller.isDeleting.value) {
        return maskingOperation(context, card);
      }
      switch (taskCategory) {
        case TaskListCategory.allPublished:
        case TaskListCategory.delegatedToMe:
          final desc = controller.userTaskActionDesc;
          return desc.isEmpty
              ? card
              : _buildTaskActionIndicator(context, card, desc);
        default:
          return card;
      }
    });
  }

  Widget _buildTaskActionIndicator(
    BuildContext context,
    Widget target,
    String desc,
  ) {
    return Stack(
      children: [
        target,
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 4.0, color: Colors.red),
              ),
              child: Text(
                desc,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return commonCard(
      InkWell(
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
            Get.find<TaskListController>().curLayer.parentId.value,
            task,
            taskCategory,
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
                        twoValidNumber.format(taskCredits),
                        style: TextStyle(fontSize: 16, color: Colors.yellow),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.diamond_outlined,
                        size: 20,
                        color: Colors.yellow,
                      ),
                      if (taskCategory == TaskListCategory.myManuscript) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () async {
                            await controller.deleteTask(task, context);
                          },
                          child: Icon(Icons.close, color: Colors.red),
                        ),
                      ],
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
          if (left.days > 0)
            Text(
              '${left.days > 9 ? "10+" : left.days}',
              style: countdownNumberStyle,
            ),
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
        final tips =
            task.receiveStrategy == ReceiveTaskStrategy.freeSelection.index
                ? [
                  const Text("剩余名额"),
                  Text(left, style: defaultNumberStyle),
                  const Text("人"),
                ]
                : [const Text("剩余名额"), Text('无限制', style: defaultNumberStyle)];
        children = [
          ...tips,
          const SizedBox(width: 2),
          if (!controller.accepted &&
              task.receiveStrategy == ReceiveTaskStrategy.freeSelection.index)
            InkWell(
              onTap: () {
                debugPrint("领取${task.name}成功！");
                controller.handleTaskAction(task.id, UserTaskAction.claim);
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
          Text(
            '${userTaskHis.total}',
            style: defaultNumberStyle.copyWith(fontSize: 16),
          ),
          const Text("人领取，剩余"),
          Text(left, style: defaultNumberStyle.copyWith(fontSize: 16)),
          const Text("人"),
        ];
        break;
      case TaskListCategory.myManuscript:
        children = [
          Tooltip(
            message: "创建子任务",
            child: InkWell(
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 2),
                  Text(
                    "子任务",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
              onTap: () {
                // todo: 跳转到子任务发布界面
              },
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
        children = [];
        break;
      case TaskListCategory.delegatedToMe:
        if (task.receiveStrategy == ReceiveTaskStrategy.twoWaySelection.index) {
          children = [
            InkWell(
              onTap: () {
                debugPrint("拒绝${task.name}的子任务成功！");
                controller.handleTaskAction(task.id, UserTaskAction.refuse);
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
                controller.handleTaskAction(task.id, UserTaskAction.accept);
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
        } else {
          children = [];
        }
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
