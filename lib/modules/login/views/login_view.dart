import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import './phone_login_view.dart';
import './user_login_view.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  Widget buildTitle() {
    return const Padding(
      // 设置边距
      padding: EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.bottomLeft,
        // child: Text('绩效考核', style: TextStyle(fontSize: 42, decoration: TextDecoration.underline)),
        child: Text('悦享管', style: TextStyle(fontSize: 42)),
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
          ? buildBasicLoginView(context)
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
                  child: buildBasicLoginView(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBasicLoginView(BuildContext context) {
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
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                      child: Icon(Icons.person, size: 28),
                    ),
                    Text("用户登录", style: TextStyle(fontSize: 22)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                      child: Icon(Icons.phone_android, size: 28),
                    ),
                    Text("手机登录", style: TextStyle(fontSize: 22)),
                  ],
                ),
              ],
              views: [
                UserLoginView(),
                PhoneLoginView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
