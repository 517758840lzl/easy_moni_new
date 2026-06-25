import 'package:easy_moni/pages/fillInforma/contact_info_page.dart';
import 'package:easy_moni/pages/fillInforma/face_verify_entry_page.dart';
import 'package:easy_moni/pages/fillInforma/face_verify_page.dart';
import 'package:easy_moni/pages/fillInforma/id_camera_page.dart';
import 'package:easy_moni/pages/fillInforma/identity_verify_page.dart';
import 'package:easy_moni/pages/fillInforma/questionnaire_page.dart';
import 'package:easy_moni/pages/loan/loan_confirm_page.dart';
import 'package:easy_moni/pages/loan/loan_order_detail_page.dart';
import 'package:easy_moni/pages/loan/loan_reviewing_page.dart';
import 'package:easy_moni/pages/loan/models/loan_confirm_request_product.dart';
import 'package:easy_moni/pages/loan/models/loan_order_detail_data.dart';
import 'package:easy_moni/pages/mine/customer_service_page.dart';
import 'package:easy_moni/pages/mine/mine_order_history_page.dart';
import 'package:easy_moni/pages/mine/mine_page.dart';
import 'package:easy_moni/pages/mine/privacy_policy_page.dart';
import 'package:easy_moni/pages/mine/settings_page.dart';
import 'package:easy_moni/entities/repay/repay_detail_resp.dart';
import 'package:easy_moni/pages/repay/repay_entry_page.dart';
import 'package:easy_moni/pages/repay/payment_page.dart';
import 'package:easy_moni/pages/repay/models/payment_request_params.dart';
import 'package:easy_moni/pages/repay/repay_extension_page.dart';
import 'package:easy_moni/pages/repay/models/repay_extension_request_data.dart';
import 'package:easy_moni/pages/repay/models/repay_multi_order_detail_request_data.dart';
import 'package:easy_moni/pages/repay/models/repay_order_detail_request_data.dart';
import 'package:easy_moni/pages/repay/repay_multi_order_detail_page.dart';
import 'package:easy_moni/pages/repay/repay_order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/pages/login/permission_page.dart';
import 'package:easy_moni/pages/login/splash_page.dart';
import 'package:easy_moni/pages/login/login_page.dart';
import 'package:easy_moni/pages/home/homesell.dart';
import 'package:easy_moni/pages/fillInforma/personal_info_page.dart'
    as fill_info;

final globalNavigationKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: globalNavigationKey,
    initialLocation: AppRoutePaths.root,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutePaths.root,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutePaths.permission,
        name: AppRouteNames.permission,
        builder: (context, state) => const PermissionPage(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePaths.customerService,
        name: AppRouteNames.customerService,
        builder: (context, state) => const CustomerServicePage(),
      ),
      GoRoute(
        path: AppRoutePaths.home,
        name: AppRouteNames.homeShell,
        builder: (context, state) {
          final initialTab =
              state.uri.queryParameters['tab'] ?? AppHomeTabs.loan;
          final tabRequestId = state.uri.queryParameters['tabRequestId'] ?? '';
          final loanHomeRefreshRequestId =
              state.uri.queryParameters['loanHomeRefreshRequestId'] ?? '';
          return HomeShell(
            initialTab: initialTab,
            tabRequestId: tabRequestId,
            loanHomeRefreshRequestId: loanHomeRefreshRequestId,
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.idCamera,
        name: AppRouteNames.idCamera,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isFront = extra?['isFront'] as bool? ?? true;
          return IdCameraScreen(isFront: isFront);
        },
      ),
      GoRoute(
        path: AppRoutePaths.repayEntry,
        name: AppRouteNames.repayEntry,
        builder: (context, state) => const RepayEntryPage(),
      ),
      GoRoute(
        path: AppRoutePaths.repayOrderDetail,
        name: AppRouteNames.repayOrderDetail,
        builder: (context, state) {
          final appOrderIds = _queryList(state, 'appOrderIds');
          if (appOrderIds.isEmpty) {
            return const _MissingRepayRouteParamsPage();
          }
          return RepayOrderDetailPage(
            requestData: RepayOrderDetailRequestData(appOrderIds: appOrderIds),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.repayMultiOrderDetail,
        name: AppRouteNames.repayMultiOrderDetail,
        builder: (context, state) {
          final appOrderIds = _queryList(state, 'appOrderIds');
          if (appOrderIds.isEmpty) {
            return const _MissingRepayRouteParamsPage();
          }
          return RepayMultiOrderDetailPage(
            requestData: RepayMultiOrderDetailRequestData(
              appOrderIds: appOrderIds,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.repayExtension,
        name: AppRouteNames.repayExtension,
        builder: (context, state) {
          final requestData = _typedExtra<RepayExtensionRequestData>(state);
          if (requestData != null) {
            return RepayExtensionPage(requestData: requestData);
          }

          final fallbackRequestData = _repayExtensionRequestFromQuery(state);
          if (fallbackRequestData == null) {
            return const _MissingRepayRouteParamsPage();
          }
          return RepayExtensionPage(requestData: fallbackRequestData);
        },
      ),
      GoRoute(
        path: AppRoutePaths.payment,
        name: AppRouteNames.payment,
        builder: (context, state) {
          final requestParams = _typedExtra<PaymentRequestParams>(state);
          if (requestParams == null) {
            return const _MissingRepayRouteParamsPage();
          }
          return PaymentPage(requestParams: requestParams);
        },
      ),
      GoRoute(
        path: AppRoutePaths.loanConfirm,
        name: AppRouteNames.loanConfirm,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rawProducts = extra?['products'];
          final products = rawProducts is List<LoanConfirmRequestProduct>
              ? rawProducts
              : const <LoanConfirmRequestProduct>[];
          return LoanConfirmPage(products: products);
        },
      ),
      GoRoute(
        path: AppRoutePaths.loanOrderDetail,
        name: AppRouteNames.loanOrderDetail,
        builder: (context, state) {
          final data = state.extra as LoanOrderDetailData?;
          if (data == null) {
            return const Scaffold(body: SizedBox.shrink());
          }
          return LoanOrderDetailPage(data: data);
        },
      ),
      GoRoute(
        path: AppRoutePaths.loanReviewing,
        name: AppRouteNames.loanReviewing,
        builder: (context, state) => const LoanReviewingPage(),
      ),
      GoRoute(
        path: AppRoutePaths.contactInfo,
        name: AppRouteNames.contactInfo,
        builder: (context, state) => const ContactInfoPage(),
      ),
      GoRoute(
        path: AppRoutePaths.personalInfo,
        name: AppRouteNames.personalInfo,
        builder: (context, state) => const fill_info.PersonalInfoPage(),
      ),
      GoRoute(
        path: AppRoutePaths.identityVerify,
        name: AppRouteNames.identityVerify,
        builder: (context, state) => const IdentityVerifyPage(),
      ),
      GoRoute(
        path: AppRoutePaths.faceVerify,
        name: AppRouteNames.faceVerify,
        builder: (context, state) => const FaceVerifyEntryPage(),
      ),
      GoRoute(
        path: AppRoutePaths.faceVerifyCapture,
        name: AppRouteNames.faceVerifyCapture,
        builder: (context, state) => const FaceVerifyPage(),
      ),
      GoRoute(
        path: AppRoutePaths.questionnaire,
        name: AppRouteNames.questionnaire,
        builder: (context, state) => const QuestionnairePage(),
      ),
      GoRoute(
        path: AppRoutePaths.mine,
        name: AppRouteNames.mine,
        builder: (context, state) => const MinePage(),
      ),
      GoRoute(
        path: AppRoutePaths.orderHistory,
        name: AppRouteNames.orderHistory,
        builder: (context, state) => const MineOrderHistoryPage(),
      ),
      GoRoute(
        path: AppRoutePaths.privacyPolicy,
        name: AppRouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: AppRoutePaths.settings,
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutePaths.root),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// 安全读取路由 extra，避免类型不匹配导致路由构建异常。
T? _typedExtra<T>(GoRouterState state) {
  final extra = state.extra;
  return extra is T ? extra : null;
}

/// 从 query 中解析逗号分隔的列表参数。
List<String> _queryList(GoRouterState state, String key) {
  final rawValue = state.uri.queryParameters[key];
  if (rawValue == null || rawValue.trim().isEmpty) {
    return const <String>[];
  }

  return rawValue
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
}

/// 从 query 中解析正整数参数。
int? _queryInt(GoRouterState state, String key) {
  final rawValue = state.uri.queryParameters[key];
  if (rawValue == null || rawValue.trim().isEmpty) return null;
  final value = int.tryParse(rawValue.trim());
  if (value == null || value <= 0) return null;
  return value;
}

/// 从展期 query 入口构造最小页面入参，支持页面恢复和外部链接直达。
RepayExtensionRequestData? _repayExtensionRequestFromQuery(
  GoRouterState state,
) {
  final appOrderId = state.uri.queryParameters['appOrderId']?.trim() ?? '';
  final productCode = state.uri.queryParameters['productCode']?.trim() ?? '';
  final installmentId = _queryInt(state, 'installmentId');

  if (appOrderId.isEmpty || installmentId == null) return null;

  return RepayExtensionRequestData(
    loanOrderDetails: [
      RepayDetailRespDataLoanOrderDetails(
        appOrderId: appOrderId,
        productCode: productCode,
        installmentId: installmentId,
      ),
    ],
  );
}

/// 还款流程缺少必要路由参数时的兜底页，避免用户看到纯白屏。
class _MissingRepayRouteParamsPage extends StatelessWidget {
  const _MissingRepayRouteParamsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.repayDetailTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 48,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.orderDetailMissingRouteParams,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111827),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go(AppRoutePaths.repayEntry),
                child: const Text(AppStrings.orderDetailBackToRepayEntry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
