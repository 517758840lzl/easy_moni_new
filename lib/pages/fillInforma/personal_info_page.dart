import 'package:easy_moni/pages/fillInforma/widgets/progressInformation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/platform_service.dart';
import '../../entities/acp_element_info_resp.dart';
import '../../entities/provinces_cities_area_resp.dart';
import '../../utils/widgets/informationBottomButton.dart';
import 'providers/acp_element_info_provider.dart';
import 'providers/provinces_cities_area_provider.dart';
import 'providers/submit_acp_element_info_provider.dart';

class PersonalInfoPage extends ConsumerStatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
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
    debugPrint('_fetchData 开始...');
    try {
      // 并行获取表单数据和省市数据
      final results = await Future.wait([
        ref.read(acpElementInfoProvider).call(1),
        ref.read(provincesCitiesAreaProvider).call(),
      ]);

      if (!mounted) return;

      // 处理表单数据
      final formResult = results[0] as dynamic;
      debugPrint('formResult: $formResult');
      debugPrint('formResult.isSuccess: ${formResult.isSuccess}');
      debugPrint('formResult.data: ${formResult.data}');

      if (formResult.isSuccess && formResult.data != null) {
        final stepInfoList = formResult.data!.stepInfoList;
        debugPrint(
          'stepInfoList: $stepInfoList, length: ${stepInfoList.length}',
        );
        final stepInfo = stepInfoList.isNotEmpty ? stepInfoList[0] : null;
        debugPrint('stepInfo: $stepInfo');
        if (stepInfo != null) {
          _stepInfo = stepInfo;
          _processId = formResult.data!.processId;
          debugPrint('设置 _stepInfo, entries 数量: ${stepInfo.entries.length}');
          // 初始化选中索引和值
          for (final entry in stepInfo.entries) {
            _selectedIndices[entry.key] = 0;
            _selectedValues[entry.key] = entry.submitValue;
            _selectedSubmitValues[entry.key] = entry.submitValue;
            debugPrint('entry: ${entry.key} - ${entry.showContent}');

            if (_isEmailEntry(entry) || entry.type == 1) {
              _textControllers[entry.key] = TextEditingController(
                text: entry.submitValue ?? '',
              );
            }

            if (entry.submitValue != null && entry.submitValue!.isNotEmpty) {
              if (_isRegionEntry(entry)) {
                final regionData = _parseGeoLocationSubmitValue(
                  entry.submitValue!,
                );
                _setRegionValueForEntry(
                  entry.key,
                  province: regionData.$1,
                  city: regionData.$2,
                );
                final matchedRegionIndex = _regionCityData.indexWhere(
                  (item) =>
                      item['region'] == regionData.$1 &&
                      item['city'] == regionData.$2,
                );
                if (matchedRegionIndex >= 0) {
                  _selectedRegionIndex = matchedRegionIndex;
                }
                continue;
              }
              final matchedIndex = entry.selectList?.indexWhere(
                (option) => option.key == entry.submitValue,
              );
              if (matchedIndex != null && matchedIndex >= 0) {
                _selectedIndices[entry.key] = matchedIndex;
                _selectedValues[entry.key] =
                    entry.selectList![matchedIndex].value;
              }
            }
          }
        }
      } else {
        debugPrint('表单数据获取失败: ${formResult.message}');
      }

      // 处理省市数据
      final areaResult = results[1] as dynamic;
      debugPrint('areaResult.isSuccess: ${areaResult.isSuccess}');
      if (areaResult.isSuccess && areaResult.data != null) {
        _provinces = areaResult.data!.province;
        _cities = areaResult.data!.city;
        // 组装省市区数据
        _buildRegionCityData();
      }

      debugPrint('_fetchData 完成, _isLoading 设置为 false');
      setState(() => _isLoading = false);
    } catch (e, stack) {
      debugPrint('获取数据失败: $e');
      debugPrint('堆栈: $stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  (String, String) _parseGeoLocationSubmitValue(String rawValue) {
    final provinceMatch = RegExp(
      r'"homeProvince":"([^"]*)"',
    ).firstMatch(rawValue);
    final cityMatch = RegExp(r'"homeCity":"([^"]*)"').firstMatch(rawValue);
    return (provinceMatch?.group(1) ?? '', cityMatch?.group(1) ?? '');
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

  Future<void> _checkAndGetLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // 检查定位权限
      bool hasPermission = await LocationService.checkPermission();

      if (!hasPermission) {
        hasPermission = await LocationService.requestPermission();
        if (!hasPermission) {
          // 权限被拒绝，直接弹出手动选择
          _showRegionPicker();
          return;
        }
      }

      // 检查定位服务是否开启
      bool serviceEnabled = await LocationService.isServiceEnabled();
      if (!serviceEnabled) {
        // 定位服务未开启，直接弹出手动选择
        _showRegionPicker();
        return;
      }

      // 获取位置
      Map<String, double>? position =
          await LocationService.getCurrentLocation();
      if (position == null) {
        // 无法获取位置，弹出手动选择
        _showRegionPicker();
        return;
      }

      debugPrint('获取到位置: ${position['latitude']}, ${position['longitude']}');

      // 根据位置匹配最近的地区
      String matchedRegion = _matchRegionByCoordinates(
        position['latitude']!,
        position['longitude']!,
      );

      setState(() {
        _selectedRegionIndex = _regionCityData.indexWhere(
          (item) => item['region'] == matchedRegion,
        );
        if (_selectedRegionIndex == -1) _selectedRegionIndex = 0;

        final selectedData = _regionCityData[_selectedRegionIndex];
        final regionEntry = _stepInfo?.entries
            .where(_isRegionEntry)
            .cast<FormEntry?>()
            .firstOrNull;
        if (regionEntry != null) {
          _setRegionValueForEntry(
            regionEntry.key,
            province: selectedData['region']!,
            city: selectedData['city']!,
          );
        }
      });
    } catch (e) {
      debugPrint('获取位置失败: $e');
      // 失败时弹出手动选择
      _showRegionPicker();
    } finally {
      setState(() => _isLoadingLocation = false);
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

  void _showLocationServiceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      builder: (context) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(
                Icons.location_off,
                size: 64,
                color: Color(0xFF268470),
              ),
              const SizedBox(height: 24),
              const Text(
                '定位服务未开启',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101314),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '请在设置中开启定位服务以继续操作。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3F4950),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF268470)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(
                            color: Color(0xFF268470),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRegionPicker();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF268470),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '手动选择',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPermissionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      builder: (context) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.location_on, size: 64, color: Color(0xFF268470)),
              const SizedBox(height: 24),
              const Text(
                '需要位置权限',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101314),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '我们使用位置信息来保障您的账户安全、防范欺诈行为。请允许位置访问权限以继续操作。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3F4950),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF268470)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(
                            color: Color(0xFF268470),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // openAppSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF268470),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '前往设置',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showRegionPicker({FormEntry? entry}) {
    int tempRegionIndex = _selectedRegionIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: 320,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE7E7E7)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const Text(
                          '居住地区与城市',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRegionIndex = tempRegionIndex;
                              final selectedData =
                                  _regionCityData[tempRegionIndex];
                              final regionEntry =
                                  entry ??
                                  _stepInfo?.entries
                                      .where(_isRegionEntry)
                                      .cast<FormEntry?>()
                                      .firstOrNull;
                              if (regionEntry != null) {
                                _setRegionValueForEntry(
                                  regionEntry.key,
                                  province: selectedData['region']!,
                                  city: selectedData['city']!,
                                );
                                _scheduleNextUnfilledPicker(regionEntry);
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF268470),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: tempRegionIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          tempRegionIndex = index;
                        },
                        children: List.generate(
                          _regionCityData.length,
                          (index) => Center(
                            child: Text(
                              _regionCityData[index]['city']!.isNotEmpty
                                  ? '${_regionCityData[index]['region']} - ${_regionCityData[index]['city']}'
                                  : _regionCityData[index]['region']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPicker({
    required FormEntry entry,
    required String title,
    required List<SelectOption> options,
    required int selectedIndex,
    required Function(int) onConfirm,
  }) {
    int tempSelectedIndex = selectedIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: 320,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE7E7E7)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            onConfirm(tempSelectedIndex);
                            _scheduleNextUnfilledPicker(entry);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            '确定',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF268470),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: tempSelectedIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          tempSelectedIndex = index;
                        },
                        children: options
                            .map(
                              (item) => Center(
                                child: Text(
                                  item.value,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _buildGeoLocationSubmitValue(String province, String city) {
    return '{"homeCity":"$city","homeProvince":"$province"}';
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
        context.push('/contact-info');
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
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          buildInformationHeader(
            context: context,
            title: _stepInfo?.pageTitle ?? '-',
            activeStep: InformationStep.personal,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                // decoration: const BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                // ),
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Column(
                          children:
                              _stepInfo?.entries.map((entry) {
                                final key = entry.key;
                                final selectedValue = _selectedValues[key];

                                if (_isEmailEntry(entry) || entry.type == 1) {
                                  return _buildTextInputItem(entry: entry);
                                }

                                return _buildFormItem(
                                  starTitle: entry.must == 1 ? '*' : '',
                                  title: entry.showContent,
                                  value: selectedValue,
                                  placeholder: entry.defaultText,
                                  onTap: () {
                                    _openPickerForEntry(entry);
                                  },
                                );
                              }).toList() ??
                              [],
                        ),
                ),
              ),
            ),
          ),
          BottomContinueButton(
            isEnabled: _canContinue && !_isSubmitting,
            onTap: () => _onContinue(),
            text: _isSubmitting ? '保存中...' : '继续',
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputItem({required FormEntry entry}) {
    final controller = _textControllers[entry.key] ??= TextEditingController(
      text: _selectedValues[entry.key] ?? '',
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
                child: Row(
                  children: [
                    if (entry.must == 1)
                      const Text(
                        '*',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                          letterSpacing: 0.4,
                        ),
                      ),
                    if (entry.must == 1) const SizedBox(width: 8),
                    Text(
                      entry.showContent,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: entry.defaultText,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFCCCCCC),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  onChanged: (value) {
                    setState(() {
                      _selectedValues[entry.key] = value.trim();
                      _selectedSubmitValues[entry.key] = value.trim();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE7E7E7)),
      ],
    );
  }

  Widget _buildFormItem({
    required String starTitle,
    required String title,
    required String? value,
    required String placeholder,
    required VoidCallback? onTap,
    bool showDivider = true,
    bool isLoading = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      if (starTitle.isNotEmpty)
                        Text(
                          starTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            letterSpacing: 0.4,
                          ),
                        ),
                      if (starTitle.isNotEmpty) const SizedBox(width: 8),
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
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF268470),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            value ?? placeholder,
                            style: TextStyle(
                              fontSize: 14,
                              color: value != null
                                  ? Colors.black
                                  : const Color(0xFFCCCCCC),
                            ),
                          ),
                        ),
                      if (!isLoading)
                        Icon(
                          Icons.chevron_right,
                          size: 12,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: const EdgeInsets.only(left: 20),
            height: 1,
            color: const Color(0xFFF5F5F5),
          ),
      ],
    );
  }
}
