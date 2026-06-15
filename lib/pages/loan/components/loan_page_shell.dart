import 'package:flutter/material.dart';

/// 贷款业务通用圆角页面外壳。
///
/// 只负责背景、顶部区域和白色圆角内容区的组合，不承载加载态、错误态或业务逻辑。
class LoanRoundedPageShell extends StatelessWidget {
  const LoanRoundedPageShell({
    super.key,
    required this.header,
    required this.content,
    this.contentTop,
    this.contentHeightFactor,
    this.contentTopRadius = 16,
    this.backgroundColor = const Color(0xFF216A4A),
    this.backgroundDecoration,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
  }) : assert(
         contentTop != null || contentHeightFactor != null,
         'contentTop 和 contentHeightFactor 至少传一个',
       ),
       assert(
         contentHeightFactor == null ||
             (contentHeightFactor > 0 && contentHeightFactor <= 1),
         'contentHeightFactor 必须大于 0 且小于等于 1',
       );

  /// 顶部信息区域，例如金额、标题、客服入口等。
  final Widget header;

  /// 白色圆角内容区，由具体页面自行处理滚动、状态和业务展示。
  final Widget content;

  /// 白色内容区距离屏幕顶部的固定位置，优先级高于 [contentHeightFactor]。
  final double Function(BuildContext context)? contentTop;

  /// 白色内容区占屏幕高度比例，例如 0.72。
  final double? contentHeightFactor;

  /// 白色内容区顶部圆角半径。
  final double contentTopRadius;

  /// Scaffold 和默认背景层颜色。
  final Color backgroundColor;

  /// 自定义背景装饰，例如背景图或渐变；为空时使用 [backgroundColor]。
  final Decoration? backgroundDecoration;

  /// 页面底部固定操作区。
  final Widget? bottomNavigationBar;

  /// 透传给 Scaffold，方便表单类页面自行决定键盘顶起行为。
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final resolvedContentTop =
        contentTop?.call(context) ?? screenHeight * (1 - contentHeightFactor!);
    final panelTop = resolvedContentTop.clamp(0.0, screenHeight).toDouble();

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration:
                    backgroundDecoration ??
                    BoxDecoration(color: backgroundColor),
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: header),
            Positioned.fill(
              top: panelTop,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(contentTopRadius),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: content,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
