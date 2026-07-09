import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/config/privacy_policy_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 隐私政策 H5 容器页，承载外部隐私政策链接展示。
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final WebViewController _controller;
  bool _isLoading = false;
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
              _isLoading = true;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    _loadUrlIfNeeded(PrivacyPolicyConfig.privacyPolicyUrl);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.privacyData),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: _handleBack,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            WebViewWidget(
              controller: _controller,
              // 隐私政策 H5 内容需要优先接收滚动手势，避免长页面无法滚动。
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  void _loadUrlIfNeeded(String rawUrl) {
    final url = _normalizeUrl(rawUrl);
    if (url.isEmpty || url == _loadedUrl) return;

    _loadedUrl = url;
    _controller.loadRequest(Uri.parse(url));
  }

  /// 兼容运营只配置域名的情况，保证 WebView 收到合法 URI。
  String _normalizeUrl(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://$url';
  }

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
