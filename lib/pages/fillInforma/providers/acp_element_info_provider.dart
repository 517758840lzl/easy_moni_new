import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/http_provider.dart';
import '../../../core/network/http_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../../entities/acp_element_info_resp.dart';

final acpElementInfoProvider = Provider<AcpElementInfoApi>((ref) {
  return AcpElementInfoApi();
});

class AcpElementInfoApi {
  /// 查询KYC步骤数据（测试用假数据）
  Future<HttpResult<AcpElementInfoResp>> call(int step) async {
    // 返回假数据用于测试
    final mockData = AcpElementInfoResp(
      processId: 36,
      stepInfoList: [
        StepInfo(
          step: 1,
          pageTitle: 'Personal Information',
          pageType: 1,
          entries: [
            FormEntry(
              code: '20001',
              showContent: 'Job Type',
              defaultText: 'Please select',
              type: 2,
              selectList: [
                SelectOption(key: '1', value: 'Full-time'),
                SelectOption(key: '2', value: 'Part-time'),
                SelectOption(key: '3', value: 'Freelance'),
                SelectOption(key: '4', value: 'Student'),
                SelectOption(key: '5', value: 'Unemployed'),
                SelectOption(key: '6', value: 'Other'),
              ],
              key: 'employment_role',
              order: 1,
              must: 1,
            ),
            FormEntry(
              code: '20002',
              showContent: 'Monthly Income',
              defaultText: 'Please select',
              type: 2,
              selectList: [
                SelectOption(key: '1', value: 'Less than GHS 1,000'),
                SelectOption(key: '2', value: 'GHS 1,000 - GHS 2,499'),
                SelectOption(key: '3', value: 'GHS 2,500 - GHS 4,999'),
                SelectOption(key: '4', value: 'GHS 5,000 - GHS 9,999'),
                SelectOption(key: '5', value: 'Above GHS 10,000'),
              ],
              key: 'income_estimate',
              order: 2,
              must: 1,
            ),
            FormEntry(
              code: '10001',
              showContent: 'Highest Education Level',
              defaultText: 'Please select',
              type: 2,
              selectList: [
                SelectOption(key: '1', value: 'Basic School'),
                SelectOption(key: '2', value: 'High School'),
                SelectOption(key: '3', value: 'Diploma'),
                SelectOption(key: '4', value: 'Bachelors Degree'),
                SelectOption(key: '5', value: "Master's Degree and higher"),
              ],
              key: 'education_attainment',
              order: 3,
              must: 1,
            ),
            FormEntry(
              code: '10002',
              showContent: 'Marital Status',
              defaultText: 'Please select',
              type: 2,
              selectList: [
                SelectOption(key: '1', value: 'Single'),
                SelectOption(key: '2', value: 'Married'),
                SelectOption(key: '3', value: 'Divorced'),
                SelectOption(key: '4', value: 'Widowed'),
              ],
              key: 'marital_status',
              order: 4,
              must: 1,
            ),
            FormEntry(
              code: '10004',
              showContent: 'Region and City',
              defaultText: 'Please select',
              type: 2,
              selectList: null,
              key: 'geo_location',
              order: 5,
              must: 1,
            ),
          ],
        ),
      ],
    );
    return HttpResult.success(mockData);
  }
}
