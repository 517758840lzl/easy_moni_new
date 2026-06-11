import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import '../../utils/widgets/loan_bottom_action_button.dart';

class LoanReviewingPage extends StatelessWidget {
  const LoanReviewingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF216A4A),
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: _ReviewingTopBackground()),
            const _ReviewingAppBar(),
            Positioned.fill(
              top: MediaQuery.of(context).padding.top + 63,
              child: const _ReviewingContentPanel(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: LoanBottomActionButton(
        enabled: true,
        text: '回到首页',
        onPressed: () => context.go('/home'),
      ),
    );
  }
}

class _ReviewingAppBar extends StatelessWidget {
  const _ReviewingAppBar();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset,
      left: 0,
      right: 0,
      height: 54,
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 6,
            child: IconButton(
              onPressed: () => context.go('/home'),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Positioned(
            top: 16,
            left: 64,
            right: 64,
            child: Text(
              '申请借款',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 20 / 16,
              ),
            ),
          ),
          Positioned(
            top: 11,
            right: 21,
            child: Assets.images.customer.image(width: 32, height: 32),
          ),
        ],
      ),
    );
  }
}

class _ReviewingTopBackground extends StatelessWidget {
  const _ReviewingTopBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF216A4A),
        image: DecorationImage(
          image: Assets.images.loginBg.provider(),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

class _ReviewingContentPanel extends StatelessWidget {
  const _ReviewingContentPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageTop = (constraints.maxHeight * 0.22).clamp(96.0, 139.0);

          return Stack(
            children: [
              Positioned(
                top: imageTop,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Center(
                      child: Assets.images.loanReviewing.image(
                        width: 163,
                        height: 168,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text('审核中',style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                    ),),
                    const SizedBox(height: 8,),
                    Text('您的借款申请正在审核中。\n通常会在几分钟内出结果。\n请耐心等待，结果将及时通知您。',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.5
                    ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
