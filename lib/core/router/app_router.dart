import 'package:easy_moni/pages/fillInforma/contact_info_page.dart';
import 'package:easy_moni/pages/fillInforma/face_verify_page.dart';
import 'package:easy_moni/pages/fillInforma/id_camera_page.dart';
import 'package:easy_moni/pages/fillInforma/identity_verify_page.dart';
import 'package:easy_moni/pages/fillInforma/questionnaire_page.dart';
import 'package:easy_moni/pages/loan/loan_confirm_page.dart';
import 'package:easy_moni/pages/loan/loan_order_detail_page.dart';
import 'package:easy_moni/pages/loan/loan_reviewing_page.dart';
import 'package:easy_moni/pages/loan/models/loan_confirm_request_product.dart';
import 'package:easy_moni/pages/loan/models/loan_order_detail_data.dart';
import 'package:easy_moni/entities/repay/repay_resp.dart';
import 'package:easy_moni/pages/mine/detailpage.dart';
import 'package:easy_moni/pages/mine/mine.dart';
import 'package:easy_moni/pages/repay/repay_entry_page.dart';
import 'package:easy_moni/pages/repay/repay_extension_page.dart';
import 'package:easy_moni/pages/repay/models/repay_extension_request_data.dart';
import 'package:easy_moni/pages/repay/repay_order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/pages/login/customer_service_page.dart';
import 'package:easy_moni/pages/login/permissionpage.dart';
import 'package:easy_moni/pages/login/loginpage.dart';
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
        name: AppRouteNames.home,
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
        builder: (context, state) => const HomeShell(),
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
          final bill = state.extra as RepayResp?;
          if (bill == null) {
            return const Scaffold(body: SizedBox.shrink());
          }
          return RepayOrderDetailPage(bill: bill);
        },
      ),
      GoRoute(
        path: AppRoutePaths.repayExtension,
        name: AppRouteNames.repayExtension,
        builder: (context, state) {
          final requestData = state.extra as RepayExtensionRequestData?;
          if (requestData == null) {
            return const Scaffold(body: SizedBox.shrink());
          }
          return RepayExtensionPage(requestData: requestData);
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
        path: AppRoutePaths.detail,
        name: AppRouteNames.detail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: DetailPage(id: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return _buildSlideTransition(animation, child);
                },
          );
        },
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

Widget _buildSlideTransition(Animation<double> animation, Widget child) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeOutCubic;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(position: offsetAnimation, child: child);
}
