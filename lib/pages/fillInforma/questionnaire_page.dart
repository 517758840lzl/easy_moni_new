import 'package:easy_moni/core/router/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../entities/acp_element_info_resp.dart';
import '../../gen/assets.gen.dart';
import '../../utils/widgets/informationBottomButton.dart';
import 'providers/questionnaire_provider.dart';

class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  static const Duration _submitDialogMinDuration = Duration(seconds: 2);

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

  Future<bool> _showPicker({
    required FormEntry entry,
    required List<SelectOption> options,
    required int selectedIndex,
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
                        Flexible(
                          child: Text(
                            entry.showContent,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final option = options[tempSelectedIndex];
                            ref
                                .read(questionnaireProvider.notifier)
                                .selectOption(
                                  entry: entry,
                                  option: option,
                                  index: tempSelectedIndex,
                                );
                            Navigator.pop(context, true);
                          },
                          child: const Text(
                            'Confirm',
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
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedIndex,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        tempSelectedIndex = index;
                      },
                      children: options
                          .map(
                            (option) => Center(
                              child: Text(
                                option.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                ],
              ),
            );
          },
        );
      },
    );

    return result ?? false;
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
      context.go(AppRoutePaths.home);
      return;
    }

    _showSnackBar(result.message ?? 'Save failed');
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireAsync = ref.watch(questionnaireProvider);
    final formState = questionnaireAsync.value;
    final pageTitle = formState?.stepInfo?.pageTitle.trim().isNotEmpty == true
        ? formState!.stepInfo!.pageTitle
        : 'Credit Report';

    return Scaffold(
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
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(left: 24, right: 150),
                  child: Text(
                    'Complete this questionnaire to help us better evaluate your credit profile.',
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
      bottomNavigationBar: BottomContinueButton(
        isEnabled: formState?.canSubmit ?? false,
        onTap: _onSubmit,
        text: (formState?.isSubmitting ?? false)
            ? 'Saving...'
            : 'Submit report, get quota',
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
              onTap: () => Navigator.of(context).pop(),
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
              'No questionnaire data',
              style: TextStyle(fontSize: 14, color: Color(0xFFACACAC)),
            ),
          );
        }

        return SingleChildScrollView(
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
        );
      },
    );
  }

  Widget _buildEntryItem({
    required QuestionnaireState formState,
    required FormEntry entry,
    required bool showDivider,
  }) {
    final isPicker = ref
        .read(questionnaireProvider.notifier)
        .isPickerEntry(entry);
    if (isPicker) {
      return _buildPickerItem(
        formState: formState,
        entry: entry,
        showDivider: showDivider,
      );
    }
    return _buildTextInputItem(
      formState: formState,
      entry: entry,
      showDivider: showDivider,
    );
  }

  Widget _buildPickerItem({
    required QuestionnaireState formState,
    required FormEntry entry,
    required bool showDivider,
  }) {
    final value = formState.selectedValues[entry.key];
    final hasValue = value != null && value.isNotEmpty;

    return GestureDetector(
      onTap: () => _onPickerEntryTap(entry),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEntryTitle(entry),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? value : entry.defaultText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.42,
                        color: hasValue
                            ? const Color(0xFF070707)
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (showDivider) _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputItem({
    required QuestionnaireState formState,
    required FormEntry entry,
    required bool showDivider,
  }) {
    final initialValue = formState.selectedSubmitValues[entry.key] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEntryTitle(entry),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: TextFormField(
              key: ValueKey(entry.key),
              initialValue: initialValue,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                hintText: entry.defaultText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCCCCCC),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF070707),
                height: 1.42,
              ),
              onChanged: (value) {
                ref
                    .read(questionnaireProvider.notifier)
                    .updateTextValue(entry: entry, value: value);
              },
            ),
          ),
          if (showDivider) _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildEntryTitle(FormEntry entry) {
    return Row(
      children: [
        if (entry.must == 1)
          const Text(
            '*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
              letterSpacing: 0.4,
            ),
          ),
        if (entry.must == 1) const SizedBox(width: 4),
        Expanded(
          child: Text(
            entry.showContent,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF070707),
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFFF5F5F5));
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
                    'Authentication',
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
                    'Just a moment...',
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
