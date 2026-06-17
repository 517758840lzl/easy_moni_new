import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/home_resp.dart';
import 'package:easy_moni/utils/extensions.dart';

/// 首页传入订单详情页的展示快照，详情页不再额外请求接口。
class LoanOrderDetailData {
  const LoanOrderDetailData({
    required this.appOrderId,
    required this.productName,
    required this.loanAmount,
    required this.receiptAmount,
    required this.repayAmount,
    this.productCode,
    this.productLevel,
    this.productLogo,
    this.statusCode,
    this.statusText,
    this.totalServiceDays,
    this.remainingDays,
    this.interest,
    this.serviceFee,
    this.term,
    this.repaidAmount,
    this.rawRepayDate,
    this.repayDateStr,
    this.isExtensionSwitch,
    this.borrowDate,
    this.dueDate,
    this.momoAccount,
    this.walletType,
    this.createTime,
    this.updateTime,
  });

  factory LoanOrderDetailData.fromHomeProductItem(HomeProductItem item) {
    return LoanOrderDetailData(
      appOrderId: _resolveAppOrderId(item),
      productName: item.productName?.isNotEmpty == true
          ? item.productName!
          : AppStrings.loanOrderProductFallback,
      loanAmount: item.loanAmount ?? 0,
      receiptAmount: item.actualToAccount ?? item.receiptAmount ?? 0,
      repayAmount: item.repayAmount ?? 0,
      productCode: item.productCode,
      productLevel: item.productLevel,
      productLogo: item.productLogo,
      statusCode: item.appOrderStatus,
      statusText: null,
      totalServiceDays: item.totalServiceDays,
      remainingDays: item.remainingDays,
      interest: item.interest,
      serviceFee: item.serviceFee,
      term: item.totalServiceDays ?? item.term,
      repaidAmount: item.repaidAmount,
      rawRepayDate: item.repayDate,
      repayDateStr: item.repayDateStr,
      isExtensionSwitch: item.isExtensionSwitch,
      borrowDate: item.repayDate?.formatBackendDate(),
      dueDate: _resolveDueDate(item),
      momoAccount: item.bankCardNo,
      walletType: item.bankCardName ?? item.bankCardType,
    );
  }

  final String appOrderId;
  final String productName;
  final num loanAmount;
  final num receiptAmount;
  final num repayAmount;
  final String? productCode;
  final int? productLevel;
  final String? productLogo;
  final int? statusCode;
  final String? statusText;
  final int? totalServiceDays;
  final int? remainingDays;
  final num? interest;
  final num? serviceFee;
  final int? term;
  final num? repaidAmount;
  final String? rawRepayDate;
  final String? repayDateStr;
  final bool? isExtensionSwitch;
  final String? borrowDate;
  final String? dueDate;
  final String? momoAccount;
  final String? walletType;
  final String? createTime;
  final String? updateTime;

  /// 优先展示后端到期日；为空时沿用首页订单卡的放款中兜底日期。
  static String? _resolveDueDate(HomeProductItem item) {
    final date = item.dueDate ?? item.repayDateStr;
    return date?.formatBackendDate();
  }

  /// 还款详情请求依赖订单号，优先使用后端提供的字符串订单号避免大整数精度风险。
  static String _resolveAppOrderId(HomeProductItem item) {
    final appOrderIdStr = item.appOrderIdStr?.trim();
    if (appOrderIdStr != null && appOrderIdStr.isNotEmpty) {
      return appOrderIdStr;
    }
    return item.appOrderId?.toString() ?? '';
  }
}

/// 订单详情页状态视觉类别，使用固定实例替代 enum。
class LoanOrderDetailStatusKind {
  const LoanOrderDetailStatusKind._(this.key);

  final String key;

  static const LoanOrderDetailStatusKind waiting = LoanOrderDetailStatusKind._(
    'waiting',
  );
  static const LoanOrderDetailStatusKind failed = LoanOrderDetailStatusKind._(
    'failed',
  );
  static const LoanOrderDetailStatusKind overdue = LoanOrderDetailStatusKind._(
    'overdue',
  );
}

/// 订单详情页状态展示配置，与首页订单卡状态规则保持一致。
class LoanOrderDetailStatusVisual {
  const LoanOrderDetailStatusVisual({required this.title, required this.kind});

  final String title;
  final LoanOrderDetailStatusKind kind;

  factory LoanOrderDetailStatusVisual.resolve(LoanOrderDetailData data) {
    if (data.statusCode == 4 &&
        data.remainingDays != null &&
        data.remainingDays! < 0) {
      return const LoanOrderDetailStatusVisual(
        title: AppStrings.loanOrderStatusOverdue,
        kind: LoanOrderDetailStatusKind.overdue,
      );
    }

    switch (data.statusCode) {
      case 3:
        return const LoanOrderDetailStatusVisual(
          title: AppStrings.loanOrderStatusDisbursingv2,
          kind: LoanOrderDetailStatusKind.waiting,
        );
      case 4:
        return const LoanOrderDetailStatusVisual(
          title: AppStrings.loanOrderStatusWaitingRepayment,
          kind: LoanOrderDetailStatusKind.waiting,
        );
      case 5:
        return const LoanOrderDetailStatusVisual(
          title: AppStrings.loanOrderStatusTransferFailed,
          kind: LoanOrderDetailStatusKind.failed,
        );
      case 20:
      default:
        return const LoanOrderDetailStatusVisual(
          title: AppStrings.loanOrderStatusReviewing,
          kind: LoanOrderDetailStatusKind.waiting,
        );
    }
  }
}
