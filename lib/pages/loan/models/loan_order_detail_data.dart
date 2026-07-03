import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/home_resp.dart';
import 'package:easy_moni/entities/order_list_resp.dart';
import 'package:easy_moni/utils/extensions.dart';

/// 首页传入订单详情页的展示快照，详情页不再额外请求接口。
class LoanOrderDetailData {
  const LoanOrderDetailData({
    required this.appOrderId,
    required this.productName,
    required this.loanAmount,
    required this.receiptAmount,
    required this.repayAmount,
    this.overdueInterest,
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
      overdueInterest: item.overdueInterest ?? 0,
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
      term: item.term,
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

  /// 从历史订单完整数据生成详情页快照，避免页面层分散维护字段映射。
  factory LoanOrderDetailData.fromOrderListItem(OrderListItem order) {
    return LoanOrderDetailData(
      appOrderId: order.appOrderId?.trim() ?? '',
      productName: order.productName?.trim().isNotEmpty == true
          ? order.productName!.trim()
          : AppStrings.loanOrderProductFallback,
      loanAmount: order.loanAmount ?? 0,
      overdueInterest: order.overdueInterest ?? 0,
      receiptAmount: order.receiptAmount ?? 0,
      repayAmount: order.repayAmount ?? 0,
      productCode: order.productSetCode,
      productLevel: _parseProductLevel(order.productLevel),
      productLogo: order.productLogo,
      statusCode: order.orderStatus,
      statusText: order.orderStatusStr,
      totalServiceDays: order.totalServiceDays,
      remainingDays: order.remainingDays,
      interest: order.interest,
      term: order.term,
      repaidAmount: order.repaidAmount,
      rawRepayDate: order.repayDate,
      repayDateStr: order.repayDateStr,
      isExtensionSwitch: order.isExtensionSwitch,
      borrowDate: _formatOrderHistoryDate(order.createTime),
      dueDate: _formatOrderHistoryDate(order.repayDateStr ?? order.repayDate),
      momoAccount: order.bankCardNo,
      walletType: order.bankCardName ?? order.bankCardType,
      createTime: order.createTime,
      updateTime: order.updateTime,
    );
  }

  /// 从路由恢复的 JSON 快照重建详情页展示数据。
  factory LoanOrderDetailData.fromJson(Map<String, dynamic> json) {
    return LoanOrderDetailData(
      appOrderId: json['appOrderId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      loanAmount: json['loanAmount'] as num? ?? 0,
      overdueInterest: json['overdueInterest'] as num?,
      receiptAmount: json['receiptAmount'] as num? ?? 0,
      repayAmount: json['repayAmount'] as num? ?? 0,
      productCode: json['productCode'] as String?,
      productLevel: json['productLevel'] as int?,
      productLogo: json['productLogo'] as String?,
      statusCode: json['statusCode'] as int?,
      statusText: json['statusText'] as String?,
      totalServiceDays: json['totalServiceDays'] as int?,
      remainingDays: json['remainingDays'] as int?,
      interest: json['interest'] as num?,
      serviceFee: json['serviceFee'] as num?,
      term: json['term'] as int?,
      repaidAmount: json['repaidAmount'] as num?,
      rawRepayDate: json['rawRepayDate'] as String?,
      repayDateStr: json['repayDateStr'] as String?,
      isExtensionSwitch: json['isExtensionSwitch'] as bool?,
      borrowDate: json['borrowDate'] as String?,
      dueDate: json['dueDate'] as String?,
      momoAccount: json['momoAccount'] as String?,
      walletType: json['walletType'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );
  }

  final String appOrderId;
  final String productName;
  final num loanAmount;
  final num? overdueInterest;
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

  Map<String, dynamic> toJson() {
    return {
      'appOrderId': appOrderId,
      'productName': productName,
      'loanAmount': loanAmount,
      'overdueInterest': overdueInterest,
      'receiptAmount': receiptAmount,
      'repayAmount': repayAmount,
      'productCode': productCode,
      'productLevel': productLevel,
      'productLogo': productLogo,
      'statusCode': statusCode,
      'statusText': statusText,
      'totalServiceDays': totalServiceDays,
      'remainingDays': remainingDays,
      'interest': interest,
      'serviceFee': serviceFee,
      'term': term,
      'repaidAmount': repaidAmount,
      'rawRepayDate': rawRepayDate,
      'repayDateStr': repayDateStr,
      'isExtensionSwitch': isExtensionSwitch,
      'borrowDate': borrowDate,
      'dueDate': dueDate,
      'momoAccount': momoAccount,
      'walletType': walletType,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

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

  static int? _parseProductLevel(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  static String _formatOrderHistoryDate(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '';

    final datePart = trimmed.contains(' ') ? trimmed.split(' ').first : trimmed;
    return datePart.formatBackendDate();
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
      case 22:
        return const LoanOrderDetailStatusVisual(
          title: AppStrings.loanOrderStatusReviewFailed,
          kind: LoanOrderDetailStatusKind.failed,
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
