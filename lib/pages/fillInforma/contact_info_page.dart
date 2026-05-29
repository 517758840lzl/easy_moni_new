import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progressInformation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../gen/assets.gen.dart';
import '../../services/platform_service.dart';
import '../../utils/widgets/linepaint.dart';

class ContactInfoPage extends ConsumerStatefulWidget {
  const ContactInfoPage({super.key});

  @override
  ConsumerState<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends ConsumerState<ContactInfoPage> {
  String? _parentSpouseContact = '0241234567';
  String? _friendColleagueContact = '0249876543';
  String? _parentSpouseName = 'John Doe';
  String? _friendColleagueName = 'Jane Smith';

  bool get _canContinue =>
      _parentSpouseContact != null &&
      _parentSpouseContact!.isNotEmpty &&
      _friendColleagueContact != null &&
      _friendColleagueContact!.isNotEmpty;

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

  void _onContinue() {
    if (_canContinue) {
      debugPrint('父母/配偶: $_parentSpouseName - $_parentSpouseContact');
      debugPrint('朋友/同事: $_friendColleagueName - $_friendColleagueContact');
      context.push('/identity-verify');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Assets.images.inforamtionBgheader.provider(),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 44),
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
                              '联系人信息',
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
                  const SizedBox(height: 16),
                  buildProgressIndicator(isidActive: true),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildContactItem(
                      icon: Assets.images.inforamtionF.image(),
                      title: AppStrings.chooseContactsPhone,
                      value: _parentSpouseContact != null
                          ? '$_parentSpouseName\n$_parentSpouseContact'
                          : null,
                      placeholder: '从通讯录中选择',
                      onTap: () => _pickContact(isParentSpouse: true),
                    ),
                    _buildContactItem(
                      icon: Assets.images.inforamtionF.image(),
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
          Container(
            height: 48,
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 4,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: GestureDetector(
              onTap: _canContinue ? _onContinue : null,
              child: Container(
                decoration: BoxDecoration(
                  color: _canContinue
                      ? const Color(0xFF45F3A6)
                      : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    '继续',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _canContinue
                          ? const Color(0xFF104440)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required Widget icon,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
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
                        )
                      else
                        Row(
                          children: [
                            Text(
                              placeholder,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFCCCCCC),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.edit_note,
                              size: 22,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) Container(height: 1, color: const Color(0xFFF5F5F5)),
      ],
    );
  }
}
