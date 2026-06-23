import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/loan/components/loan_order_detail_cards.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/pages/loan/models/loan_order_detail_data.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 首页订单点击后的纯展示详情页，数据全部由上一级页面传入。
class LoanOrderDetailPage extends StatelessWidget {
  const LoanOrderDetailPage({super.key, required this.data});

  final LoanOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final canRepay = data.statusCode == 4;
    final hasRepayOrderId = data.appOrderId.isNotEmpty;

    return LoanRoundedPageShell(
      contentTop: (_) => topInset + 114,
      contentTopRadius: 12,
      backgroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      header: _OrderDetailHeader(data: data),
      content: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(children: [LoanOrderDetailCards(data: data)]),
      ),
      bottomNavigationBar: canRepay
          ? LoanBottomActionButton(
              enabled: hasRepayOrderId,
              text: AppStrings.orderDetailRepayNow,
              onPressed: hasRepayOrderId
                  ? () => context.push(
                      AppRoutePaths.repayOrderDetailWithIds([data.appOrderId]),
                    )
                  : null,
            )
          : null,
    );
  }
}

class _OrderDetailHeader extends StatelessWidget {
  const _OrderDetailHeader({required this.data});

  final LoanOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    final visual = LoanOrderDetailStatusVisual.resolve(data);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 10,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const Text(
                  AppStrings.orderDetailTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 20 / 16,
                  ),
                ),
                Positioned(
                  right: 18,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push(AppRoutePaths.customerService),
                    child: Assets.images.customer.image(width: 32, height: 32),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 0, 17, 18),
            child: Row(
              children: [
                LoanOrderStatusIcon(kind: visual.kind),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visual.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 24 / 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        AppStrings.appTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 16 / 13,
                        ),
                      ),
                    ],
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

/// 订单状态图标，根据状态类别映射本地资源。
class LoanOrderStatusIcon extends StatelessWidget {
  const LoanOrderStatusIcon({super.key, required this.kind});

  final LoanOrderDetailStatusKind kind;

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage();
    return image.image(width: 34, height: 34, fit: BoxFit.contain);
  }

  AssetGenImage _resolveImage() {
    if (kind == LoanOrderDetailStatusKind.failed) {
      return Assets.images.loanOrderError;
    }
    if (kind == LoanOrderDetailStatusKind.overdue) {
      return Assets.images.loanOrderWarning;
    }
    return Assets.images.loanOrderLoading;
  }
}
