import 'package:easy_moni/core/constants/app_strings.dart';

/// 人脸动作常量，和后端下发的 action key 保持一致。
class FaceAction {
  const FaceAction._();

  static const String nodHead = 'nod_head';
  static const String shakeHead = 'shake_head';
  static const String blink = 'blink';
  static const String faceFront = 'face_front';
  static const String openMouth = 'open_mouth';

  static const List<String> values = [
    nodHead,
    shakeHead,
    blink,
    faceFront,
    openMouth,
  ];

  static bool isSupported(String action) => values.contains(action);
}

/// 每个动作对应的前端提示配置。
class FaceActionPrompt {
  const FaceActionPrompt({required this.action, required this.description});

  final String action;
  final String description;
}

/// 单个活体动作步骤，包含识别动作、提示语和稳定帧要求。
class FaceLivenessStep {
  const FaceLivenessStep({
    required this.action,
    required this.prompt,
    required this.stableFrameThreshold,
    required this.timeout,
  });

  final String action;
  final FaceActionPrompt prompt;
  final int stableFrameThreshold;
  final Duration timeout;

  String get description => prompt.description;

  /// 将后端 action key 转换为前端可执行步骤。
  static FaceLivenessStep? fromAction(String action, {String? description}) {
    final normalizedAction = action.trim();
    if (!FaceAction.isSupported(normalizedAction)) return null;

    return FaceLivenessStep(
      action: normalizedAction,
      prompt: FaceVerifyActionConfig.promptFor(
        normalizedAction,
        description: description,
      ),
      stableFrameThreshold: FaceVerifyActionConfig.stableFrameThresholdFor(
        normalizedAction,
      ),
      timeout: FaceVerifyActionConfig.timeoutFor(normalizedAction),
    );
  }
}

/// 人脸活体动作配置。当前模拟后端下发动作，后续接入接口时只替换这里的数据来源。
class FaceVerifyActionConfig {
  const FaceVerifyActionConfig._();

  // TODO: 接入后端动作接口后，替换当前模拟动作列表。后端每次应下发 2-3 个动作。
  static const List<String> mockBackendActionKeys = [
    FaceAction.openMouth,
    FaceAction.shakeHead,
    FaceAction.blink,
  ];

  static const String finalCaptureAction = FaceAction.faceFront;
  static const int finalCaptureStableFrameThreshold = 4;

  /// 正脸：主要看 yaw + 睁眼；pitch/roll 在 iOS Vision 上噪声大，不参与判定。
  static const double frontFaceYawThreshold = 10.0;
  static const double frontFaceEyeOpenThreshold = 0.55;

  /// 摇头：先转到足够角度，再摆到对侧才算完成。
  static const double shakeHeadTurnThreshold = 10.0;

  // TODO: 后续接入后端动作配置时，确认动作超时阈值是否由接口下发。
  static const Duration defaultActionTimeout = Duration(seconds: 15);

  static List<FaceLivenessStep> mockBackendSteps() {
    final actions = mockBackendActionKeys
        .where(FaceAction.isSupported)
        .take(3)
        .toList(growable: false);
    final selectedActions = actions.length >= 2
        ? actions
        : const [FaceAction.nodHead, FaceAction.blink];

    return selectedActions
        .map(FaceLivenessStep.fromAction)
        .whereType<FaceLivenessStep>()
        .toList(growable: false);
  }

  static FaceLivenessStep get finalCaptureStep =>
      FaceLivenessStep.fromAction(finalCaptureAction)!;

  static FaceActionPrompt promptFor(String action, {String? description}) {
    final customDescription = description?.trim();
    if (customDescription?.isNotEmpty == true) {
      return FaceActionPrompt(
        action: action,
        description: customDescription!,
      );
    }

    return FaceActionPrompt(
      action: action,
      description: switch (action) {
        FaceAction.nodHead => AppStrings.faceVerifyNodHead,
        FaceAction.shakeHead => AppStrings.faceVerifyShakeHead,
        FaceAction.blink => AppStrings.faceVerifyBlink,
        FaceAction.faceFront => AppStrings.faceVerifyFaceFront,
        FaceAction.openMouth => AppStrings.faceVerifyOpenMouth,
        _ => '',
      },
    );
  }

  static int stableFrameThresholdFor(String action) {
    return switch (action) {
      FaceAction.shakeHead => 2,
      FaceAction.nodHead || FaceAction.blink => 1,
      FaceAction.faceFront => 3,
      FaceAction.openMouth => 3,
      _ => 1,
    };
  }

  static Duration timeoutFor(String action) {
    return defaultActionTimeout;
  }
}
