import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/services/auth_service.dart';

import '../../../components/user/change_pwd_comp.dart';

class ChangePwdView extends GetView<GetxController> {
  const ChangePwdView({super.key});

  Widget buildTitle() {
    return const Padding(
      // 设置边距
      padding: EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.bottomLeft,
        // child: Text('绩效考核', style: TextStyle(fontSize: 42, decoration: TextDecoration.underline)),
        child: Text('绩效考核', style: TextStyle(fontSize: 42)),
      ),
    );
  }

  Widget buildTitleLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(color: Colors.black, width: 40, height: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          GetPlatform.isMobile
              ? buildBasicChangePwdView(context)
              : Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        // image: AssetImage('images/backbode/back1.png'), // 全局设置背景图片
                        image: AssetImage('assets/images/background.jpg'), //动态
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(flex: 2, child: SizedBox.shrink()),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.only(
                            right: 20,
                            top: 30,
                            bottom: 30,
                          ),
                          child: buildBasicChangePwdView(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget buildBasicChangePwdView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
          buildTitle(), // Login
          buildTitleLine(), // 标题下面的下滑线
          const SizedBox(height: 50),
          Expanded(
            // width: w, // 指定图片的宽度
            // height: h,
            child: ContainedTabBarView(
              tabs: [
                Obx(
                  () => Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                        child: Icon(Icons.workspaces, size: 28),
                      ),
                      Text(
                        AuthService.instance.isWeak ? '密码已过期，请重新修改' : "修改密码",
                        style: TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ],
              views: [ChangePwdCompView()],
            ),
          ),
        ],
      ),
    );
  }
}
