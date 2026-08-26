import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebViewPage extends StatefulWidget {
  LegalWebViewPage({
    super.key,
    required this.title,
    this.url,
    this.resolveUrl,
  }) : assert(
         (url != null && url.trim().isNotEmpty) || resolveUrl != null,
         'Provide url or resolveUrl',
       );

  final String title;
  final String? url;
  final Future<String> Function()? resolveUrl;

  static Future<void> open(
    BuildContext context, {
    required String title,
    String? url,
    Future<String> Function()? resolveUrl,
  }) {
    final target = url?.trim();
    if (target != null && target.isNotEmpty) {
      _logOpenUrl(title: title, url: target);
    }
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LegalWebViewPage(
          title: title,
          url: target,
          resolveUrl: resolveUrl,
        ),
      ),
    );
  }

  static void _logOpenUrl({required String title, required String url}) {
    if (kReleaseMode) return;

    final uri = Uri.tryParse(url.trim());
    // ignore: avoid_print
    print('[H5] open: $title');
    // ignore: avoid_print
    print('[H5]   url: $url');

    final query = uri?.queryParameters ?? const <String, String>{};
    if (query.isEmpty) {
      // ignore: avoid_print
      print('[H5]   query: (empty)');
      return;
    }

    // ignore: avoid_print
    print('[H5]   query:');
    for (final entry in query.entries) {
      // ignore: avoid_print
      print('[H5]   │ ${entry.key}: ${entry.value}');
    }
  }

  @override
  State<LegalWebViewPage> createState() => _LegalWebViewPageState();
}

class _LegalWebViewPageState extends State<LegalWebViewPage> {
  late final WebViewController _controller;
  bool _isResolvingUrl = false;
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
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
        ),
      );

    final initialUrl = widget.url?.trim();
    if (initialUrl != null && initialUrl.isNotEmpty) {
      _loadUrlIfNeeded(initialUrl);
      return;
    }

    final resolveUrl = widget.resolveUrl;
    if (resolveUrl != null) {
      _isResolvingUrl = true;
      _resolveAndLoad(resolveUrl);
    }
  }

  Future<void> _resolveAndLoad(Future<String> Function() resolveUrl) async {
    try {
      final resolved = (await resolveUrl()).trim();
      if (!mounted) return;
      if (resolved.isEmpty) {
        Navigator.of(context).pop();
        return;
      }

      LegalWebViewPage._logOpenUrl(title: widget.title, url: resolved);
      setState(() => _isResolvingUrl = false);
      _loadUrlIfNeeded(resolved);
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
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
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
            ),
            if (_isResolvingUrl || _isLoading)
              const Center(child: CircularProgressIndicator()),
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
