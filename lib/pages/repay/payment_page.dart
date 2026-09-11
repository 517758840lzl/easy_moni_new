import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/pages/repay/models/payment_request_params.dart';
import 'package:easy_moni/pages/repay/providers/payment_provider.dart';
import 'package:easy_moni/utils/widgets/app_state_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        error: (error, _) => AppErrorStateView(
          text: error.toString(),
          onReload: () =>
              ref.invalidate(paymentUrlProvider(widget.requestParams)),
        ),
        loading: () => const AppStateView(child: CircularProgressIndicator()),
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
    if (message.message == _goHomeMessage) {
      context.go(
        AppRoutePaths.homeWithTab(AppHomeTabs.loan, refreshLoanHome: true),
      );
    } else {
      return;
    }
  }
}
