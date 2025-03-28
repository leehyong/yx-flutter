// ignore_for_file: non_constant_identifier_names
part of 'app_pages.dart';

abstract class Routes {
  static const app = '/';
  static const settings = '/settings';
  static const login = '/login';
  static const changePwd = '/change-pwd';
  static const notFound = '/not-found';

  Routes._();
  static String LOGIN_THEN(String afterSuccessfulLogin) =>
      '$login?then=${Uri.encodeQueryComponent(afterSuccessfulLogin)}';
}