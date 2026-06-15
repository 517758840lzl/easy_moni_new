/// 应用运行环境名称，避免在业务代码里散落字符串判断。
class AppEnvironment {
  AppEnvironment._();

  static const String test = 'test';
  static const String production = 'production';

  static const String currentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: production,
  );

  static bool get isTest => currentName == test;
}
