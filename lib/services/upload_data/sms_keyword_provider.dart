class SmsKeywordProvider {
  /// 获取短信筛选关键词。
  ///
  /// 当前后端接口暂未提供，先返回空数组；空数组表示不过滤短信。
  Future<List<String>> fetchKeywords() async {
    return const <String>[];
  }
}
