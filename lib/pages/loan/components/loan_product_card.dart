import 'package:flutter/material.dart';

import 'package:easy_moni/core/constants/app_strings.dart';

/// 借款产品卡片状态
class LoanProductCardState {
  const LoanProductCardState._({
    required this.label,
    required this.canConfirm,
    required this.isGreen,
  });

  static const LoanProductCardState available = LoanProductCardState._(
    label: AppStrings.loanProductAvailable,
    canConfirm: true,
    isGreen: true,
  );

  static const LoanProductCardState unavailable = LoanProductCardState._(
    label: AppStrings.loanProductUnavailable,
    canConfirm: false,
    isGreen: false,
  );

  static const LoanProductCardState rejected = LoanProductCardState._(
    label: AppStrings.loanProductRejected,
    canConfirm: false,
    isGreen: false,
  );

  final String label;
  final bool canConfirm;
  final bool isGreen;
}

class LoanProductCard extends StatelessWidget {
  const LoanProductCard({
    super.key,
    required this.brand,
    required this.level,
    required this.amountLabel,
    required this.interestLabel,
    required this.termLabel,
    required this.state,
    required this.isSelected,
    required this.isConfirmed,
    required this.onTap,
    this.logoUrl,
    this.onToggleConfirmed,
  });

  final String brand;
  final String level;
  final String amountLabel;
  final String interestLabel;
  final String termLabel;
  final LoanProductCardState state;
  final bool isSelected;
  final bool isConfirmed;
  final VoidCallback onTap;
  final String? logoUrl;
  final VoidCallback? onToggleConfirmed;

  @override
  Widget build(BuildContext context) {
    final colors = _LoanProductCardColors.forState(state);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 141,
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors.cardGradient,
          ),
          borderRadius: BorderRadius.circular(10),
          border: _border,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F1418),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(colors),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoRow(
                      label: AppStrings.loanAvailableAmountLabel,
                      value: amountLabel,
                    ),
                    _InfoRow(
                      label: AppStrings.loanDailyInterestRateLabel,
                      value: interestLabel,
                    ),
                    _InfoRow(label: AppStrings.loanTermLabel, value: termLabel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxBorder? get _border {
    if (state == LoanProductCardState.rejected) {
      return Border.all(color: const Color(0xFFFF4D4F), width: 1);
    }

    return null;
  }

  Widget _buildHeader(_LoanProductCardColors colors) {
    return SizedBox(
      height: 21,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 4),
                _ProductLogo(
                  brand: brand,
                  logoUrl: logoUrl,
                  color: colors.logoText,
                ),
                const SizedBox(width: 4),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 16 / 12,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _LevelBadge(level: level),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StateBadge(state: state, colors: colors),
              const SizedBox(width: 7),
              _StateIcon(
                state: state,
                isConfirmed: isConfirmed,
                onToggleConfirmed: onToggleConfirmed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoanProductCardColors {
  const _LoanProductCardColors({
    required this.cardGradient,
    required this.badgeGradient,
    required this.badgeColor,
    required this.border,
    required this.logoText,
  });

  final List<Color> cardGradient;
  final List<Color>? badgeGradient;
  final Color badgeColor;
  final Color border;
  final Color logoText;

  factory _LoanProductCardColors.forState(LoanProductCardState state) {
    if (state.isGreen) {
      return const _LoanProductCardColors(
        cardGradient: [Color(0xFF24835D), Color(0xFFD2EEE1)],
        badgeGradient: null,
        badgeColor: Color(0xFF38B899),
        border: Color(0xFFD2EEE1),
        logoText: Color(0xFF24835D),
      );
    }

    return const _LoanProductCardColors(
      cardGradient: [Color(0xFFAAAAAA), Color(0xFFF0F0F0)],
      badgeGradient: null,
      badgeColor: Color(0xFFC1C3C6),
      border: Color(0xFFE6E8EC),
      logoText: Color(0xFFAAAAAA),
    );
  }
}

class _ProductLogo extends StatelessWidget {
  const _ProductLogo({
    required this.brand,
    required this.logoUrl,
    required this.color,
  });

  final String brand;
  final String? logoUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
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
    final initial = brand.isNotEmpty
        ? brand.characters.first
        : AppStrings.loanProductLogoFallback;

    return Container(
      width: 21,
      height: 21,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 11,
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          level,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF737A86),
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state, required this.colors});

  final LoanProductCardState state;
  final _LoanProductCardColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colors.badgeGradient == null ? colors.badgeColor : null,
        gradient: colors.badgeGradient == null
            ? null
            : LinearGradient(colors: colors.badgeGradient!),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          state.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({
    required this.state,
    required this.isConfirmed,
    required this.onToggleConfirmed,
  });

  final LoanProductCardState state;
  final bool isConfirmed;
  final VoidCallback? onToggleConfirmed;

  @override
  Widget build(BuildContext context) {
    if (state.canConfirm) {
      return GestureDetector(
        onTap: onToggleConfirmed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConfirmed
                ? const Color(0xFF50FFB2)
                : Colors.white.withValues(alpha: 0.22),
          ),
          child: isConfirmed
              ? const Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: Color(0xFF216A4A),
                )
              : const SizedBox.shrink(),
        ),
      );
    }

    return Container(
      width: 17,
      height: 17,
      decoration: const BoxDecoration(
        color: Color(0xFFA9A9A9),
        shape: BoxShape.circle,
      ),
      child: Icon(
        state == LoanProductCardState.rejected
            ? Icons.block_rounded
            : Icons.lock_outline_rounded,
        size: 13,
        color: const Color(0xFF45537A),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
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
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 16 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
