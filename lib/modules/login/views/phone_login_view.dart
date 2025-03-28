import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:yx/modules/login/controllers/phone_login_controller.dart';

class PhoneLoginView extends GetView<PhoneLoginController> {
  const PhoneLoginView({super.key});

  Widget buildPhoneTextField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: '手机号',
        icon: Icon(Icons.phone),
      ),
      validator: (v) {
        if (!PhoneLoginController.phoneReg.hasMatch(v!)) {
          controller.hasPhoneError.value = true;
          return PhoneLoginController.phoneRegErrorTxt;
        }
        controller.hasPhoneError.value = false;
        return null;
      },
      onChanged: (v) => controller.phone.value = v!,
    );
  }

  // Widget buildPasswordTextField(BuildContext context) {
  //   return TextFormField(
  //     obscureText: !controller.showPwd.value, // 是否显示文字
  //     onChanged: (v) => controller.pwd.value = v!,
  //     validator: (v) {
  //       if (!PhoneLoginController.pwdReg.hasMatch(v!)) {
  //         return PhoneLoginController.pwdRegErrorTxt;
  //       }
  //       return null;
  //     },
  //     decoration: InputDecoration(
  //       labelText: "密码",
  //       icon: Icon(Icons.password),
  //
  //       suffixIcon: IconButton(
  //         icon: Icon(
  //           Icons.remove_red_eye,
  //           color:
  //               controller.showPwd.value
  //                   ? Theme.of(context).iconTheme.color
  //                   : Colors.grey,
  //         ),
  //         onPressed: () {
  //           controller.showPwd.value = !controller.showPwd.value;
  //         },
  //       ),
  //     ),
  //   );
  // }

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
          onPressed: () async {
            var state = controller.formKey.currentState as FormState;
            // 表单校验通过才会继续执行
            if (!state.validate()) {
              return;
            }
            var res = await controller.login();
            if (res.isEmpty) {
              Get.offAndToNamed("/");
            }
            // Get.offAndToNamed("/");
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
  Widget buildPhoneCaptchaTextField(BuildContext context) {
    return TextFormField(
      onChanged: (v) => controller.captcha.value = v!,
      validator: (v) {
        if (v!.isEmpty) {
          return PhoneLoginController.captchaErrorTxt;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "验证码",
        icon: Icon(Icons.text_fields),
        suffixIcon: ElevatedButton(
          onPressed: () async {
            // 手机号填写正确时才发送验证码
            // if (!controller.hasPhoneError.value){
            if (controller.canSendCaptcha) {
              controller.sendingCaptcha.value = true;
              // var res = controller.sentCaptcha();
              await controller.sendCaptchaAction();
            }
          },
          child:
              !controller.sentCaptcha.value
                  ? Text("发送验证码")
                  : Countdown(
                    seconds: 60,
                    build:
                        (BuildContext context, double time) =>
                            Text(time.toInt().toString().padLeft(3, "0")),
                    interval: Duration(milliseconds: 1000),
                    onFinished: () {
                      controller.sentCaptcha.value = false;
                      controller.sendingCaptcha.value = false;
                      // print('Timer is done!');
                    },
                  ),
          //Icon(Icons.refresh)),
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
            buildPhoneTextField(), // 输入手机
            // const SizedBox(height: 30),
            // buildPasswordTextField(context), // 输入密码
            const SizedBox(height: 30),
            buildPhoneCaptchaTextField(context), // 输入验证码
            const SizedBox(height: 50),
            buildLoginButton(context), // 登录按钮
            const SizedBox(height: 30),
            // buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }
}
