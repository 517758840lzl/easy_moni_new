import 'dart:convert';
import 'package:easy_moni/core/utils/app_logger.dart';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progressInformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../gen/assets.gen.dart';
import '../../services/platform_service.dart';
import '../../entities/acp_element_info_resp.dart';
import '../../utils/widgets/informationBottomButton.dart';
import '../../utils/widgets/limit_toast.dart';
import 'providers/acp_element_info_provider.dart';
import 'providers/submit_acp_element_info_provider.dart';

class ContactInfoPage extends ConsumerStatefulWidget {
  const ContactInfoPage({super.key});

  @override
  ConsumerState<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends ConsumerState<ContactInfoPage> {
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

  String? _parentSpouseContact = '0241234567';
  String? _friendColleagueContact = '0249876543';
  String? _parentSpouseName = 'John Doe';
  String? _friendColleagueName = 'Jane Smith';

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

        if (stepInfo != null) {
          for (final entry in stepInfo.entries) {
            if (entry.code == _codePrimaryName &&
                entry.submitValue != null &&
                entry.submitValue!.isNotEmpty) {
              _parentSpouseName = entry.submitValue;
            }
            if (entry.code == _codePrimaryPhone &&
                entry.submitValue != null &&
                entry.submitValue!.isNotEmpty) {
              _parentSpouseContact = _decodeContactPhone(entry.submitValue!);
            }
            if (entry.code == _codeSecondaryName &&
                entry.submitValue != null &&
                entry.submitValue!.isNotEmpty) {
              _friendColleagueName = entry.submitValue;
            }
            if (entry.code == _codeSecondaryPhone &&
                entry.submitValue != null &&
                entry.submitValue!.isNotEmpty) {
              _friendColleagueContact = _decodeContactPhone(entry.submitValue!);
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Failed to load contacts')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load contacts: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        _showErrorDialog('No phone number found for this contact');
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
      _showErrorDialog('Failed to open contacts. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _encodeContactPhone(String phoneNumber) {
    return jsonEncode({'contactPhoneNumber': phoneNumber});
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
      final relationPrimary = _stepInfo!.entries
          .where((entry) => entry.code == _codePrimaryRelation)
          .cast<FormEntry?>()
          .firstOrNull;
      final namePrimary = _stepInfo!.entries
          .where((entry) => entry.code == _codePrimaryName)
          .cast<FormEntry?>()
          .firstOrNull;
      final phonePrimary = _stepInfo!.entries
          .where((entry) => entry.code == _codePrimaryPhone)
          .cast<FormEntry?>()
          .firstOrNull;
      final relationSecondary = _stepInfo!.entries
          .where((entry) => entry.code == _codeSecondaryRelation)
          .cast<FormEntry?>()
          .firstOrNull;
      final nameSecondary = _stepInfo!.entries
          .where((entry) => entry.code == _codeSecondaryName)
          .cast<FormEntry?>()
          .firstOrNull;
      final phoneSecondary = _stepInfo!.entries
          .where((entry) => entry.code == _codeSecondaryPhone)
          .cast<FormEntry?>()
          .firstOrNull;
      final jsonParam = <Map<String, dynamic>>[];
      if (relationPrimary != null) {
        jsonParam.add({
          'key': relationPrimary.key,
          'value': relationPrimary.submitValue ?? '1',
        });
      }
      if (namePrimary != null) {
        jsonParam.add({
          'key': namePrimary.key,
          'value': _parentSpouseName ?? '',
        });
      }
      if (phonePrimary != null) {
        jsonParam.add({
          'key': phonePrimary.key,
          'value': _encodeContactPhone(_parentSpouseContact ?? ''),
        });
      }
      if (relationSecondary != null) {
        jsonParam.add({
          'key': relationSecondary.key,
          'value': relationSecondary.submitValue ?? '2',
        });
      }
      if (nameSecondary != null) {
        jsonParam.add({
          'key': nameSecondary.key,
          'value': _friendColleagueName ?? '',
        });
      }
      if (phoneSecondary != null) {
        jsonParam.add({
          'key': phoneSecondary.key,
          'value': _encodeContactPhone(_friendColleagueContact ?? ''),
        });
      }
      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: jsonParam,
          );

      if (!mounted) return;
      if (result.isSuccess) {
        context.push(AppRoutePaths.identityVerify);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Save failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          buildInformationHeader(
            context: context,
            title: 'Contact information',
            activeStep: InformationStep.personal,
            onBack: () => FundingLimitDialog.showRetainDialog(context),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildContactItem(
                            title: AppStrings.chooseContactsPhone,
                            value: _parentSpouseContact != null
                                ? '$_parentSpouseName\n$_parentSpouseContact'
                                : null,
                            placeholder: 'Choose from contacts',
                            onTap: () => _pickContact(isParentSpouse: true),
                          ),
                          _buildContactItem(
                            title: 'Friend/colleague phone number',
                            value: _friendColleagueContact != null
                                ? '$_friendColleagueName\n$_friendColleagueContact'
                                : null,
                            placeholder: 'Choose from contacts',
                            onTap: () => _pickContact(isParentSpouse: false),
                            showDivider: false,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          BottomContinueButton(
            isEnabled: _canContinue && !_isSubmitting,
            onTap: () => _onContinue(),
            text: _isSubmitting ? 'Saving...' : 'Continue',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required String title,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '*',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                      if (hasValue)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: value
                              .split('\n')
                              .map(
                                (line) => Text(
                                  line,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                Assets.images.notebook.image(width: 22, height: 22),
              ],
            ),
          ),
        ),
        if (showDivider) Container(height: 1, color: const Color(0xFFF5F5F5)),
      ],
    );
  }
}
