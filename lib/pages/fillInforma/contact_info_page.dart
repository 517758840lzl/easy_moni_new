import 'dart:convert';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/personal_info_form_item.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/widgets/limit_toast.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ContactInfoPage extends ConsumerStatefulWidget {
  const ContactInfoPage({super.key});

  @override
  ConsumerState<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends ConsumerState<ContactInfoPage> {
  static const double _headerTitleBarHeight = 44;
  static const double _headerTopGap = 16;
  static const double _stepIndicatorHeight = 56;
  static const double _headerBottomGap = 16;
  static const String _codePrimaryRelation = '30051';
  static const String _codePrimaryName = '30052';
  static const String _codePrimaryPhone = '30053';
  static const String _codeSecondaryRelation = '30061';
  static const String _codeSecondaryName = '30062';
  static const String _codeSecondaryPhone = '30063';

  StepInfo? _stepInfo;
  int? _processId;
  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _parentSpouseContact;
  String? _friendColleagueContact;
  String? _parentSpouseName;
  String? _friendColleagueName;

  @override
  void initState() {
    super.initState();
    _fetchStepInfo();
  }

  bool get _canContinue =>
      !_isLoading &&
      _parentSpouseContact != null &&
      _parentSpouseContact!.isNotEmpty &&
      _friendColleagueContact != null &&
      _friendColleagueContact!.isNotEmpty;

  Future<void> _fetchStepInfo() async {
    try {
      final result = await ref.read(acpElementInfoProvider).call(2);
      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        final stepInfo = result.data!.stepInfoList.isNotEmpty
            ? result.data!.stepInfoList.first
            : null;
        _stepInfo = stepInfo;
        _processId = result.data!.processId;

        if (stepInfo != null) _restoreSubmittedContacts(stepInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? AppStrings.contactInfoLoadFailed),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.contactInfoLoadFailed}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 恢复后台已提交过的联系人信息，用于页面回显。
  void _restoreSubmittedContacts(StepInfo stepInfo) {
    for (final entry in stepInfo.entries) {
      final submitValue = entry.submitValue;
      if (submitValue == null || submitValue.isEmpty) {
        continue;
      }

      if (entry.code == _codePrimaryName) {
        _parentSpouseName = submitValue;
      } else if (entry.code == _codePrimaryPhone) {
        _parentSpouseContact = _decodeContactPhone(submitValue);
      } else if (entry.code == _codeSecondaryName) {
        _friendColleagueName = submitValue;
      } else if (entry.code == _codeSecondaryPhone) {
        _friendColleagueContact = _decodeContactPhone(submitValue);
      }
    }
  }

  Future<void> _pickContact({required bool isParentSpouse}) async {
    try {
      final contact = await ContactsService.pickContact();

      if (contact == null) {
        return;
      }

      final displayName = contact['name'] ?? '';
      final phone = contact['phone'] ?? '';

      if (phone.isEmpty) {
        _showErrorDialog(AppStrings.contactInfoNoPhoneNumber);
        return;
      }

      setState(() {
        if (isParentSpouse) {
          _parentSpouseName = displayName;
          _parentSpouseContact = phone;
        } else {
          _friendColleagueName = displayName;
          _friendColleagueContact = phone;
        }
      });
    } catch (e) {
      AppLogger.debug('Failed to open contacts: $e');
      _showErrorDialog(AppStrings.contactInfoPickFailed);
    }
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _encodeContactPhone(String phoneNumber) {
    return jsonEncode({
      'contactPhoneNumber': _normalizeContactPhone(phoneNumber),
    });
  }

  /// 统一通讯录号码的提交格式，避免系统展示字符影响后端手机号校验。
  String _normalizeContactPhone(String phoneNumber) {
    return phoneNumber
        .trim()
        .replaceAll(RegExp(r'[^\d\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _decodeContactPhone(String submitValue) {
    try {
      final decoded = jsonDecode(submitValue);
      if (decoded is Map<String, dynamic>) {
        return decoded['contactPhoneNumber'] as String? ?? submitValue;
      }
    } catch (_) {
      return submitValue;
    }
    return submitValue;
  }

  Future<void> _onContinue() async {
    if (!_canContinue ||
        _isSubmitting ||
        _stepInfo == null ||
        _processId == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final jsonParam = _buildSubmitParams();
      AppLogger.debug('contactInfo jsonParam: ${jsonEncode(jsonParam)}');
      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: jsonParam,
          );

      if (!mounted) return;
      if (result.isSuccess) {
        final submitData = result.data;
        if (submitData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? AppStrings.errorMessage)),
          );
          return;
        }

        final route = AcquisitionProgressRouteResolver.resolveSubmitResult(
          submitData,
        );
        if (route == AppRoutePaths.home) {
          context.go(route);
        } else {
          context.push(route);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? AppStrings.contactInfoSaveFailed),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.contactInfoSaveFailed}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// 按后台表单项 key 组装提交参数，保持原有接口字段和值格式不变。
  List<Map<String, dynamic>> _buildSubmitParams() {
    final jsonParam = <Map<String, dynamic>>[];
    _addSubmitParam(
      jsonParam,
      code: _codePrimaryRelation,
      valueBuilder: (entry) => entry.submitValue ?? '1',
    );
    _addSubmitParam(
      jsonParam,
      code: _codePrimaryName,
      valueBuilder: (_) => _parentSpouseName ?? '',
    );
    _addSubmitParam(
      jsonParam,
      code: _codePrimaryPhone,
      valueBuilder: (_) => _encodeContactPhone(_parentSpouseContact ?? ''),
    );
    _addSubmitParam(
      jsonParam,
      code: _codeSecondaryRelation,
      valueBuilder: (entry) => entry.submitValue ?? '2',
    );
    _addSubmitParam(
      jsonParam,
      code: _codeSecondaryName,
      valueBuilder: (_) => _friendColleagueName ?? '',
    );
    _addSubmitParam(
      jsonParam,
      code: _codeSecondaryPhone,
      valueBuilder: (_) => _encodeContactPhone(_friendColleagueContact ?? ''),
    );
    return jsonParam;
  }

  void _addSubmitParam(
    List<Map<String, dynamic>> jsonParam, {
    required String code,
    required String Function(FormEntry entry) valueBuilder,
  }) {
    final entry = _findEntryByCode(code);
    if (entry == null) return;

    jsonParam.add({'key': entry.key, 'value': valueBuilder(entry)});
  }

  FormEntry? _findEntryByCode(String code) {
    return _stepInfo!.entries
        .where((entry) => entry.code == code)
        .cast<FormEntry?>()
        .firstOrNull;
  }

  /// 获取后端配置的页面标题，接口缺省时使用本地文案兜底。
  String get _pageTitle {
    final pageTitle = _stepInfo?.pageTitle.trim() ?? '';
    return pageTitle.isNotEmpty ? pageTitle : AppStrings.contactInfoTitle;
  }

  /// 根据表单 code 获取后端配置的展示标题。
  String _entryTitle(String code, String fallback) {
    final entry = _stepInfo?.entries
        .where((entry) => entry.code == code)
        .cast<FormEntry?>()
        .firstOrNull;
    final showContent = entry?.showContent.trim() ?? '';
    return showContent.isNotEmpty ? showContent : fallback;
  }

  /// 按信息采集流程 header 比例计算白色内容区起点。
  double _contentTop(BuildContext context) {
    return MediaQuery.of(context).padding.top +
        _headerTitleBarHeight +
        _headerTopGap +
        _stepIndicatorHeight +
        _headerBottomGap;
  }

  @override
  Widget build(BuildContext context) {
    return LoanRoundedPageShell(
      contentTop: _contentTop,
      contentTopRadius: 12,
      backgroundColor: AppColors.primaryDark,
      header: buildInformationHeader(
        context: context,
        title: _pageTitle,
        activeStep: InformationStep.personal,
        onBack: () => FundingLimitDialog.showRetainDialog(context),
      ),
      content: _buildContent(),
      bottomNavigationBar: LoanBottomActionButton(
        enabled: _canContinue && !_isSubmitting,
        onPressed: () => _onContinue(),
        text: _isSubmitting
            ? AppStrings.personalInfoSaving
            : AppStrings.continueStr,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildContactItem(
            title: _entryTitle(
              _codePrimaryRelation,
              AppStrings.chooseContactsPhone,
            ),
            value: _buildContactDisplayValue(
              _parentSpouseName,
              _parentSpouseContact,
            ),
            onTap: () => _pickContact(isParentSpouse: true),
          ),
          _buildContactItem(
            title: _entryTitle(
              _codeSecondaryRelation,
              AppStrings.contactInfoFriendColleaguePhone,
            ),
            value: _buildContactDisplayValue(
              _friendColleagueName,
              _friendColleagueContact,
            ),
            onTap: () => _pickContact(isParentSpouse: false),
          ),
        ],
      ),
    );
  }

  String? _buildContactDisplayValue(String? name, String? phone) {
    if (phone == null || phone.isEmpty) {
      return null;
    }
    final contactName = name?.trim() ?? '';
    if (contactName.isEmpty) {
      return phone;
    }
    return '$contactName-$phone';
  }

  Widget _buildContactItem({
    required String title,
    required String? value,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return PersonalInfoFormItem(
      title: title,
      placeholder: AppStrings.contactPlaceholder,
      isRequired: true,
      value: value,
      onTap: onTap,
      showDivider: showDivider,
      trailing: Assets.images.notebook.image(width: 22, height: 22),
    );
  }
}
