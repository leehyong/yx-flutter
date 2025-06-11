import 'dart:convert';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:yx/routes/app_pages.dart';
import 'package:yx/types.dart';
import 'package:yx/utils/common_util.dart';
import 'package:yx/utils/toast.dart';

import '../controllers/user_login_controller.dart';

class UserLoginView extends GetView<UserLoginController> {
  UserLoginView({super.key}) {
    Get.put(UserLoginController());
  }

  Widget buildUserTextField() {
    return TextFormField(
      autofocus: true,
      key: controller.userFieldKey,
      focusNode: controller.userFocusNode,
      onTapOutside: (p) async {
        controller.userFocusNode.unfocus();
        await controller.maybeGetCaptcha();
      },
      controller: controller.userEditingController,
      decoration: const InputDecoration(
        labelText: "用户名",
        icon: Tooltip(
          richMessage: TextSpan(
            children: [
              TextSpan(text: "用户名遵循以下规则\n", style: TextStyle(fontSize: 14)),
              TextSpan(text: "1.至少5个最多60个字符\n", style: TextStyle(fontSize: 10)),
              TextSpan(text: "2.首字母只能是大小写\n", style: TextStyle(fontSize: 10)),
              TextSpan(
                children: [
                  TextSpan(text: "3.可以是特殊字符"),
                  TextSpan(
                    text: "@-#*&!%",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: "或者数字"),
                  TextSpan(
                    text: "0-9",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
                style: TextStyle(fontSize: 10),
              ),
              TextSpan(text: "\n4.不能包含空白字符", style: TextStyle(fontSize: 10)),
            ],
          ),
          child: Icon(Icons.person_outline),
        ),
      ),
      validator: (v) {
        if (!isValidUser(v!)) {
          return "用户名格式不对";
        }
        // controller.user.value = v!;
        return null;
      },
    );
  }

  Widget buildPasswordTextField(BuildContext context) {
    return TextFormField(
      controller: controller.pwdEditingController,
      obscureText: !controller.showPwd.value,
      // 是否显示文字
      validator: (v) {
        // 密码格式验证
        if (!isValidPwd(v!)) {
          return "密码格式不对，请检查";
        }
        return null;
        // controller.pwd.value = v!;
      },
      onTap: () async {
        if (controller.userEditingController.text.isEmpty) {
          EasyThrottle.throttle(
            'err-toast-user', // <-- An ID for this particular throttler
            Duration(seconds: 3), // <-- The throttle duration
            () => errToast("请先输入用户名"), // <-- The target method
          );
        } else {
          await controller.maybeGetCaptcha();
        }
      },
      decoration: InputDecoration(
        labelText: "密码",
        icon: Tooltip(
          richMessage: TextSpan(
            children: [
              TextSpan(text: "密码遵循以下规则\n", style: TextStyle(fontSize: 14)),
              TextSpan(
                text: "1.至少6位，最多20位的不包括中文的字符\n",
                style: TextStyle(fontSize: 10),
              ),
              TextSpan(
                text: "2.至少包括大小写字母、数字、特殊字符中的3类\n",
                style: TextStyle(fontSize: 10),
              ),
              TextSpan(
                children: [
                  TextSpan(text: "3.特殊字符是"),
                  TextSpan(
                    text: r'''^~`!@#$%&*()-_+={[]}}\、:;'",<>./?''',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
                style: TextStyle(fontSize: 10),
              ),
              TextSpan(text: "\n4.不能包含任何空白字符", style: TextStyle(fontSize: 10)),
            ],
          ),
          child: Icon(Icons.password_outlined),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color:
                controller.showPwd.value
                    ? Theme.of(context).iconTheme.color
                    : Colors.grey,
          ),
          onPressed: () {
            controller.showPwd.value = !controller.showPwd.value;
          },
        ),
      ),
    );
  }

  Widget buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            // Navigator.pop(context);
            print("忘记密码");
          },
          child: const Text(
            "忘记密码？",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
          style: ButtonStyle(
            // 设置圆角
            shape: WidgetStateProperty.all(
              const StadiumBorder(side: BorderSide(style: BorderStyle.none)),
            ),
          ),
          child: const Text('登录', style: TextStyle(fontSize: 24)),
          onPressed: () async {
            // 表单校验通过才会继续执行
            // Get.offAndToNamed(Routes.app);

            if (controller.isValidInput) {
              //执行登录方法
              final err = await controller.login();
              if (err.isEmpty) {
                Get.offAndToNamed(Routes.app);
              }
            }
          },
        ),
      ),
    );
  }

  Widget buildRegisterText(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('没有账号?'),
            GestureDetector(
              child: const Text('点击注册', style: TextStyle(color: Colors.green)),
              onTap: () {
                print("点击注册");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserCaptchaTextField(BuildContext context) {
    return TextFormField(
      controller: controller.captchaEditingController,
      decoration: InputDecoration(
        labelText: "验证码",
        icon: Icon(Icons.text_fields),
        suffixIcon: InkWell(
          onTap: () {
            if (controller.isValidInput) {
              // 发送验证码之前，清空已填的旧的验证码
              controller.captchaEditingController.clear();
              controller.sendCaptchaAction();
            } else {
              errToast("请输入合规的用户名和密码");
            }
          },
          child: _buildCaptcha(context),
        ),
      ),
    );
  }

  Widget _buildCaptcha(BuildContext context) {
    if (controller.sendingCaptcha.value == DataLoadingStatus.loading) {
      return const Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 20,
          height: 20,
          child: LoadingIndicator(
            indicatorType: Indicator.ballPulseSync,

            /// Required, The loading type of the widget
            colors: loadingColors,
            strokeWidth: 2,
          ),
        ),
      );
    } else if (controller.captcha.value.isEmpty) {
      return const Icon(Icons.calculate, color: Colors.red);
    }
    return Image.memory(
      base64.decode(
        // "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEYAAAAjCAIAAACmdes6AAACP0lEQVR4Xu2W0U3EQAxETxSA+OMnFdAL30AV1EUproB2SGJwhpldZ7MJEBDSfCT22Ot3vj3dxV5f/pguGvrt+kf6Mg2P9xrs01mQbKY6BOxESK79YKdDcu0BOwype4JEfT1PjWRd6zo7kmsTWCvSzfXzKAo+PdyFxiPxVW2X26ui0KlZ9DSC7UJyIZJmyaaDqnLPKlgTkvPUkGweN7akWTd4Kpk1lHgCJqFaR3KSHMnmM3Ikf0jGDSUeJKmt63gkpcJgMm4o8SiDgq0gBcYmJKSi12TcRo9SeTDiGVIweEGO5DZC0qWNg+rnSgokdPqzCgv9tYpEaxmfa41CHsddEY9VxtU+dBZFsFBTGRK9YqTW3T4jUU+TLxV1QE/xiCjRqqVcQyY8HtGgS89uQUJ5bTGoo+txfISGiqMnSCE8bKj8psfEtfLw1Ob+biSDFRXPTpCiyTBvTGvJU0yZIsXcVNaIhJvBS4V4OZLBr2Jt7iQ1leOLz03C7hHURvaBhBG9VKvjuie31eLv5fiiPAme9kqQIk5fvGIrvUtkS2aYyjVUlC4H8RymeAZRrd6l8OjcRFg8bip3hyZIioSi26LZQ5BctfhSHj7NoRKkGDeaIN7w+b/ffiTsr6mpPEyaQ21CIiFeICVUhERtMYjZeFjuUm0glyLhZ+/SDrofxUM/AqMNq9zpDxhf/NgxCvq0tZxGqWW10LMa9PhPIpEIrw/J9Ec8sbZoZ3mI8FS1uJ0Wyda25AYNmiIl1hbtqSV1I70B+dAU/4dAw64AAAAASUVORK5C"
        //     .split(",")[1],
        controller.captcha.value,
      ),
      height: 40, //设置高度
      width: 100, //设置宽度
      fit: BoxFit.fill, //填充
      gaplessPlayback: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            const SizedBox(height: 30),
            buildUserTextField(), // 输入邮箱
            const SizedBox(height: 30),
            buildPasswordTextField(context), // 输入密码
            const SizedBox(height: 30),
            buildUserCaptchaTextField(context), // 验证码
            buildForgetPasswordText(context),
            const SizedBox(height: 50),
            buildLoginButton(context), // 登录按钮
            const SizedBox(height: 30),
            buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }
}
