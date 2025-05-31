import 'package:flutter/material.dart';
import 'package:yx/components/work-task/task-list/view.dart';
import 'package:yx/types.dart';


class TaskHomeView extends StatelessWidget {
  const TaskHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("任务清单", style: defaultTitleStyle)),
      body: TaskListView(cats: TaskListCategoryExtension.homeTaskList),
    );
  }
}
