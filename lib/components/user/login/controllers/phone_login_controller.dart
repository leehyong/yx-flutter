import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yx/api/user_api.dart' as user_api;
import 'package:yx/types.dart';


class PhoneLoginController extends GetxController {
  var phone = ''.obs;
  var hasPhoneError = false.obs;
  var showPwd = false.obs;
  var captcha = ''.obs;
  var sentCaptcha = false.obs;
  var pwd = ''.obs;
  var hasPwdError = false.obs;
  var sendingCaptcha = false.obs;

  static RegExp pwdReg = RegExp(
    r'^(?:(?=.*[a-z])(?=.*[A-Z])|(?=.*[a-zA-Z])(?=.*\d)|(?=.*[a-zA-Z])(?=.*[\W_])|(?=.*\d)(?=.*[\W_])).{6,}$',
    caseSensitive: true,
  );
  final GlobalKey formKey = GlobalKey<FormState>();
  static String pwdRegErrorTxt = "请输入至少6位字符密码";
  static String captchaErrorTxt = "请输入验证码";

  // static String pwdRegErrorTxt = "请输入至少6个字符的密码";

  static PhoneLoginController get to => Get.find();

  Future<String> sendCaptchaAction() async {
    var res =  await user_api.getCaptchaCode(phone.value, phoneCaptchaCode);
    sentCaptcha.value = res.isEmpty;
    sendingCaptcha.value = false;
    return res;
  }

  Future<String> login() async =>
      user_api.login(phone.value, pwd.value, captcha.value);

  get canSendCaptcha => !(hasPhoneError.value || hasPwdError.value);
}
