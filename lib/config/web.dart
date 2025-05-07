const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
const _appServer = String.fromEnvironment(
  'APP_SERVER',
  defaultValue: 'https://www.yoo.com:18012',
);

class AppConfig {
  static final apiServer = _appServer;
}


