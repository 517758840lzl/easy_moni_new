import 'dart:typed_data';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/controllers/identity_verify_form_controller.dart';
import 'package:easy_moni/pages/fillInforma/utils/form_entry_input_type_helper.dart';
import 'package:easy_moni/pages/fillInforma/widgets/personal_info_form_item.dart';
import 'package:flutter/material.dart';

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
        Expanded(
          child: Text(
            AppStrings.identityVerifyCheckInfo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.4,
            ),
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
    required this.isProcessing,
    this.errorText,
    required this.onTap,
  });

  final AssetGenImage bgImage;
  final Uint8List? imageData;
  final bool isProcessing;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localImageData = imageData;
    final isFilled = localImageData != null && localImageData.isNotEmpty;
    final normalizedErrorText = errorText?.trim();
    final hasError =
        normalizedErrorText != null && normalizedErrorText.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (MediaQuery.of(context).size.width - 40) * 683.0 / 1005.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: bgImage.provider(),
            fit: BoxFit.contain,
          ),
        ),
        child: Stack(
          children: [
            if (isFilled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            localImageData,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) {
                              return const _IdCardImageStatus(
                                icon: Icons.broken_image_outlined,
                                message:
                                    AppStrings.identityVerifyImageLoadFailed,
                                color: Color(0xFFE5484D),
                              );
                            },
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
            if (!isFilled && !isProcessing)
              Center(
                child: hasError
                    ? _IdCardImageStatus(
                        icon: Icons.error_outline,
                        message: normalizedErrorText,
                        color: const Color(0xFFE5484D),
                      )
                    : Assets.images.inforamtionScan.image(
                        width: 40,
                        height: 40,
                      ),
              ),
            if (isProcessing)
              const Positioned.fill(child: _IdCardImageProcessingOverlay()),
          ],
        ),
      ),
    );
  }
}

/// 证件图片上传中的加载状态。
class _IdCardImageProcessingOverlay extends StatelessWidget {
  const _IdCardImageProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

/// 证件图片失败态提示，统一承接上传失败与远端图片加载失败。
class _IdCardImageStatus extends StatelessWidget {
  const _IdCardImageStatus({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
              height: 1.3,
            ),
          ),
        ],
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
        keyboardType: FormEntryInputTypeHelper.keyboardTypeFor(entry),
        inputFormatters: FormEntryInputTypeHelper.inputFormattersFor(entry),
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
    this.options,
    required this.onPickFromGallery,
    required this.onTakePhoto,
  });

  final List<SelectOption>? options;
  final VoidCallback onPickFromGallery;
  final VoidCallback onTakePhoto;

  static Future<void> show({
    required BuildContext context,
    List<SelectOption>? options,
    required VoidCallback onPickFromGallery,
    required VoidCallback onTakePhoto,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      requestFocus: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: UploadMethodSheet(
            options: options,
            onPickFromGallery: () {
              Navigator.pop(context);
              onPickFromGallery();
            },
            onTakePhoto: () {
              Navigator.pop(context);
              onTakePhoto();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadMethods = _resolveUploadMethods();
    final itemWidth = (MediaQuery.of(context).size.width - 72) / 2;
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
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: uploadMethods
                    .map(
                      (method) => SizedBox(
                        width: itemWidth,
                        child: _UploadMethodOption(
                          icon: method.isGallery
                              ? Assets.images.gallerySend.image(
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                )
                              : Assets.images.cameraM.image(
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                          cornerDecoration: method.isGallery
                              ? null
                              : Assets.images.inforamtionStar.image(
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                ),
                          text: method.label,
                          onTap: method.isGallery
                              ? onPickFromGallery
                              : onTakePhoto,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  List<_UploadMethodData> _resolveUploadMethods() {
    final backendOptions = options;
    if (backendOptions == null || backendOptions.isEmpty) {
      return const [
        _UploadMethodData(label: AppStrings.selectFormPhotos, isGallery: true),
        _UploadMethodData(label: AppStrings.takephotos, isGallery: false),
      ];
    }

    final methods = backendOptions
        .map((option) {
          final isGallery = _isGalleryOption(option);
          final label = _fallbackUploadLabel(isGallery: isGallery);
          return _UploadMethodData(label: label, isGallery: isGallery);
        })
        .toList(growable: false);

    // 上传方式视觉顺序固定为左侧相册、右侧拍照，不受后端 selectList 顺序影响。
    methods.sort((a, b) {
      if (a.isGallery == b.isGallery) {
        return 0;
      }
      return a.isGallery ? -1 : 1;
    });
    return methods;
  }

  bool _isGalleryOption(SelectOption option) {
    final text = '${option.key} ${option.value}'.toLowerCase();
    return option.key == '2' ||
        text.contains('album') ||
        text.contains('gallery');
  }

  String _fallbackUploadLabel({required bool isGallery}) {
    return isGallery ? AppStrings.selectFormPhotos : AppStrings.takephotos;
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

/// 上传方式视图数据，后端 key 暂按 1=拍照、2=相册 映射到本地动作。
class _UploadMethodData {
  const _UploadMethodData({required this.label, required this.isGallery});

  final String label;
  final bool isGallery;
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
