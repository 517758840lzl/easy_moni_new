/// Platform-agnostic face metrics for liveness checks.
///
/// Android: filled from ML Kit. iOS: filled from Apple Vision.
class DetectedFace {
  const DetectedFace({
    this.leftEyeOpen,
    this.rightEyeOpen,
    this.smilingProbability,
    this.headYaw,
    this.headPitch,
    this.headRoll,
    this.normalizedLipOpening,
  });

  final double? leftEyeOpen;
  final double? rightEyeOpen;
  final double? smilingProbability;
  final double? headYaw;
  final double? headPitch;
  final double? headRoll;
  final double? normalizedLipOpening;

  double? get avgEyeOpen {
    final l = leftEyeOpen;
    final r = rightEyeOpen;
    if (l == null || r == null) return null;
    return (l + r) / 2;
  }
}
