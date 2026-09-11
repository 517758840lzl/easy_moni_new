class AcpElementInfoResp {
  final int processId;
  final List<StepInfo> stepInfoList;

  const AcpElementInfoResp({
    required this.processId,
    required this.stepInfoList,
  });

  factory AcpElementInfoResp.fromJson(Map<String, dynamic> json) {
    return AcpElementInfoResp(
      processId: json['processId'] as int? ?? 0,
      stepInfoList:
          (json['stepInfoList'] as List<dynamic>?)
              ?.map((e) => StepInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class StepInfo {
  final int step;
  final String pageTitle;
  final int pageType;
  final List<FormEntry> entries;

  const StepInfo({
    required this.step,
    required this.pageTitle,
    required this.pageType,
    required this.entries,
  });

  factory StepInfo.fromJson(Map<String, dynamic> json) {
    return StepInfo(
      step: json['step'] as int? ?? 0,
      pageTitle: json['pageTitle'] as String? ?? '',
      pageType: json['pageType'] as int? ?? 0,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => FormEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FormEntry {
  final String code;
  final String showContent;
  final String defaultText;
  final String? submitValue;
  final int type;
  final List<SelectOption>? selectList;
  final String key;
  final int order;
  final int must;
  final List<FormEntryRule> rules;

  const FormEntry({
    required this.code,
    required this.showContent,
    required this.defaultText,
    this.submitValue,
    required this.type,
    this.selectList,
    required this.key,
    required this.order,
    required this.must,
    required this.rules,
  });

  factory FormEntry.fromJson(Map<String, dynamic> json) {
    return FormEntry(
      code: json['code'] as String? ?? '',
      showContent: json['showContent'] as String? ?? '',
      defaultText: json['defaultText'] as String? ?? '',
      submitValue: json['submitValue'] as String?,
      type: json['type'] as int? ?? 0,
      selectList: (json['selectList'] as List<dynamic>?)
          ?.map((e) => SelectOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      key: json['key'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      must: json['must'] as int? ?? 0,
      rules:
          (json['rules'] as List<dynamic>?)
              ?.map((e) => FormEntryRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FormEntryRule {
  final int type;
  final String validator;
  final String errorMsg;

  const FormEntryRule({
    required this.type,
    required this.validator,
    required this.errorMsg,
  });

  factory FormEntryRule.fromJson(Map<String, dynamic> json) {
    return FormEntryRule(
      type: json['type'] as int? ?? 0,
      validator: json['validator'] as String? ?? '',
      errorMsg: json['errorMsg'] as String? ?? '',
    );
  }
}

class SelectOption {
  final String key;
  final String value;

  const SelectOption({required this.key, required this.value});

  factory SelectOption.fromJson(Map<String, dynamic> json) {
    return SelectOption(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}
