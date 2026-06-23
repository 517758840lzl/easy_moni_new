/// KYC 步骤提交结果，后端通过 nextStep 告知客户端下一步采集页面。
class SubmitAcpInfoResp {
  final Object? userId;
  final int? nextStep;
  final int isFinished;

  const SubmitAcpInfoResp({
    this.userId,
    this.nextStep,
    this.isFinished = 0,
  });

  factory SubmitAcpInfoResp.fromJson(dynamic json) {
    if (json == null) {
      return const SubmitAcpInfoResp();
    }

    final Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else {
      map = Map<String, dynamic>.from(json as Map);
    }

    return SubmitAcpInfoResp(
      userId: map['userId'],
      nextStep: map['nextStep'] as int?,
      isFinished: map['isFinished'] as int? ?? 0,
    );
  }

  bool get isKycFinished => isFinished == 1;
}
