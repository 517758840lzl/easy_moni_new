import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/pages/fillInforma/providers/ocr_verification_provider.dart';
import 'package:easy_moni/pages/fillInforma/utils/form_entry_input_type_helper.dart';
import 'package:flutter/material.dart';

class IdentityImageSide {
  IdentityImageSide._();

  static const String front = 'front';
  static const String back = 'back';
  static const String unknown = '';
}

class IdentityVerifyFieldCode {
  IdentityVerifyFieldCode._();

  static const String gender = '40001';
  static const String idCardNumber = '40002';
  static const String fatherName = '40003';
  static const String name = '40004';
  static const String birthday = '40006';
  static const String idCardFrontImage = '40007';
  static const String idCardBackImage = '40008';
}

class IdentityVerifyFormController {
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, String?> _displayValues = {};
  final Map<String, String?> _submitValues = {};
  final Map<String, int> _selectedIndices = {};
  final Set<String> _textEntryKeys = {};

  List<FormEntry> _entries = [];

  List<FormEntry> get _sortedEntries {
    final sortedEntries = [..._entries];
    sortedEntries.sort((a, b) => a.order.compareTo(b.order));
    return sortedEntries;
  }

  List<FormEntry> get idCardImageEntries => _sortedEntries
      .where(FormEntryInputTypeHelper.isIdCardImage)
      .toList(growable: false);

  List<FormEntry> get visibleEntries => _sortedEntries
      .where((entry) => !FormEntryInputTypeHelper.isSpecialProcessEntry(entry))
      .toList(growable: false);

  List<String> get requiredIdCardImageSides {
    final sides = <String>{};
    for (final entry in idCardImageEntries) {
      if (entry.must != 1) {
        continue;
      }

      final side = imageSideFor(entry);
      if (side.isNotEmpty) {
        sides.add(side);
      }
    }
    return sides.toList(growable: false);
  }

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

  void applyEntries(List<FormEntry> entries) {
    _entries = entries;
    _selectedIndices.clear();
    _displayValues.clear();
    _submitValues.clear();
    _textEntryKeys.clear();

    for (final entry in _sortedEntries) {
      _selectedIndices[entry.key] = 0;
      _restoreInitialValue(entry, entry.submitValue);
      _focusNodes[entry.key] ??= FocusNode(debugLabel: entry.key);

      if (_isTextEntry(entry)) {
        _textEntryKeys.add(entry.key);
        final controller = _textControllers[entry.key] ??=
            TextEditingController();
        controller.text = _displayValues[entry.key] ?? '';
      } else if (FormEntryInputTypeHelper.isPicker(entry)) {
        _restorePickerValue(entry);
      }
    }
  }

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

  void clearOcrResult() {
    for (final entry in visibleEntries) {
      _displayValues[entry.key] = '';
      _submitValues[entry.key] = '';
      _selectedIndices[entry.key] = 0;
      if (_isTextEntry(entry)) {
        _textControllers[entry.key]?.clear();
      }
    }
  }

  TextEditingController controllerFor(FormEntry entry) {
    return _textControllers[entry.key] ??= TextEditingController(
      text: _displayValues[entry.key] ?? '',
    );
  }

  FocusNode focusNodeFor(FormEntry entry) {
    return _focusNodes[entry.key] ??= FocusNode(debugLabel: entry.key);
  }

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

  bool isIdCardImageEntry(FormEntry entry) {
    return FormEntryInputTypeHelper.isIdCardImage(entry);
  }

  bool isFrontImageEntry(FormEntry entry) {
    return imageSideFor(entry) == IdentityImageSide.front;
  }

  bool isBackImageEntry(FormEntry entry) {
    return imageSideFor(entry) == IdentityImageSide.back;
  }

  String imageSideFor(FormEntry entry) {
    if (!FormEntryInputTypeHelper.isIdCardImage(entry)) {
      return IdentityImageSide.unknown;
    }
    if (entry.code == IdentityVerifyFieldCode.idCardFrontImage) {
      return IdentityImageSide.front;
    }
    if (entry.code == IdentityVerifyFieldCode.idCardBackImage) {
      return IdentityImageSide.back;
    }
    return IdentityImageSide.unknown;
  }

  bool hasNextVisibleEntry(FormEntry entry) =>
      nextVisibleEntryAfter(entry) != null;

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
    final entry = recognizedIdNumberEntry;
    if (entry == null) {
      return '';
    }
    return (_submitValues[entry.key] ?? _displayValues[entry.key] ?? '').trim();
  }

  FormEntry? get recognizedIdNumberEntry =>
      visibleEntries.where(_isRecognizedIdNumberEntry).firstOrNull;

  bool isRecognizedIdNumberEntry(FormEntry entry) =>
      _isRecognizedIdNumberEntry(entry);

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

  void updateBirthdayValue(FormEntry entry, DateTime date) {
    final submitValue = _formatBackendDate(date);
    _submitValues[entry.key] = submitValue;
    _displayValues[entry.key] = _formatDisplayDate(date);
  }

  DateTime? dateValueFor(FormEntry entry) {
    return _parseBirthdayDate(_submitValues[entry.key]) ??
        _parseBirthdayDate(_displayValues[entry.key]);
  }

  List<Map<String, dynamic>> buildSubmitParams({
    required String? frontImageUrl,
    required String? backImageUrl,
  }) {
    final jsonParam = <Map<String, dynamic>>[];

    for (final entry in _sortedEntries) {
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
    if (_isBirthdayPickerEntry(entry) ||
        FormEntryInputTypeHelper.isSpecialProcessEntry(entry)) {
      return false;
    }
    return FormEntryInputTypeHelper.isTextInput(entry);
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
    if (FormEntryInputTypeHelper.isIdCardImage(entry)) {
      final side = imageSideFor(entry);
      if (side == IdentityImageSide.front) {
        return frontImageUrl;
      }
      if (side == IdentityImageSide.back) {
        return backImageUrl;
      }
    }
    return _submitValues[entry.key];
  }

  String? _ocrSubmitValueForEntry(FormEntry entry, OcrVerificationResp data) {
    final text = _entryIdentityText(entry);
    final keyText = entry.key.toLowerCase();
    final fieldCodeValue = _ocrSubmitValueForFieldCode(entry.code, data);
    if (fieldCodeValue != null) {
      return fieldCodeValue;
    }

    if (_isIdNumberEntry(text)) {
      return data.idCardNumber;
    }
    if (_isDocumentNumberEntry(text)) {
      return data.documentNumber;
    }
    if (_isFatherNameEntry(text, keyText)) {
      return data.fatherName;
    }
    if (_isMotherNameEntry(text, keyText)) {
      return data.motherName;
    }
    if (_isFirstNameEntry(text, keyText)) {
      return data.name;
    }
    if (_isLastNameEntry(text, keyText)) {
      return data.name;
    }
    if (_isFullNameEntry(text, keyText)) {
      return data.name;
    }
    if (_hasIdentityToken(text, 'gender') || _hasIdentityToken(text, 'sex')) {
      return data.gender?.toString();
    }
    if (_isBirthdayEntry(text)) {
      return _backendBirthdaySubmitValue(data.birthday);
    }
    return null;
  }

  String? _ocrDisplayValueForEntry(FormEntry entry, OcrVerificationResp data) {
    final text = _entryIdentityText(entry);
    if (entry.code == IdentityVerifyFieldCode.gender) {
      return _displayGender(data.gender?.toString());
    }
    if (entry.code == IdentityVerifyFieldCode.birthday) {
      final birthday = _parseBirthdayDate(data.birthday);
      return birthday == null ? data.birthday : _formatDisplayDate(birthday);
    }
    if (_hasIdentityToken(text, 'gender') || _hasIdentityToken(text, 'sex')) {
      return _displayGender(data.gender?.toString());
    }
    if (_isBirthdayEntry(text)) {
      final birthday = _parseBirthdayDate(data.birthday);
      return birthday == null ? data.birthday : _formatDisplayDate(birthday);
    }
    return null;
  }

  String? _ocrSubmitValueForFieldCode(String code, OcrVerificationResp data) {
    switch (code) {
      case IdentityVerifyFieldCode.idCardNumber:
        return data.idCardNumber;
      case IdentityVerifyFieldCode.fatherName:
        return data.fatherName;
      case IdentityVerifyFieldCode.name:
        return data.name;
      case IdentityVerifyFieldCode.gender:
        return data.gender?.toString();
      case IdentityVerifyFieldCode.birthday:
        return _backendBirthdaySubmitValue(data.birthday);
      default:
        return null;
    }
  }

  String? _backendBirthdaySubmitValue(String? value) {
    final birthday = _parseBirthdayDate(value);
    return birthday == null ? value : _formatBackendDate(birthday);
  }

  bool _isIdNumberEntry(String text) {
    return text.contains('national_id') ||
        text.contains('id_number') ||
        text.contains('id_card_number') ||
        text.contains(IdentityVerifyFieldCode.idCardNumber);
  }

  bool _isDocumentNumberEntry(String text) {
    return text.contains('document_number');
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

  bool _isFullNameEntry(String text, String keyText) {
    return keyText == 'name' ||
        keyText == 'full_name' ||
        text.contains('full_name') ||
        _hasIdentityToken(text, 'name');
  }

  bool _isFatherNameEntry(String text, String keyText) {
    return keyText == 'father_name' || text.contains('father_name');
  }

  bool _isMotherNameEntry(String text, String keyText) {
    return keyText == 'mother_name' || text.contains('mother_name');
  }

  bool _isBirthdayEntry(String text) {
    return text.contains('date_of_birth') ||
        text.contains('birthday') ||
        _hasIdentityToken(text, 'birth');
  }

  bool _isBirthdayPickerEntry(FormEntry entry) {
    return FormEntryInputTypeHelper.isDatePicker(entry);
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
