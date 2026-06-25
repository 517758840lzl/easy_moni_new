import 'dart:async';
import 'package:easy_moni/core/utils/app_logger.dart';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/login/providers/auth_provider.dart';
import 'package:easy_moni/pages/login/widgets/permissionalert.dart';
import 'package:easy_moni/services/auth_storage.dart';
import 'package:easy_moni/services/permission_storage.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/services/saved_session_route_service.dart';
import 'package:easy_moni/services/upload_data/upload_data_sync_service.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PermissionPage extends ConsumerStatefulWidget {
  const PermissionPage({super.key});

  @override
  ConsumerState<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends ConsumerState<PermissionPage> {
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    _checkAgreedStatus();
  }

  Future<void> _checkAgreedStatus() async {
    final privacyAgreed = await PermissionStorage.isPrivacyAgreed();
    final permissionsAccepted = await PermissionStorage.isPermissionsAccepted();

    if (!mounted) return;

    if (privacyAgreed && permissionsAccepted) {
      // Permissions are already accepted, so route by saved token state.
      unawaited(_runPrivacyAwareStartupSync());
      await _routeAfterPermissionsAccepted();
    } else {
      setState(() {
        _isAgreed = true;
      });
    }
  }

  Future<void> _routeAfterPermissionsAccepted() async {
    final route = await ref
        .read(savedSessionRouteServiceProvider)
        .resolveSavedSessionRoute();
    if (!mounted) return;

    if (route != null) {
      context.go(route);
    } else {
      context.go(AppRoutePaths.login);
    }
  }

  /// 用户接受授权后，后台静默采集风控所需数据，不阻塞后续页面跳转。
  void _startSilentPermissionDataCollection() {
    unawaited(
      SilentPermissionDataService.collect()
          .then((data) {
            AppLogger.debug('静默权限数据采集完成: $data');
          })
          .catchError((Object error, StackTrace stackTrace) {
            AppLogger.debug('静默权限数据采集异常: $error\n$stackTrace');
          }),
    );
  }

  /// 用户同意隐私政策后，依次拉起系统权限弹窗；无论授权结果如何都继续后续流程。
  Future<void> _requestRequiredNativePermissions() async {
    final permissionRequests = <Future<bool> Function()>[
      CameraService.requestPermission,
      SmsService.requestPermission,
      LocationService.requestPermission,
    ];

    for (final requestPermission in permissionRequests) {
      try {
        await requestPermission();
      } catch (error, stackTrace) {
        AppLogger.debug('原生权限请求异常: $error\n$stackTrace');
      }

      if (!mounted) return;
    }
  }

  void _onAccept() {
    PrivacyPolicyDialog.show(
      context: context,
      onAgree: () async {
        // 保存用户同意状态
        await PermissionStorage.setPrivacyAgreed(true);
        if (!mounted) return;

        // 关掉隐私确认弹窗
        Navigator.of(context).pop();

        await _requestRequiredNativePermissions();
        if (!mounted) return;

        await PermissionStorage.setPermissionsAccepted(true);
        if (!mounted) return;

        _startSilentPermissionDataCollection();
        unawaited(_runPrivacyAwareStartupSync());

        // 跳转到下一页面
        if (mounted) {
          await _routeAfterPermissionsAccepted();
        }
      },
      onDecline: () {
        SystemNavigator.pop(); // 拒绝就退出
      },
    );
  }

  /// 隐私同意后执行启动阶段数据有效性检查，并按需触发非阻塞上传。
  Future<void> _runPrivacyAwareStartupSync() async {
    final checkUploadDataValidApi = ref.read(checkUploadDataValidProvider);
    final uploadDataSyncService = ref.read(uploadDataSyncServiceProvider);

    final privacyAgreed = await PermissionStorage.isPrivacyAgreed();
    if (!privacyAgreed) return;

    final savedToken = await AuthStorage.getToken();
    if (savedToken == null || savedToken.isEmpty) return;

    try {
      HttpProvider.instance.restoreToken(savedToken);
      final checkDataResult = await checkUploadDataValidApi.call();
      if (checkDataResult.isSuccess) {
        AppLogger.debug(
          'startup checkUploadDataValid 成功: ${checkDataResult.data}',
        );
        uploadDataSyncService.handleCheckResult(checkDataResult.data);
      } else {
        AppLogger.debug(
          'startup checkUploadDataValid 失败: ${checkDataResult.message}',
        );
      }
    } catch (error, stackTrace) {
      AppLogger.debug('startup checkUploadDataValid 请求异常: $error\n$stackTrace');
    }
  }

  void _onReject() {
    AppLogger.debug('点击了拒绝按钮');
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // 如果还没检查完同意状态，显示加载中
    if (!_isAgreed) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.images.loginBg.provider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Padding(
                        // AppTheme.TextTheme.te
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                AppStrings.appinstrunctions,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          AppStrings.appdiscrptions,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // 白色底色和显示区域 - 用ClipRRect确保圆角生效
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildPermissionItem(
                              icon: Assets.images.takepicture.image(
                                width: 48,
                                height: 48,
                              ),
                              title: AppStrings.messageReceive,
                              description: AppStrings.messageReceiveDetail,
                            ),
                            _buildPermissionItem(
                              icon: Assets.images.message.image(
                                width: 48,
                                height: 48,
                              ),
                              title: AppStrings.gainLocation,
                              description: AppStrings.gainLocationDetail,
                            ),
                            _buildPermissionItem(
                              icon: Assets.images.location.image(
                                width: 48,
                                height: 48,
                              ),
                              title: AppStrings.carema,
                              description: AppStrings.caremaDetail,
                            ),
                            _buildPermissionItem(
                              icon: Assets.images.moban.image(
                                width: 48,
                                height: 48,
                              ),
                              title: AppStrings.installAppData,
                              description: AppStrings.installAppDataDetail,
                            ),
                            _buildPermissionItem(
                              icon: Assets.images.biaoqian.image(
                                width: 48,
                                height: 48,
                              ),
                              title: AppStrings.deviceinformation,
                              description: AppStrings.deviceInformationDetail,
                            ),
                            _buildPermissionItem(
                              icon: Assets.images.dotss.image(
                                width: 48,
                                height: 48,
                              ),
                              title: AppStrings.campaign,
                              description: AppStrings.campaignDetail,
                              showDivider: false,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 底部 吸底：隐私提示 + 按钮
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 隐私提示- 吸底
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          children: [
                            Assets.images.loginSetting.image(
                              width: 15,
                              height: 15,
                            ),
                            const SizedBox(width: 13),
                            const Expanded(
                              child: Text(
                                AppStrings.receiveData,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF3C4A3D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),
                      // 底部操作按钮组，按设计稿保持 40px 高度和 14px 间距。
                      PermissionActionButtons(
                        secondaryText: AppStrings.decline,
                        primaryText: AppStrings.receives,
                        onSecondaryPressed: _onReject,
                        onPrimaryPressed: _onAccept,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required Widget icon,
    required String title,
    required String description,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
            ), // 限制左右两边为 24 像素
            child: const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider,
            ),
          ),
      ],
    );
  }
}
