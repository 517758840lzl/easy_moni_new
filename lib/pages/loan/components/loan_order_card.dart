import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoanOrderCardRowData {
  const LoanOrderCardRowData({required this.label, required this.value});

  final String label;
  final String value;
}

class LoanOrderCardStatusBadgeData {
  const LoanOrderCardStatusBadgeData({
    required this.text,
    required this.gradient,
  });

  final String text;
  final List<Color> gradient;
}

class LoanOrderCardFooterData {
  const LoanOrderCardFooterData({
    required this.text,
    this.showCouponIcon = false,
  });

  final String text;
  final bool showCouponIcon;
}

class LoanOrderCard extends StatelessWidget {
  const LoanOrderCard({
    super.key,
    required this.productName,
    required this.rows,
    this.productLogo,
    this.statusBadge,
    this.footer,
    this.onFooterTap,
    this.onTap,
  });

  final String productName;
  final String? productLogo;
  final List<LoanOrderCardRowData> rows;
  final LoanOrderCardStatusBadgeData? statusBadge;
  final LoanOrderCardFooterData? footer;
  final VoidCallback? onFooterTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5EE),
        borderRadius: BorderRadius.circular(4.375),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderHeader(
                productName: productName,
                productLogo: productLogo,
                hasStatusBadge: statusBadge != null,
              ),
              const SizedBox(height: 7),
              ..._buildInfoRows(rows),
              if (footer != null) ...[
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0x1A000000),
                ),
                const SizedBox(height: 11),
                _OrderFooterAction(
                  text: footer!.text,
                  showCouponIcon: footer!.showCouponIcon,
                  onTap: onFooterTap,
                ),
              ],
            ],
          ),
          if (statusBadge != null)
            Positioned(
              top: 3,
              right: 0,
              child: _OrderStatusBadge(data: statusBadge!),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4.375),
        onTap: onTap,
        child: card,
      ),
    );
  }

  static List<Widget> _buildInfoRows(List<LoanOrderCardRowData> rows) {
    final widgets = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      widgets.add(_OrderInfoRow(label: row.label, value: row.value));
      if (i < rows.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.productName,
    required this.productLogo,
    required this.hasStatusBadge,
  });

  final String productName;
  final String? productLogo;
  final bool hasStatusBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OrderLogo(productName: productName, productLogo: productLogo),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0E0E0E),
              height: 16 / 12,
            ),
          ),
        ),
        if (hasStatusBadge) const SizedBox(width: 62),
      ],
    );
  }
}

class _OrderLogo extends StatelessWidget {
  const _OrderLogo({required this.productName, required this.productLogo});

  final String productName;
  final String? productLogo;

  @override
  Widget build(BuildContext context) {
    final logo = productLogo;
    if (logo != null && logo.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          logo,
          width: 21,
          height: 21,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallback(),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    final initial = productName.isNotEmpty
        ? productName.characters.first
        : AppStrings.loanOrderLogoFallback;

    return Container(
      width: 21,
      height: 21,
      decoration: const BoxDecoration(
        color: Color(0xFF216A4A),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.data});

  final LoanOrderCardStatusBadgeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: data.gradient,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        data.text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 16 / 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF131313),
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderFooterAction extends StatelessWidget {
  const _OrderFooterAction({
    required this.text,
    required this.showCouponIcon,
    this.onTap,
  });

  final String text;
  final bool showCouponIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        if (showCouponIcon) ...[
          SvgPicture.asset(Assets.images.couponIcon, width: 14, height: 14),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF216A4A),
              height: 1,
            ),
          ),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}
