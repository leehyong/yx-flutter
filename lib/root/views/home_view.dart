import 'package:yx/components/task/bindings/task_creation_binding.dart';
import 'package:yx/components/task/views/detail2.dart';
import 'package:yx/components/task/views/detail3.dart';
import 'package:yx/root/bindings/home_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../../components/task/bindings/task_binding.dart';
import '../../components/task/views/detail.dart';
import '../../components/task/views/task_creation_view.dart';
import '../../vo/duty_vo.dart';
import '../controllers/home_controller.dart';
import '../nest_nav_key.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    // final Controller c = Get.put(Controller());
    return Navigator(
      key: Get.nestedKey(NestedNavigatorKeyId.homeId),
      initialRoute: "/home",
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/home') {
          return GetPageRoute(
            settings: settings,
            page: () => Home(),
            bindings: [HomeBinding()],
            transition: Transition.topLevel,
          );
        } else if (settings.name == '/task/detail1') {
          return GetPageRoute(
            settings: settings,
            bindings: [TaskBinding()],
            page: () => const TaskDetailView1(),
            transition: Transition.rightToLeftWithFade,
          );
        } else if (settings.name == '/task/detail2') {
          return GetPageRoute(
            settings: settings,
            bindings: [TaskBinding()],
            page: () => const TaskDetailView2(),
            transition: Transition.fadeIn,
          );
        } else if (settings.name == '/task/detail3') {
          return GetPageRoute(
            settings: settings,
            bindings: [TaskBinding()],
            page: () => const TaskDetailView3(),
            transition: Transition.fadeIn,
          );
        }
        else if (settings.name == '/other') {
          return GetPageRoute(
            settings: settings,
            page: () => const Other(),
            transition: Transition.fadeIn,
          );
        }
        else if (settings.name == '/task_creation') {
          return GetPageRoute(
            settings: settings,
            bindings: [TaskCreationBinding()],
            page: () => const TaskCreationView(),
            transition: Transition.fadeIn,
          );
        }
        return null;
      },
    );
  }
}

class Other extends GetView<HomeController> {
  const Other({super.key});

  // You can ask Get to find a Controller that is being used by another page and redirect you to it.

  @override
  Widget build(context) {
    // Access the updated count variable
    return Scaffold(body: Center(child: Text("${controller.count}")));
  }
}

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("工作任务列表"),
        actions: [
          if (GetPlatform.isMobile)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // 新增任务的逻辑
                Get.toNamed('/task_creation',id:NestedNavigatorKeyId.homeId);
              },
            ),
        ],
      ),
      body: GetPlatform.isMobile ? buildMobile(context) : buildWeb(context),
      );
  }
  Widget buildWeb(BuildContext context) {
    return FutureBuilder(
      future: controller.initTaskList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            primary: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: double.infinity), // 确保宽度不受限制
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DepartmentFilter(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "新增任务",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ClickableCard(),
                  ...controller.multiDutyMap.entries.map((entry) => TaskSection(title: entry.key, tasks: entry.value)),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildMobile(BuildContext context) {
    return FutureBuilder(
      future: controller.initTaskList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Obx(() => Column(
            children: [
              // 筛选下拉菜单
              _buildFilterDropdown(),
              // 新增任务按钮+任务网格
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.initTaskList(),
                  child: _buildGridLayout(),
                ),
              ),
            ],
          ));
        }
      },
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: controller.selectedMobileTaskType.value,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        items: [
          DropdownMenuItem(
            value: '全部',
            child: Text('全部任务'),
          ),
          ...controller.multiDutyMap.keys.map((key) {
            return DropdownMenuItem(
              value: key,
              child: Text(key),
            );
          }),
        ],
        onChanged: (value) {
          controller.selectedMobileTaskType.value = value!;
        },
      ),
    );
  }

  Widget _buildGridLayout() {
    final tasks = controller.selectedMobileTaskType.value == '全部'
        ? controller.multiDutyMap.values.expand((list) => list).toList()
        : controller.multiDutyMap[controller.selectedMobileTaskType.value] ?? [];

    return CustomScrollView(
      slivers: [
        // 新增任务卡片
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //     child: ClickableCard(),
        //   ),
        // ),
        // 双列任务网格
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 双列显示
              crossAxisSpacing: 12, // 列间距
              mainAxisSpacing: 12, // 行间距
              childAspectRatio: 1.0, // 宽高比调整
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                // 安全访问 + 空值兜底
                final duty = index < tasks.length ? tasks[index] : null;
                return duty != null
                    ? TaskCard(duty: duty)
                    : _buildErrorCard("数据异常"); // 空数据占位
              },
              childCount: tasks.length,
            ),
          ),
        ),
      ],
    );
  }
// 空数据占位组件
  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red[50],
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
class DepartmentFilter extends GetView<HomeController> {
  // 使用GetX的Controller来管理状态
  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 使用Obx来监听状态变化
        Obx(() {
          return SegmentedButton(
            segments: const [
              ButtonSegment<int>(value: 0, label: Text('全部')),
              ButtonSegment<int>(value: 1, label: Text('网优室')),
              ButtonSegment<int>(value: 2, label: Text('应用研发室')),
            ],
            selected: {_controller.selectedValue.value}, // 绑定选中的值
            onSelectionChanged: (newSelection) {
              // 更新选中的值
              _controller.selectedValue.value = newSelection.first;
              debugPrint(_controller.selectedValue.value.toString());
            },
          );
        }),
        SizedBox(height: 20)
      ],
    );
  }
}
class TaskSection extends GetView<HomeController> {
  final String title;
  final List<DutyVo> tasks;

  const TaskSection({super.key, required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    // 使用GetX的Get.put来确保ScrollController的单例
    final ScrollController _scrollController = Get.put(ScrollController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // 水平滚动的任务卡片
        Scrollbar(
          controller: _scrollController,
          child: SizedBox(
            height: GetPlatform.isMobile? 120:160,
            width: MediaQuery.of(context).size.width, // 明确父容器宽度
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: tasks.length,
              itemExtent: 160, // 关键修复：明确子项宽度
              itemBuilder: (context, index) {
                return TaskCard(duty: tasks[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}
class TaskCard extends GetView<HomeController> {
  final DutyVo duty;

  const TaskCard({super.key, required this.duty});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          toastification.show(
            type: ToastificationType.info,
            title: Text("卡片被点击了！"),
            autoCloseDuration: const Duration(seconds: 3),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行（带图标和日期）
              Row(
                children: [
                  Expanded(
                    child: Text(
                      duty.dutyName ?? '未命名任务',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,  // 限制单行显示
                      overflow: TextOverflow.ellipsis,  // 超出部分显示省略号
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // 信息项通用构建方法
              _buildInfoItem(
                icon: Icons.date_range,
                text: (duty.dutyEndDate?.isNotEmpty ?? false)
                    ? duty.dutyEndDate!
                    : '无截止日期',
              ),
              _buildInfoItem(
                icon: Icons.account_circle,
                text: (duty.responsibleDepartment?.isNotEmpty ?? false)
                    ? duty.responsibleDepartment![0].departmentName
                    : '无负责部门',
              ),
              _buildInfoItem(
                icon: Icons.person,
                text: (duty.responsiblePerson?.isNotEmpty ?? false)
                    ? (duty.responsiblePerson![0].responsible ?? '无负责人')
                    : '无负责人',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(  // 关键：使用 Expanded 约束宽度
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
              maxLines: 1,  // 单行显示
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// 新建任务的卡片
class ClickableCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          Get.toNamed('/task_creation',id:NestedNavigatorKeyId.homeId);
          // Get.to(()=>TaskCreationView(),binding: TaskCreationBinding());
        },
        splashColor: Colors.blue.withAlpha(30), // 设置涟漪效果的颜色
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          height: 140,
          width: 140,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("+"),
                Text("新增任务"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}