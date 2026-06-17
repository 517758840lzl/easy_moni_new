/// 项目所有文案集中管理
/// 修改语言只需修改此文件中的值即可
class AppStrings {
  AppStrings._();

  // ==================== App ====================
  static const String appTitle = 'Easy moni';
  static const String appinstrunctions = '权限收集说明';
  static const String decline = '拒绝';
  static const String agrees = '同意';
  static const String receives = '接受';
  static const String messageReceive = '短信数据收集';
  static const String messageReceiveDetail =
      'Reads financial transaction messages (deposit alerts, repayment reminders) for credit assessment and risk control. All data is encrypted.';
  static const String gainLocation = '位置信息收集';
  static const String gainLocationDetail =
      'Uses approximate device location to verify your application environment and prevent fraud.';
  static const String appdiscrptions =
      '我们申请以下权限，是为了提供安全的贷款服务，并严格遵守加纳的数据保护相关法律。\n\n未经您的许可，我们绝不会向任何第三方分享您的个人数据。';
  static const String carema = '相机权限访问';
  static const String caremaDetail =
      'Used for identity verification (ID photo + face check) to prevent fraud. Your images are stored securely for verification only.';
  static const String installAppData = '已安装应用数据';
  static const String installAppDataDetail =
      'Checks for financial apps (banking, lending, mobile money) on your device to secure your account and prevent fraud.';
  static const String receiveData = '点击「接受」，即表示您已阅读、理解并同意上述声明内容。';
  static const String deviceinformation = '设备信息';
  static const String campaign = '应用内活动';
  static const String declineBtn = 'Decline';
  static const String agreeandContinue = 'Agree & Continue';
  static const String campaignDetail =
      'Logs app usage data (error logs, crash reports) to improve stability, monitor security, and fix issues.';
  static const String deviceInformationDetail =
      'Collects basic device info (model, OS version) to ensure app stability, compatibility, and risk control.';
  static const String privacyData = '隐私政策';
  static const String grantedData =
      '''GATED LTDINTELLIGENCE LTD ("we", "us", or "our") is he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and the developer and operator of the Palm Loan application. This Privacy Policy also applies to our official website www.gatedintelligence.com.We understand the importance of your personal information and are committed to complying fully with applicable privacy protection laws in Ghana. This policy explains how we collect, use, store, and share your personal information.By using the Palm Loan service, you agree to the processing of your information as described in this Privacy Policy. The information we collect is used solely for providing, maintaining, and improving our services. Unless explicitly stated in this policy, we will not share your personal information with any third party.''';
  static const String wellcome = '欢迎使用 Easy moni';
  static const String wellcomedeailData = '在 Easy moni 一站式管理您的信用、快速放款并安全借款。';
  static const String phoneStr = '用于移动支付的手机号码';
  static const String codestr = '输入短信中的验证码';
  static const String gainCode = '获取验证码';
  static const String login = 'Log in';
  static const String chooseContacts = '选择父母/配偶联系人';
  static const String chooseFriends = '选择朋友/同事联系人';
  static const String needsContacts = '需要通讯录权限';
  static const String needsSms = '需要短信权限';
  static const String smsPermissionDesc = '读取存款、还款类交易短信，用作授信评估及风控核验，数据全程加密保护。';
  static const String cancel = '取消';
  static const String goSettings = '前往设置';
  static const String contactsEmpty = '通讯录为空';
  static const String chooseContactsPhone = '父母/配偶联系电话';
  static const String checkIdCard = '请确保您的加纳身份证四角完整、图像清晰，光线均匀。';
  static const String chooseUploadMethod = '选择上传方式';
  static const String selectFormPhotos = '从相册选择';
  static const String takephotos = '拍摄照片';
  static const String idcardMessage = '为了让您上传加纳身份证，我们需要获取相机访问权限。';
  static const String idcardVer = '身份验证';
  static const String homeTab = '首页';
  static const String repayTab = '还款';
  static const String mineTab = '我的';
  static const String continueStr = '继续';
  static const String continueIdentifyStr = '开始识别证件信息...';
  static const String continueUploadPicture = '开始上传证件图片...';
  static const String continueOcr = '请根据指引完成人脸验证';
  static const String confirmOwnerData = '请确认本人操作';
  static const String standard = 'Standard shooting';
  static const String toolBright = 'Too bright';
  static const String incompletePhoto = 'Incomplete photo';
  static const String blueryPhoto = 'Blurry/Faded photo';
  static const String continueSallery = "继续获取资金";
  static const String looseSallery = "放弃本次机会";
  static const String noLoanProducts = '暂无可借产品';
  static const String selectProucts = 'Choose a loan product';
  static const String takeOcrPictures =
      'Please use landscape mode and place all four corners of your Ghana Card inside the frame.';

  // ==================== 首页 =======================
  static const String homeButtonText = '我要借款';
  static const String homeLoanSectionTitle = '我的借款';
  static const String homeHeaderTitle = '最高可借额度';
  static const String homeAvailableString = '可借产品：';

  // ==================== 贷款详情 ====================
  static const String loanDetailTitle = '贷款详情';
  static const String loanItemIdPrefix = '贷款Item ID: ';
  static const String createdRecently = 'Created recently';
  static const String statusLabel = 'Status';
  static const String statusActive = 'Active';
  static const String typeLabel = 'Type';
  static const String typePremium = 'Premium';
  static const String createdLabel = 'Created';
  static const String loanProductAvailable = '可借款';
  static const String loanProductUnavailable = '不可借';
  static const String loanProductRejected = '已拒绝';
  static const String loanAvailableAmountLabel = 'Available Loan Amount';
  static const String loanDailyInterestRateLabel = 'Daily Interest Rate';
  static const String loanTermLabel = 'Term';
  static const String loanProductLogoFallback = '?';

  // ==================== 贷款订单状态 ====================
  static const String loanOrderStatusOverdue = '已逾期';
  static const String loanOrderStatusReviewing = '借款审核中';
  static const String loanOrderStatusDisbursing = '放款中';
  static const String loanOrderStatusDisbursingv2 = '放款中（至MoMo）';
  static const String loanOrderStatusWaitingRepayment = '等待还款';
  static const String loanOrderStatusTransferFailed = '转账失败';
  static const String loanOrderFooterOverdue = '已逾期，请尽快完成还款 >';
  static const String loanOrderFooterReviewing = '借款审核中，请耐心等待 >';
  static const String loanOrderFooterDisbursing = '放款中，资金即将抵达 MoMo 账户 >';
  static const String loanOrderFooterWaitingRepayment = '等待还款，请按时完成还款 >';
  static const String loanOrderFooterCouponRepayment = '优惠券还款 >';
  static const String loanOrderFooterImmediateRepayment = '立即还款 >';
  static const String loanOrderFooterTransferFailed = '转账失败，请查看订单详情 >';
  static const String loanOrderProductFallback = '';
  static const String loanOrderLogoFallback = '';
  static const String loanOrderEmptyValue = '';
  static const String loanOrderUnknownValue = '-';
  static const String loanOrderDaysUnit = 'days';
  static const String loanOrderLoanAmountLabel = '借款金额';
  static const String loanOrderLoanTermLabel = '借款期限';
  static const String loanOrderServiceFeeLabel = '服务费';
  static const String loanOrderOverdueFeeLabel = '逾期费';
  static const String loanOrderOverdueDaysLabel = '逾期天数';
  static const String loanOrderRemainingDayLabel = '距离到期日';
  static const String loanOrderInterestLabel = '利息';
  static const String loanOrderRepaymentDateLabel = '还款日期';
  static const String loanOrderReceiptAmountLabel = '到账金额';
  static const String loanOrderRepayAmountLabel = '应还金额';
  static const String loanOrderDueDateLabel = '到期日';
  static const String loanOrderAccountLabel = 'MoMo收款账户';

  // ==================== 账单详情 ====================
  static const String orderDetailTitle = '账单详情';
  static const String orderDetailNoOrderData = '没有订单数据';
  static const String orderDetailLoadFailed = '获取账单详情失败';
  static const String orderDetailRepayingStatus = '还款中';
  static const String orderDetailPendingRepaymentStatus = '待还款';
  static const String orderDetailTotalRepayAmountLabel = '待还总金额';
  static const String orderDetailRemainingDaysLabel = '剩余天数';
  static const String orderDetailOrderCountLabel = '订单数量';
  static const String orderDetailExtensionLabel = '展期';
  static const String orderDetailExtensionAvailable = '可展期';
  static const String orderDetailExtensionUnavailable = '不可展期';
  static const String orderDetailAccountInfoTitle = '收款账户信息';
  static const String orderDetailMomoAccountLabel = 'MOMO账户';
  static const String orderDetailWalletTypeLabel = '钱包类型';
  static const String orderDetailRepayNow = '立即还款';
  static const String orderDetailRepayLog = '点击了立即还款';
  static const String orderDetailCurrencyCode = 'GHS';
  static const String orderDetailZeroAmount = '0.00';

  // ==================== 还款卡片 ====================
  static const String repayEntryHeaderTitle = '待还总额';
  static const String repayEntryBillTitle = '待还账单';
  static const String repayEntryRepayAll = '全部还款';
  static const String repayEntryEmpty = '暂无待还账单';
  static const String repayEntryLoadFailed = '获取待还账单失败';
  static const String repayEntryRetry = '重试';
  static const String repayBillDueDateLabel = '到期日';
  static const String repayBillOverdueStatus = '已逾期';
  static const String repayBillRepayNow = '立即还款';
  static const String repayBillLogoFallback = '';
  static const String repayDetailTitle = '还款详情';
  static const String repayDetailPendingStatus = '待还款';
  static const String repayDetailApplyExtension = '申请展期';
  static const String repayDetailRepayNow = '立即还款';
  static const String repayDetailOrderInfoTitle = '订单信息';
  static const String repayDetailCouponUnavailable = '暂无可用优惠券';
  static const String repayDetailPaymentPending = '还款页面待接入';
  static const String repayDetailExtensionPending = '展期页面待接入';
  static const String repayMultiDetailTitle = '还款详情';
  static const String repayMultiTotalLoanAmountLabel = '总借款本金';
  static const String repayMultiTotalInterestLabel = '总利息';
  static const String repayMultiTotalOverdueFeeLabel = '总逾期费';
  static const String repayExtensionTitle = '展期申请';
  static const String repayExtensionFeeLabel = 'Extension Fee';
  static const String repayExtensionInfoTitle = '展期信息';
  static const String repayExtensionNotice = '延期成功后，还款金额将保持不变，不会产生更多费用。';
  static const String repayExtensionDaysLabel = '延长天数';
  static const String repayExtensionNewDueDateLabel = '新的到期日';
  static const String repayExtensionNewRepayAmountLabel = '新到期日应还金额';
  static const String repayExtensionConfirm = '确认展期';
  static const String repayExtensionLoadFailed = '获取展期信息失败';
  static const String repayExtensionNoOrderData = '没有展期订单数据';
  static const String repayExtensionSubmitPending = '展期提交接口待接入';
  static const String couponEntrySubtitle = '提额券或降息券';
  static const String couponSelectedFallback = '已选择优惠券';

  static String orderDetailDayValue(int days) => '$days天';
  static String orderDetailCountValue(int count) => '$count个';
  static String orderDetailPeriodValue(int period) => '$period期';
  static String orderDetailOverdueDays(int days) => '已逾期$days天';
  static String orderDetailRemainingDays(int days) => '剩余$days天';
  static String orderDetailCurrencyAmount(num amount) =>
      '$orderDetailCurrencyCode ${amount.toStringAsFixed(2)}';
  static String orderDetailRepayButtonText(num? amount) =>
      '$orderDetailRepayNow $orderDetailCurrencyCode ${amount?.toStringAsFixed(2) ?? orderDetailZeroAmount}';

  // ==================== 借款审核 ====================
  static const String loanReviewTitle = '审核中';
  static const String loanReviewAppBarTitle = '申请借款';
  static const String loanReviewDesc =
      '您的借款申请正在审核中。\n通常会在几分钟内出结果。\n请耐心等待，结果将及时通知您。';

  // ===================== 优惠券 ========================
  static const String couponEmptyDesc = '无可用优惠券，按时还款，后续可解锁优惠券';
  static const String couponString = '优惠券';
  static const String couponConfirmButtonText = 'Confirm';
  static const String couponLoadFailed = '优惠券加载失败，请重试';

  // ==================== 确认借款 ====================
  static const String loanConfirmButtonText = '确认借款';
  static const String loanConfirmButtonLoadingText = '提交中...';
}
