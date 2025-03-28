import 'package:get/get.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final accessToken = ''.obs;
  final refreshToken = ''.obs;
  final user = ''.obs;

  /// Mocks a login process
  final isLoggedIn = false.obs;

  bool get isLoggedInValue => accessToken.value.isNotEmpty;

  bool get isWeak => false;

  void setLoginInfo(String token, String refreshToken, String user) {
    accessToken.value = token;
    this.refreshToken.value = refreshToken;
    this.user.value = user;
  }

  void resetLoginInfo() {
    accessToken.value = '';
    refreshToken.value = '';
    user.value = '';
  }

  void login() {
    isLoggedIn.value = true;
  }

  void logout() {
    isLoggedIn.value = false;
  }
}
