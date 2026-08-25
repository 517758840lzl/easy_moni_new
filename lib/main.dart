import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/app_router.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/utils/widgets/toast.dart';

/// 绿色顶栏页面默认使用白色状态栏内容；带 AppBar 的白底页仍由 theme 覆盖为深色。
const SystemUiOverlayStyle _defaultSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarIconBrightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final talker = AppLogger.instance;
  HttpProvider.init(talker: talker);

  SystemChrome.setSystemUIOverlayStyle(_defaultSystemUiOverlayStyle);
  // 方向锁定
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ProviderScope(
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
  );
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
        // Toast 的 Overlay 需要位于 MaterialApp 本地化上下文内，避免文本选择工具栏缺少 MaterialLocalizations。
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _defaultSystemUiOverlayStyle,
          child: EasyToast(
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child ?? const SizedBox(),
            ),
          ),
        );
      },
    );
  }
}
