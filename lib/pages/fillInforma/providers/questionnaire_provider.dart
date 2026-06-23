import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/entities/submit_acp_info_resp.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final questionnaireProvider =
    AsyncNotifierProvider.autoDispose<
      QuestionnaireController,
      QuestionnaireState
    >(QuestionnaireController.new);

class QuestionnaireState {
  final StepInfo? stepInfo;
  final int? processId;
  final bool isSubmitting;
  final Map<String, int> selectedIndices;
  final Map<String, String?> selectedValues;
  final Map<String, String?> selectedSubmitValues;

  const QuestionnaireState({
    required this.stepInfo,
    required this.processId,
    required this.isSubmitting,
    required this.selectedIndices,
    required this.selectedValues,
    required this.selectedSubmitValues,
  });

  factory QuestionnaireState.empty() {
    return const QuestionnaireState(
      stepInfo: null,
      processId: null,
      isSubmitting: false,
      selectedIndices: {},
      selectedValues: {},
      selectedSubmitValues: {},
    );
  }

  List<FormEntry> get entries {
    final sortedEntries = [...?stepInfo?.entries];
    sortedEntries.sort((a, b) => a.order.compareTo(b.order));
    return sortedEntries;
  }

  bool get canSubmit {
    if (stepInfo == null || isSubmitting) return false;

    for (final entry in entries) {
      final value = selectedSubmitValues[entry.key];
      if (entry.must == 1 && (value == null || value.trim().isEmpty)) {
        return false;
      }
    }
    return true;
  }

  QuestionnaireState copyWith({
    StepInfo? stepInfo,
    int? processId,
    bool? isSubmitting,
    Map<String, int>? selectedIndices,
    Map<String, String?>? selectedValues,
    Map<String, String?>? selectedSubmitValues,
  }) {
    return QuestionnaireState(
      stepInfo: stepInfo ?? this.stepInfo,
      processId: processId ?? this.processId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      selectedValues: selectedValues ?? this.selectedValues,
      selectedSubmitValues: selectedSubmitValues ?? this.selectedSubmitValues,
    );
  }
}

class QuestionnaireSubmitResult {
  final bool isSuccess;
  final String? message;
  final SubmitAcpInfoResp? submitData;

  const QuestionnaireSubmitResult({
    required this.isSuccess,
    this.message,
    this.submitData,
  });
}

class QuestionnaireController extends AsyncNotifier<QuestionnaireState> {
  static const int _questionnaireStep = 6;

  @override
  Future<QuestionnaireState> build() async {
    final result = await ref
        .read(acpElementInfoProvider)
        .call(_questionnaireStep);

    if (!result.isSuccess || result.data == null) {
      throw Exception(result.message ?? 'Failed to load questionnaire');
    }

    final stepInfo = result.data!.stepInfoList.isNotEmpty
        ? result.data!.stepInfoList.first
        : null;

    return _buildInitialState(
      stepInfo: stepInfo,
      processId: result.data!.processId,
    );
  }

  bool isPickerEntry(FormEntry entry) {
    return entry.selectList != null && entry.selectList!.isNotEmpty;
  }

  void selectOption({
    required FormEntry entry,
    required SelectOption option,
    required int index,
  }) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(
        selectedIndices: {...currentState.selectedIndices, entry.key: index},
        selectedValues: {
          ...currentState.selectedValues,
          entry.key: option.value,
        },
        selectedSubmitValues: {
          ...currentState.selectedSubmitValues,
          entry.key: option.key,
        },
      ),
    );
  }

  void updateTextValue({required FormEntry entry, required String value}) {
    final currentState = state.value;
    if (currentState == null) return;

    final trimmedValue = value.trim();
    state = AsyncData(
      currentState.copyWith(
        selectedValues: {
          ...currentState.selectedValues,
          entry.key: trimmedValue,
        },
        selectedSubmitValues: {
          ...currentState.selectedSubmitValues,
          entry.key: trimmedValue,
        },
      ),
    );
  }

  Future<QuestionnaireSubmitResult> submit() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.canSubmit ||
        currentState.stepInfo == null ||
        currentState.processId == null) {
      return const QuestionnaireSubmitResult(
        isSuccess: false,
        message: 'Please complete the questionnaire',
      );
    }

    state = AsyncData(currentState.copyWith(isSubmitting: true));

    try {
      final jsonParam = currentState.entries.map((entry) {
        return {
          'key': entry.key,
          'value': currentState.selectedSubmitValues[entry.key] ?? '',
        };
      }).toList();

      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: currentState.processId!,
            step: currentState.stepInfo!.step,
            jsonParam: jsonParam,
          );

      return QuestionnaireSubmitResult(
        isSuccess: result.isSuccess,
        message: result.message,
        submitData: result.data,
      );
    } catch (e) {
      return QuestionnaireSubmitResult(
        isSuccess: false,
        message: 'Save failed: $e',
      );
    } finally {
      final latestState = state.value;
      if (latestState != null) {
        state = AsyncData(latestState.copyWith(isSubmitting: false));
      }
    }
  }

  QuestionnaireState _buildInitialState({
    required StepInfo? stepInfo,
    required int processId,
  }) {
    final selectedIndices = <String, int>{};
    final selectedValues = <String, String?>{};
    final selectedSubmitValues = <String, String?>{};

    if (stepInfo == null) {
      return QuestionnaireState.empty().copyWith(processId: processId);
    }

    for (final entry in stepInfo.entries) {
      final submitValue = entry.submitValue ?? '';
      selectedSubmitValues[entry.key] = submitValue;

      if (isPickerEntry(entry)) {
        final matchedIndex = entry.selectList!.indexWhere(
          (option) => option.key == submitValue,
        );
        if (matchedIndex >= 0) {
          selectedIndices[entry.key] = matchedIndex;
          selectedValues[entry.key] = entry.selectList![matchedIndex].value;
        } else {
          selectedIndices[entry.key] = 0;
          selectedValues[entry.key] = submitValue.isEmpty ? null : submitValue;
        }
      } else {
        selectedValues[entry.key] = submitValue;
      }
    }

    return QuestionnaireState(
      stepInfo: stepInfo,
      processId: processId,
      isSubmitting: false,
      selectedIndices: selectedIndices,
      selectedValues: selectedValues,
      selectedSubmitValues: selectedSubmitValues,
    );
  }
}
