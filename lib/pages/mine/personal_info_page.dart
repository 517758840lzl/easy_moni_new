import 'package:easy_moni/core/router/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/platform_service.dart';
import 'package:easy_moni/gen/assets.gen.dart';
import '../../utils/widgets/linepaint.dart';
import 'package:easy_moni/core/utils/app_logger.dart';

class PersonalInfoPage extends ConsumerStatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
  String? _employmentStatus;
  String? _monthlyIncome;
  String? _education;
  String? _maritalStatus;
  String? _residence;
  bool _isLoadingLocation = false;

  final List<String> _employmentOptions = ['全职工作', '兼职工作', '自由职业', '学生', '失业'];
  final List<String> _incomeOptions = [
    '1000以下',
    '1000-3000',
    '3000-5000',
    '5000-10000',
    '10000以上',
  ];
  final List<String> _educationOptions = [
    '初中及以下',
    '高中/中专',
    '大专',
    '本科',
    '硕士及以上',
  ];
  final List<String> _maritalOptions = ['未婚', '已婚', '离异', '丧偶'];

  // 加纳地区和城市数据
  final List<Map<String, String>> _regionCityData = [
    {'region': 'Ashanti', 'city': 'Kumasi'},
    {'region': 'Greater Accra', 'city': 'Accra'},
    {'region': 'Central', 'city': 'Cape Coast'},
    {'region': 'Eastern', 'city': 'Koforidua'},
    {'region': 'Western', 'city': 'Takoradi'},
    {'region': 'Northern', 'city': 'Tamale'},
    {'region': 'Upper East', 'city': 'Bolgatanga'},
    {'region': 'Upper West', 'city': 'Wa'},
    {'region': 'Volta', 'city': 'Ho'},
    {'region': 'Brong-Ahafo', 'city': 'Sunyani'},
  ];

  int _selectedEmploymentIndex = 0;
  int _selectedIncomeIndex = 0;
  int _selectedEducationIndex = 0;
  int _selectedMaritalIndex = 0;
  int _selectedRegionIndex = 0;

  bool get _canContinue =>
      _employmentStatus != null &&
      _monthlyIncome != null &&
      _education != null &&
      _maritalStatus != null &&
      _residence != null;

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

      AppLogger.debug(
        '获取到位置: ${position['latitude']}, ${position['longitude']}',
      );

      // 根据位置匹配最近的地区
      String matchedRegion = _matchRegionByCoordinates(
        position['latitude']!,
        position['longitude']!,
      );

      setState(() {
        _selectedRegionIndex = _regionCityData.indexWhere(
          (item) => item['region'] == matchedRegion,
        );
        if (_selectedRegionIndex == -1) _selectedRegionIndex = 1;

        _residence =
            '${_regionCityData[_selectedRegionIndex]['region']} - ${_regionCityData[_selectedRegionIndex]['city']}';
      });
    } catch (e) {
      AppLogger.debug('获取位置失败: $e');
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

  void _showRegionPicker() {
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
                              _residence =
                                  '${_regionCityData[tempRegionIndex]['region']} - ${_regionCityData[tempRegionIndex]['city']}';
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
                              '${_regionCityData[index]['region']} - ${_regionCityData[index]['city']}',
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
    required String title,
    required List<String> options,
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
                                  item,
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

  void _onContinue() {
    if (_canContinue) {
      AppLogger.debug('点击了继续按钮');
      context.push(AppRoutePaths.contactInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Assets.images.inforamtionBgheader.provider(),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          // if (Navigator.of(context).canPop())
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          if (Navigator.of(context).canPop())
                            const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              '个人信息',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFormItem(
                        starTitle: '*',
                        title: '就业状态',
                        value: _employmentStatus,
                        placeholder: '请选择您的就业状态',
                        onTap: () => _showPicker(
                          title: '就业状态',
                          options: _employmentOptions,
                          selectedIndex: _selectedEmploymentIndex,
                          onConfirm: (index) {
                            setState(() {
                              _selectedEmploymentIndex = index;
                              _employmentStatus = _employmentOptions[index];
                            });
                          },
                        ),
                      ),
                      _buildFormItem(
                        starTitle: '*',
                        title: '月收入',
                        value: _monthlyIncome,
                        placeholder: '请选择您的月收入',
                        onTap: () => _showPicker(
                          title: '月收入',
                          options: _incomeOptions,
                          selectedIndex: _selectedIncomeIndex,
                          onConfirm: (index) {
                            setState(() {
                              _selectedIncomeIndex = index;
                              _monthlyIncome = _incomeOptions[index];
                            });
                          },
                        ),
                      ),
                      _buildFormItem(
                        starTitle: '*',
                        title: '最高学历',
                        value: _education,
                        placeholder: '请选择您的教育水平',
                        onTap: () => _showPicker(
                          title: '最高学历',
                          options: _educationOptions,
                          selectedIndex: _selectedEducationIndex,
                          onConfirm: (index) {
                            setState(() {
                              _selectedEducationIndex = index;
                              _education = _educationOptions[index];
                            });
                          },
                        ),
                      ),
                      _buildFormItem(
                        starTitle: '*',
                        title: '婚姻状况',
                        value: _maritalStatus,
                        placeholder: '请选择您的婚姻状况',
                        onTap: () => _showPicker(
                          title: '婚姻状况',
                          options: _maritalOptions,
                          selectedIndex: _selectedMaritalIndex,
                          onConfirm: (index) {
                            setState(() {
                              _selectedMaritalIndex = index;
                              _maritalStatus = _maritalOptions[index];
                            });
                          },
                        ),
                      ),
                      _buildFormItem(
                        starTitle: '*',
                        title: '居住地区与城市',
                        value: _residence,
                        placeholder: '请选择您的居住地址',
                        onTap: () => _checkAndGetLocation(),
                        showDivider: false,
                        isLoading: _isLoadingLocation,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 48,
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 4,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: GestureDetector(
              onTap: _canContinue ? _onContinue : null,
              child: Container(
                decoration: BoxDecoration(
                  color: _canContinue
                      ? const Color(0xFF45F3A6)
                      : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    '继续',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _canContinue
                          ? const Color(0xFF104440)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //动态数据 先写死
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 36, right: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(
            icon: Assets.images.inforamtionIdcard.image(),
            label: '个人信息',
            isCompleted: true,
          ),
          _buildConnector(),
          _buildStepItem(
            icon: Assets.images.inforamtionIdo.image(),
            label: '身份验证',
            isCompleted: false,
          ),
          _buildConnector(),
          _buildStepItem(
            icon: Assets.images.inforamtionIdtNormal.image(),
            label: '人脸验证',
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required Widget icon,
    required String label,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(width: 36, height: 36, child: icon),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted ? const Color(0xFF45F3A6) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 30),
        child: CustomPaint(painter: DashedLinePainter()),
      ),
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
                      Text(
                        "*",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
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
