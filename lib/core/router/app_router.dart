import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_moni/pages/login/permissionpage.dart';
import 'package:easy_moni/pages/login/loginpage.dart';
import 'package:easy_moni/entities/user_repayment_resp.dart';
import 'package:easy_moni/pages/home/homesell.dart';

import '../../pages/fillInforma/contact_info_page.dart';
import '../../pages/fillInforma/face_verify_page.dart';
import '../../pages/fillInforma/id_camera_page.dart';
import '../../pages/fillInforma/identity_verify_page.dart';
import '../../pages/fillInforma/personal_info_page.dart' as fill_info;
import '../../pages/mine/detailpage.dart';
import '../../pages/mine/mine.dart';
import '../../pages/mine/order_history_page.dart';
import '../../pages/mine/order_detail_page.dart';
import '../../pages/repay/extension_apply_page.dart';
import '../../pages/repay/payment_page.dart';
import '../../pages/repay/repay_detail_page.dart';
import '../../pages/repay/repay_entry_page.dart';
import '../../pages/repay/repay_multi_detail_page.dart';
import '../../pages/repay/survey_page.dart';

final globalNavigationKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    navigatorKey: globalNavigationKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const PermissionPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'homeShell',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/idcamera',
        name: 'idcamera',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isFront = extra?['isFront'] as bool? ?? true;
          return IdCameraScreen(isFront: isFront);
        },
      ),

      GoRoute(
        path: '/order-detail',
        name: 'orderDetail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra != null && extra.containsKey('orders')) {
            return OrderDetailPage(
              orderData: extra['orderData'] as OrderData?,
              orders: extra['orders'] as List<UserRepaymentResp>?,
            );
          }
          return OrderDetailPage(orderData: state.extra as OrderData?);
        },
      ),
      GoRoute(
        path: '/repay-entry',
        name: 'repayEntry',
        builder: (context, state) => const RepayEntryPage(),
      ),
      GoRoute(
        path: '/repay-detail',
        name: 'repayDetail',
        builder: (context, state) {
          final bill = state.extra as BillItem;
          return RepayDetailPage(bill: bill);
        },
      ),
      GoRoute(
        path: '/repay-multi-detail',
        name: 'repayMultiDetail',
        builder: (context, state) {
          final bills = state.extra as List<BillItem>;
          return RepayMultiDetailPage(bills: bills);
        },
      ),
      GoRoute(
        path: '/extension-apply',
        name: 'extensionApply',
        builder: (context, state) {
          final billId = state.extra as String? ?? '';
          return ExtensionApplyPage(billId: billId);
        },
      ),
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          final amount = params?['amount'] as double? ?? 0.0;
          final phone = params?['phone'] as String?;
          final idNumber = params?['idNumber'] as String?;
          return PaymentPage(amount: amount, phone: phone, idNumber: idNumber);
        },
      ),
      GoRoute(
        path: '/survey',
        name: 'survey',
        builder: (context, state) => const SurveyPage(),
      ),
      GoRoute(
        path: '/contact-info',
        name: 'contactInfo',
        builder: (context, state) => const ContactInfoPage(),
      ),
      GoRoute(
        path: '/personal-info',
        name: 'personalInfo',
        builder: (context, state) => const fill_info.PersonalInfoPage(),
      ),
      GoRoute(
        path: '/identity-verify',
        name: 'identityVerify',
        builder: (context, state) => const IdentityVerifyPage(),
      ),
      GoRoute(
        path: '/face-verify',
        name: 'faceVerify',
        builder: (context, state) => const FaceVerifyPage(),
      ),
      GoRoute(
        path: '/mine',
        name: 'mine',
        builder: (context, state) => const MinePage(),
      ),
      GoRoute(
        path: '/order-history',
        name: 'orderHistory',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: '/detail/:id',
        name: 'detail',
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
              onPressed: () => context.go('/'),
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
