class AcquisitionProgressResp {
  final int? totalStep;
  final int? filledStep;
  final List<ProcessStep>? processSteps;

  const AcquisitionProgressResp({
    this.totalStep,
    this.filledStep,
    this.processSteps,
  });

  factory AcquisitionProgressResp.fromJson(dynamic json) {
    final Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else {
      map = Map<String, dynamic>.from(json as Map);
    }
    return AcquisitionProgressResp(
      totalStep: map['totalStep'] as int?,
      filledStep: map['filledStep'] as int?,
      processSteps: (map['processSteps'] as List<dynamic>?)
          ?.map((e) => ProcessStep.fromJson(e))
          .toList(),
    );
  }

  bool get hasCompletedKyc => (filledStep ?? 0) >= (totalStep ?? 0);
}

class ProcessStep {
  final int? step;
  final String? pageTitle;
  final int? pageType;
  final List<dynamic>? entries;

  const ProcessStep({this.step, this.pageTitle, this.pageType, this.entries});

  factory ProcessStep.fromJson(dynamic json) {
    final Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else {
      map = Map<String, dynamic>.from(json as Map);
    }
    return ProcessStep(
      step: map['step'] as int?,
      pageTitle: map['pageTitle'] as String?,
      pageType: map['pageType'] as int?,
      entries: map['entries'] as List<dynamic>?,
    );
  }
}
