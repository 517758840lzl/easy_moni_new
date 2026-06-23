import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/pages/fillInforma/providers/ocr_verification_provider.dart';
import 'package:flutter/material.dart';

/// 身份认证表单控制器，负责后端表单项、OCR 数据和提交参数之间的映射。
class IdentityVerifyFormController {
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, String?> _displayValues = {};
  final Map<String, String?> _submitValues = {};
  final Map<String, int> _selectedIndices = {};
  final Set<String> _textEntryKeys = {};

  List<FormEntry> _entries = [];

  List<FormEntry> get visibleEntries =>
      _entries.where((entry) => !_isImageEntry(entry)).toList(growable: false);

  /// 校验身份证 OCR 回显表单中的必填项，确保底部按钮只在信息完整时可用。
  bool get areRequiredVisibleEntriesFilled {
    for (final entry in visibleEntries) {
      if (entry.must != 1) {
        continue;
      }

      final value = (_submitValues[entry.key] ?? _displayValues[entry.key])
          ?.trim();
      if (value == null || value.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
  }

  /// 初始化后端表单配置，并恢复已提交过的文本或选择项值。
  void applyEntries(List<FormEntry> entries) {
    _entries = entries;
    _textEntryKeys.clear();

    for (final entry in entries) {
      _selectedIndices[entry.key] = 0;
      _restoreInitialValue(entry, entry.submitValue);
      _focusNodes[entry.key] ??= FocusNode(debugLabel: entry.key);

      if (_isTextEntry(entry)) {
        _textEntryKeys.add(entry.key);
        _textControllers[entry.key] = TextEditingController(
          text: _displayValues[entry.key] ?? '',
        );
      } else if (!_isBirthdayPickerEntry(entry)) {
        _restorePickerValue(entry);
      }
    }
  }

  /// OCR 成功后回填可编辑字段，字段标题仍由后端配置决定。
  void applyOcrResult(OcrVerificationResp? data) {
    if (data == null) return;

    for (final entry in visibleEntries) {
      final value = _ocrSubmitValueForEntry(entry, data);
      if (value == null) {
        continue;
      }

      if (_isTextEntry(entry)) {
        final displayValue = _ocrDisplayValueForEntry(entry, data) ?? value;
        _textControllers[entry.key]?.text = displayValue;
        _displayValues[entry.key] = displayValue;
        _submitValues[entry.key] = value;
      } else if (_isBirthdayPickerEntry(entry)) {
        _restoreInitialValue(entry, value);
      } else {
        _restorePickerValue(entry, preferredSubmitValue: value);
      }
    }
  }

  TextEditingController controllerFor(FormEntry entry) {
    return _textControllers[entry.key] ??= TextEditingController(
      text: _displayValues[entry.key] ?? '',
    );
  }

  /// 为所有可见表单项提供稳定 FocusNode，让文本、选择器、日期项共用同一焦点链。
  FocusNode focusNodeFor(FormEntry entry) {
    return _focusNodes[entry.key] ??= FocusNode(debugLabel: entry.key);
  }

  /// 清理表单内所有文本焦点，避免选择器弹窗切换时恢复到底层输入框。
  void unfocusTextInputs() {
    for (final key in _textEntryKeys) {
      final focusNode = _focusNodes[key];
      if (focusNode == null) {
        continue;
      }
      if (focusNode.hasFocus) {
        focusNode.unfocus(disposition: UnfocusDisposition.scope);
      }
    }
  }

  bool isTextEntry(FormEntry entry) => _isTextEntry(entry);

  bool isBirthdayPickerEntry(FormEntry entry) => _isBirthdayPickerEntry(entry);

  bool hasNextVisibleEntry(FormEntry entry) =>
      nextVisibleEntryAfter(entry) != null;

  /// 按当前可见表单顺序寻找下一个表单项，保持文本与选择项的填写节奏一致。
  FormEntry? nextVisibleEntryAfter(FormEntry entry) {
    final currentIndex = visibleEntries.indexWhere(
      (visibleEntry) => visibleEntry.key == entry.key,
    );
    if (currentIndex < 0 || currentIndex + 1 >= visibleEntries.length) {
      return null;
    }
    return visibleEntries[currentIndex + 1];
  }

  String? displayValueFor(FormEntry entry) => _displayValues[entry.key];

  int selectedIndexFor(FormEntry entry) => _selectedIndices[entry.key] ?? 0;

  String get recognizedIdNumber {
    final entry = visibleEntries.where(_isRecognizedIdNumberEntry).firstOrNull;
    if (entry == null) {
      return '';
    }
    return (_submitValues[entry.key] ?? _displayValues[entry.key] ?? '').trim();
  }

  void updateTextValue(FormEntry entry, String value) {
    final trimmedValue = value.trim();
    _displayValues[entry.key] = trimmedValue;
    _submitValues[entry.key] = trimmedValue;
  }

  void updatePickerValue(FormEntry entry, int index) {
    final options = entry.selectList;
    if (options == null || options.isEmpty) {
      return;
    }

    final safeIndex = index.clamp(0, options.length - 1);
    final option = options[safeIndex];
    _selectedIndices[entry.key] = safeIndex;
    _displayValues[entry.key] = option.value;
    _submitValues[entry.key] = option.key;
  }

  /// 用户通过日期选择器更新生日，展示值与提交值分别维护，避免自由输入格式不一致。
  void updateBirthdayValue(FormEntry entry, DateTime date) {
    final submitValue = _formatBackendDate(date);
    _submitValues[entry.key] = submitValue;
    _displayValues[entry.key] = _formatDisplayDate(date);
  }

  /// 根据已有提交值或 OCR 回显值推导日期选择器初始值。
  DateTime? dateValueFor(FormEntry entry) {
    return _parseBirthdayDate(_submitValues[entry.key]) ??
        _parseBirthdayDate(_displayValues[entry.key]);
  }

  /// 按后端 key 组装提交参数，图片字段由页面传入上传后的 URL。
  List<Map<String, dynamic>> buildSubmitParams({
    required String? frontImageUrl,
    required String? backImageUrl,
  }) {
    final jsonParam = <Map<String, dynamic>>[];

    for (final entry in _entries) {
      final value = _submitValueForEntry(
        entry,
        frontImageUrl: frontImageUrl,
        backImageUrl: backImageUrl,
      );
      if (value == null || value.isEmpty) {
        continue;
      }
      jsonParam.add({'key': entry.key, 'value': value});
    }

    return jsonParam;
  }

  bool _isTextEntry(FormEntry entry) {
    if (_isBirthdayPickerEntry(entry)) {
      return false;
    }
    return entry.selectList == null || entry.selectList!.isEmpty;
  }

  void _restoreInitialValue(FormEntry entry, String? value) {
    if (_isBirthdayPickerEntry(entry)) {
      final birthday = _parseBirthdayDate(value);
      _submitValues[entry.key] = birthday == null
          ? value
          : _formatBackendDate(birthday);
      _displayValues[entry.key] = birthday == null
          ? value
          : _formatDisplayDate(birthday);
      return;
    }

    _displayValues[entry.key] = value;
    _submitValues[entry.key] = value;
  }

  void _restorePickerValue(FormEntry entry, {String? preferredSubmitValue}) {
    final options = entry.selectList;
    final submitValue = preferredSubmitValue ?? entry.submitValue;
    if (options == null || options.isEmpty || submitValue == null) {
      return;
    }

    final matchedIndex = options.indexWhere(
      (option) => option.key == submitValue || option.value == submitValue,
    );
    if (matchedIndex < 0) {
      return;
    }

    updatePickerValue(entry, matchedIndex);
  }

  String? _submitValueForEntry(
    FormEntry entry, {
    required String? frontImageUrl,
    required String? backImageUrl,
  }) {
    if (_isFrontImageEntry(entry)) {
      return frontImageUrl;
    }
    if (_isBackImageEntry(entry)) {
      return backImageUrl;
    }
    return _submitValues[entry.key];
  }

  String? _ocrSubmitValueForEntry(FormEntry entry, OcrVerificationResp data) {
    final text = _entryIdentityText(entry);
    final keyText = entry.key.toLowerCase();

    if (_isIdNumberEntry(text)) {
      return data.idCardNumber;
    }
    if (_isFirstNameEntry(text, keyText)) {
      return data.firstNames;
    }
    if (_isLastNameEntry(text, keyText)) {
      return data.lastName;
    }
    if (_hasIdentityToken(text, 'gender') || _hasIdentityToken(text, 'sex')) {
      return data.gender;
    }
    if (_isBirthdayEntry(text)) {
      return data.birthday;
    }
    return null;
  }

  String? _ocrDisplayValueForEntry(FormEntry entry, OcrVerificationResp data) {
    final text = _entryIdentityText(entry);
    if (_hasIdentityToken(text, 'gender') || _hasIdentityToken(text, 'sex')) {
      return _displayGender(data.gender);
    }
    if (_isBirthdayEntry(text)) {
      final birthday = _parseBirthdayDate(data.birthday);
      return birthday == null ? data.birthday : _formatDisplayDate(birthday);
    }
    return null;
  }

  bool _isImageEntry(FormEntry entry) {
    return _isFrontImageEntry(entry) || _isBackImageEntry(entry);
  }

  bool _isFrontImageEntry(FormEntry entry) {
    final text = _entryIdentityText(entry);
    return text.contains('id_card_front') ||
        (text.contains('front') &&
            (text.contains('image') || text.contains('photo')));
  }

  bool _isBackImageEntry(FormEntry entry) {
    final text = _entryIdentityText(entry);
    return text.contains('id_card_back') ||
        (text.contains('back') &&
            (text.contains('image') || text.contains('photo')));
  }

  bool _isIdNumberEntry(String text) {
    return text.contains('national_id') ||
        text.contains('id_number') ||
        text.contains('id_card_number');
  }

  bool _isRecognizedIdNumberEntry(FormEntry entry) {
    return _isIdNumberEntry(_entryIdentityText(entry));
  }

  bool _isFirstNameEntry(String text, String keyText) {
    return keyText == 'first_names' || text.contains('first_name');
  }

  bool _isLastNameEntry(String text, String keyText) {
    return keyText == 'last_name' ||
        text.contains('last_name') ||
        text.contains('surname') ||
        text.contains('family_name');
  }

  bool _isBirthdayEntry(String text) {
    return text.contains('date_of_birth') ||
        text.contains('birthday') ||
        _hasIdentityToken(text, 'birth');
  }

  bool _isBirthdayPickerEntry(FormEntry entry) {
    return entry.code == '40006' || entry.key.toLowerCase() == 'date_of_birth';
  }

  String _entryIdentityText(FormEntry entry) {
    return '${entry.key} ${entry.code} ${entry.showContent} ${entry.defaultText}'
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  bool _hasIdentityToken(String text, String token) {
    return text == token ||
        text.startsWith('${token}_') ||
        text.endsWith('_$token') ||
        text.contains('_${token}_');
  }

  String _displayGender(String? value) {
    switch (value?.trim()) {
      case '1':
      case 'M':
      case 'Male':
        return 'Male';
      case '2':
      case 'F':
      case 'Female':
        return 'Female';
      default:
        return value ?? '';
    }
  }

  DateTime? _parseBirthdayDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final normalizedValue = value.trim().replaceAll('/', '-');
    final parts = normalizedValue.split('-');
    if (parts.length != 3) return null;

    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    final third = int.tryParse(parts[2]);
    if (first == null || second == null || third == null) return null;

    final isBackendFormat = parts[0].length == 4;
    final year = isBackendFormat ? first : third;
    final month = second;
    final day = isBackendFormat ? third : first;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  String _formatBackendDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year.toString().padLeft(4, '0')}';
  }
}
