import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../utils/widgets/toast.dart';

abstract class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  @protected
  String get title => '';

  @protected
  bool get showAppBar => true;

  @protected
  bool get keepAlive => false;

  @protected
  Widget buildBody(BuildContext context, WidgetRef ref);

  @override
  ConsumerState<BasePage> createState() => _BasePageState();
}

class _BasePageState<T extends BasePage> extends ConsumerState<T>
    with AutomaticKeepAliveClientMixin<T> {
  final List<CancelToken> _cancelTokens = [];

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    if (wantKeepAlive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateKeepAlive();
      });
    }
  }

  @override
  void dispose() {
    _cancelAllRequests();
    super.dispose();
  }

  void _cancelAllRequests() {
    for (final token in _cancelTokens) {
      if (!token.isCancelled) {
        token.cancel('Page disposed');
      }
    }
    _cancelTokens.clear();
  }

  CancelToken createCancelToken() {
    final token = CancelToken();
    _cancelTokens.add(token);
    return token;
  }

  void removeCancelToken(CancelToken token) {
    _cancelTokens.remove(token);
  }

  void showLoading() {
    LoadingOverlay.show(context);
  }

  void hideLoading() {
    LoadingOverlay.hide();
  }

  void showOKToast(String message, {bool isError = false}) {
    showToast(message);
  }

  void showSuccessToast(String message) {
    showToast(
      message,
      // position: ToastPosition.bottom,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      radius: 8.0,
    );
  }

  void showErrorToast(String message) {
    showToast(message, backgroundColor: Colors.black, radius: 8.0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!widget.showAppBar) {
      return Scaffold(body: SafeArea(child: widget.buildBody(context, ref)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: SafeArea(child: widget.buildBody(context, ref)),
    );
  }
}

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black26,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
