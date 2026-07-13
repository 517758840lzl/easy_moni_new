class SignOutResp {
  const SignOutResp();

  factory SignOutResp.fromJson(dynamic json) {
    try {
      if (json is Map<String, dynamic>) {
      } else if (json is Map) {
      } else if (json is String) {
      } else {
        return const SignOutResp();
      }

      return const SignOutResp();
    } catch (e) {
      return const SignOutResp();
    }
  }

  @override
  String toString() {
    return 'SignOutResp()';
  }
}
