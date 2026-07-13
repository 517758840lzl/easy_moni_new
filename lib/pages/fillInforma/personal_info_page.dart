import 'dart:convert';

import 'package:easy_moni/core/constants/app_strings.dart';
import 'package:easy_moni/core/network/http_result.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/core/router/app_routes.dart';
import 'package:easy_moni/core/theme/app_theme.dart';
import 'package:easy_moni/entities/acp_element_info_resp.dart';
import 'package:easy_moni/entities/provinces_cities_area_resp.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import 'package:easy_moni/pages/fillInforma/providers/acquisition_progress_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/provinces_cities_area_provider.dart';
import 'package:easy_moni/pages/fillInforma/providers/submit_acp_element_info_provider.dart';
import 'package:easy_moni/pages/fillInforma/utils/form_entry_input_type_helper.dart';
import 'package:easy_moni/pages/fillInforma/widgets/personal_info_form_item.dart';
import 'package:easy_moni/pages/fillInforma/widgets/picker_bottom_sheet.dart';
import 'package:easy_moni/pages/fillInforma/widgets/progress_information.dart';
import 'package:easy_moni/pages/loan/components/loan_page_shell.dart';
import 'package:easy_moni/services/platform_service.dart';
import 'package:easy_moni/utils/widgets/app_state_view.dart';
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
  static const double _stepIndicatorHeight = 80;
  static const double _headerBottomGap = 16;
  static const String _codeRegionCity = '10004';

  StepInfo? _stepInfo;
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _isSubmitting = false;
  int? _processId;
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, int> _selectedIndices = {};
  final Map<String, String?> _selectedValues = {};
  final Map<String, String?> _selectedSubmitValues = {};
  final ScrollController _contentScrollController = ScrollController();

  // Region and city data from the backend.
  List<AreaItem> _provinces = [];
  List<AreaItem> _cities = [];
  final List<Map<String, String>> _regionCityData = [];

  int _selectedRegionIndex = 0;
  bool _hasHandledInitialLocation = false;

  bool _isRegionEntry(FormEntry entry) {
    return entry.code == _codeRegionCity;
  }

  bool _isPickerEntry(FormEntry entry) {
    if (_isRegionEntry(entry)) {
      return true;
    }
    return FormEntryInputTypeHelper.isPicker(entry);
  }

  bool _isEntryFilled(FormEntry entry) {
    final value = _selectedValues[entry.key];
    return value != null && value.trim().isNotEmpty;
  }

  FormEntry? _findNextUnfilledPickerEntry(FormEntry currentEntry) {
    final entries = _formEntries;
    if (entries.isEmpty) return null;

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

  /// Renders form entries by backend order for server-driven field order.
  List<FormEntry> get _formEntries {
    final entries = _stepInfo?.entries ?? const <FormEntry>[];
    final sortedEntries = [...entries];
    sortedEntries.sort((a, b) => a.order.compareTo(b.order));
    return sortedEntries;
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
    _contentScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (mounted) {
      setState(() {
        _resetLoadedData();
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      // Fetch form config and area data in parallel.
      final formFuture = ref.read(acpElementInfoProvider).call(1);
      final areaFuture = ref.read(provincesCitiesAreaProvider).call();
      final formResult = await formFuture;
      final areaResult = await areaFuture;

      if (!mounted) return;

      if (!_isValidFormResult(formResult) || !_isValidAreaResult(areaResult)) {
        setState(() {
          _isLoading = false;
          _hasLoadError = true;
        });
        return;
      }

      _applyFormResult(formResult);
      _applyAreaResult(areaResult);
      setState(() {
        _isLoading = false;
        _hasLoadError = false;
      });
      _scheduleInitialLocationCheck();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadError = true;
        });
      }
    }
  }

  /// Clears old form state before retrying to avoid stale data.
  void _resetLoadedData() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _stepInfo = null;
    _processId = null;
    _textControllers.clear();
    _selectedIndices.clear();
    _selectedValues.clear();
    _selectedSubmitValues.clear();
    _provinces = [];
    _cities = [];
    _regionCityData.clear();
    _selectedRegionIndex = 0;
    _hasHandledInitialLocation = false;
  }

  bool _isValidFormResult(HttpResult<AcpElementInfoResp> result) {
    final stepInfo = result.data?.stepInfoList.firstOrNull;
    return result.isSuccess && stepInfo != null && stepInfo.entries.isNotEmpty;
  }

  bool _isValidAreaResult(HttpResult<ProvincesCitiesAreaResp> result) {
    return result.isSuccess && result.data != null;
  }

  /// Retries by checking acquisition progress and routes like post-login flow.
  Future<void> _retryByProgress() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });

    try {
      final progressResult = await ref.read(acquisitionProgressProvider).call();
      if (!mounted) return;

      if (progressResult.isSuccess && progressResult.data != null) {
        final progressData = progressResult.data!;
        final route = AcquisitionProgressRouteResolver.resolve(progressData);

        if (route == AppRoutePaths.personalInfo) {
          setState(() {
            _isLoading = false;
            _hasLoadError = true;
          });
          return;
        }

        context.go(route);
        return;
      }

      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    }
  }

  /// Applies personal info form config and restores submitted backend values.
  void _applyFormResult(HttpResult<AcpElementInfoResp> result) {
    if (!result.isSuccess || result.data == null) {
      return;
    }

    final data = result.data!;
    final stepInfo = data.stepInfoList.firstOrNull;
    if (stepInfo == null) {
      return;
    }

    _stepInfo = stepInfo;
    _processId = data.processId;

    for (final entry in _formEntries) {
      _initializeEntryValue(entry);
    }
  }

  /// Applies area data for the region picker and historical value display.
  void _applyAreaResult(HttpResult<ProvincesCitiesAreaResp> result) {
    if (!result.isSuccess || result.data == null) {
      return;
    }

    _provinces = result.data!.province;
    _cities = result.data!.city;
    _buildRegionCityData();
    _restoreRegionSelectionIndex();
  }

  /// Initializes display value, submit value, and picker index for one entry.
  void _initializeEntryValue(FormEntry entry) {
    final submitValue = entry.submitValue;
    _selectedIndices[entry.key] = 0;
    _selectedValues[entry.key] = submitValue;
    _selectedSubmitValues[entry.key] = submitValue;

    if (FormEntryInputTypeHelper.isTextInput(entry)) {
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

  /// Repositions picker index when area data arrives after form config.
  void _restoreRegionSelectionIndex() {
    final regionEntry = _regionEntry;
    final submitValue = regionEntry?.submitValue;
    if (regionEntry == null || submitValue == null || submitValue.isEmpty) {
      return;
    }

    final regionData = _parseGeoLocationSubmitValue(submitValue);
    final matchedRegionIndex = _regionCityData.indexWhere(
      (item) =>
          item['region'] == regionData.$1 && item['city'] == regionData.$2,
    );
    if (matchedRegionIndex >= 0) {
      _selectedRegionIndex = matchedRegionIndex;
    }
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
      (option) => option.key == submitValue || option.value == submitValue,
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
    } catch (_) {}
    return ('', '');
  }

  /// Builds region and city data.
  void _buildRegionCityData() {
    _regionCityData.clear();
    for (final province in _provinces) {
      // Find all cities under this region.
      final provinceCities = _cities
          .where((city) => city.parentId == province.id)
          .toList();

      if (provinceCities.isNotEmpty) {
        for (final city in provinceCities) {
          _regionCityData.add({'region': province.name, 'city': city.name});
        }
      } else {
        // Add only the region if it has no cities.
        _regionCityData.add({'region': province.name, 'city': ''});
      }
    }
  }

  bool get _canContinue {
    if (_stepInfo == null) return false;
    for (final entry in _formEntries) {
      if (FormEntryInputTypeHelper.isDisplayOnly(entry) ||
          FormEntryInputTypeHelper.isSpecialProcessEntry(entry)) {
        continue;
      }
      if (entry.must == 1 &&
          (_selectedValues[entry.key] == null ||
              _selectedValues[entry.key]!.isEmpty)) {
        return false;
      }
    }
    return true;
  }

  /// 检测定位权限，未开启时提示用户去设置。
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
    return _formEntries.where(_isRegionEntry).cast<FormEntry?>().firstOrNull;
  }

  String get _pageTitle => _stepInfo?.pageTitle.trim() ?? '';

  /// Calculates the white content start based on acquisition header layout.
  double _contentTop(BuildContext context) {
    return MediaQuery.of(context).padding.top +
        _headerTitleBarHeight +
        _headerTopGap +
        _stepIndicatorHeight +
        _headerBottomGap;
  }

  Future<void> _checkInitialLocationPermission() async {
    try {
      // 只检查权限状态；不再自动获取定位并回填地区。
      final isLocationPermissionGranted =
          await LocationService.checkPermission();
      if (!mounted || isLocationPermissionGranted) return;

      final shouldOpenSettings = await _showLocationPermissionDialog();
      if (!mounted || !shouldOpenSettings) return;

      await LocationService.openAppSettings();
    } catch (e) {
      return;
    }
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

  /// Shows the region and city picker with page-side display formatting.
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

  /// Shows a standard form option picker.
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
      final jsonParam = _formEntries.map((entry) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? AppStrings.personalInfoSaveFailed),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.personalInfoSaveFailedWithError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FundingLimitPopScope(
      child: LoanRoundedPageShell(
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
        bottomNavigationBar: _buildBottomAction(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const AppStateView(child: CircularProgressIndicator());
    }

    if (_hasLoadError) {
      return AppErrorStateView(
        text: AppStrings.personalInfoLoadFailed,
        onReload: () => _retryByProgress(),
      );
    }

    return Scrollbar(
      controller: _contentScrollController,
      thumbVisibility: true,
      radius: const Radius.circular(8),
      child: SingleChildScrollView(
        controller: _contentScrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var i = 0; i < _formEntries.length; i++)
              _buildEntryItem(
                entry: _formEntries[i],
                showDivider: i != _formEntries.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomAction() {
    if (_isLoading || _hasLoadError) {
      return null;
    }

    return LoanBottomActionButton(
      enabled: _canContinue && !_isSubmitting,
      onPressed: _canContinue && !_isSubmitting ? _onContinue : null,
      text: _isSubmitting
          ? AppStrings.personalInfoSaving
          : AppStrings.continueStr,
    );
  }

  /// Builds a personal info form item from backend form config.
  Widget _buildEntryItem({
    required FormEntry entry,
    required bool showDivider,
  }) {
    if (FormEntryInputTypeHelper.isDisplayOnly(entry)) {
      return PersonalInfoDisplayFormItem(
        title: entry.showContent,
        isRequired: entry.must == 1,
        showDivider: showDivider,
      );
    }

    if (_isPickerEntry(entry)) {
      return PersonalInfoFormItem(
        title: entry.showContent,
        isRequired: entry.must == 1,
        value: _selectedValues[entry.key],
        placeholder: entry.defaultText,
        showDivider: showDivider,
        onTap: () => _openPickerForEntry(entry),
      );
    }

    if (FormEntryInputTypeHelper.isTextInput(entry)) {
      final controller = _textControllers[entry.key] ??= TextEditingController(
        text: _selectedValues[entry.key] ?? '',
      );

      return PersonalInfoFormItem(
        title: entry.showContent,
        isRequired: entry.must == 1,
        placeholder: entry.defaultText,
        controller: controller,
        keyboardType: FormEntryInputTypeHelper.keyboardTypeFor(entry),
        inputFormatters: FormEntryInputTypeHelper.inputFormattersFor(entry),
        textInputAction: TextInputAction.next,
        showDivider: showDivider,
        onChanged: (value) {
          setState(() {
            _selectedValues[entry.key] = value.trim();
            _selectedSubmitValues[entry.key] = value.trim();
          });
        },
      );
    }

    return PersonalInfoDisplayFormItem(
      title: entry.showContent,
      isRequired: entry.must == 1,
      showDivider: showDivider,
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
