import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/app_router.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/pages/login/providers/auth_provider.dart';
import 'package:easy_moni/services/auth_storage.dart';
import 'package:easy_moni/utils/widgets/toast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final talker = AppLogger.instance;
  HttpProvider.init(talker: talker);

  final savedToken = await AuthStorage.getToken();
  if (savedToken != null && savedToken.isNotEmpty) {
    await HttpProvider.instance.setToken(savedToken);
    await _checkUploadDataValidOnStartup();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(
      EasyToast(
        child: ProviderScope(
          observers: [
            TalkerRiverpodObserver(
              talker: talker,
              settings: const TalkerRiverpodLoggerSettings(
                printProviderDisposed: true,
              ),
            ),
          ],
          child: const MainApp(),
        ),
      ),
    );
  });
}

// App 启动恢复登录态后，检查本地采集数据是否仍然有效。
Future<void> _checkUploadDataValidOnStartup() async {
  try {
    final checkDataResult = await CheckUploadDataValidApi().call();
    if (checkDataResult.isSuccess) {
      AppLogger.debug(
        'startup checkUploadDataValid 成功: ${checkDataResult.data}',
      );
    } else {
      AppLogger.debug(
        'startup checkUploadDataValid 失败: ${checkDataResult.message}',
      );
    }
  } catch (e) {
    AppLogger.debug('startup checkUploadDataValid 请求异常: $e');
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
