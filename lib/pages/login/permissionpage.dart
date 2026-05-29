import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/login/widgets/permissionalert.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionPage extends ConsumerStatefulWidget {
  const PermissionPage({super.key});

  @override
  ConsumerState<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends ConsumerState<PermissionPage> {
  void _onReject() {
    debugPrint('点击了拒绝按钮');
    SystemNavigator.pop();
  }

  void _onAccept() {
    PrivacyPolicyDialog.show(
      context: context,
      onAgree: () async {
        // 关掉隐私确认弹窗
        Navigator.of(context).pop();

        // 调用你自己写的原生桥接方法
        // bool hasCamera = await CameraService.checkPermission();

        // if (hasCamera) {
        //   debugPrint("原生桥接成功：拿到了相机权限，可以安全跳转登录页");
        //   // Navigator.of(context).pushReplacement();
        // } else {
        //   debugPrint("原生桥接提示：用户拒绝了权限");
        // }
      },
      onDecline: () {
        SystemNavigator.pop(); // 拒绝就退出
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Padding(
                        // AppTheme.TextTheme.te
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    bottom: MediaQuery.of(context).padding.bottom + 16,
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

                      const SizedBox(height: 16),
                      // Action buttons - 吸底
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _onReject,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF268470),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48),
                                ),
                              ),
                              child: const Text(
                                AppStrings.decline,
                                style: TextStyle(
                                  color: Color(0xFF268470),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onAccept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF268470),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: const Text(
                                AppStrings.receives,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
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
