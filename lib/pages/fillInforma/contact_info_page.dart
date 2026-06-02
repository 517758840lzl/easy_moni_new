import 'package:easy_moni/core/constants/app_strings.dart';
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
  static const String _codePrimaryName = '30053';
  static const String _codeSecondaryRelation = '30061';
  static const String _codeSecondaryName = '30063';

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
            if (entry.code == _codeSecondaryName &&
                entry.submitValue != null &&
                entry.submitValue!.isNotEmpty) {
              _friendColleagueName = entry.submitValue;
            }
          }
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message ?? '联系人信息加载失败')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('联系人信息加载失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickContact({required bool isParentSpouse}) async {
    // 请求通讯录权限
    bool hasPermission = await ContactsService.checkPermission();

    if (!hasPermission) {
      hasPermission = await ContactsService.requestPermission();
      if (!hasPermission) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    // 获取通讯录联系人
    try {
      List<Map<String, String>>? contacts = await ContactsService.getContacts();

      if (contacts == null || contacts.isEmpty) {
        _showNoContactsDialog();
        return;
      }

      _showContactPicker(contacts: contacts, isParentSpouse: isParentSpouse);
    } catch (e) {
      debugPrint('获取通讯录失败: $e');
      _showErrorDialog('获取通讯录失败，请重试');
    }
  }

  void _showContactPicker({
    required List<Map<String, String>> contacts,
    required bool isParentSpouse,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      builder: (context) {
        return Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE7E7E7))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    isParentSpouse
                        ? AppStrings.chooseContacts
                        : AppStrings.chooseFriends,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final displayName = contact['name'] ?? 'Unknown';
                  final phone = contact['phone'] ?? '';

                  return ListTile(
                    onTap: () {
                      setState(() {
                        if (isParentSpouse) {
                          _parentSpouseName = displayName;
                          _parentSpouseContact = phone;
                        } else {
                          _friendColleagueName = displayName;
                          _friendColleagueContact = phone;
                        }
                      });
                      Navigator.pop(context);
                    },
                    leading: CircleAvatar(
                      backgroundColor: const Color(
                        0xFF268470,
                      ).withValues(alpha: 0.1),
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFF268470),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    subtitle: Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      builder: (context) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.contacts, size: 64, color: Color(0xFF268470)),
              const SizedBox(height: 24),
              const Text(
                AppStrings.needsContacts,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101314),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '请允许访问通讯录以选择联系人。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3F4950),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF268470)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: Color(0xFF268470),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // openAppSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF268470),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          AppStrings.goSettings,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showNoContactsDialog() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.contactsEmpty)));
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      final relationSecondary = _stepInfo!.entries
          .where((entry) => entry.code == _codeSecondaryRelation)
          .cast<FormEntry?>()
          .firstOrNull;
      final nameSecondary = _stepInfo!.entries
          .where((entry) => entry.code == _codeSecondaryName)
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

      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: jsonParam,
          );

      if (!mounted) return;
      if (result.isSuccess) {
        context.push('/identity-verify');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message ?? '保存失败')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
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
            title: '联系人信息',
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
                            placeholder: '从通讯录中选择',
                            onTap: () => _pickContact(isParentSpouse: true),
                          ),
                          _buildContactItem(
                            title: '朋友/同事联系电话',
                            value: _friendColleagueContact != null
                                ? '$_friendColleagueName\n$_friendColleagueContact'
                                : null,
                            placeholder: '从通讯录中选择',
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
            text: _isSubmitting ? '保存中...' : '继续',
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
