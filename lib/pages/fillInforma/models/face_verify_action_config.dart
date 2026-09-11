import 'package:easy_moni/core/constants/app_strings.dart';

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

class FaceActionPrompt {
  const FaceActionPrompt({required this.action, required this.description});

  final String action;
  final String description;
}

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

class FaceVerifyActionConfig {
  const FaceVerifyActionConfig._();

  static const List<String> mockBackendActionKeys = [
    FaceAction.openMouth,
    FaceAction.shakeHead,
    FaceAction.blink,
  ];

  static const String finalCaptureAction = FaceAction.faceFront;
  static const int finalCaptureStableFrameThreshold = 4;

  static const double frontFaceYawThreshold = 10.0;
  static const double frontFaceEyeOpenThreshold = 0.55;

  static const double shakeHeadTurnThreshold = 10.0;

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
