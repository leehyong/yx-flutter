import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yx/routes/app_pages.dart';

import '../types.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final _storage = GetStorage(userStorage);

  final _accessToken = ''.obs;
  final _refreshToken = ''.obs;
  final _user = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _accessToken.value = _storage.read(accessStorageKey) ?? '';
    _refreshToken.value = _storage.read(refreshStorageKey) ?? '';
    _user.value = _storage.read(userStorageKey) ?? '';
  }

  String get accessToken {
    var access = _accessToken.value;
    if (access.isEmpty) {
      access = _storage.read(accessStorageKey) ?? '';
    }
    return access;
  }

  String get refreshToken {
    var refresh = _refreshToken.value;
    if (refresh.isEmpty) {
      refresh = _storage.read(refreshStorageKey) ?? '';
    }
    return refresh;
  }

  String get user {
    var user = _user.value;
    if (user.isEmpty) {
      user = _storage.read(userStorageKey) ?? '';
    }
    return user;
  }

  bool get isLoggedInValue =>
      accessToken.isNotEmpty && refreshToken.isNotEmpty && user.isNotEmpty;

  bool get isWeak => false;

  void setLoginInfo(String token, String refreshToken, String user) {
    _accessToken.value = token;
    _refreshToken.value = refreshToken;
    _user.value = user;
    // 把数据写入文件
    _storage.write(accessStorageKey, token);
    _storage.write(refreshStorageKey, refreshToken);
    _storage.write(userStorageKey, user);
  }

  void resetLoginInfo() {
    _accessToken.value = '';
    _refreshToken.value = '';
    _user.value = '';
  }

  void logout() {
    resetLoginInfo();
    _storage.remove(userStorageKey);
    _storage.remove(accessStorageKey);
    _storage.remove(refreshStorageKey);
    Get.offAndToNamed(Routes.login);
  }
}
