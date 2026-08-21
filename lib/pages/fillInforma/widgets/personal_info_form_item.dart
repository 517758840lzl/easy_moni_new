import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 个人信息表单项，统一承载选择项与文本输入项的展示样式。
class PersonalInfoFormItem extends StatelessWidget {
  const PersonalInfoFormItem({
    super.key,
    this.title,
    this.isRequired = false,
    this.value,
    this.placeholder = '',
    this.onTap,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.showDivider = true,
    this.isLoading = false,
    this.emphasized = false,
    this.trailing,
    this.inputTrailing,
    this.onInputTrailingTap,
  });

  final String? title;
  final bool isRequired;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool showDivider;
  final bool isLoading;
  final bool emphasized;
  final Widget? trailing;
  final Widget? inputTrailing;
  final VoidCallback? onInputTrailingTap;

  bool get _isTextInput => controller != null;

  @override
  Widget build(BuildContext context) {
    final hasTitle = title?.isNotEmpty ?? false;
    final itemContent = GestureDetector(
      onTap: _isTextInput ? null : _handlePickerTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTitle) ...[
              _FormItemTitle(title: title!, isRequired: isRequired),
              const SizedBox(height: 10),
            ],
            Padding(
              padding: EdgeInsets.only(
                left: hasTitle && !isRequired ? 0 : _requiredMarkWidth,
              ),
              child: _isTextInput ? _buildTextField() : _buildPickerValue(),
            ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        _isTextInput ? itemContent : _buildFocusablePicker(itemContent),
        if (showDivider)
          Container(
            margin: EdgeInsets.zero,
            height: 1,
            color: _isTextInput
                ? const Color(0xFFE7E7E7)
                : const Color(0xFFF5F5F5),
          ),
      ],
    );
  }

  Widget _buildFocusablePicker(Widget child) {
    if (focusNode == null) {
      return child;
    }

    return Focus(
      focusNode: focusNode,
      descendantsAreFocusable: false,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          _handlePickerTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  void _handlePickerTap() {
    focusNode?.requestFocus();
    onTap?.call();
  }

  Widget _buildTextField() {
    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        hintText: placeholder,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        suffixIcon: inputTrailing == null
            ? null
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onInputTrailingTap,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: inputTrailing,
                ),
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
      style: const TextStyle(fontSize: 14, color: Colors.black),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );

    if (!emphasized) {
      return field;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE53935)),
      ),
      child: field,
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
      size: 16,
      color: Colors.black.withValues(alpha: 0.8),
    );
  }
}

/// 仅展示型表单项，复用统一标题样式，不展示 defaultText。
class PersonalInfoDisplayFormItem extends StatelessWidget {
  const PersonalInfoDisplayFormItem({
    super.key,
    this.title,
    this.isRequired = false,
    this.showDivider = true,
  });

  final String? title;
  final bool isRequired;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final hasTitle = title?.isNotEmpty ?? false;
    if (!hasTitle) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _FormItemTitle(title: title!, isRequired: isRequired),
        ),
        // if (showDivider)
        //   const Divider(height: 1, thickness: 1, color: Color(0xFFE7E7E7)),
      ],
    );
  }
}

const double _requiredMarkWidth = 16;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isRequired)
            const SizedBox(
              width: _requiredMarkWidth,
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              height: 1,
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
