/// 好评弹窗配置，承接 `/api/common/pop/config` 接口返回的数据。
class ReviewPopConfig {
  const ReviewPopConfig({
    required this.isPop,
    required this.okText,
    required this.cancelText,
    required this.title,
    required this.description,
    required this.lowScoreLimit,
    required this.isShowEmail,
  });

  final int isPop;
  final String okText;
  final String cancelText;
  final String title;
  final String description;
  final int lowScoreLimit;
  final int isShowEmail;

  bool get shouldPop => isPop == 1;

  int get initialScore => (lowScoreLimit).clamp(1, 5).toInt();

  bool isLowScore(int score) => score < lowScoreLimit;

  factory ReviewPopConfig.fromJson(dynamic json) {
    if (json is! Map) {
      return ReviewPopConfig.empty();
    }

    final map = Map<String, dynamic>.from(json);
    final config = map['config'] is Map
        ? Map<String, dynamic>.from(map['config'] as Map)
        : const <String, dynamic>{};

    return ReviewPopConfig(
      isPop: _asInt(map['isPop']),
      okText: _asString(map['okText']),
      cancelText: _asString(map['cancelText']),
      title: _asString(map['title']),
      description: _asString(map['description']),
      lowScoreLimit: _asInt(config['score']),
      isShowEmail: _asInt(config['isShowEmail']),
    );
  }

  factory ReviewPopConfig.empty() {
    return const ReviewPopConfig(
      isPop: 0,
      okText: '',
      cancelText: '',
      title: '',
      description: '',
      lowScoreLimit: 3,
      isShowEmail: 0,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
