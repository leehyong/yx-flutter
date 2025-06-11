import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/change_pwd.dart';


class ChangePwdCompView extends GetView<ChangePwdController> {
  const ChangePwdCompView({super.key});

  Widget buildOldPasswordTextField(BuildContext context) {
    return TextFormField(
      obscureText: !controller.showOldPwd.value, // 是否显示文字
      onChanged: (v) => controller.oldPwd.value = v!,
      validator: (v) {
        if (!ChangePwdController.pwdReg.hasMatch(v!)) {
          return ChangePwdController.pwdRegErrorTxt;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "旧密码",
        icon: Icon(Icons.password),

        suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color:
                controller.showOldPwd.value
                    ? Theme.of(context).iconTheme.color
                    : Colors.grey,
          ),
          onPressed: () {
            controller.showOldPwd.value = !controller.showOldPwd.value;
          },
        ),
      ),
    );
  }
  Widget buildNewPasswordTextField(BuildContext context) {
    return TextFormField(
      obscureText: !controller.showNewPwd.value, // 是否显示文字
      onChanged: (v) => controller.newPwd.value = v!,
      validator: (v) {
        if (!ChangePwdController.pwdReg.hasMatch(v!)) {
          return ChangePwdController.pwdRegErrorTxt;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "新密码",
        icon: Icon(Icons.password),

        suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color:
                controller.showNewPwd.value
                    ? Theme.of(context).iconTheme.color
                    : Colors.grey,
          ),
          onPressed: () {
            controller.showNewPwd.value = !controller.showNewPwd.value;
          },
        ),
      ),
    );
  }
  Widget buildCheckPasswordTextField(BuildContext context) {
    return TextFormField(
      obscureText: !controller.showCheckPwd.value, // 是否显示文字
      onChanged: (v) => controller.checkPwd.value = v!,
      validator: (v) {
        if (!ChangePwdController.pwdReg.hasMatch(v!)) {
          return ChangePwdController.pwdRegErrorTxt;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "确认密码",
        icon: Icon(Icons.password),

        suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color:
                controller.showCheckPwd.value
                    ? Theme.of(context).iconTheme.color
                    : Colors.grey,
          ),
          onPressed: () {
            controller.showCheckPwd.value = !controller.showCheckPwd.value;
          },
        ),
      ),
    );
  }

  Widget buildConfirmButton(BuildContext context) {
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
          child: Text('确定', style: TextStyle(fontSize: 24)),
          onPressed: () async {
            var state = controller.formKey.currentState as FormState;
            if (state.validate()) {
              var res = await  controller.changePwd();
              if (res.isEmpty) {
                Get.offAndToNamed("/");
              }
              // 执行确认方法
              // AuthService.to.login();
              // var res = await  controller.login();
              // if (res) {
              //   Get.offAndToNamed("/");
              // }
            }
          },
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
            buildOldPasswordTextField(context), // 输入密码
            const SizedBox(height: 30),
            buildNewPasswordTextField(context), // 输入密码
            const SizedBox(height: 30),
            buildCheckPasswordTextField(context), // 输入密码
            const SizedBox(height: 50),
            buildConfirmButton(context), // 登录按钮
            const SizedBox(height: 30),
            // buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }
}
