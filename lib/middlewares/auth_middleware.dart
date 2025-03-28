import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../routes/app_pages.dart';

class EnsureAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route){
    // 没有登录， 则跳转到登录页
    if (!AuthService.to.isLoggedInValue && route != Routes.login){
      return RouteSettings(name: Routes.login, arguments: {});
    }else if( route == Routes.app){
      if (AuthService.to.isWeak) {
        // 需要修改密码
        return RouteSettings(name: Routes.changePwd, arguments: {});
      }
    }
    return null;
    // you can do whatever you want here
    // but it's preferable to make this method fast
    // await Future.delayed(Duration(milliseconds: 500));
    // return   RouteSettings(name: route, arguments: {});
    // if (!AuthService.to.isLoggedInValue) {
    //   final newRoute = Routes.LOGIN_THEN(route.currentPage?.name ?? Routes.login);
    //   return GetNavConfig.fromRoute(newRoute);
    // }
    // return await super.redirectDelegate(route);
  }
}

class EnsureNotAuthedMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route){
    return null;
    // if (AuthService.to.isLoggedInValue) {
    //   //NEVER navigate to auth screen, when user is already authed
    //   return null;
    //
    //   //OR redirect user to another screen
    //   //return RouteDecoder.fromRoute(Routes.PROFILE);
    // }
    // return await super.redirectDelegate(route);
  }
}