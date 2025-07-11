import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:yx/root/nest_nav_key.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/services/auth_service.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/toast.dart';

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
  double credits = 10.0;

  Widget _buildUserProfile(BuildContext context) {
    return // 头像、用户名等信息
    Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: ImageWidget.asset(
            'assets/images/girl.jpeg',
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
            children: [
              Text(
                AuthService.instance.user?.username ?? '游客，您好',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '儒生 北京市 高三理',
                style: TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        TextButton(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          onPressed: () {
            // todo 获取积分记录列表
            if (!AuthService.instance.isLoggedInValue) {
              warnToast('当前还没登录，请登录!');
              return;
            }
          },
          child: Row(
            spacing: 10,
            children: [
              Text(
                AuthService.instance.isLoggedInValue ? '$credits' : "0",
                style: TextStyle(fontSize: 18, color: Colors.purple),
              ),
              Icon(Icons.diamond, color: Colors.purple, size: 22),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyselfProfile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildUserProfile(context),
        AuthService.instance.isLoggedInValue
            ? _buildOrganizationProfile(context)
            : _buildVisitorProfile(context),
      ],
    );
  }

  Widget _buildOrganizationProfile(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('欢迎加入'),
        TextButton(
          // 短按展示企业信息
          onPressed: () {
            debugPrint('地球村');
          },
          // 长按复杂企业名称
          onLongPress: () {},
          child: Row(
            spacing: 4,
            children: [
              Text(
                AuthService.instance.user?.orgName ?? '地球村',
                // '地球村',
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
    );
  }

  Widget _buildVisitorProfile(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          // 短按展示企业信息
          onPressed: () {
            Get.offAndToNamed(Routes.login);
          },
          // 长按复杂企业名称
          onLongPress: () {},
          child: Row(
            spacing: 10,
            children: [
              Icon(Icons.login, size: 22),
              Text(
                '立即登录',
                // '地球村',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyselfProfileBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadiusAll20,
      ),
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        // horizontal: horizontalPadding,
      ),
      child: _buildMyselfProfile(context),
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
            checkedLogin: true,
            onTap: () {
              Get.toNamed(
                UserProfileRoutes.organization,
                arguments: UserCenterPageParams(
                  UserCenterAction.joinOrganization,
                ),
                id: NestedNavigatorKeyId.userCenterId,
              );
            },
          ),
          _buildListTileItem(
            context,
            icon: Icons.swap_horiz,
            title: '切换组织',
            checkedLogin: true,
            onTap: () {
              Get.toNamed(
                UserProfileRoutes.organization,
                arguments: UserCenterPageParams(
                  UserCenterAction.switchOrganization,
                ),
                id: NestedNavigatorKeyId.userCenterId,
              );
            },
          ),
          _buildListTileItem(
            context,
            icon: Icons.add,
            title: '注册组织',
            checkedLogin: true,
            onTap: () {
              Get.toNamed(
                UserProfileRoutes.registerOrganization,
                arguments: UserCenterPageParams(
                  UserCenterAction.registerOrganization,
                ),
                id: NestedNavigatorKeyId.userCenterId,
              );
            },
          ),
          _buildListTileItem(
            context,
            icon: Icons.update,
            title: '修改秘密',
            checkedLogin: true,
            onTap: () {
              Get.toNamed(
                UserProfileRoutes.changePwd,
                arguments: UserCenterPageParams(UserCenterAction.changePwd),
                id: NestedNavigatorKeyId.userCenterId,
              );
            },
          ),
          AuthService.instance.isLoggedInValue
              ? _buildListTileItem(
                context,
                icon: Icons.logout,
                title: '退出登录',
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (
                      BuildContext buildContext,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                    ) {
                      return TDAlertDialog(
                        title: "确定退出吗？",
                        leftBtnAction: () {
                          Navigator.of(buildContext).pop();
                        },
                        rightBtnAction: () {
                          Navigator.of(buildContext).pop();
                          Get.offAndToNamed(Routes.login);
                        },
                      );
                    },
                  );
                },
              )
              : _buildListTileItem(
                context,
                icon: Icons.login,
                title: '立即登录',
                onTap: () {
                  Get.offAndToNamed(Routes.login);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    final msg = Icon(Icons.message, color: Colors.white, size: 28);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 20,
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
    bool checkedLogin = false,
  }) {
    return InkWell(
      onTap: () {
        if (checkedLogin && !AuthService.instance.isLoggedInValue) {
          warnToast('当前还没登录，请登录!');
          return;
        }
        onTap();
      },
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
            // clipBehavior: Clip.none,
            children: [
              Column(
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
                  Expanded(child: _buildActionBox(context)),
                ],
              ),
              Positioned(
                left: hp,
                width: cons.maxWidth - hp * 2,
                top: profileBoxMarginBottom * 2,
                // height: cons.maxHeight,
                child: _buildMyselfProfileBox(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
