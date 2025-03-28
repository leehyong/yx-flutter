import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _storage = GetStorage();

  final accessToken = ''.obs;
  final refreshToken = ''.obs;
  final user = ''.obs;

  @override
  void onInit() {
    super.onInit();
    accessToken.value = _storage.read("accessToken") ?? '';
    refreshToken.value = _storage.read("refreshToken") ?? '';
    user.value = _storage.read("user") ?? '';
  }

  bool get isLoggedInValue =>
      accessToken.value.isNotEmpty &&
      refreshToken.value.isNotEmpty &&
      user.value.isNotEmpty;

  bool get isWeak => false;

  void setLoginInfo(String token, String refreshToken, String user) {
    accessToken.value = token;
    this.refreshToken.value = refreshToken;
    this.user.value = user;
    // 把数据写入文件
    _storage.write("accessToken", accessToken.value);
    _storage.write("refreshToken", refreshToken);
    _storage.write("user", user);
  }

  void resetLoginInfo() {
    accessToken.value = '';
    refreshToken.value = '';
    user.value = '';
  }

  void login() {
    // isLoggedIn.value = true;
  }

  void logout() {
    // isLoggedIn.value = false;
  }
}
