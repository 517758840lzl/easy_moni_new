class CustomerServiceInfoResp {
  final int showType;
  final List<dynamic> appCustomerServiceInfoResps;
  final CustomerServiceDetail? appCustomerServiceInfo;

  const CustomerServiceInfoResp({
    required this.showType,
    required this.appCustomerServiceInfoResps,
    this.appCustomerServiceInfo,
  });

  factory CustomerServiceInfoResp.fromJson(Map<String, dynamic> json) {
    return CustomerServiceInfoResp(
      showType: json['showType'] as int? ?? 0,
      appCustomerServiceInfoResps: json['appCustomerServiceInfoResps'] as List<dynamic>? ?? [],
      appCustomerServiceInfo: json['appCustomerServiceInfo'] != null
          ? CustomerServiceDetail.fromJson(json['appCustomerServiceInfo'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CustomerServiceDetail {
  final int type;
  final String account;
  final String? title;
  final String? desc;
  final List<CustomerServiceAccount>? accountList;

  const CustomerServiceDetail({
    required this.type,
    required this.account,
    this.title,
    this.desc,
    this.accountList,
  });

  factory CustomerServiceDetail.fromJson(Map<String, dynamic> json) {
    return CustomerServiceDetail(
      type: json['type'] as int? ?? 0,
      account: json['account'] as String? ?? '',
      title: json['title'] as String?,
      desc: json['desc'] as String?,
      accountList: (json['accountList'] as List<dynamic>?)
          ?.map((e) => CustomerServiceAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CustomerServiceAccount {
  final int type;
  final String account;
  final String? title;
  final String? desc;
  final List<CustomerServiceAccount>? accountList;

  const CustomerServiceAccount({
    required this.type,
    required this.account,
    this.title,
    this.desc,
    this.accountList,
  });

  factory CustomerServiceAccount.fromJson(Map<String, dynamic> json) {
    return CustomerServiceAccount(
      type: json['type'] as int? ?? 0,
      account: json['account'] as String? ?? '',
      title: json['title'] as String?,
      desc: json['desc'] as String?,
      accountList: (json['accountList'] as List<dynamic>?)
          ?.map((e) => CustomerServiceAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
