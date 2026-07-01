import 'dart:convert';

import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/pages/fillInforma/utils/form_entry_input_type_helper.dart';
import 'package:flutter/material.dart';

/// 联系人信息表单控制器，负责固定联系人字段的展示值和提交值映射。
class ContactInfoFormController {
  static const Set<String> _visibleContactCodes = {
    '30051',
    '30053',
    '30061',
    '30063',
  };
  static const Set<String> _hiddenContactNameCodes = {'30052', '30062'};
  static const Set<String> _submitContactCodes = {
    ..._visibleContactCodes,
    ..._hiddenContactNameCodes,
  };
  static const Map<String, String> _phoneToNameCodes = {
    '30053': '30052',
    '30063': '30062',
  };

  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, int> _selectedIndices = {};
  final Map<String, String?> _displayValues = {};
  final Map<String, String?> _submitValues = {};

  List<FormEntry> _entries = [];

  /// 页面仅展示两个联系人关系和两个联系人手机号字段。
  List<FormEntry> get entries {
    return _sortedEntries
        .where((entry) => _visibleContactCodes.contains(entry.code))
        .toList(growable: false);
  }

  List<FormEntry> get _sortedEntries {
    final sortedEntries = [..._entries];
    sortedEntries.sort((a, b) => a.order.compareTo(b.order));
    return sortedEntries;
  }

  /// 校验联系人页可见必填项是否已填写。
  bool get canSubmit {
    for (final entry in entries) {
      if (entry.must != 1) {
        continue;
      }

      final value = _submitValues[entry.key] ?? _displayValues[entry.key];
      if (value == null || value.trim().isEmpty) {
        return false;
      }
    }
    return entries.isNotEmpty;
  }

  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
  }

  /// 应用后端联系人表单配置，并恢复已提交过的表单值。
  void applyEntries(List<FormEntry> entries) {
    _entries = entries;
    _selectedIndices.clear();
    _displayValues.clear();
    _submitValues.clear();

    for (final entry in entries) {
      _selectedIndices[entry.key] = 0;
      _focusNodes[entry.key] ??= FocusNode(debugLabel: entry.key);
      _restoreInitialValue(entry);

      if (FormEntryInputTypeHelper.isTextInput(entry)) {
        final controller = _textControllers[entry.key] ??=
            TextEditingController();
        controller.text = _displayValues[entry.key] ?? '';
      }
    }

    _restoreContactDisplayValues();
  }

  TextEditingController controllerFor(FormEntry entry) {
    return _textControllers[entry.key] ??= TextEditingController(
      text: _displayValues[entry.key] ?? '',
    );
  }

  FocusNode focusNodeFor(FormEntry entry) {
    return _focusNodes[entry.key] ??= FocusNode(debugLabel: entry.key);
  }

  String? displayValueFor(FormEntry entry) => _displayValues[entry.key];

  int selectedIndexFor(FormEntry entry) => _selectedIndices[entry.key] ?? 0;

  /// 更新输入框值，联系人手机号需转换为后端 JSON 字符串提交。
  void updateTextValue(FormEntry entry, String value) {
    if (_isContactPhoneEntry(entry)) {
      _updateContactInputValue(entry, value);
      return;
    }

    final submitValue = value.trim();
    final displayValue = value.trim();

    _displayValues[entry.key] = displayValue;
    _submitValues[entry.key] = submitValue;
  }

  /// 更新联系人关系选择值。
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

  /// 更新通讯录选择值，并同步隐藏姓名字段和可见手机号字段。
  void updateContactValue({
    required FormEntry entry,
    required String name,
    required String phone,
  }) {
    final phoneEntry = _isContactPhoneEntry(entry) ? entry : null;
    if (phoneEntry == null) {
      return;
    }

    final displayName = name.trim();
    final normalizedPhone = _normalizeContactPhone(phone);
    final nameEntry = _nameEntryForPhone(phoneEntry);

    if (nameEntry != null) {
      _displayValues[nameEntry.key] = displayName;
      _submitValues[nameEntry.key] = displayName;
      _textControllers[nameEntry.key]?.text = displayName;
    }

    final displayValue = _formatContactDisplay(displayName, normalizedPhone);
    _displayValues[phoneEntry.key] = displayValue;
    _submitValues[phoneEntry.key] = _encodeContactPhone(normalizedPhone);
    _textControllers[phoneEntry.key]?.text = displayValue;
  }

  /// 按后台 key 组装联系人信息提交参数。
  List<Map<String, dynamic>> buildSubmitParams() {
    return _sortedEntries
        .where((entry) => _submitContactCodes.contains(entry.code))
        .map((entry) {
          return {'key': entry.key, 'value': _submitValues[entry.key] ?? ''};
        })
        .toList();
  }

  void _restoreInitialValue(FormEntry entry) {
    final submitValue = entry.submitValue ?? '';
    _displayValues[entry.key] = submitValue.isEmpty ? null : submitValue;
    _submitValues[entry.key] = submitValue;

    if (FormEntryInputTypeHelper.isPicker(entry)) {
      _restorePickerValue(entry, submitValue);
      return;
    }

    if (_isContactPhoneEntry(entry) && submitValue.isNotEmpty) {
      _displayValues[entry.key] = _decodeContactPhone(submitValue);
    }
  }

  void _restorePickerValue(FormEntry entry, String submitValue) {
    final options = entry.selectList;
    if (options == null || options.isEmpty || submitValue.isEmpty) {
      return;
    }

    final matchedIndex = options.indexWhere(
      (option) => option.key == submitValue || option.value == submitValue,
    );
    if (matchedIndex < 0) {
      return;
    }

    _selectedIndices[entry.key] = matchedIndex;
    _displayValues[entry.key] = options[matchedIndex].value;
    _submitValues[entry.key] = options[matchedIndex].key;
  }

  void _restoreContactDisplayValues() {
    for (final phoneCode in _phoneToNameCodes.keys) {
      final phoneEntry = _findEntryByCode(phoneCode);
      final nameEntry = phoneEntry == null
          ? null
          : _nameEntryForPhone(phoneEntry);
      if (phoneEntry == null || nameEntry == null) {
        continue;
      }

      final name = _entryValue(nameEntry).trim();
      final phone = _phoneValueFor(phoneEntry);
      if (name.isEmpty || phone.isEmpty) {
        continue;
      }

      final displayValue = _formatContactDisplay(name, phone);
      _displayValues[phoneEntry.key] = displayValue;
      _textControllers[phoneEntry.key]?.text = displayValue;
    }
  }

  FormEntry? _nameEntryForPhone(FormEntry phoneEntry) {
    final nameCode = _phoneToNameCodes[phoneEntry.code];
    return nameCode == null ? null : _findEntryByCode(nameCode);
  }

  FormEntry? _findEntryByCode(String code) {
    return _entries.where((entry) => entry.code == code).firstOrNull;
  }

  bool _isContactPhoneEntry(FormEntry entry) {
    return _phoneToNameCodes.containsKey(entry.code) &&
        FormEntryInputTypeHelper.isContactPicker(entry);
  }

  String _entryValue(FormEntry? entry) {
    if (entry == null) {
      return '';
    }
    return _submitValues[entry.key] ?? _displayValues[entry.key] ?? '';
  }

  String _phoneValueFor(FormEntry phoneEntry) {
    return _normalizeContactPhone(_decodeContactPhone(_entryValue(phoneEntry)));
  }

  /// 解析可输入联系人字段，保留展示姓名，仅规范化手机号提交给后端。
  void _updateContactInputValue(FormEntry entry, String value) {
    final contactInput = _parseContactInput(value);
    final displayName = contactInput.name.trim();
    final normalizedPhone = _normalizeContactPhone(contactInput.phone);
    final displayValue = displayName.isEmpty
        ? normalizedPhone
        : _formatContactDisplay(displayName, normalizedPhone);

    _displayValues[entry.key] = displayValue;
    _submitValues[entry.key] = _encodeContactPhone(normalizedPhone);

    final nameEntry = _nameEntryForPhone(entry);
    if (nameEntry != null) {
      _displayValues[nameEntry.key] = displayName;
      _submitValues[nameEntry.key] = displayName;
      _textControllers[nameEntry.key]?.text = displayName;
    }
  }

  String _encodeContactPhone(String phoneNumber) {
    final normalizedPhone = _normalizeContactPhone(phoneNumber);
    if (normalizedPhone.isEmpty) {
      return '';
    }
    return jsonEncode({'contactPhoneNumber': normalizedPhone});
  }

  String _normalizeContactPhone(String phoneNumber) {
    return phoneNumber.trim().replaceAll(RegExp(r'\D'), '');
  }

  String _formatContactDisplay(String name, String phone) {
    final trimmedName = name.trim();
    final normalizedPhone = _normalizeContactPhone(phone);
    if (trimmedName.isEmpty) {
      return normalizedPhone;
    }
    return '$trimmedName-$normalizedPhone';
  }

  String _decodeContactPhone(String submitValue) {
    try {
      final decoded = jsonDecode(submitValue);
      if (decoded is Map<String, dynamic>) {
        return decoded['contactPhoneNumber'] as String? ?? submitValue;
      }
    } catch (_) {
      return submitValue;
    }
    return submitValue;
  }

  _ContactInputParts _parseContactInput(String value) {
    final trimmedValue = value.trim();
    final match = RegExp(
      r'^(.*?)[\s-]+([+\d][\d\s().-]*)$',
    ).firstMatch(trimmedValue);
    if (match == null) {
      return _ContactInputParts(name: '', phone: trimmedValue);
    }

    return _ContactInputParts(
      name: match.group(1) ?? '',
      phone: match.group(2) ?? '',
    );
  }
}

class _ContactInputParts {
  const _ContactInputParts({required this.name, required this.phone});

  final String name;
  final String phone;
}
