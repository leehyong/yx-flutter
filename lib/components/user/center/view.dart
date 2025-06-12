import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/root/controller.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';

class PersonalCenterView extends StatefulWidget {
  const PersonalCenterView({super.key});

  @override
  PersonalCenterViewState createState() => PersonalCenterViewState();
}

class PersonalCenterViewState extends State<PersonalCenterView> {
  final profileBoxHeight = 220.0;
  final profileBoxMarginBottom = 60.0;
  final horizontalPadding = 40.0;
  final verticalPadding = 20.0;
  final borderRadiusAll20 = BorderRadius.all(Radius.circular(20));
  final messageCount = 10;
  final credits = 10.0;

  Widget _buildMyselfProfile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadiusAll20,
      ),
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        // horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 头像、用户名等信息
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.network(
                  'https://img.36krcdn.com/hsossms/20250611/v2_6946b1a1ac1f436ab79880cd07c98c3f@000000_oswg42582oswg1080oswg720_img_000?x-oss-process=image/format,jpg/interlace,1',
                  // 实际替换成你的头像地址
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '奋斗的青春',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '儒生 北京市 高三理',
                      style: TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                onPressed: () {
                  // 获取积分列表
                },
                child: Row(
                  spacing: 4,
                  children: [
                    Text(
                      '$credits',
                      style: TextStyle(fontSize: 18, color: Colors.purple),
                    ),
                    Icon(Icons.diamond, color: Colors.purple, size: 22),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('欢迎加入'),
              TextButton(
                // 短按展示企业信息
                onPressed: () {},
                // 长按复杂企业名称
                onLongPress: () {},
                child: Row(
                  spacing: 4,
                  children: [
                    const Text(
                      '地球村',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Icon(Icons.copy, size: 14),
                  ],
                ),
              ),
              const Text('大家庭'),
              Icon(Icons.tag_faces, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow.withAlpha(10),
        borderRadius: borderRadiusAll20,
      ),
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Column(
        spacing: 4,
        children: [
          _buildListTileItem(
            context,
            icon: Icons.layers,
            title: '加入组织',
            onTap: () {
              Get.toNamed(
                UserProfileRoutes.organization,
                arguments: UserCenterPageParams(
                  UserCenterAction.joinOrganization,
                ),
                id: Get.find<RootTabController>().curRouteId,
              );
            },
          ),
          _buildListTileItem(
            context,
            icon: Icons.swap_horiz,
            title: '切换组织',
            onTap: () {
              Get.toNamed(
                UserProfileRoutes.organization,
                arguments: UserCenterPageParams(
                  UserCenterAction.switchOrganization,
                ),
                id: Get.find<RootTabController>().curRouteId,
              );
            },
          ),
          _buildListTileItem(
            context,
            icon: Icons.add,
            title: '注册组织',
            onTap: () {
              final a = 'x';
              debugPrint('注册组织');
              Get.toNamed(
                UserProfileRoutes.registerOrganization,
                arguments: UserCenterPageParams(
                  UserCenterAction.registerOrganization,
                ),
                id: Get.find<RootTabController>().curRouteId,
              );
            },
          ),
          _buildListTileItem(
            context,
            icon: Icons.logout,
            title: '退出登录',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Widget _buildMyInfo(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _FunctionItem(
  //         icon: Icons.diamond,
  //         label: '我的积分',
  //         bgColor: Colors.greenAccent,
  //         onTap: () {},
  //       ),
  //       // _FunctionItem(
  //       //   icon: Icons.stacked_bar_chart,
  //       //   label: '进行中的任务',
  //       //   bgColor: Colors.pinkAccent,
  //       //   onTap: () {},
  //       // ),
  //       // _FunctionItem(
  //       //   icon: Icons.pie_chart,
  //       //   label: '已完成的任务',
  //       //   bgColor: Colors.purpleAccent,
  //       //   onTap: () {},
  //       // ),
  //       _FunctionItem(
  //         icon: Icons.view_list,
  //         label: '我的计划',
  //         bgColor: Colors.orangeAccent,
  //         onTap: () {},
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTopActions(BuildContext context) {
    final msg = Icon(Icons.message, color: Colors.white, size: 28);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 16,
      children: [
        IconButton(
          onPressed: () {
            debugPrint('消息');
          },
          icon:
              messageCount > 0
                  ? Badge(label: Text('$messageCount'), child: msg)
                  : msg,
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.share, color: Colors.white, size: 28),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.settings, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Widget _buildListTileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   spacing: 6,
        //   children: [
        //     Icon(icon),
        //     Text(title),
        //     const Spacer(),
        //     const Icon(Icons.arrow_forward_ios, size: 16)
        //   ],
        // ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = isBigScreen(context) ? 60.0 : 10.0;
    return Scaffold(
      body: LayoutBuilder(
        builder: (cxt, cons) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: cons.maxWidth,
                height: profileBoxHeight,
                alignment: Alignment(-1, -0.5),
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: hp),
                margin: EdgeInsets.only(bottom: profileBoxMarginBottom),
                child: _buildTopActions(context),
              ),
              Positioned(
                left: hp,
                width: cons.maxWidth - hp * 2,
                top: profileBoxMarginBottom * 2,
                height: cons.maxHeight,
                child: Column(
                  spacing: 8,
                  children: [
                    _buildMyselfProfile(context),
                    // SizedBox(height: 4),
                    // _buildMyInfo(context),
                    Expanded(child: _buildActionBox(context)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 功能入口子项 widget
class _FunctionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _FunctionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
