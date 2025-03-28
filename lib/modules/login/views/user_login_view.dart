import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/auth_service.dart';
import '../controllers/user_login_controller.dart';

class UserLoginView extends GetView<UserLoginController> {
  const UserLoginView({super.key});

  Widget buildUserTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '用户名'),
      validator: (v) {
        if (!UserLoginController.userReg.hasMatch(v!)) {
          return UserLoginController.userRegErrorTxt;
        }
        return null;
      },
      onSaved: (v) => controller.user.value = v!,
    );
  }

  Widget buildPasswordTextField(BuildContext context) {
    return TextFormField(
      obscureText: !controller.showPwd.value, // 是否显示文字
      onSaved: (v) => controller.pwd.value = v!,
      validator: (v) {
        if (!UserLoginController.pwdReg.hasMatch(v!)) {
          return UserLoginController.pwdRegErrorTxt;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "密码",
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
          child: Text('登录', style: TextStyle(fontSize: 24)),
          onPressed: () {
            var state = controller.formKey.currentState as FormState;
            // 表单校验通过才会继续执行
            if (state.validate()) {
              state.save();
              AuthService.to.login();
              Get.offAndToNamed("/");
              //TODO 执行登录方法
              // if (kDebugMode) {
              print(
                'email: ${controller.user.value}, password:  ${controller.pwd.value}',
              );
              // }
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
      onSaved: (v) => controller.captcha.value = v!,
      decoration: InputDecoration(
        labelText: "验证码",
        icon: Icon(Icons.text_fields),
        suffixIcon: InkWell(
          onTap: () {
            if (controller.user.value.isNotEmpty) {
              controller.sentCaptcha.value = true;
            }
          },
          child: Image.memory(
            base64.decode(
              "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEYAAAAjCAIAAACmdes6AAACP0lEQVR4Xu2W0U3EQAxETxSA+OMnFdAL30AV1EUproB2SGJwhpldZ7MJEBDSfCT22Ot3vj3dxV5f/pguGvrt+kf6Mg2P9xrs01mQbKY6BOxESK79YKdDcu0BOwype4JEfT1PjWRd6zo7kmsTWCvSzfXzKAo+PdyFxiPxVW2X26ui0KlZ9DSC7UJyIZJmyaaDqnLPKlgTkvPUkGweN7akWTd4Kpk1lHgCJqFaR3KSHMnmM3Ikf0jGDSUeJKmt63gkpcJgMm4o8SiDgq0gBcYmJKSi12TcRo9SeTDiGVIweEGO5DZC0qWNg+rnSgokdPqzCgv9tYpEaxmfa41CHsddEY9VxtU+dBZFsFBTGRK9YqTW3T4jUU+TLxV1QE/xiCjRqqVcQyY8HtGgS89uQUJ5bTGoo+txfISGiqMnSCE8bKj8psfEtfLw1Ob+biSDFRXPTpCiyTBvTGvJU0yZIsXcVNaIhJvBS4V4OZLBr2Jt7iQ1leOLz03C7hHURvaBhBG9VKvjuie31eLv5fiiPAme9kqQIk5fvGIrvUtkS2aYyjVUlC4H8RymeAZRrd6l8OjcRFg8bip3hyZIioSi26LZQ5BctfhSHj7NoRKkGDeaIN7w+b/ffiTsr6mpPEyaQ21CIiFeICVUhERtMYjZeFjuUm0glyLhZ+/SDrofxUM/AqMNq9zpDxhf/NgxCvq0tZxGqWW10LMa9PhPIpEIrw/J9Ec8sbZoZ3mI8FS1uJ0Wyda25AYNmiIl1hbtqSV1I70B+dAU/4dAw64AAAAASUVORK5C"
                  .split(",")[1],
            ),
            height: 30, //设置高度
            width: 100, //设置宽度
            fit: BoxFit.fill, //填充
            gaplessPlayback: true,
          ),
        ),
      ),
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
