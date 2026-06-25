import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/entities/acquisition_progress_resp.dart';
import 'package:easy_moni/entities/submit_acp_info_resp.dart';

/// 采集进度路由解析器，根据后端返回的最新 KYC 进度决定下一步页面。
class AcquisitionProgressRouteResolver {
  const AcquisitionProgressRouteResolver._();

  static String resolve(AcquisitionProgressResp progressData) {
    final filledStep = progressData.filledStep ?? 0;
    final totalStep = progressData.totalStep;

    if (totalStep != null && totalStep > 0 && filledStep >= totalStep) {
      return AppRoutePaths.home;
    }

    final nextStep = _nextStep(progressData.processSteps, filledStep);
    if (nextStep != null) {
      return _routeForStep(nextStep);
    }

    if ((progressData.processSteps ?? const []).isEmpty) {
      return AppRoutePaths.personalInfo;
    }

    return _routeForStep(filledStep + 1);
  }

  static String resolveSubmitResult(SubmitAcpInfoResp submitResult) {
    if (submitResult.isKycFinished) {
      return AppRoutePaths.home;
    }

    final nextStep = submitResult.nextStep;
    if (nextStep == null) {
      return AppRoutePaths.home;
    }

    return _routeForStep(nextStep);
  }

  /// 从后端步骤列表中寻找当前已完成步骤之后的最小步骤，避免依赖数组顺序。
  static int? _nextStep(List<ProcessStep>? steps, int filledStep) {
    final pendingSteps = (steps ?? const [])
        .map((step) => step.step)
        .whereType<int>()
        .where((step) => step > filledStep)
        .toList()
      ..sort();

    return pendingSteps.isEmpty ? null : pendingSteps.first;
  }

  static String _routeForStep(int step) {
    switch (step) {
      case 1:
        return AppRoutePaths.personalInfo;
      case 2:
        return AppRoutePaths.contactInfo;
      case 4:
        return AppRoutePaths.identityVerify;
      case 5:
        return AppRoutePaths.faceVerify;
      case 6:
        return AppRoutePaths.questionnaire;
      default:
        return AppRoutePaths.home;
    }
  }
}
