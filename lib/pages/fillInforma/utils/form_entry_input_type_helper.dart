import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:flutter/services.dart';

/// 后端表单项输入类型常量，统一描述信息填写流程的 1-10 类型。
class FormEntryInputType {
  FormEntryInputType._();

  static const int text = 1;
  static const int dropdown = 2;
  static const int number = 3;
  static const int radio = 4;
  static const int date = 5;
  static const int idCardImage = 6;
  static const int faceVerify = 7;
  static const int displayOnly = 8;
  static const int contactPickOnly = 9;
  static const int contactInputOrPick = 10;
}

/// 表单输入类型工具类，负责把后端 type 转换为页面可复用的渲染与输入规则。
class FormEntryInputTypeHelper {
  FormEntryInputTypeHelper._();

  /// 判断表单项是否由文本输入框承载。
  static bool isTextInput(FormEntry entry) {
    return entry.type == FormEntryInputType.text ||
        entry.type == FormEntryInputType.number ||
        entry.type == FormEntryInputType.contactInputOrPick;
  }

  /// 判断表单项是否由底部选择器承载。
  static bool isPicker(FormEntry entry) {
    if (isTextInput(entry) ||
        isDisplayOnly(entry) ||
        isContactPicker(entry) ||
        isDatePicker(entry) ||
        isSpecialProcessEntry(entry)) {
      return false;
    }

    return entry.type == FormEntryInputType.dropdown ||
        entry.type == FormEntryInputType.radio ||
        hasOptions(entry);
  }

  /// 判断表单项是否为联系人选择类。
  static bool isContactPicker(FormEntry entry) {
    return entry.type == FormEntryInputType.contactPickOnly ||
        entry.type == FormEntryInputType.contactInputOrPick;
  }

  /// 判断表单项是否允许用户手动输入联系人。
  static bool isContactInputOrPick(FormEntry entry) {
    return entry.type == FormEntryInputType.contactInputOrPick;
  }

  /// 判断表单项是否为日期选择类。
  static bool isDatePicker(FormEntry entry) {
    return entry.type == FormEntryInputType.date;
  }

  /// 判断表单项是否为证件图片上传类。
  static bool isIdCardImage(FormEntry entry) {
    return entry.type == FormEntryInputType.idCardImage;
  }

  /// 判断表单项是否为人脸验证类。
  static bool isFaceVerify(FormEntry entry) {
    return entry.type == FormEntryInputType.faceVerify;
  }

  /// 判断表单项是否仅展示标题。
  static bool isDisplayOnly(FormEntry entry) {
    return entry.type == FormEntryInputType.displayOnly;
  }

  /// 判断表单项是否属于其他专用流程页面。
  static bool isSpecialProcessEntry(FormEntry entry) {
    return isIdCardImage(entry) || isFaceVerify(entry);
  }

  /// 判断表单项是否具备后端选项数据。
  static bool hasOptions(FormEntry entry) {
    return entry.selectList != null && entry.selectList!.isNotEmpty;
  }

  /// 根据后端输入类型提供键盘类型。
  static TextInputType keyboardTypeFor(FormEntry entry) {
    // 联系人姓名字段即使支持通讯录选择，也应保留普通文本输入体验。
    if (_isContactNameEntry(entry)) {
      return TextInputType.text;
    }
    if (entry.type == FormEntryInputType.number) {
      return TextInputType.number;
    }
    if (isContactPicker(entry)) {
      return TextInputType.phone;
    }
    return TextInputType.text;
  }

  /// 根据后端输入类型提供输入限制。
  static List<TextInputFormatter>? inputFormattersFor(FormEntry entry) {
    if (_isContactNameEntry(entry)) {
      return null;
    }
    // 联系人可输入字段可能展示“姓名-手机号”，不能使用纯数字过滤器。
    if (entry.type == FormEntryInputType.contactInputOrPick) {
      return null;
    }
    if (entry.type == FormEntryInputType.number) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  static bool _isContactNameEntry(FormEntry entry) {
    return entry.code == '30052' || entry.code == '30062';
  }
}
