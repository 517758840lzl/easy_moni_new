import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/service/service_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/mine/providers/customer_service_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 客服展示方式，和后端 showType 保持一致。
class CustomerServiceShowType {
  CustomerServiceShowType._();

  static const int webView = 0;
  static const int text = 1;
}

/// 客服联系方式类型，和后端 type 保持一致。
class CustomerServiceContactType {
  CustomerServiceContactType._();

  static const int phone = 1;
  static const int whatsapp = 2;
  static const int email = 3;
  static const int zalo = 5;
}

/// 客服页，负责根据后端 showType 切换 WebView 或纯文本联系方式。
class CustomerServicePage extends ConsumerWidget {
  const CustomerServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerServiceAsync = ref.watch(customerServiceInfoAsyncProvider);

    return customerServiceAsync.when(
      data: (data) {
        if (data.showType == CustomerServiceShowType.text) {
          return _CustomerServiceTextPage(data: data);
        }
        return _CustomerServiceWebViewPage(data: data);
      },
      loading: () =>
          const _CustomerServiceStatePage(child: CircularProgressIndicator()),
      error: (error, _) => _CustomerServiceStatePage(
        icon: Icons.error_outline_rounded,
        text: AppStrings.mineCustomerServiceLoadFailed,
        actionText: AppStrings.mineOrderHistoryRetry,
        onActionTap: () => ref.invalidate(customerServiceInfoAsyncProvider),
      ),
    );
  }
}

class _CustomerServiceTextPage extends StatelessWidget {
  const _CustomerServiceTextPage({required this.data});

  final ServiceInfoRespData data;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final detail = data.appCustomerServiceInfo;
    final contacts = _CustomerServiceContact.fromDetail(detail);

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 64,
      contentTopRadius: 16,
      backgroundColor: AppColors.primaryDark,
      backgroundDecoration: BoxDecoration(
        color: AppColors.primaryDark,
        image: DecorationImage(
          image: Assets.images.mineBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: _CustomerServiceHeader(data: detail),
      content: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            28,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            _AntiFraudCard(),
            const SizedBox(height: 24),
            if (contacts.isEmpty)
              const _CustomerServiceEmptyView()
            else
              ...contacts.map(_CustomerServiceContactCard.new),
          ],
        ),
      ),
    );
  }
}

class _AntiFraudCard extends StatelessWidget {
  const _AntiFraudCard();

  static const double _cardHeight = 192;
  static const double _imageSize = 134;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _cardHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF141B2B),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _AntiFraudGradient()),
          Positioned(
            right: 16,
            bottom: 24,
            child: Opacity(
              opacity: 0.4,
              child: Assets.images.serviceSafe.image(
                width: _imageSize,
                height: _imageSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.customerServiceAntiFraudTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  AppStrings.customerServiceAntiFraudDesc,
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 14,
                    height: 16 / 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 深色卡片右上角的绿色径向光效。
class _AntiFraudGradient extends StatelessWidget {
  const _AntiFraudGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 0.7,
          colors: [
            const Color(0xFF006C49).withValues(alpha: 0.1),
            const Color(0xFF006C49).withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _CustomerServiceWebViewPage extends StatefulWidget {
  const _CustomerServiceWebViewPage({required this.data});

  final ServiceInfoRespData data;

  @override
  State<_CustomerServiceWebViewPage> createState() =>
      _CustomerServiceWebViewPageState();
}

class _CustomerServiceWebViewPageState
    extends State<_CustomerServiceWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = false;
  String? _loadedSource;

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
    final source = _CustomerServiceWebSource.fromList(
      widget.data.appCustomerServiceInfoResps,
    );
    _loadSourceIfNeeded(source);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.mineCustomerService),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: _handleBack,
        ),
      ),
      body: SafeArea(
        top: false,
        child: source == null
            ? const _CustomerServiceEmptyView()
            : Stack(
                children: [
                  WebViewWidget(
                    controller: _controller,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        EagerGestureRecognizer.new,
                      ),
                    },
                  ),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
      ),
    );
  }

  void _loadSourceIfNeeded(_CustomerServiceWebSource? source) {
    if (source == null || source.value == _loadedSource) return;

    _loadedSource = source.value;
    if (source.isHtml) {
      _controller.loadHtmlString(source.value);
      return;
    }
    _controller.loadRequest(Uri.parse(source.value));
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

class _CustomerServiceHeader extends StatelessWidget {
  const _CustomerServiceHeader({required this.data});
  final ServiceInfoRespDataAppCustomerServiceInfo? data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(
                data?.title ?? AppStrings.mineCustomerService,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 客服联系方式卡片
class _CustomerServiceContactCard extends StatelessWidget {
  const _CustomerServiceContactCard(this.contact);

  final _CustomerServiceContact contact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE1E3E4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                contact.icon,
                size: 20,
                color: const Color(0xFF006C49),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _CustomerServiceContactText(contact: contact)),
            const SizedBox(width: 12),
            Assets.images.serviceRightArrow.image(width: 8, height: 12),
          ],
        ),
      ),
    );
  }
}

/// 联系方式文字区域，优先展示后端标题，缺省时按类型展示官方渠道名称。
class _CustomerServiceContactText extends StatelessWidget {
  const _CustomerServiceContactText({required this.contact});

  final _CustomerServiceContact contact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (contact.displayTitle.isNotEmpty)
          Text(
            contact.displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF414943),
              letterSpacing: 0.14,
            ),
          ),
        if (contact.displayTitle.isNotEmpty) const SizedBox(height: 2),
        SelectableText(
          contact.account,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF141B2B),
          ),
        ),
        if (contact.desc.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            contact.desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 18 / 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}

class _CustomerServiceStatePage extends StatelessWidget {
  const _CustomerServiceStatePage({
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text(AppStrings.mineCustomerService)),
      body: _CustomerServiceStateView(
        icon: icon,
        text: text,
        actionText: actionText,
        onActionTap: onActionTap,
        child: child,
      ),
    );
  }
}

class _CustomerServiceStateView extends StatelessWidget {
  const _CustomerServiceStateView({
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

class _CustomerServiceEmptyView extends StatelessWidget {
  const _CustomerServiceEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          AppStrings.mineCustomerServiceEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF787878),
            height: 20 / 14,
          ),
        ),
      ),
    );
  }
}

/// 纯文本展示下的一条客服联系方式。
class _CustomerServiceContact {
  const _CustomerServiceContact({
    required this.type,
    required this.account,
    required this.title,
    required this.desc,
  });

  final int type;
  final String account;
  final String title;
  final String desc;

  String get displayTitle => title.isNotEmpty ? title : typeLabel;

  String get typeLabel {
    switch (type) {
      case CustomerServiceContactType.whatsapp:
        return AppStrings.customerServiceWhatsApp;
      case CustomerServiceContactType.email:
        return AppStrings.customerServiceEmail;
      case CustomerServiceContactType.zalo:
        return AppStrings.customerServiceZalo;
      case CustomerServiceContactType.phone:
        return AppStrings.customerServicePhone;
      default:
        return '';
    }
  }

  IconData get icon {
    switch (type) {
      case CustomerServiceContactType.whatsapp:
        return Icons.chat_bubble_outline_rounded;
      case CustomerServiceContactType.email:
        return Icons.email_outlined;
      case CustomerServiceContactType.zalo:
        return Icons.forum_outlined;
      case CustomerServiceContactType.phone:
      default:
        return Icons.phone_outlined;
    }
  }

  static List<_CustomerServiceContact> fromDetail(
    ServiceInfoRespDataAppCustomerServiceInfo? detail,
  ) {
    if (detail == null) return const <_CustomerServiceContact>[];

    final accountList = detail.accountList ?? const [];
    final contacts = accountList
        .map(
          (item) => _CustomerServiceContact(
            type: item.type ?? detail.type ?? 0,
            account: _text(item.account),
            title: _text(item.title),
            desc: _text(item.desc),
          ),
        )
        .where((item) => item.account.isNotEmpty)
        .toList();

    if (contacts.isNotEmpty) return contacts;
    if (_text(detail.account).isEmpty) return const <_CustomerServiceContact>[];

    return [
      _CustomerServiceContact(
        type: detail.type ?? 0,
        account: _text(detail.account),
        title: _text(detail.title),
        desc: _text(detail.desc),
      ),
    ];
  }
}

/// WebView 模式下从后端集合中提取首个可展示资源。
class _CustomerServiceWebSource {
  const _CustomerServiceWebSource({required this.value, required this.isHtml});

  final String value;
  final bool isHtml;

  static _CustomerServiceWebSource? fromList(List<dynamic>? sourceList) {
    // 兼容 String、url/link/h5Url/content/html 字段。
    for (final item in sourceList ?? const <dynamic>[]) {
      final rawValue = _extractWebValue(item);
      if (rawValue.isEmpty) continue;
      final isUrl =
          rawValue.startsWith('http://') || rawValue.startsWith('https://');
      return _CustomerServiceWebSource(value: rawValue, isHtml: !isUrl);
    }
    return null;
  }

  static String _extractWebValue(dynamic item) {
    if (item == null) return '';
    if (item is String) return item.trim();
    if (item is Map) {
      for (final key in const [
        'url',
        'link',
        'h5Url',
        'webUrl',
        'content',
        'html',
      ]) {
        final value = item[key];
        if (_text(value).isNotEmpty) return _text(value);
      }
    }
    return '';
  }
}

String _text(dynamic value) => value?.toString().trim() ?? '';
