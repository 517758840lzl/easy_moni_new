import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/pages/repay/models/payment_request_params.dart';
import 'package:easy_moni/pages/repay/providers/payment_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 付款 H5 容器页，负责生成支付链接并承载三方支付 WebView 交互。
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key, required this.requestParams});

  final PaymentRequestParams requestParams;

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  static const String _jsChannelName = 'appChannel';
  static const String _goHomeMessage = 'goHome';

  late final WebViewController _controller;
  bool _isWebLoading = false;
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isWebLoading = true;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isWebLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        _jsChannelName,
        onMessageReceived: _handleJsMessage,
      );
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(paymentUrlProvider(widget.requestParams));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.paymentTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: _handleBack,
        ),
      ),
      body: paymentAsync.when(
        data: (data) {
          _loadUrlIfNeeded(data.payUrl);
          return Stack(
            children: [
              WebViewWidget(
                controller: _controller,
                // 支付 H5 页面需要接管滚动手势，避免 WebView 内容超出视口后无法滚动。
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    EagerGestureRecognizer.new,
                  ),
                },
              ),
              if (_isWebLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
        error: (error, _) => _PaymentStateView(
          icon: Icons.error_outline_rounded,
          text: error.toString(),
          actionText: AppStrings.repayEntryRetry,
          onActionTap: () =>
              ref.invalidate(paymentUrlProvider(widget.requestParams)),
        ),
        loading: () =>
            const _PaymentStateView(child: CircularProgressIndicator()),
      ),
    );
  }

  void _loadUrlIfNeeded(String? rawUrl) {
    final url = rawUrl?.trim();
    if (url == null || url.isEmpty || url == _loadedUrl) return;

    _loadedUrl = url;
    _controller.loadRequest(Uri.parse(url));
  }

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }

    if (mounted) {
      context.pop();
    }
  }

  void _handleJsMessage(JavaScriptMessage message) {
    AppLogger.debug('Payment H5 message: ${message.message}');
    if (message.message == _goHomeMessage) {
      context.go(AppRoutePaths.homeWithTab(AppHomeTabs.loan));
    } else {
      AppLogger.debug('Unsupported payment H5 message: ${message.message}');
    }
  }
}

class _PaymentStateView extends StatelessWidget {
  const _PaymentStateView({
    this.child,
    this.icon,
    this.text = '',
    this.actionText = '',
    this.onActionTap,
  });

  final Widget? child;
  final IconData? icon;
  final String text;
  final String actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final customChild = child;
    if (customChild != null) {
      return Center(child: customChild);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 54, color: const Color(0xFFACACAC)),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF787878),
                  height: 20 / 14,
                ),
              ),
            ],
            if (actionText.isNotEmpty && onActionTap != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onActionTap, child: Text(actionText)),
            ],
          ],
        ),
      ),
    );
  }
}
