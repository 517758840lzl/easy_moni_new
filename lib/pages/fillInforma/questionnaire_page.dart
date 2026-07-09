import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/providers/questionnaire_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/personal_info_form_item.dart';
import 'package:easy_moni/pages/fillInforma/widgets/picker_bottom_sheet.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/limit_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  static const Duration _submitDialogMinDuration = Duration(seconds: 2);
  final ScrollController _scrollController = ScrollController();
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSubmitDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SubmitProgressDialog(),
    );
  }

  void _hideSubmitDialog() {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  /// 展示问卷选择项通用底部弹窗，并在确认后同步表单状态。
  Future<bool> _showPicker({
    required FormEntry entry,
    required List<SelectOption> options,
    required int selectedIndex,
  }) async {
    var isConfirmed = false;
    await PickerBottomSheet.show(
      context: context,
      title: entry.showContent,
      options: options
          .map((option) => PickerBottomSheetOption(label: option.value))
          .toList(),
      selectedIndex: selectedIndex,
      onConfirm: (index) {
        isConfirmed = true;
        final option = options[index];
        ref
            .read(questionnaireProvider.notifier)
            .selectOption(entry: entry, option: option, index: index);
      },
    );

    return isConfirmed;
  }

  Future<bool> _showPickerForEntry(FormEntry entry) async {
    final options = entry.selectList;
    if (options == null || options.isEmpty) return false;

    final formState = ref.read(questionnaireProvider).value;
    return _showPicker(
      entry: entry,
      options: options,
      selectedIndex: formState?.selectedIndices[entry.key] ?? 0,
    );
  }

  Future<void> _onPickerEntryTap(FormEntry entry) async {
    final confirmed = await _showPickerForEntry(entry);
    if (!confirmed || !mounted) return;

    final formState = ref.read(questionnaireProvider).value;
    if (formState == null) return;

    final entries = formState.entries;
    final currentIndex = entries.indexWhere((item) => item.key == entry.key);
    if (currentIndex < 0) return;

    final notifier = ref.read(questionnaireProvider.notifier);
    for (var i = currentIndex + 1; i < entries.length; i++) {
      final nextEntry = entries[i];
      if (!notifier.isPickerEntry(nextEntry)) continue;

      final latestState = ref.read(questionnaireProvider).value;
      final value = latestState?.selectedSubmitValues[nextEntry.key];
      if (value != null && value.isNotEmpty) continue;

      final nextConfirmed = await _showPickerForEntry(nextEntry);
      if (!nextConfirmed || !mounted) break;
    }
  }

  Future<void> _onSubmit() async {
    _showSubmitDialog();
    final delayFuture = Future<void>.delayed(_submitDialogMinDuration);
    final result = await ref.read(questionnaireProvider.notifier).submit();
    await delayFuture;
    if (!mounted) return;

    _hideSubmitDialog();

    if (result.isSuccess) {
      final submitData = result.submitData;
      if (submitData == null) {
        _showSnackBar(result.message ?? AppStrings.questionnaireSaveFailed);
        return;
      }

      final route = AcquisitionProgressRouteResolver.resolveSubmitResult(
        submitData,
      );
      context.go(route);
      return;
    }

    _showSnackBar(result.message ?? AppStrings.questionnaireSaveFailed);
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireAsync = ref.watch(questionnaireProvider);
    final formState = questionnaireAsync.value;
    final pageTitle = formState?.stepInfo?.pageTitle.trim().isNotEmpty == true
        ? formState!.stepInfo!.pageTitle
        : AppStrings.questionnaireDefaultTitle;

    return FundingLimitPopScope(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image(
                image: Assets.images.loanBg.provider(),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: Text(
                      pageTitle,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.only(left: 24, right: 150),
                    child: Text(
                      AppStrings.questionnaireDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: _buildBody(questionnaireAsync),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: LoanBottomActionButton(
          enabled: formState?.canSubmit ?? false,
          onPressed: _onSubmit,
          text: (formState?.isSubmitting ?? false)
              ? AppStrings.questionnaireSaving
              : AppStrings.questionnaireSubmitButton,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            GestureDetector(
              // 返回时展示统一挽留弹窗，避免直接弹空 GoRouter 页面栈。
              onTap: () => FundingLimitDialog.showRetainDialog(context),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(width: 44, height: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AsyncValue<QuestionnaireState> questionnaireAsync) {
    return questionnaireAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFFACACAC)),
          ),
        ),
      ),
      data: (formState) {
        if (formState.entries.isEmpty) {
          return const Center(
            child: Text(
              AppStrings.questionnaireNoData,
              style: TextStyle(fontSize: 14, color: Color(0xFFACACAC)),
            ),
          );
        }

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          radius: const Radius.circular(8),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                for (var i = 0; i < formState.entries.length; i++)
                  _buildEntryItem(
                    formState: formState,
                    entry: formState.entries[i],
                    showDivider: i != formState.entries.length - 1,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 根据问卷表单配置复用个人信息表单项，统一选择项与输入项样式。
  Widget _buildEntryItem({
    required QuestionnaireState formState,
    required FormEntry entry,
    required bool showDivider,
  }) {
    final isPicker = ref
        .read(questionnaireProvider.notifier)
        .isPickerEntry(entry);
    if (isPicker) {
      return PersonalInfoFormItem(
        title: entry.showContent,
        isRequired: entry.must == 1,
        value: formState.selectedValues[entry.key],
        placeholder: entry.defaultText,
        showDivider: showDivider,
        onTap: () => _onPickerEntryTap(entry),
      );
    }

    final controller = _textControllers[entry.key] ??= TextEditingController(
      text: formState.selectedSubmitValues[entry.key] ?? '',
    );

    return PersonalInfoFormItem(
      title: entry.showContent,
      isRequired: entry.must == 1,
      placeholder: entry.defaultText,
      controller: controller,
      showDivider: showDivider,
      onChanged: (value) {
        ref
            .read(questionnaireProvider.notifier)
            .updateTextValue(entry: entry, value: value);
      },
    );
  }
}

class _SubmitProgressDialog extends StatelessWidget {
  const _SubmitProgressDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 307,
            height: 370,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: Assets.images.loanCard.provider(),
                fit: BoxFit.contain,
              ),
            ),
            child: const Stack(
              children: [
                Positioned(
                  left: 24,
                  right: 24,
                  top: 86,
                  child: Text(
                    AppStrings.questionnaireAuthentication,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Color(0xFF055CFF),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  top: 248,
                  child: Text(
                    AppStrings.questionnaireSubmitWaiting,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
