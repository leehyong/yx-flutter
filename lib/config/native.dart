import 'package:get/get.dart';

const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
const _appServer = String.fromEnvironment(
  'APP_SERVER',
  defaultValue: 'https://www.yoo.com:18012',
);
const _proxyDevServer = 'https://deeply-included-polecat.ngrok-free.app';

class AppConfig {
  static final apiServer =
      GetPlatform.isMobile
          ? (appEnv == 'dev'
              // 开发环境时，使用ngrok的内网穿透工具来转发本地开发环境的服务
              ? _proxyDevServer
              : _appServer)
          : _appServer;
}


