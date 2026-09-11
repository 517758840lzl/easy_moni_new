import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/controllers/contact_info_form_controller.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/utils/form_entry_input_type_helper.dart';
import 'package:easy_moni/pages/fillInforma/widgets/personal_info_form_item.dart';
import 'package:easy_moni/pages/fillInforma/widgets/picker_bottom_sheet.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:easy_moni/pages/loan/components/loan_rounded_page.dart';
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
  static const double _stepIndicatorHeight = 80;
  static const double _headerBottomGap = 16;

  final ContactInfoFormController _formController = ContactInfoFormController();
  final ScrollController _contentScrollController = ScrollController();

  StepInfo? _stepInfo;
  int? _processId;
  bool _isLoading = true;
  bool _isSubmitting = false;

  bool get _canContinue => !_isLoading && _formController.canSubmit;

  @override
  void initState() {
    super.initState();
    _fetchStepInfo();
  }

  @override
  void dispose() {
    _formController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchStepInfo() async {
    try {
      final result = await ref.read(acpElementInfoProvider).call(2);
      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        final stepInfo = result.data!.stepInfoList.firstOrNull;
        _stepInfo = stepInfo;
        _processId = result.data!.processId;
        _formController.applyEntries(stepInfo?.entries ?? []);
      } else {
        _showSnackBar(result.message ?? AppStrings.contactInfoLoadFailed);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('${AppStrings.contactInfoLoadFailed}: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleTextChanged(FormEntry entry, String value) {
    final canContinueBefore = _canContinue;
    _formController.updateTextValue(entry, value);
    if (_canContinue != canContinueBefore && mounted) {
      setState(() {});
    }
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _pickContact(FormEntry entry) async {
    try {
      final contact = await ContactsService.pickContact();
      if (contact == null) {
        return;
      }

      final displayName = contact['name'] ?? '';
      final phone = contact['phone'] ?? '';
      if (phone.isEmpty) {
        _showSnackBar(AppStrings.contactInfoNoPhoneNumber);
        return;
      }

      setState(() {
        _formController.updateContactValue(
          entry: entry,
          name: displayName,
          phone: phone,
        );
      });
    } catch (e) {
      _showSnackBar(AppStrings.contactInfoPickFailed);
    }
  }

  Future<void> _openPickerForEntry(FormEntry entry) async {
    final options = entry.selectList;
    if (options == null || options.isEmpty) {
      return;
    }

    await PickerBottomSheet.show(
      context: context,
      title: entry.showContent,
      options: options
          .map((item) => PickerBottomSheetOption(label: item.value))
          .toList(),
      selectedIndex: _formController.selectedIndexFor(entry),
      onConfirm: (index) {
        setState(() => _formController.updatePickerValue(entry, index));
      },
    );
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
      final jsonParam = _formController.buildSubmitParams();
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
          _showSnackBar(result.message ?? AppStrings.errorMessage);
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
        _showSnackBar(result.message ?? AppStrings.contactInfoSaveFailed);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('${AppStrings.contactInfoSaveFailed}: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String get _pageTitle {
    final pageTitle = _stepInfo?.pageTitle.trim() ?? '';
    return pageTitle.isNotEmpty ? pageTitle : AppStrings.contactInfoTitle;
  }

  double _contentTop(BuildContext context) {
    return MediaQuery.of(context).padding.top +
        _headerTitleBarHeight +
        _headerTopGap +
        _stepIndicatorHeight +
        _headerBottomGap;
  }

  @override
  Widget build(BuildContext context) {
    return FundingLimitPopScope(
      child: LoanRoundedPage(
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
          onPressed: _canContinue && !_isSubmitting ? _onContinue : null,
          text: _isSubmitting
              ? AppStrings.personalInfoSaving
              : AppStrings.continueStr,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Scrollbar(
        controller: _contentScrollController,
        thumbVisibility: true,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: _contentScrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (var i = 0; i < _formController.entries.length; i++)
                _buildEntryItem(
                  entry: _formController.entries[i],
                  showDivider: i != _formController.entries.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryItem({
    required FormEntry entry,
    required bool showDivider,
  }) {
    if (FormEntryInputTypeHelper.isDisplayOnly(entry)) {
      return PersonalInfoDisplayFormItem(
        title: entry.showContent,
        isRequired: entry.must == 1,
        showDivider: showDivider,
      );
    }

    if (FormEntryInputTypeHelper.isPicker(entry)) {
      return PersonalInfoFormItem(
        isRequired: entry.must == 1,
        value: _formController.displayValueFor(entry),
        placeholder: entry.defaultText,
        showDivider: showDivider,
        focusNode: _formController.focusNodeFor(entry),
        onTap: () => _openPickerForEntry(entry),
      );
    }

    if (FormEntryInputTypeHelper.isContactPicker(entry) &&
        !FormEntryInputTypeHelper.isContactInputOrPick(entry)) {
      return PersonalInfoFormItem(
        isRequired: entry.must == 1,
        value: _formController.displayValueFor(entry),
        placeholder: AppStrings.contactPlaceholder,
        showDivider: showDivider,
        focusNode: _formController.focusNodeFor(entry),
        trailing: Assets.images.notebook.image(width: 22, height: 22),
        onTap: () => _pickContact(entry),
      );
    }

    if (FormEntryInputTypeHelper.isTextInput(entry)) {
      final isContactInput = FormEntryInputTypeHelper.isContactInputOrPick(
        entry,
      );
      return PersonalInfoFormItem(
        isRequired: entry.must == 1,
        placeholder: AppStrings.contactPlaceholder,
        controller: _formController.controllerFor(entry),
        focusNode: _formController.focusNodeFor(entry),
        keyboardType: FormEntryInputTypeHelper.keyboardTypeFor(entry),
        inputFormatters: FormEntryInputTypeHelper.inputFormattersFor(entry),
        textInputAction: TextInputAction.next,
        showDivider: showDivider,
        inputTrailing: isContactInput
            ? Assets.images.notebook.image(width: 22, height: 22)
            : null,
        onInputTrailingTap: isContactInput ? () => _pickContact(entry) : null,
        onChanged: (value) => _handleTextChanged(entry, value),
      );
    }

    return PersonalInfoDisplayFormItem(
      title: entry.showContent,
      isRequired: entry.must == 1,
      showDivider: showDivider,
    );
  }
}
