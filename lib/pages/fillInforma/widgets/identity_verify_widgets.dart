import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/controllers/identity_verify_form_controller.dart';
import 'package:easy_moni/pages/fillInforma/widgets/personal_info_form_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 身份证 OCR 信息核对提示。
class IdentityCheckNotice extends StatelessWidget {
  const IdentityCheckNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          '*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8),
        Text(
          AppStrings.identityVerifyCheckInfo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// 身份证正反面贴图上传区域。
class IdCardUploadItem extends StatelessWidget {
  const IdCardUploadItem({
    super.key,
    required this.bgImage,
    required this.imageData,
    required this.onTap,
  });

  final AssetGenImage bgImage;
  final Uint8List? imageData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFilled = imageData != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (MediaQuery.of(context).size.width - 40) * 683.0 / 1005.0,
        decoration: BoxDecoration(
          image: DecorationImage(image: bgImage.provider(), fit: BoxFit.contain),
        ),
        child: Stack(
          children: [
            if (!isFilled)
              Center(
                child: Assets.images.inforamtionScan.image(
                  width: 40,
                  height: 40,
                ),
              ),
            if (isFilled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF8FB3B0),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: MemoryImage(imageData!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.cached_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// OCR 回显表单项，按后端 selectList 决定文本输入或选择项。
class IdentityFormEntryItem extends StatelessWidget {
  const IdentityFormEntryItem({
    super.key,
    required this.entry,
    required this.formController,
    required this.onTextChanged,
    required this.onTextSubmitted,
    required this.onPickerTap,
    required this.onDatePickerTap,
  });

  final FormEntry entry;
  final IdentityVerifyFormController formController;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<FormEntry> onTextSubmitted;
  final ValueChanged<FormEntry> onPickerTap;
  final ValueChanged<FormEntry> onDatePickerTap;

  @override
  Widget build(BuildContext context) {
    if (formController.isTextEntry(entry)) {
      return PersonalInfoFormItem(
        title: entry.showContent,
        isRequired: entry.must == 1,
        placeholder: entry.defaultText,
        controller: formController.controllerFor(entry),
        focusNode: formController.focusNodeFor(entry),
        textInputAction: formController.hasNextVisibleEntry(entry)
            ? TextInputAction.next
            : TextInputAction.done,
        onChanged: onTextChanged,
        onSubmitted: (_) => onTextSubmitted(entry),
      );
    }

    if (formController.isBirthdayPickerEntry(entry)) {
      return PersonalInfoFormItem(
        title: entry.showContent,
        isRequired: entry.must == 1,
        value: formController.displayValueFor(entry),
        placeholder: entry.defaultText,
        focusNode: formController.focusNodeFor(entry),
        trailing: const Icon(
          Icons.calendar_month_outlined,
          size: 16,
          color: Color(0xCC000000),
        ),
        onTap: () => onDatePickerTap(entry),
      );
    }

    return PersonalInfoFormItem(
      title: entry.showContent,
      isRequired: entry.must == 1,
      value: formController.displayValueFor(entry),
      placeholder: entry.defaultText,
      focusNode: formController.focusNodeFor(entry),
      onTap: () => onPickerTap(entry),
    );
  }
}

/// 身份证上传方式选择弹窗内容。
class UploadMethodSheet extends StatelessWidget {
  const UploadMethodSheet({
    super.key,
    required this.onPickFromGallery,
    required this.onTakePhoto,
  });

  final VoidCallback onPickFromGallery;
  final VoidCallback onTakePhoto;

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onPickFromGallery,
    required VoidCallback onTakePhoto,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return UploadMethodSheet(
          onPickFromGallery: () {
            Navigator.pop(context);
            onPickFromGallery();
          },
          onTakePhoto: () {
            Navigator.pop(context);
            onTakePhoto();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE7E7E7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                AppStrings.chooseUploadMethod,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101314),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.checkIdCard,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3F4950),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _UploadMethodOption(
                      icon: Assets.images.gallerySend.image(
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      text: AppStrings.selectFormPhotos,
                      onTap: onPickFromGallery,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _UploadMethodOption(
                      icon: Assets.images.cameraM.image(
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      cornerDecoration: Assets.images.inforamtionStar.image(
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                      text: AppStrings.takephotos,
                      onTap: onTakePhoto,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}

/// 身份证号码二次确认弹窗图标。
class ConfirmIdNumberIcon extends StatelessWidget {
  const ConfirmIdNumberIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0x1A27D3C3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Icon(
        Icons.priority_high_rounded,
        size: 52,
        color: Color(0xFF27B7A7),
      ),
    );
  }
}

/// 上传方式选择项，按设计稿展示图标与右上角推荐标识。
class _UploadMethodOption extends StatelessWidget {
  const _UploadMethodOption({
    required this.icon,
    this.cornerDecoration,
    required this.text,
    required this.onTap,
  });

  final Widget icon;
  final Widget? cornerDecoration;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(height: 4),
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (cornerDecoration != null)
              Positioned(top: -1, right: 8, child: cornerDecoration!),
          ],
        ),
      ),
    );
  }
}
