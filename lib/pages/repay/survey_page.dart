import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';

class SurveyPage extends ConsumerStatefulWidget {
  const SurveyPage({super.key});

  @override
  ConsumerState<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends ConsumerState<SurveyPage> {
  String? _loanAmount;
  String? _loanPurpose;
  String? _unpaidAmount;
  String? _unpaidCount;
  String? _hasOverdue;
  String? _maxOverdueDays;
  String? _creditYears;

  final List<String> _loanAmountOptions = [
    '500-1000',
    '1000-2000',
    '2000-5000',
    '5000-10000',
    '10000以上',
  ];
  final List<String> _loanPurposeOptions = [
    '日常消费',
    '购物',
    '教育',
    '医疗',
    '装修',
    '其他',
  ];
  final List<String> _unpaidAmountOptions = [
    '无',
    '1000以下',
    '1000-5000',
    '5000-10000',
    '10000以上',
  ];
  final List<String> _unpaidCountOptions = ['无', '1笔', '2-3笔', '4-5笔', '5笔以上'];
  final List<String> _hasOverdueOptions = ['是', '否'];
  final List<String> _maxOverdueDaysOptions = [
    '无逾期',
    '7天以内',
    '7-30天',
    '30-60天',
    '60天以上',
  ];
  final List<String> _creditYearsOptions = ['1年以下', '1-3年', '3-5年', '5年以上'];

  int _selectedLoanAmountIndex = 0;
  int _selectedLoanPurposeIndex = 0;
  int _selectedUnpaidAmountIndex = 0;
  int _selectedUnpaidCountIndex = 0;
  int _selectedHasOverdueIndex = 0;
  int _selectedMaxOverdueDaysIndex = 0;
  int _selectedCreditYearsIndex = 0;

  bool get _canSubmit =>
      _loanAmount != null &&
      _loanPurpose != null &&
      _unpaidAmount != null &&
      _unpaidCount != null &&
      _hasOverdue != null &&
      _maxOverdueDays != null &&
      _creditYears != null;

  static const _fieldCount = 7;

  String? _getFieldValue(int index) {
    switch (index) {
      case 0:
        return _loanAmount;
      case 1:
        return _loanPurpose;
      case 2:
        return _unpaidAmount;
      case 3:
        return _unpaidCount;
      case 4:
        return _hasOverdue;
      case 5:
        return _maxOverdueDays;
      case 6:
        return _creditYears;
      default:
        return null;
    }
  }

  int _getFieldSelectedIndex(int index) {
    switch (index) {
      case 0:
        return _selectedLoanAmountIndex;
      case 1:
        return _selectedLoanPurposeIndex;
      case 2:
        return _selectedUnpaidAmountIndex;
      case 3:
        return _selectedUnpaidCountIndex;
      case 4:
        return _selectedHasOverdueIndex;
      case 5:
        return _selectedMaxOverdueDaysIndex;
      case 6:
        return _selectedCreditYearsIndex;
      default:
        return 0;
    }
  }

  void _setFieldValue(int index, int optionIndex) {
    switch (index) {
      case 0:
        _selectedLoanAmountIndex = optionIndex;
        _loanAmount = _loanAmountOptions[optionIndex];
      case 1:
        _selectedLoanPurposeIndex = optionIndex;
        _loanPurpose = _loanPurposeOptions[optionIndex];
      case 2:
        _selectedUnpaidAmountIndex = optionIndex;
        _unpaidAmount = _unpaidAmountOptions[optionIndex];
      case 3:
        _selectedUnpaidCountIndex = optionIndex;
        _unpaidCount = _unpaidCountOptions[optionIndex];
      case 4:
        _selectedHasOverdueIndex = optionIndex;
        _hasOverdue = _hasOverdueOptions[optionIndex];
      case 5:
        _selectedMaxOverdueDaysIndex = optionIndex;
        _maxOverdueDays = _maxOverdueDaysOptions[optionIndex];
      case 6:
        _selectedCreditYearsIndex = optionIndex;
        _creditYears = _creditYearsOptions[optionIndex];
    }
  }

  ({String title, List<String> options}) _getFieldMeta(int index) {
    switch (index) {
      case 0:
        return (title: '期望借款金额', options: _loanAmountOptions);
      case 1:
        return (title: '借款用途', options: _loanPurposeOptions);
      case 2:
        return (title: '未还款总金额', options: _unpaidAmountOptions);
      case 3:
        return (title: '未还贷款笔数', options: _unpaidCountOptions);
      case 4:
        return (title: '近6个月是否有逾期', options: _hasOverdueOptions);
      case 5:
        return (title: '最长逾期时长（近6个月）', options: _maxOverdueDaysOptions);
      case 6:
        return (title: '使用信贷服务年限', options: _creditYearsOptions);
      default:
        return (title: '', options: const []);
    }
  }

  Future<bool> _showPicker({
    required String title,
    required List<String> options,
    required int selectedIndex,
    required void Function(int) onConfirm,
  }) async {
    int tempSelectedIndex = selectedIndex;

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: 320,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE7E7E7)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context, false),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            onConfirm(tempSelectedIndex);
                            Navigator.pop(context, true);
                          },
                          child: const Text(
                            '确定',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF268470),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: tempSelectedIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          tempSelectedIndex = index;
                        },
                        children: options
                            .map(
                              (item) => Center(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _showPickerForField(int index) async {
    final meta = _getFieldMeta(index);
    return _showPicker(
      title: meta.title,
      options: meta.options,
      selectedIndex: _getFieldSelectedIndex(index),
      onConfirm: (optionIndex) {
        setState(() => _setFieldValue(index, optionIndex));
      },
    );
  }

  Future<void> _onFieldTap(int index) async {
    final confirmed = await _showPickerForField(index);
    if (!confirmed || !mounted) return;

    for (var i = index + 1; i < _fieldCount; i++) {
      if (_getFieldValue(i) != null) continue;
      final nextConfirmed = await _showPickerForField(i);
      if (!nextConfirmed || !mounted) break;
    }
  }

  void _onSubmit() {
    if (_canSubmit) {
      debugPrint(
        '提交问卷: $_loanAmount, $_loanPurpose, $_unpaidAmount, $_unpaidCount, $_hasOverdue, $_maxOverdueDays, $_creditYears',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('提交成功')));
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.images.loanBg.provider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 导航栏
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            '问卷调查',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 标题
                const Text(
                  '问卷调查',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // 副标题
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Text(
                    '完成这份问卷，帮助我们更全面地评估您的信用状况',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 80),
                // 表单内容区域
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildFormItem(
                            title: '期望借款金额',
                            value: _loanAmount,
                            placeholder: '请选择',
                            onTap: () => _onFieldTap(0),
                          ),
                          _buildFormItem(
                            title: '借款用途',
                            value: _loanPurpose,
                            placeholder: '请选择',
                            onTap: () => _onFieldTap(1),
                          ),
                          _buildFormItem(
                            title: '未还款总金额',
                            value: _unpaidAmount,
                            placeholder: '请选择',
                            onTap: () => _onFieldTap(2),
                          ),
                          _buildFormItem(
                            title: '未还贷款笔数',
                            value: _unpaidCount,
                            placeholder: '请选择',
                            onTap: () => _onFieldTap(3),
                          ),
                          _buildFormItem(
                            title: '近6个月是否有逾期',
                            value: _hasOverdue,
                            placeholder: '请选择',
                            onTap: () => _onFieldTap(4),
                          ),
                          _buildFormItem(
                            title: '最长逾期时长（近6个月）',
                            value: _maxOverdueDays,
                            placeholder: '请选择',
                            onTap: () => _onFieldTap(5),
                          ),
                          _buildFormItem(
                            title: '使用信贷服务年限',
                            value: _creditYears,
                            placeholder: '请选择',
                            onTap: () => _onFieldTap(6),
                            showDivider: false,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 底部提交按钮
      bottomNavigationBar: Container(
        height: 48 + MediaQuery.of(context).padding.bottom,
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 4,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: GestureDetector(
          onTap: _canSubmit ? _onSubmit : null,
          child: Container(
            decoration: BoxDecoration(
              color: _canSubmit
                  ? const Color(0xFF268470)
                  : const Color(0xFFBDBDBD),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Text(
                '提交报告，获取额度',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormItem({
    required String title,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value ?? placeholder,
                        style: TextStyle(
                          fontSize: 14,
                          color: value != null
                              ? Colors.black
                              : const Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 12,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: const Color(0xFFF5F5F5)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
