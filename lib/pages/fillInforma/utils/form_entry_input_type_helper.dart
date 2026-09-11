import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:flutter/services.dart';

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

class FormEntryInputTypeHelper {
  FormEntryInputTypeHelper._();

  static bool isTextInput(FormEntry entry) {
    return entry.type == FormEntryInputType.text ||
        entry.type == FormEntryInputType.number ||
        entry.type == FormEntryInputType.contactInputOrPick;
  }

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

  static bool isContactPicker(FormEntry entry) {
    return entry.type == FormEntryInputType.contactPickOnly ||
        entry.type == FormEntryInputType.contactInputOrPick;
  }

  static bool isContactInputOrPick(FormEntry entry) {
    return entry.type == FormEntryInputType.contactInputOrPick;
  }

  static bool isDatePicker(FormEntry entry) {
    return entry.type == FormEntryInputType.date;
  }

  static bool isIdCardImage(FormEntry entry) {
    return entry.type == FormEntryInputType.idCardImage;
  }

  static bool isFaceVerify(FormEntry entry) {
    return entry.type == FormEntryInputType.faceVerify;
  }

  static bool isDisplayOnly(FormEntry entry) {
    return entry.type == FormEntryInputType.displayOnly;
  }

  static bool isSpecialProcessEntry(FormEntry entry) {
    return isIdCardImage(entry) || isFaceVerify(entry);
  }

  static bool hasOptions(FormEntry entry) {
    return entry.selectList != null && entry.selectList!.isNotEmpty;
  }

  static TextInputType keyboardTypeFor(FormEntry entry) {
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

  static List<TextInputFormatter>? inputFormattersFor(FormEntry entry) {
    if (_isContactNameEntry(entry)) {
      return null;
    }
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
