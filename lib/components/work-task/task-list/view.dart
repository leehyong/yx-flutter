import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:yt_dart/cus_task.pb.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/api/task_api.dart' as task_api;
import 'package:yx/components/common.dart';
import 'package:yx/root/controller.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/services/auth_service.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';
import 'package:yx/utils/toast.dart';

import 'controller.dart';

class TaskListView extends StatefulWidget {
  TaskListView({this.cats, this.showSegBtns = true})
    : super(key: Get.find<RootTabController>().taskListViewState);

  final List<TaskListCategory>? cats;
  final bool showSegBtns;

  @override
  TaskListViewState createState() => TaskListViewState();
}

class TaskListViewState extends State<TaskListView> {
  final _layers = <TaskListLayer>[TaskListLayer()];

  bool isSecondLayer(TaskListCategory cat) => {
    TaskListCategory.parentTaskInfo,
    TaskListCategory.childrenTaskInfo,
  }.contains(cat);

  // 不是第一层就是第二层
  bool isFirstLayer(TaskListCategory cat) => !isSecondLayer(cat);

  int layerIdx(TaskListCategory cat) => isFirstLayer(cat) ? 0 : 1;

  TaskListLayer get curLayer => _layers.last;

  bool get inSecondLayer => _layers.length == 2;

  Future<void> reloadCurTaskListData([TaskListCategory? cat]) async {
    setState(() {
      curLayer.tabChanging = true;
      curLayer.reset();
      curLayer.curCat = {
        cat ?? widget.cats?.first ?? TaskListCategory.allPublished,
      };
    });
    curLayer
        .loadTaskList()
        .then((v) {
          return Future.delayed(Duration(milliseconds: 100));
        })
        .whenComplete(() {
          curLayer.tabChanging = false;
          setState(() {});
        });
  }

  void setSecondLayerTaskListInfo({
    Int64 parentId = Int64.ZERO,
    TaskListCategory defaultCat = TaskListCategory.allPublished,
  }) {
    if (!isSecondLayer(defaultCat)) {
      return;
    }
    if (_layers.length == 1) {
      _layers.add(TaskListLayer());
    }
    curLayer.curCat.clear();
    curLayer.curCat.add(defaultCat);
    curLayer.parentId = parentId;
    setState(() {});
  }

  void removeSecondLayer() {
    if (inSecondLayer) {
      _layers.removeLast();
    }
  }

  Future<void> deleteOneTask(Int64 id) async {
    final err = await task_api.deleteWorkTask(id);
    if (err == null) {
      // 剔除对应id的任务，保留其余的任务
      curLayer.tasks = curLayer.tasks.where((e) => e.task.id != id).toList();
    }
  }

  Widget _buildSegmentButtons(BuildContext context) {
    return SizedBox(
      width: 400,
      child: SegmentedButton(
        emptySelectionAllowed: true,
        expandedInsets: EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        segments:
            widget.cats!
                .map(
                  (e) => ButtonSegment(
                    value: e,
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(e.i18name, softWrap: false, maxLines: 1),
                    ),
                  ),
                )
                .toList(),
        onSelectionChanged: (s) {
          reloadCurTaskListData(s.first);
        },
        selected: curLayer.curCat,
        multiSelectionEnabled: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cats == null || widget.cats!.isEmpty) {
      return emptyWidget(context);
    }
    return widget.showSegBtns
        ? Padding(
          padding: EdgeInsets.only(left: 3, right: 3),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: _buildSegmentButtons(context),
              ),
              Expanded(child: _buildTasks(context)),
            ],
          ),
        )
        : _buildTasks(context);
  }

  Widget _buildTasks(BuildContext context) {
    return curLayer.tabChanging
        ? buildLoading(context)
        : LayoutBuilder(
          builder: (ctx, constraints) {
            final crossCount = constraints.maxWidth >= 720 ? 3 : 1;
            return _buildRefresher(context, crossCount);
          },
        );
  }

  Widget _buildRefresher(BuildContext context, int crossCount) {
    return SmartRefresher(
      key: curLayer.smartRefreshKey,
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      onLoading: curLayer.loadTaskList,
      onRefresh: () async {
        curLayer.reset();
        await curLayer.loadTaskList();
      },
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("加载更多");
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
    return curLayer.tasks.isEmpty
        ? Column(children: [emptyWidget(context)])
        : GridView.builder(
          primary: true,
          shrinkWrap: true,
          itemCount: curLayer.tasks.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: crossCount == 1 ? 0 : 6,
            mainAxisSpacing: 1,
            childAspectRatio: crossCount == 1 ? 2 : 1.6,
          ),
          itemBuilder: (BuildContext context, int index) {
            final userTaskHis = curLayer.tasks[index];
            return OneTaskCardView(
              key: ValueKey(userTaskHis.task.id),
              userTaskHis: userTaskHis,
              taskCategory: curLayer.curCat.first,
            );
          },
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
        status: userTaskHis.task.status,
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
    } else if (taskCategory == TaskListCategory.myPublished) {
      try {
        final my = userTaskHis.history.firstWhere(
          (e) => e.userId == AuthService.instance.user?.userId,
        );
        return my.action;
      } catch (e) {
        // firstWhere 抛出异常，则表明，没有本人的领取记录，则返回 -1 即可
        return -1;
      }
    }
    return userTaskHis.history.last.action;
  }

  int get leftNum {
    if (task.receiveStrategy == ReceiveTaskStrategy.freeSelection.index) {
      return task.maxReceiverCount <= 0
          // maxReceiverCount <= 0, 那就都是 无限制的
          ? -1
          : task.maxReceiverCount -
              userTaskHis.total -
              (controller.accepted ? 1 : 0);
    } else if ([
      ReceiveTaskStrategy.onlyForceDelegation.index,
      ReceiveTaskStrategy.onlyTwoWaySelection.index,
    ].contains(task.receiveStrategy)) {
      // 只有指定的人才可以在委托列表里看到
      return 0;
    }
    // 无限制
    return -1;
  }

  String get actualLeft {
    final maxR = maxReceiverCount;
    if (maxR.isNumericOnly) {
      if (leftNum < 0) return '无限制';
      return leftNum.toString();
    }
    return maxR;
  }

  String get left {
    final maxR = maxReceiverCount;
    if (maxR.isNumericOnly) {
      if (leftNum < 0) return '无限制';
      if (leftNum > 999) {
        return '999+';
      }
      return leftNum.toString();
    }
    return maxR;
  }

  String get maxReceiverCount {
    if (task.receiveStrategy == ReceiveTaskStrategy.freeSelection.index) {
      if (task.maxReceiverCount > 0) {
        return '${task.maxReceiverCount}';
      }
    } else if ([
      ReceiveTaskStrategy.onlyTwoWaySelection.index,
      ReceiveTaskStrategy.onlyForceDelegation.index,
    ].contains(task.receiveStrategy)) {
      return '限定';
    }
    return '无限制';
  }

  bool get hasLeft {
    final receiveStrategy = ReceiveTaskStrategy.values[task.receiveStrategy];
    switch (receiveStrategy) {
      case ReceiveTaskStrategy.freeSelection:
        if (task.maxReceiverCount <= 0) {
          return true;
        }
        return leftNum > 0;
      case ReceiveTaskStrategy.twoWaySelection:
      case ReceiveTaskStrategy.forceDelegation:
        return true;
      default:
        return false;
    }
  }

  double get taskCredits {
    // 如果任务积分
    if (controller.accepted) {
      // 接受了的任务，返回接受时的积分大小,
      if (userTaskHis.history.isNotEmpty) {
        // 领取的任务的积分即是最后一条记录的积分
        return userTaskHis.history.last.credits;
      }
    }
    // fixme： 没有接受的直接返回任务的当前积分 ， 而不管任务拒绝之后，某个任务的积分有更新，使其与当前任务的积分不一致
    return task.credits;
  }

  String get userTaskActionDesc {
    if (task.receiveStrategy == ReceiveTaskStrategy.onlyForceDelegation.index) {
      if (controller.action.value == UserTaskAction.accept.index) {
        // 强制委派的用户是没有拒绝机会的
        return '强制委派';
      }
    } else if (task.receiveStrategy ==
        ReceiveTaskStrategy.forceDelegation.index) {
      if (controller.action.value == UserTaskAction.accept.index) {
        // 强制委派的用户是没有拒绝机会的
        return '强制委派';
      }
      if (controller.action.value == UserTaskAction.unconfirmed.index) {
        return '待确认';
      }
    } else if ([
      ReceiveTaskStrategy.onlyTwoWaySelection.index,
      ReceiveTaskStrategy.twoWaySelection.index,
    ].contains(task.receiveStrategy)) {
      if (controller.action.value == UserTaskAction.accept.index) {
        return '自愿接受';
      }
      if (controller.action.value == UserTaskAction.unconfirmed.index) {
        return '待确认';
      }
    }

    if (controller.action.value == UserTaskAction.claim.index) {
      return '已领取';
    } else if (controller.action.value == UserTaskAction.accept.index) {
      return '已接受';
    } else if (controller.action.value == UserTaskAction.refuse.index) {
      return '已拒绝';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final card = _buildCard(context);
      if (controller.isHandling.value) {
        return maskingOperation(context, card);
      }
      switch (taskCategory) {
        case TaskListCategory.allPublished:
        case TaskListCategory.delegatedToMe:
          final desc = userTaskActionDesc;
          return desc.isEmpty
              ? card
              : _buildTaskActionIndicator(context, card, desc);
        case TaskListCategory.myManuscript:
          String desc =
              controller.taskStatus.value == SystemTaskStatus.initial.index
                  ? ''
                  : '已发布';
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
            child: Transform.rotate(
              angle: -30 * 3.141592653589793 / 180,
              child: Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(width: 3.0, color: Colors.red),
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
              // 填报历史记录
              op = TaskOperationCategory.submitDetailTask;
              break;
            case TaskListCategory.myParticipant:
              if (controller.taskStatus.value !=
                  SystemTaskStatus.running.index) {
                errToast("请先启动任务再进行内容填报");
                return;
              }
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
            Get.find<RootTabController>()
                    .taskListViewState
                    .currentState
                    ?.curLayer
                    .parentId ??
                Int64.ZERO,
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
          Get.toNamed(page, arguments: args, id: routeId);
        },
        child: Column(
          children: [
            _buildTaskNameAndAction(context),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 5, child: _buildTaskLeft(context)),
                  SizedBox(width: 2),
                  Expanded(flex: 4, child: _buildTaskRight(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCredits(BuildContext context, [bool rightIcon = false]) {
    final children = [
      Icon(Icons.diamond_outlined, size: 20, color: Colors.purple),
      const SizedBox(width: 2),
      Text(
        twoValidNumber.format(taskCredits),
        style: TextStyle(fontSize: 16, color: Colors.purple),
      ),
    ];
    return Row(children: rightIcon ? children.reversed.toList() : children);
  }

  Widget _buildTaskName(BuildContext context) {
    return Text(
      task.name,
      style: TextStyle(
        fontSize: 22,
        color: Colors.black,
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
    );
  }

  Widget _buildTaskNameAndActionByStack(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              _buildTaskName(context),
              Positioned(
                top: 0,
                bottom: 0,
                right: 2,
                child: _buildTaskCredits(context, true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskNameAndActionByColumn(
    BuildContext context,
    List<Widget> actions,
  ) {
    MainAxisAlignment alignment = MainAxisAlignment.end;
    if (taskCategory == TaskListCategory.myPublished) {
      alignment = MainAxisAlignment.spaceBetween;
    }
    return Column(
      children: [
        _buildTaskName(context),
        Row(
          children: [
            _buildTaskCredits(context),
            const SizedBox(width: 4),
            Expanded(
              child: Row(mainAxisAlignment: alignment, children: actions),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskNameAndAction(BuildContext context) {
    const r = Radius.circular(16);
    final actions = _buildAction(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(40), // 设置背景色
        borderRadius: BorderRadius.only(topLeft: r, topRight: r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child:
            actions.isEmpty
                ? _buildTaskNameAndActionByStack(context)
                : _buildTaskNameAndActionByColumn(context, actions),
      ),
    );
  }

  Widget? _buildCountDown(BuildContext context) {
    final ignores = [
      TaskListCategory.myManuscript,
      TaskListCategory.myParticipant,
      TaskListCategory.finished,
      TaskListCategory.parentTaskInfo,
      TaskListCategory.childrenTaskInfo,
    ];
    if (ignores.contains(taskCategory)) {
      return null;
    } else if (task.receiveDeadline <= 0) {
      // 任务没填截止时间
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
            Text('${left.hours}'.padLeft(2), style: countdownNumberStyle),
          if (left.hours > 0 || left.hours > 0) const Text('小时'),
          Text('${left.minutes}'.padLeft(2), style: countdownNumberStyle),
          const Text('分'),
        ]);
      } else if (left.left == 0) {
        children.add(Text("报名已截止", style: countdownNumberStyle));
      } else {
        children.addAll([
          const Text("剩余"),
          Text('${left.minutes}'.padLeft(2), style: countdownNumberStyle),
          const Text(":"),
          Text('${left.seconds}'.padLeft(2), style: countdownNumberStyle),
        ]);
      }
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
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.0)),
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
          Text(maxReceiverCount, style: defaultNumberStyle),
        ],
      ),
    ];

    final countDownWidget = _buildCountDown(context);
    if (countDownWidget != null) {
      children.add(countDownWidget);
    }
    // final actionsWidget = _buildAction(context);
    // if (actionsWidget != null) {
    //   children.add(actionsWidget);
    // }
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

  Widget _buildClaimAction(BuildContext context) {
    return InkWell(
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
    );
  }

  List<Widget> _buildAcceptRefuseAction(BuildContext context) {
    return [
      InkWell(
        onTap: () {
          debugPrint("拒绝${task.name}的子任务成功！");
          controller.handleTaskAction(task.id, UserTaskAction.refuse);
        },
        child: Row(
          children: [
            // const Icon(Icons.close),
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
            // const Icon(Icons.done, color: Colors.green),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildAction(BuildContext context) {
    List<Widget> children;
    switch (taskCategory) {
      case TaskListCategory.allPublished:
        children = [const Text("剩余名额"), Text(left, style: defaultNumberStyle)];
        if (!controller.accepted &&
            hasLeft &&
            {
              // 这些任务类型，还是可以领取的
              ReceiveTaskStrategy.freeSelection.index,
              ReceiveTaskStrategy.forceDelegation.index,
              ReceiveTaskStrategy.twoWaySelection.index,
            }.contains(task.receiveStrategy)) {
          if ([
            UserTaskAction.unconfirmed.index,
            UserTaskAction.refuse.index,
          ].contains(controller.action.value)) {
            children.addAll(_buildAcceptRefuseAction(context));
          } else {
            children.add(_buildClaimAction(context));
          }
        }
        break;

      case TaskListCategory.myPublished:
        final left_ = left;
        final actions = <Widget>[_buildAddSubTask(context)];
        final status = SystemTaskStatus.values[controller.taskStatus.value];
        if (status != SystemTaskStatus.running) {
          actions.add(_buildStartTask(context));
        } else {
          actions.add(_buildPauseTask(context));
        }
        // 任何状态都可以结束任务
        actions.add(_buildFinishTask(context));
        children = [
          Tooltip(
            preferBelow: false,
            message: '剩余:$actualLeft',
            child: Row(
              children: [
                Text(
                  '${userTaskHis.total}',
                  style: defaultNumberStyle.copyWith(fontSize: 16),
                ),
                const Text("人领取"),
                if (!['无限制', '限定'].contains(left_)) ...[
                  const Text("，剩余"),
                  Text(left, style: defaultNumberStyle.copyWith(fontSize: 16)),
                  const Text("人"),
                ],
              ],
            ),
          ),
          // const Spacer(),
          const SizedBox(width: 2),
          Row(children: actions),
        ];

        break;
      case TaskListCategory.myManuscript:
        children = [
          _buildAddSubTask(context),
          Spacer(),
          Tooltip(
            message: '把任务置为发布状态',
            preferBelow: false,
            child: IconButton(
              onPressed: () {
                controller.handleTaskStatusAction(
                  context,
                  task,
                  UserTaskAction.publish,
                );
              },
              icon: Tooltip(
                message: '发布该任务',
                child: Icon(Icons.send, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () async {
              await controller.deleteTask(task, context);
            },
            child: Icon(Icons.close, color: Colors.red),
          ),
        ];
        break;
      case TaskListCategory.myParticipant:
      case TaskListCategory.finished:
        children = [];
        break;
      case TaskListCategory.delegatedToMe:
        if ([
          ReceiveTaskStrategy.twoWaySelection.index,
          ReceiveTaskStrategy.onlyTwoWaySelection.index,
        ].contains(task.receiveStrategy)) {
          final desc = userTaskActionDesc;
          if (['待确认', '已拒绝'].contains(desc)) {
            children = _buildAcceptRefuseAction(context);
            break;
          }
        }
        children = [];
        break;
      case TaskListCategory.parentTaskInfo:
      case TaskListCategory.childrenTaskInfo:
        return [];
    }
    return children;
  }

  Widget _buildAddSubTask(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: "创建子任务",
      child: IconButton(
        icon: const Row(
          children: [
            Icon(Icons.add),
            Text("子任务", style: TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
        onPressed: () {
          // 跳转到新增子任务界面
          final routeId = Get.find<RootTabController>().curRouteId;
          final args = WorkTaskPageParams(
            task.id,
            null,
            taskCategory,
            opCat: TaskOperationCategory.publishTask,
          );
          Get.toNamed(
            WorkTaskRoutes.hallTaskDetail,
            arguments: args,
            id: routeId,
          );
        },
      ),
    );
  }

  Widget _buildStartTask(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: '启动该任务',
      child: IconButton(
        icon: Icon(Icons.not_started_outlined),
        onPressed: () {
          controller.handleTaskStatusAction(
            context,
            task,
            UserTaskAction.start,
          );
        },
      ),
    );
  }

  Widget _buildPauseTask(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: '暂停该任务',
      child: IconButton(
        icon: Icon(Icons.pause_circle_outline),
        onPressed: () {
          controller.handleTaskStatusAction(
            context,
            task,
            UserTaskAction.pause,
          );
        },
      ),
    );
  }

  Widget _buildFinishTask(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: '结束该任务',
      child: IconButton(
        icon: const Text("结束"),
        onPressed: () {
          controller.handleTaskStatusAction(
            context,
            task,
            UserTaskAction.finish,
          );
        },
      ),
    );
  }
}
