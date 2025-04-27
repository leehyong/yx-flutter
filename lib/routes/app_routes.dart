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

abstract class WorkTaskRoutes {
  static const hallList = '/hall';
  static const hallTaskDetail = '/hall/task/detail';
  static const hallTaskPublish = '/hall/task/publish';

  static const homeList = '/home';
  static const homeTaskSubmit = '/home/task/submit';
  static const homeTaskDetail = '/home/task/detail';
}