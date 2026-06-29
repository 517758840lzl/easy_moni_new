import 'dart:convert';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/core/utils/app_logger.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/entities/provinces_cities_area_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/provinces_cities_area_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/widgets/personal_info_form_item.dart';
import 'package:easy_moni/pages/fillInforma/widgets/picker_bottom_sheet.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/widgets/loan_bottom_action_button.dart';
import 'package:easy_moni/utils/widgets/limit_toast.dart';
import 'package:easy_moni/utils/widgets/permission_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoPage extends ConsumerStatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
  static const double _headerTitleBarHeight = 44;
  static const double _headerTopGap = 16;
  static const double _stepIndicatorHeight = 56;
  static const double _headerBottomGap = 16;
  static const String _codeEmail = '10003';
  static const String _codeRegionCity = '10004';

  StepInfo? _stepInfo;
  bool _isLoading = true;
  bool _isSubmitting = false;
  int? _processId;
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, int> _selectedIndices = {};
  final Map<String, String?> _selectedValues = {};
  final Map<String, String?> _selectedSubmitValues = {};

  // 省市数据（从后台获取）
  List<AreaItem> _provinces = [];
  List<AreaItem> _cities = [];
  final List<Map<String, String>> _regionCityData = [];

  int _selectedRegionIndex = 0;
  bool _isLoadingLocation = false;
  bool _hasHandledInitialLocation = false;

  bool _isRegionEntry(FormEntry entry) {
    return entry.code == _codeRegionCity;
  }

  bool _isEmailEntry(FormEntry entry) {
    return entry.code == _codeEmail;
  }

  bool _isPickerEntry(FormEntry entry) {
    if (_isEmailEntry(entry) || entry.type == 1) {
      return false;
    }
    if (_isRegionEntry(entry)) {
      return true;
    }
    return entry.selectList != null && entry.selectList!.isNotEmpty;
  }

  bool _isEntryFilled(FormEntry entry) {
    final value = _selectedValues[entry.key];
    return value != null && value.trim().isNotEmpty;
  }

  FormEntry? _findNextUnfilledPickerEntry(FormEntry currentEntry) {
    final entries = _stepInfo?.entries;
    if (entries == null || entries.isEmpty) return null;

    final currentIndex = entries.indexWhere(
      (entry) => entry.key == currentEntry.key,
    );
    if (currentIndex < 0) return null;

    for (var i = currentIndex + 1; i < entries.length; i++) {
      final nextEntry = entries[i];
      if (!_isPickerEntry(nextEntry)) {
        continue;
      }
      if (!_isEntryFilled(nextEntry)) {
        return nextEntry;
      }
    }
    return null;
  }

  void _openPickerForEntry(FormEntry entry) {
    final key = entry.key;
    if (_isRegionEntry(entry)) {
      _showRegionPicker(entry: entry);
      return;
    }

    final options = entry.selectList;
    if (options == null || options.isEmpty) {
      return;
    }

    _showPicker(
      entry: entry,
      title: entry.showContent,
      options: options,
      selectedIndex: _selectedIndices[key] ?? 0,
      onConfirm: (index) {
        setState(() {
          _selectedIndices[key] = index;
          _selectedValues[key] = options[index].value;
          _selectedSubmitValues[key] = options[index].key;
        });
      },
    );
  }

  void _scheduleNextUnfilledPicker(FormEntry currentEntry) {
    final nextEntry = _findNextUnfilledPickerEntry(currentEntry);
    if (nextEntry == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _openPickerForEntry(nextEntry);
      });
    });
  }

  void _setRegionValueForEntry(
    String entryKey, {
    required String province,
    required String city,
  }) {
    _selectedValues[entryKey] = city.isNotEmpty
        ? '$province - $city'
        : province;
    _selectedSubmitValues[entryKey] = _buildGeoLocationSubmitValue(
      province,
      city,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchData() async {
    AppLogger.debug('_fetchData 开始...');
    try {
      // 并行获取表单配置与地区数据
      final formFuture = ref.read(acpElementInfoProvider).call(1);
      final areaFuture = ref.read(provincesCitiesAreaProvider).call();
      final formResult = await formFuture;
      final areaResult = await areaFuture;

      if (!mounted) return;

      _applyFormResult(formResult);
      _applyAreaResult(areaResult);

      AppLogger.debug('_fetchData 完成, _isLoading 设置为 false');
      setState(() => _isLoading = false);
      _scheduleInitialLocationCheck();
    } catch (e, stack) {
      AppLogger.debug('获取数据失败: $e');
      AppLogger.debug('堆栈: $stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 应用个人信息表单配置，并恢复后台已提交过的表单值。
  void _applyFormResult(HttpResult<AcpElementInfoResp> result) {
    if (!result.isSuccess || result.data == null) {
      AppLogger.debug('表单数据获取失败: ${result.message}');
      return;
    }

    final data = result.data!;
    final stepInfo = data.stepInfoList.firstOrNull;
    AppLogger.debug(
      'stepInfoList length: ${data.stepInfoList.length}, stepInfo: $stepInfo',
    );
    if (stepInfo == null) {
      return;
    }

    _stepInfo = stepInfo;
    _processId = data.processId;
    AppLogger.debug('设置 _stepInfo, entries 数量: ${stepInfo.entries.length}');

    for (final entry in stepInfo.entries) {
      _initializeEntryValue(entry);
    }
  }

  /// 应用地区数据，供地区选择器和历史值回显使用。
  void _applyAreaResult(HttpResult<ProvincesCitiesAreaResp> result) {
    AppLogger.debug('areaResult.isSuccess: ${result.isSuccess}');
    if (!result.isSuccess || result.data == null) {
      return;
    }

    _provinces = result.data!.province;
    _cities = result.data!.city;
    _buildRegionCityData();
  }

  /// 初始化单个表单项的展示值、提交值和选择器索引。
  void _initializeEntryValue(FormEntry entry) {
    final submitValue = entry.submitValue;
    _selectedIndices[entry.key] = 0;
    _selectedValues[entry.key] = submitValue;
    _selectedSubmitValues[entry.key] = submitValue;
    AppLogger.debug('entry: ${entry.key} - ${entry.showContent}');

    if (_isEmailEntry(entry) || entry.type == 1) {
      _textControllers[entry.key] = TextEditingController(
        text: submitValue ?? '',
      );
    }

    if (submitValue == null || submitValue.isEmpty) {
      return;
    }

    if (_isRegionEntry(entry)) {
      _restoreRegionEntryValue(entry.key, submitValue);
      return;
    }

    _restorePickerEntryValue(entry, submitValue);
  }

  void _restoreRegionEntryValue(String entryKey, String submitValue) {
    final regionData = _parseGeoLocationSubmitValue(submitValue);
    _setRegionValueForEntry(
      entryKey,
      province: regionData.$1,
      city: regionData.$2,
    );

    final matchedRegionIndex = _regionCityData.indexWhere(
      (item) =>
          item['region'] == regionData.$1 && item['city'] == regionData.$2,
    );
    if (matchedRegionIndex >= 0) {
      _selectedRegionIndex = matchedRegionIndex;
    }
  }

  void _restorePickerEntryValue(FormEntry entry, String submitValue) {
    final options = entry.selectList;
    final matchedIndex = options?.indexWhere(
      (option) => option.key == submitValue,
    );
    if (options == null || matchedIndex == null || matchedIndex < 0) {
      return;
    }

    _selectedIndices[entry.key] = matchedIndex;
    _selectedValues[entry.key] = options[matchedIndex].value;
  }

  (String, String) _parseGeoLocationSubmitValue(String rawValue) {
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map<String, dynamic>) {
        return (
          decoded['homeProvince'] as String? ?? '',
          decoded['homeCity'] as String? ?? '',
        );
      }
    } catch (_) {
      AppLogger.debug('地区提交值解析失败: $rawValue');
    }
    return ('', '');
  }

  /// 组装省市区数据
  void _buildRegionCityData() {
    _regionCityData.clear();
    for (final province in _provinces) {
      // 查找该省下的所有城市
      final provinceCities = _cities
          .where((city) => city.parentId == province.id)
          .toList();

      if (provinceCities.isNotEmpty) {
        for (final city in provinceCities) {
          _regionCityData.add({'region': province.name, 'city': city.name});
        }
      } else {
        // 如果该省没有城市，只添加省
        _regionCityData.add({'region': province.name, 'city': ''});
      }
    }
  }

  bool get _canContinue {
    if (_stepInfo == null) return false;
    for (final entry in _stepInfo!.entries) {
      if (entry.must == 1 &&
          (_selectedValues[entry.key] == null ||
              _selectedValues[entry.key]!.isEmpty)) {
        return false;
      }
    }
    return true;
  }

  /// 页面初始化后处理定位权限：已授权直接定位，未授权才展示业务说明弹窗。
  void _scheduleInitialLocationCheck() {
    if (_hasHandledInitialLocation || !_hasRegionEntryToFill) {
      return;
    }
    _hasHandledInitialLocation = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkInitialLocationPermission();
    });
  }

  bool get _hasRegionEntryToFill {
    final regionEntry = _regionEntry;
    return regionEntry != null && !_isEntryFilled(regionEntry);
  }

  FormEntry? get _regionEntry {
    return _stepInfo?.entries
        .where(_isRegionEntry)
        .cast<FormEntry?>()
        .firstOrNull;
  }

  String get _pageTitle => _stepInfo?.pageTitle.trim() ?? '';

  /// 按信息采集流程 header 比例计算白色内容区起点。
  double _contentTop(BuildContext context) {
    return MediaQuery.of(context).padding.top +
        _headerTitleBarHeight +
        _headerTopGap +
        _stepIndicatorHeight +
        _headerBottomGap;
  }

  Future<void> _checkInitialLocationPermission() async {
    try {
      // 仅检查系统授权状态，避免已授权用户再次看到位置权限引导弹窗。
      final isLocationPermissionGranted =
          await LocationService.checkPermission();
      if (!mounted) return;

      if (isLocationPermissionGranted) {
        await _detectLocationAndFillRegion();
        return;
      }

      // 未授权时先展示业务说明弹窗，用户确认后直接进入系统权限设置页。
      final shouldOpenSettings = await _showLocationPermissionDialog();
      if (!mounted || !shouldOpenSettings) return;

      await LocationService.openAppSettings();
    } catch (e) {
      AppLogger.debug('初始化定位权限检查失败: $e');
    }
  }

  /// 获取当前位置并回填地区；定位失败或服务不可用时降级为手动选择。
  Future<void> _detectLocationAndFillRegion() async {
    if (_isLoadingLocation) return;

    setState(() => _isLoadingLocation = true);

    try {
      final serviceEnabled = await LocationService.isServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        return;
      }

      final position = await LocationService.getCurrentLocation();
      if (!mounted) return;
      if (position == null) {
        return;
      }

      AppLogger.debug(
        '获取到位置: ${position['latitude']}, ${position['longitude']}',
      );

      final matchedRegion = _matchRegionByCoordinates(
        position['latitude']!,
        position['longitude']!,
      );
      final matchedIndex = _regionCityData.indexWhere(
        (item) => item['region'] == matchedRegion,
      );
      if (matchedIndex < 0 || _regionCityData.isEmpty) {
        return;
      }

      setState(() {
        _selectedRegionIndex = matchedIndex;
        final selectedData = _regionCityData[_selectedRegionIndex];
        final regionEntry = _regionEntry;
        if (regionEntry != null) {
          _setRegionValueForEntry(
            regionEntry.key,
            province: selectedData['region']!,
            city: selectedData['city']!,
          );
        }
      });
    } catch (e) {
      AppLogger.debug('获取位置失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  String _matchRegionByCoordinates(double lat, double lng) {
    if (lng < -1.5) {
      return 'Ashanti';
    } else if (lng > -0.2 && lng < 0.3 && lat > 5.5 && lat < 6.3) {
      return 'Greater Accra';
    } else if (lat < 5.5) {
      return 'Central';
    } else if (lng > 0.3 && lng < 1.0) {
      return 'Eastern';
    } else if (lat > 4.5 && lat < 5.5 && lng < -1.5) {
      return 'Western';
    }
    return 'Greater Accra';
  }

  Future<bool> _showLocationPermissionDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        final bottomPadding = MediaQuery.paddingOf(context).bottom;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Material(
            color: const Color(0xFFFDFEFF),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Assets.images.inforamtionLocation.image(
                            width: 115,
                            height: 116,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppStrings.locationPermissionTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101314),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppStrings.locationPermissionDesc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF3F4950),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ColoredBox(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: PermissionActionButtons(
                          secondaryText: AppStrings.cancel,
                          primaryText: AppStrings.goSettings,
                          onSecondaryPressed: () =>
                              Navigator.of(context).pop(false),
                          onPrimaryPressed: () =>
                              Navigator.of(context).pop(true),
                        ),
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Center(child: _LocationPermissionDragHandle()),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  /// 展示地区城市选择弹窗，省市展示格式由页面侧适配。
  void _showRegionPicker({FormEntry? entry}) {
    if (_regionCityData.isEmpty) {
      return;
    }

    PickerBottomSheet.show(
      context: context,
      title: AppStrings.personalInfoRegionCityTitle,
      options: _regionCityData.map((item) {
        final region = item['region'] ?? '';
        final city = item['city'] ?? '';
        return PickerBottomSheetOption(
          label: city.isNotEmpty ? '$region - $city' : region,
        );
      }).toList(),
      selectedIndex: _selectedRegionIndex,
      onConfirm: (index) {
        setState(() {
          _selectedRegionIndex = index;
          final selectedData = _regionCityData[index];
          final regionEntry = entry ?? _regionEntry;
          if (regionEntry != null) {
            _setRegionValueForEntry(
              regionEntry.key,
              province: selectedData['region'] ?? '',
              city: selectedData['city'] ?? '',
            );
            _scheduleNextUnfilledPicker(regionEntry);
          }
        });
      },
    );
  }

  /// 展示普通表单选项弹窗。
  void _showPicker({
    required FormEntry entry,
    required String title,
    required List<SelectOption> options,
    required int selectedIndex,
    required Function(int) onConfirm,
  }) {
    PickerBottomSheet.show(
      context: context,
      title: title,
      options: options
          .map((item) => PickerBottomSheetOption(label: item.value))
          .toList(),
      selectedIndex: selectedIndex,
      onConfirm: (index) {
        onConfirm(index);
        _scheduleNextUnfilledPicker(entry);
      },
    );
  }

  String _buildGeoLocationSubmitValue(String province, String city) {
    return jsonEncode({'homeCity': city, 'homeProvince': province});
  }

  Future<void> _onContinue() async {
    if (!_canContinue ||
        _isSubmitting ||
        _stepInfo == null ||
        _processId == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final jsonParam = _stepInfo!.entries.map((entry) {
        return {
          'key': entry.key,
          'value': _selectedSubmitValues[entry.key] ?? '',
        };
      }).toList();

      final result = await ref
          .read(submitAcpElementInfoProvider)
          .call(
            processId: _processId!,
            step: _stepInfo!.step,
            jsonParam: jsonParam,
          );

      if (!mounted) return;

      if (result.isSuccess) {
        final submitData = result.data;
        if (submitData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? AppStrings.errorMessage)),
          );
          return;
        }

        final route = AcquisitionProgressRouteResolver.resolveSubmitResult(
          submitData,
        );
        if (route == AppRoutePaths.home) {
          context.go(route);
        } else {
          context.push(route);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message ?? '保存失败')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoanRoundedPageShell(
      contentTop: _contentTop,
      contentTopRadius: 12,
      backgroundColor: AppColors.primaryDark,
      header: buildInformationHeader(
        context: context,
        title: _pageTitle,
        activeStep: InformationStep.personal,
        onBack: () => FundingLimitDialog.showRetainDialog(context),
      ),
      content: _buildContent(),
      bottomNavigationBar: LoanBottomActionButton(
        enabled: _canContinue && !_isSubmitting,
        onPressed: _canContinue && !_isSubmitting ? _onContinue : null,
        text: _isSubmitting
            ? AppStrings.personalInfoSaving
            : AppStrings.continueStr,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _stepInfo?.entries.map(_buildEntryItem).toList() ?? [],
      ),
    );
  }

  /// 根据后台表单配置生成对应的个人信息表单项。
  Widget _buildEntryItem(FormEntry entry) {
    if (_isEmailEntry(entry) || entry.type == 1) {
      final controller = _textControllers[entry.key] ??= TextEditingController(
        text: _selectedValues[entry.key] ?? '',
      );

      return PersonalInfoFormItem(
        title: entry.showContent,
        isRequired: entry.must == 1,
        placeholder: entry.defaultText,
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          setState(() {
            _selectedValues[entry.key] = value.trim();
            _selectedSubmitValues[entry.key] = value.trim();
          });
        },
      );
    }

    return PersonalInfoFormItem(
      title: entry.showContent,
      isRequired: entry.must == 1,
      value: _selectedValues[entry.key],
      placeholder: entry.defaultText,
      onTap: () => _openPickerForEntry(entry),
    );
  }
}

class _LocationPermissionDragHandle extends StatelessWidget {
  const _LocationPermissionDragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
