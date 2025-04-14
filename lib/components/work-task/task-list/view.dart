import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:yt_dart/generate_sea_orm_query.pb.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/common_widget.dart';

import 'controller.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({
    super.key,
    required this.tasks,
    required this.taskCategory,
    required this.routeId,
    required this.isLoading,
  });

  final List<WorkTask> tasks;
  final TaskListCategory taskCategory;
  final int routeId;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final crossCount = constraints.maxWidth >= 720 ? 4 : 1;
        final cnt = tasks.length;
        return GridView.builder(
          primary: true,
          shrinkWrap: true,
          itemCount: isLoading ? cnt + 1 : cnt,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: crossCount == 1 ? 0 : 6,
            mainAxisSpacing: 1,
            childAspectRatio: 2,
          ),
          itemBuilder: (BuildContext context, int index) {
            return index < tasks.length
                ? OneTaskView(
                  task: tasks[index],
                  taskCategory: taskCategory,
                  routeId: routeId,
                )
                : Center(
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballGridBeat,

                      /// Required, The loading type of the widget
                      colors: loadingColors,
                      strokeWidth: 2,
                    ),
                  ),
                );
          },
        );
      },
    );
  }
}

class OneTaskView extends GetView<OneTaskController> {
  OneTaskView({
    super.key,
    required this.task,
    required this.taskCategory,
    required this.routeId,
  }) {
    Get.put(
      OneTaskController(deadline: task.receiveDeadline.toInt()),
      tag: '${task.id}',
    );
  }

  @override
  String? get tag => '${task.id}';

  final WorkTask task;
  final TaskListCategory taskCategory;
  final int routeId;

  @override
  Widget build(BuildContext context) {
    return commonCard(
      GestureDetector(
        onTap: () {
          debugPrint("点击了详情${task.id};$taskCategory");
        },
        child: Column(
          children: [
            _buildTaskName(context),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 5, child: _buildTaskLeft(context)),
                  SizedBox(width: 2),
                  Expanded(flex: 4, child: Obx(() => _buildTaskRight(context))),
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
      final Widget w;
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
            const Text("开始时间:"),
            Text(
              localFromMicroSecondsTimestamp(task.planStartDt.toInt()),
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
            const Text("结束时间:"),
            Text(
              localFromMicroSecondsTimestamp(task.planEndDt.toInt()),
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
      case TaskListCategory.myLeading:
      case TaskListCategory.myParticipant:
      case TaskListCategory.finished:
        children = [
          InkWell(
            onTap: () {
              debugPrint("${task.name}任务详情！");
              Get.toNamed(
                '/task_detail',
                arguments: "${task.id};$taskCategory",
                id: routeId,
              );
            },
            child: const Text(
              "点击查看详情",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
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
