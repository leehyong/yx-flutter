import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:yx/routes/app_pages.dart';

import '../types.dart';

class UserInfo{
  final String username;
  final Int64 userId;
  final Int64 orgId;
  final String orgName;
  final List<String> roles;
  final List<String> permissions;
  UserInfo({
    required this.username,
    required this.userId,
    required this.orgId,
    required this.orgName,
    required this.roles,
    required this.permissions,
});
}

class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final _storage = GetStorage(userStorage);

  final _accessToken = ''.obs;
  final _refreshToken = ''.obs;
  final _user = (null as UserInfo?).obs;

  @override
  void onInit() {
    super.onInit();
    _accessToken.value = _storage.read(accessStorageKey) ?? '';
    _refreshToken.value = _storage.read(refreshStorageKey) ?? '';
    _user.value = _storage.read(userStorageKey);
  }

  String get accessToken {
    var access = _accessToken.value;
    if (access.isEmpty) {
      access = _storage.read(accessStorageKey) ?? '';
    }
    return access.isNotEmpty ? 'Bearer $access' : '';
  }

  String get refreshToken {
    var refresh = _refreshToken.value;
    if (refresh.isEmpty) {
      refresh = _storage.read(refreshStorageKey) ?? '';
    }
    return refresh;
  }

  UserInfo? get user {
    if (_user.value == null) {
      _user.value = _storage.read(userStorageKey);
    }
    return _user.value;
  }

  bool get isLoggedInValue =>
      // accessToken.isNotEmpty && refreshToken.isNotEmpty && user.isNotEmpty;
      accessToken.isNotEmpty;

  bool get isWeak => false;

  void setLoginInfo(String token, String refreshToken, UserInfo? user) {
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
    _user.value = null;
  }

  void logout() {
    resetLoginInfo();
    _storage.remove(userStorageKey);
    _storage.remove(accessStorageKey);
    _storage.remove(refreshStorageKey);
    Get.offAndToNamed(Routes.login);
  }
}
