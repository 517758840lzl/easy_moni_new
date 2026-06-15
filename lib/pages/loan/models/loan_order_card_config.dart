import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/utils/extensions.dart';

/// 订单卡片展示模式，使用固定实例替代 enum。
class LoanOrderCardMode {
  const LoanOrderCardMode._(this.key);

  /// 模式唯一标识，避免无字段 const 实例被 Dart 规范化为同一个对象。
  final String key;

  static const LoanOrderCardMode repaymentStatus =
      LoanOrderCardMode._('repaymentStatus');
  static const LoanOrderCardMode loanConfirm = LoanOrderCardMode._(
    'loanConfirm',
  );
}

/// 订单字段类型，负责描述配置项读取哪一类订单数据。
class LoanOrderCardFieldType {
  const LoanOrderCardFieldType._(this.key);

  final String key;

  static const LoanOrderCardFieldType loanAmount =
      LoanOrderCardFieldType._('loanAmount');
  static const LoanOrderCardFieldType loanTerm =
      LoanOrderCardFieldType._('loanTerm');
  static const LoanOrderCardFieldType serviceFee =
      LoanOrderCardFieldType._('serviceFee');
  static const LoanOrderCardFieldType interest =
      LoanOrderCardFieldType._('interest');
  static const LoanOrderCardFieldType repaymentDate =
      LoanOrderCardFieldType._('repaymentDate');
  static const LoanOrderCardFieldType receiptAmount =
      LoanOrderCardFieldType._('receiptAmount');
  static const LoanOrderCardFieldType repayAmount =
      LoanOrderCardFieldType._('repayAmount');
  static const LoanOrderCardFieldType dueDate =
      LoanOrderCardFieldType._('dueDate');
}

/// 订单字段数据快照，避免配置层直接依赖具体接口实体。
class LoanOrderCardFieldData {
  const LoanOrderCardFieldData({
    required this.loanAmount,
    required this.receiptAmount,
    required this.repayAmount,
    required this.dueDate,
    this.totalServiceDays,
    this.serviceFee,
    this.interest,
  });

  final num loanAmount;
  final num receiptAmount;
  final num repayAmount;
  final String? dueDate;
  final int? totalServiceDays;
  final num? serviceFee;
  final num? interest;
}

/// 单个订单信息行配置，包含展示标题和取值类型。
class LoanOrderCardFieldConfig {
  const LoanOrderCardFieldConfig({
    required this.label,
    required this.type,
  });

  final String label;
  final LoanOrderCardFieldType type;

  String resolveValue(LoanOrderCardFieldData data) {
    if (type == LoanOrderCardFieldType.loanAmount) {
      return _formatAmount(data.loanAmount);
    }
    if (type == LoanOrderCardFieldType.loanTerm) {
      return data.totalServiceDays == null
          ? AppStrings.loanOrderUnknownValue
          : '${data.totalServiceDays} ${AppStrings.loanOrderDaysUnit}';
    }
    if (type == LoanOrderCardFieldType.serviceFee) {
      return _formatAmount(data.serviceFee ?? 0);
    }
    if (type == LoanOrderCardFieldType.interest) {
      return _formatAmount(data.interest ?? 0);
    }
    if (type == LoanOrderCardFieldType.repaymentDate) {
      return data.dueDate ?? AppStrings.loanOrderEmptyValue;
    }
    if (type == LoanOrderCardFieldType.receiptAmount) {
      return _formatAmount(data.receiptAmount);
    }
    if (type == LoanOrderCardFieldType.repayAmount) {
      return _formatAmount(data.repayAmount);
    }
    if (type == LoanOrderCardFieldType.dueDate) {
      return data.dueDate ?? AppStrings.loanOrderEmptyValue;
    }
    return AppStrings.loanOrderEmptyValue;
  }

  static String _formatAmount(num value) {
    return value.toDouble().formatAmount(showCurrencySymbol: true);
  }
}

/// 订单卡片配置，统一控制字段列表、页脚和状态角标等展示规则。
class LoanOrderCardConfig {
  const LoanOrderCardConfig({
    required this.height,
    required this.fields,
    required this.showStatusBadge,
    required this.showFooter,
  });

  final double height;
  final List<LoanOrderCardFieldConfig> fields;
  final bool showStatusBadge;
  final bool showFooter;

  static const LoanOrderCardConfig repaymentStatus = LoanOrderCardConfig(
    height: 204,
    showStatusBadge: true,
    showFooter: true,
    fields: [
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderLoanAmountLabel,
        type: LoanOrderCardFieldType.loanAmount,
      ),
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderReceiptAmountLabel,
        type: LoanOrderCardFieldType.receiptAmount,
      ),
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderRepayAmountLabel,
        type: LoanOrderCardFieldType.repayAmount,
      ),
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderDueDateLabel,
        type: LoanOrderCardFieldType.dueDate,
      ),
    ],
  );

  static const LoanOrderCardConfig loanConfirm = LoanOrderCardConfig(
    height: 198,
    showStatusBadge: false,
    showFooter: false,
    fields: [
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderLoanAmountLabel,
        type: LoanOrderCardFieldType.loanAmount,
      ),
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderLoanTermLabel,
        type: LoanOrderCardFieldType.loanTerm,
      ),
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderServiceFeeLabel,
        type: LoanOrderCardFieldType.serviceFee,
      ),
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderInterestLabel,
        type: LoanOrderCardFieldType.interest,
      ),
      LoanOrderCardFieldConfig(
        label: AppStrings.loanOrderRepaymentDateLabel,
        type: LoanOrderCardFieldType.repaymentDate,
      ),
    ],
  );

  static LoanOrderCardConfig forMode(LoanOrderCardMode mode) {
    if (mode == LoanOrderCardMode.loanConfirm) {
      return loanConfirm;
    }
    return repaymentStatus;
  }
}
