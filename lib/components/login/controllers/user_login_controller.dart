import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/api/user_api.dart' as user_api;
import 'package:yx/types.dart';

class UserLoginController extends GetxController {
  // var user = ''.obs;
  // var pwd = ''.obs;
  final showPwd = false.obs;
  final captcha = ''.obs;
  final sendingCaptcha = DataLoadingStatus.none.obs;

  final pwdEditingController = TextEditingController();
  final userEditingController = TextEditingController();
  final captchaEditingController = TextEditingController();
  final userFocusNode = FocusNode();
  final GlobalKey userFieldKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey formKey = GlobalKey<FormState>();
  static RegExp userReg = RegExp(r"^[a-zA-Z][a-zA-Z0-9_\-@#]{4,}");

  static String userRegErrorTxt =
      "请输入不包括中文的至少5个字符的用户名";

  // static String pwdRegErrorTxt = "请输入至少6个字符的密码";
  static String pwdRegErrorTxt = "请输入至少6位字符的密码";

  static UserLoginController get to => Get.find();

  // @override
  // void onInit() {
  //   super.onInit();
  //   // 只执行一次自动获取验证码， 后续验证码获取需要手动点击获取
  //   once(
  //     captcha,
  //     (event) {
  //       sendCaptchaAction();
  //     },
  //     condition:
  //         userEditingController.text.isNotEmpty &&
  //         pwdEditingController.text.isNotEmpty &&
  //         captcha.value.isEmpty,
  //   );
  // }

  sendCaptchaAction() async {
    captcha.value = '';
    sendingCaptcha.value = DataLoadingStatus.loading;
    var res = await user_api.getCaptchaCode(
      userEditingController.text,
      userCaptchaCode,
    );
    sendingCaptcha.value = DataLoadingStatus.loaded;
    if (res.isNotEmpty) {
      final parts = res.split("::");
      final cap = parts.length == 2 ? parts[1] : parts[0];
      captcha.value = cap.split(",")[1];
    }
    // sendingCaptcha.value = false;
  }

  Future<String> login() async => user_api.login(
    userEditingController.text,
    pwdEditingController.text,
    captchaEditingController.text,
  );

  @override
  void onClose(){
    super.onClose();
    userEditingController.dispose();
    pwdEditingController.dispose();
    captchaEditingController.dispose();
    userFocusNode.dispose();
  }

  bool get isValidInput {
    final state = formKey.currentState as FormState;
    return state.validate();
  }
}
