import 'package:flutter/material.dart';
import 'package:yx/utils/common_util.dart';

class PersonalCenterView extends StatefulWidget {
  const PersonalCenterView({super.key});

  @override
  PersonalCenterViewState createState() => PersonalCenterViewState();
}

class PersonalCenterViewState extends State<PersonalCenterView> {
  final profileBoxHeight = 260.0;
  final profileBoxMarginBottom = 60.0;
  final horizontalPadding = 40.0;
  final verticalPadding = 20.0;
  final borderRadiusAll20 = BorderRadius.all(Radius.circular(20));

  Widget _buildMyselfProfile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadiusAll20,
      ),
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 头像、用户名等信息
          Row(
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
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '奋斗的青春',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('儒生 北京市 高三理', style: TextStyle(fontSize: 14)),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // 个人主页点击事件
                },
                child: const Text('个人主页'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 收藏、关注等统计数据
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _StatsItem(title: '66', subTitle: '收藏'),
              _StatsItem(title: '102', subTitle: '关注'),
              _StatsItem(title: '68', subTitle: '帖子'),
              _StatsItem(title: '99', subTitle: '问答'),
            ],
          ),
        ],
      ),
    );
  }

  double profileBoxPaddingHorizontal(BuildContext context) {
    return isBigScreen(context) ? 60 : 10;
  }

  Widget _buildActionBox(BuildContext context) {
    final children = _buildCommonActions(context);
    children.insert(0, _buildMyInfo(context));
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: borderRadiusAll20,
      ),
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Column(spacing: 4, children: children),
    );
  }

  Widget _buildPositionedCenter(BuildContext context) {
    return Column(
      children: [_buildMyselfProfile(context), _buildActionBox(context)],
    );
  }

  List<Widget> _buildCommonActions(BuildContext context) {
    return [
      // 我的积分等列表项
      _ListTileItem(icon: Icons.star, title: '我的积分', onTap: () {}),
      _ListTileItem(icon: Icons.download, title: '我的下载', onTap: () {}),
      _ListTileItem(icon: Icons.nightlight_round, title: '夜间模式', onTap: () {}),
      _ListTileItem(icon: Icons.settings, title: '设置', onTap: () {}),
      _ListTileItem(icon: Icons.logout, title: '退出登录', onTap: () {}),
    ];
  }

  Widget _buildMyInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FunctionItem(
          icon: Icons.calendar_today,
          label: '高考日历',
          bgColor: Colors.greenAccent,
          onTap: () {},
        ),
        _FunctionItem(
          icon: Icons.timer,
          label: '倒计时',
          bgColor: Colors.pinkAccent,
          onTap: () {},
        ),
        _FunctionItem(
          icon: Icons.pie_chart,
          label: '学习统计',
          bgColor: Colors.purpleAccent,
          onTap: () {},
        ),
        _FunctionItem(
          icon: Icons.view_list,
          label: '我的计划',
          bgColor: Colors.orangeAccent,
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = profileBoxPaddingHorizontal(context);
    return LayoutBuilder(
      builder: (cxt, cons) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: cons.maxWidth,
              height: profileBoxHeight,
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: hp),
              margin: EdgeInsets.only(bottom: profileBoxMarginBottom),
            ),
            Positioned(
              left: hp,
              width: cons.maxWidth - hp * 2,
              top: profileBoxMarginBottom * 1.6,
              child: _buildPositionedCenter(context),
            ),
          ],
        );
      },
    );
  }
}

// 统计数据子项 widget
class _StatsItem extends StatelessWidget {
  final String title;
  final String subTitle;

  const _StatsItem({Key? key, required this.title, required this.subTitle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subTitle, style: const TextStyle(fontSize: 12)),
      ],
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
    Key? key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  }) : super(key: key);

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

// 列表项 widget
class _ListTileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ListTileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
