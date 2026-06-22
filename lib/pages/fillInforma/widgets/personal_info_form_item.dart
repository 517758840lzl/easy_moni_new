import 'package:flutter/material.dart';

/// 个人信息表单项，统一承载选择项与文本输入项的展示样式。
class PersonalInfoFormItem extends StatelessWidget {
  const PersonalInfoFormItem({
    super.key,
    required this.title,
    required this.isRequired,
    this.value,
    this.placeholder = '',
    this.onTap,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.showDivider = true,
    this.isLoading = false,
    this.trailing,
  });

  final String title;
  final bool isRequired;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool showDivider;
  final bool isLoading;
  final Widget? trailing;

  bool get _isTextInput => controller != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isTextInput ? null : onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormItemTitle(title: title, isRequired: isRequired),
                SizedBox(height: _isTextInput ? 10 : 8),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: _isTextInput ? _buildTextField() : _buildPickerValue(),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.only(left: _isTextInput ? 0 : 20),
            height: 1,
            color: _isTextInput
                ? const Color(0xFFE7E7E7)
                : const Color(0xFFF5F5F5),
          ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        hintText: placeholder,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 14, color: Colors.black),
      onChanged: onChanged,
    );
  }

  Widget _buildPickerValue() {
    return Row(
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF268470)),
            ),
          )
        else
          Expanded(
            child: Text(
              value ?? placeholder,
              style: TextStyle(
                fontSize: 14,
                color: value != null ? Colors.black : const Color(0xFFCCCCCC),
              ),
            ),
          ),
        if (!isLoading) trailing ?? _buildDefaultTrailingIcon(),
      ],
    );
  }

  Widget _buildDefaultTrailingIcon() {
    return Icon(
      Icons.chevron_right,
      size: 12,
      color: Colors.black.withValues(alpha: 0.3),
    );
  }
}

/// 表单项标题，负责必填星号和标题文本的统一排版。
class _FormItemTitle extends StatelessWidget {
  const _FormItemTitle({required this.title, required this.isRequired});

  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          if (isRequired)
            const Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
                letterSpacing: 0.4,
              ),
            ),
          if (isRequired) const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
