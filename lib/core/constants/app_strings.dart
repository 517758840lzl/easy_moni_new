/// 项目所有文案集中管理
/// 修改语言只需修改此文件中的值即可
class AppStrings {
  AppStrings._();

  // ==================== App ====================
  // ==================== 通用组件文本 ====================
  static const String appTitle = 'Easy Moni';
  static const String appinstrunctions = 'Permissions';
  static const String decline = 'Decline';
  static const String continueStr = 'Continue';
  static const String agrees = 'Agree';
  static const String receives = 'Accpet';
  static const String back = 'Back';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String goSettings = 'Go to Settings';
  // ==================== KYC流程 ====================
  static const String messageReceive = 'SMS Permission';
  static const String messageReceiveDetail =
      'With your authorization, we may access SMS messages related to financial transactions, such as bank transaction notifications, credit card repayment reminders, loan approval notifications, and mobile payment transaction alerts. This information is used solely to support credit assessment, risk management, and fraud prevention. We do not collect SMS messages unrelated to financial services. All relevant information is encrypted during transmission and storage, and access is strictly restricted.';
  static const String gainLocation = 'Location Permission';
  static const String gainLocationDetail =
      'With your authorization, we may access your device\'s approximate location to perform security verification, detect abnormal application activities, and prevent fraudulent behavior, helping protect your account and funds. Your location information will not be used for purposes unrelated to those described above.';
  static const String appdiscrptions =
      'To assess your loan eligibility and provide you with secure and reliable credit services, we may request the following device permissions after obtaining your authorization. We are committed to processing your personal information in a lawful, transparent, and secure manner, and in compliance with the applicable data protection laws and regulations of Ghana.';
  static const String carema = 'Camera Permission';
  static const String caremaDetail =
      'With your authorization, we will access your device\'s camera to capture images of your identification document and perform facial liveness verification. This helps verify your identity and prevent identity theft and fraudulent activities. The captured images are used solely for identity verification, security validation, and fraud prevention. They are securely transmitted and stored and will not be used for purposes unrelated to those described above.';
  static const String installAppData = 'App List Permission';
  static const String installAppDataDetail =
      'With your authorization, we may obtain information about installed financial applications on your device, such as banking, lending, and mobile payment applications. This information is used solely to support credit assessment, risk management, and the identification of potential fraud risks. We do not collect information about applications unrelated to risk management, and the collected data is used only for risk assessment models.';

  static const String receiveData =
      'By tapping "Agree & Continue", you confirm that you have read, understood, and agreed to the statement above.';
  static const String deviceinformation = 'Device Info';
  static const String campaign = 'In-app Activity';
  static const String agreeandContinue = 'Agree & Continue';
  static const String campaignDetail =
      'To maintain the security and stability of our application, we may collect necessary app activity information, such as application status and crash logs. This information is used solely for security monitoring, system troubleshooting, risk management, and fraud prevention, helping us continuously improve system stability and service quality.';
  static const String deviceInformationDetail =
      'To ensure the proper operation of our services and enhance system security, we may collect limited basic device information, such as your device model and operating system version. This information is used solely to ensure service compatibility, support risk management, prevent duplicate applications, and identify abnormal devices. It will not be used for purposes unrelated to those described above.';
  static const String privacyData = 'Privacy Policy';
  static const String grantedData =
      '''GATED LTDINTELLIGENCE LTD ("we", "us", or "our") is he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and he developer and the developer and operator of the Palm Loan application. This Privacy Policy also applies to our official website www.gatedintelligence.com.We understand the importance of your personal information and are committed to complying fully with applicable privacy protection laws in Ghana. This policy explains how we collect, use, store, and share your personal information.By using the Palm Loan service, you agree to the processing of your information as described in this Privacy Policy. The information we collect is used solely for providing, maintaining, and improving our services. Unless explicitly stated in this policy, we will not share your personal information with any third party.''';
  static const String wellcome = 'Welcome to Easy Moni';
  static const String wellcomedeailData =
      'Manage your credit, get funds faster, and borrow with confidence—all in one place.';
  static const String phoneStr = 'Mobile Money Number';
  static const String codestr = 'Enter your OTP';
  static const String gainCode = 'Send OTP';
  static const String login = 'Log In';
  static const String loginPhoneRequired = 'Please enter your mobile number';
  static const String loginPhoneInvalid = 'Please enter a valid mobile number';
  static const String loginCodeRequired = 'Please enter the OTP';
  static const String loginCodeSent = 'OTP sent.';
  static const String loginSendCodeFailed =
      'Failed to send OTP. Please try again.';
  static const String loginFailed = 'Login failed. Please try again.';
  static const String loginTokenMissing =
      'Authentication failed. Please try again.';
  // ================ 联系人流程 ========================
  static const String chooseContacts = 'Select a Parent/Spouse';
  static const String chooseFriends = 'Select a Friend/Colleague';
  static const String contactPlaceholder = 'Select from Contacts';
  static const String needsContacts = 'Contacts permission required';
  static const String needsSms = 'SMS permission required';
  static const String needsCamera = 'Camera permission required';
  static const String smsPermissionDesc =
      'Reads deposit and repayment SMS for credit assessment and fraud prevention. Your data is encrypted and protected.';
  static const String contactsEmpty = 'No contacts found';
  static const String chooseContactsPhone = 'Parent/Spouse Phone Number';
  static const String contactInfoTitle = 'Contact information';
  static const String contactInfoFriendColleaguePhone =
      'Friend/colleague phone number';
  static const String contactInfoLoadFailed = 'Failed to load contacts';
  static const String contactInfoNoPhoneNumber =
      'No phone number found for this contact';
  static const String contactInfoPickFailed =
      'Failed to open contacts. Please try again.';
  static const String contactInfoSaveFailed = 'Save failed';
  static const String checkIdCard =
      'Please upload a clear and complete photo of your ID.';
  static const String chooseUploadMethod = 'Choose Upload Method';
  static const String selectFormPhotos = 'Choose from Gallery';
  static const String takephotos = 'Take Photo';
  static const String idcardMessage =
      'Camera access is required to capture your Ghana Card.';
  static const String idcardVer = 'Identity Verification';
  static const String informationPersonalStep = 'Personal Information';
  static const String informationIdentityStep = 'Identity Verification';
  static const String informationFaceStep = 'Face Verification';
  static const String personalInfoSaving = 'Saving...';
  static const String personalInfoLoadFailed =
      'Failed to load data. Please try again.';
  static const String personalInfoSaveFailed = 'Save failed';
  static const String personalInfoRegionCityTitle = 'Residential Region & City';
  static const String questionnaireDefaultTitle = '';
  static const String questionnaireDescription =
      'Complete this questionnaire to help us better evaluate your credit profile.';
  static const String questionnaireSaving = 'Saving...';
  static const String questionnaireSubmitButton = 'Complete Application';
  static const String questionnaireNoData = 'No questionnaire data';
  static const String questionnaireSaveFailed = 'Save failed';
  static const String questionnaireAuthentication = 'Authentication';
  static const String questionnaireSubmitWaiting = 'Just a moment...';
  static const String locationPermissionTitle = 'Location Permission Required';
  static const String locationPermissionDesc =
      'We use your location to protect your account and prevent fraud. Please allow location access to continue.';
  static const String homeTab = 'Home';
  static const String repayTab = 'Repay';
  static const String mineTab = 'Me';
  static const String continueIdentifyStr = 'Scanning your ID...';
  static const String continueUploadPicture = 'Uploading your ID...';
  static const String continueOcr =
      'Follow the instructions to complete face verification.';
  static const String faceVerifyEntryContinue = 'CONTINUE';
  static const String faceVerifyEntryRetake = 'Retake';
  static const String faceVerifyEntryConfirmPhoto = 'Use This Photo';
  static const String faceVerifyEntryNoPhoto = 'Please take a selfie first.';
  static const String faceVerifyEntryPhotoConfirmTip =
      'Please check if your photo is clear.';
  static const String faceVerifyEntryPhotoBlurRisk =
      'A blurry photo may affect your verification.';
  static const String faceVerifyEntryResultLoading =
      'Processing your selfie...';
  static const String faceVerifyTitle = 'Face Verification';
  static const String faceVerifyGuideTitle =
      'Follow the instructions to complete face verification.';
  static const String faceVerifyLookStraight =
      'Please look straight at the camera';
  static const String faceVerifyFaceFront =
      'Please look straight at the camera';
  static const String faceVerifyNodHead = 'Please nod your head';
  static const String faceVerifyShakeHead = 'Please shake your head';
  static const String faceVerifyTurnLeft = 'Please turn your head left';
  static const String faceVerifyTurnRight = 'Please turn your head right';
  static const String faceVerifyBlink = 'Please blink your eyes';
  static const String faceVerifyOpenMouth = 'Please open your mouth';
  static const String faceVerifySmile = 'Please smile';
  static const String faceVerifyCaptureCompleted = 'Face capture completed';
  static const String faceVerifyActionTimeout =
      'Face verification timed out. Please try again.';
  static const String faceVerifyUploadFailed =
      'Upload failed. Please try again.';
  static const String faceVerifyCaptureFailedRetry =
      'Failed to capture photo. Please try again.';
  static const String faceVerifyUnsupportedWeb =
      'Face verification is not supported on the web. Please use an Android device.';
  static const String faceVerifyNoCamera = 'No camera available.';
  static const String faceVerifySubmitFailed = 'Submission failed';
  static const String faceVerifyAutoCaptureHint =
      'Please look at the camera. Your photo will be captured automatically.';
  static const String identityVerifyCheckInfo =
      'Please upload your Ghana Card';
  static const String identityVerifyConfirmIdNumber =
      'Please confirm your Ghana Card number.';
  static const String identityVerifyConfirmRequired =
      'Please confirm your Ghana Card number first.';
  static const String identityVerifyImageNotSelected = 'No image selected.';
  static const String identityVerifyImageNotCaptured = 'No image captured.';
  static const String identityVerifyCameraError = 'Failed to init camera';
  static const String identityVerifyImageDecodeFailed =
      'Unable to process the image.';
  static const String identityVerifyCameraPermissionDenied =
      'Camera permission denied.';
  static const String identityVerifyFlipCardAndContinue =
      'Turn over your Ghana Card and continue.';
  static const String identityVerifyPhotoProcessing =
      'Photo captured. Processing...';
  static const String identityVerifyCameraReturning = 'please waite...';
  static const String identityVerifyPhotoUploading = 'uploading...';
  static const String identityVerifyBackUploadSuccess =
      'Back of Ghana Card uploaded successfully.';
  static const String identityVerifyUploadFailed = 'Image upload failed.';
  static const String identityVerifyImageLoadFailed =
      'Failed to load data. Please try again.';
  static const String identityVerifyOcrSuccess = 'ID verified successfully.';
  static const String identityVerifyOcrFailed = 'ID recognition failed.';
  static const String identityVerifySaveFailed = 'Submission failed.';
  static const String identityVerifyEdit = 'Edit';
  static const String confirmOwnerData = 'Please verify yourself';
  static const String standard = 'Standard shooting';
  static const String toolBright = 'Too bright';
  static const String incompletePhoto = 'Incomplete photo';
  static const String blueryPhoto = 'Blurry/Faded photo';
  static const String fundingLimitDialogDesc =
      'You\'re one step away! Complete your loan application to receive your funds faster.';
  static const String continueSallery = "Continue";
  static const String looseSallery = "Not Now";
  static const String noLoanProducts = 'No loan offers available.';
  static const String selectProucts = 'Select the loan offer you want';
  static const String takeOcrPictures =
      'Please use landscape mode and place all four corners of your Ghana Card inside the frame.';
  static String captureFailed(Object error) =>
      'Failed to capture photo: $error';
  static String personalInfoSaveFailedWithError(Object error) =>
      '$personalInfoSaveFailed: $error';
  static String faceVerifyCameraInitFailed(Object error) =>
      'Failed to initialize camera: $error';
  static String faceVerifyEntryOwnerConfirm(String userName) {
    final name = userName.trim();
    return name.isEmpty
        ? confirmOwnerData
        : 'Please verify your identity as $name';
  }

  // ==================== 我的 ====================
  static const String mineCurrentPending = 'Outstanding Amount';
  static const String mineGoToRepay = 'Repay Now';
  static const String mineOtherFeatures = 'More';
  static const String mineHistoryOrders = 'My Loans';
  static const String mineCustomerService = 'Customer Support';
  static const String mineCustomerServiceEmpty =
      'No support information available.';
  static const String mineCustomerServiceLoadFailed =
      'Failed to load support information.';
  static const String customerServicePhone = 'Phone';
  static const String customerServiceWhatsApp = 'WhatsApp';
  static const String customerServiceEmail = 'Email';
  static const String customerServiceZalo = 'Zalo';
  static const String customerServiceIntelligent = 'Online Support';
  static const String customerServiceAntiFraudTitle =
      'Contact Our Support Team';
  static const String customerServiceAntiFraudDesc =
      'Reach out anytime for help with your loan or repayment.';
  static const String mineSettings = 'Settings';
  static const String mineLogout = 'Log Out';
  static const String mineDeleteAccount = 'Delete Account';
  static const String mineDeleteAccountDialogTitle = 'Delete Account';
  static const String mineDeleteAccountDialogContent =
      'Are you sure you want to delete your account?';
  static const String mineDeleteAccountSuccess = 'Account deleted';
  static const String mineDeleteAccountFailed = 'Delete failed, please retry';
  static const String mineTestUploadData = 'Test upload data';
  static const String mineTestUploadDataSuccess = 'Upload data success';
  static const String mineTestUploadDataFailed = 'Upload data failed';
  static const String mineTestUploadDataNoTrackId = 'No valid trackId';
  static const String mineOrderHistoryTitle = 'My Loans';
  static const String mineOrderHistoryAllTab = 'All';
  static const String mineOrderHistoryDisbursingTab = 'Processing';
  static const String mineOrderHistoryRepayingTab = 'Repay';
  static const String mineOrderHistoryFailedTab = 'Failed';
  static const String mineOrderHistoryEmpty = 'No loans found.';
  static const String mineOrderHistoryLoadFailed = 'Failed to load loans.';
  static const String mineOrderHistoryRetry = 'Retry';
  static const String mineOrderLoanDateLabel = 'Loan Date';
  static const String mineLogoutDialogTitle = 'Log Out';
  static const String mineLogoutDialogContent =
      'Are you sure you want to log out?';
  static const String mineLogoutSuccess = 'Logged out successfully.';
  static const String mineLogoutFailed = 'Failed to log out. Please try again.';

  // ==================== 首页 =======================
  static const String homeButtonText = 'Borrow Now';
  static const String homeLoanSectionTitle = 'My Loans';
  static const String homeLockedSectionTitle = 'More Products to Unlock';
  static const String homeHeaderTitle = 'Maximum Loan Amount';
  static const String homeAvailableString = 'Available Offers';
  static const String homeMultiSelectHint = 'Multiple Selection Available';
  static const String backToHomeText = 'Back to Home';
  static const String reviewFeatureTitle = 'Why Choose Us';
  static const String reviewFeatureApplyTitle = 'Easy Application';
  static const String reviewFeatureApplyDesc =
      'Apply in 3 steps with fast approval.';
  static const String reviewFeatureDisburseTitle = 'Fast Funding';
  static const String reviewFeatureDisburseDesc =
      'Funds in as little as 10 minutes.';
  static const String reviewFeatureFlexibleTitle = 'Flexible Repayment';
  static const String reviewFeatureFlexibleDesc =
      'Borrow anytime and manage everything online.';

  // ==================== 贷款详情 ====================
  static const String loanDetailTitle = 'Loan Details';
  static const String loanItemIdPrefix = 'Loan ID:';
  static const String createdRecently = 'Created recently';
  static const String statusLabel = 'Status';
  static const String statusActive = 'Active';
  static const String typeLabel = 'Type';
  static const String typePremium = 'Premium';
  static const String createdLabel = 'Created';
  static const String loanProductAvailable = 'Available';
  static const String loanProductUnavailable = 'Unavailable';
  static const String loanProductRejected = 'Rejected';
  static const String loanAvailableAmountLabel = 'Available Loan Amount';
  static const String loanDailyInterestRateLabel = 'Daily Interest Rate';
  static const String loanTermLabel = 'Term';
  static const String loanProductLogoFallback = '?';

  // ==================== 贷款订单状态 ====================
  static const String loanOrderStatusOverdue = 'Overdue';
  static const String loanOrderStatusReviewing = 'Under Review';
  static const String loanOrderStatusReviewFailed = 'Rejected';
  static const String loanOrderStatusDisbursing = 'Disbursing';
  static const String loanOrderStatusDisbursingv2 = 'Disbursing to MoMo';
  static const String loanOrderStatusWaitingRepayment = 'To Repay';
  static const String loanOrderStatusTransferFailed = 'Payout Failed';
  static const String loanOrderFooterOverdue = 'Overdue. Repay now >';
  static const String loanOrderFooterReviewing = 'Under review. Please wait >';
  static const String loanOrderFooterDisbursing =
      'Funds on the way to your MoMo >';
  static const String loanOrderFooterWaitingRepayment =
      'To Repay. Please repay on time >';
  static const String loanOrderFooterCouponRepayment = 'Repay with Coupon >';
  static const String loanOrderFooterImmediateRepayment = 'Repay Now >';
  static const String loanOrderFooterTransferFailed =
      'Payout Failed. View loan details. >';
  static const String loanOrderProductFallback = '';
  static const String loanOrderLogoFallback = '';
  static const String loanOrderEmptyValue = '';
  static const String loanOrderUnknownValue = '-';
  static const String loanOrderDaysUnit = 'days';
  static const String loanOrderDetailInfoTitle = 'Loan Details';
  static const String loanOrderAccountInfoTitle = 'Receiving Account';
  static const String loanOrderLoanAmountLabel = 'Loan Amount';
  static const String loanOrderLoanTermLabel = 'Loan Term';
  static const String loanOrderServiceFeeLabel = 'Service Fee';
  static const String loanOrderOverdueFeeLabel = 'Overdue Fee';
  static const String loanOrderOverdueDaysLabel = 'Overdue Days';
  static const String loanOrderRemainingDayLabel = 'Days Until Due';
  static const String loanOrderRepaymentRemainingDaysLabel =
      'Days Until Repayment';
  static const String loanOrderInterestLabel = 'Interest';
  static const String loanOrderRepaymentDateLabel = 'Repayment Date';
  static const String loanOrderReceiptAmountLabel = 'Amount to Receive';
  static const String loanOrderRepayAmountLabel = 'Outstanding Amount';
  static const String loanOrderDueDateLabel = 'Due Date';
  static const String loanOrderAccountLabel = 'MoMo Account';
  static const String loanOrderMomoAccountLabel = 'MoMo Account';
  static const String loanOrderWalletTypeLabel = 'Wallet Provider';

  // ==================== 账单详情 ====================
  static const String orderDetailTitle = 'Loan Details';
  static const String orderDetailNoOrderData = 'No bill found';
  static const String orderDetailLoadFailed = 'Failed to load bill details';
  static const String orderDetailMissingRouteParams =
      'Unable to load this bill. Please try again.';
  static const String orderDetailBackToRepayEntry = 'Back to Repayment';
  static const String orderDetailRepayingStatus = 'Repaying';
  static const String orderDetailPendingRepaymentStatus = 'To Repay';
  static const String orderDetailTotalRepayAmountLabel =
      'Total Outstanding Amount';
  static const String orderDetailRemainingDaysLabel = 'Days Remaining';
  static const String orderDetailOrderCountLabel = 'Bills';
  static const String orderDetailExtensionLabel = 'Extension';
  static const String orderDetailExtensionAvailable = 'Extension Available';
  static const String orderDetailExtensionUnavailable = 'Extension Unavailable';
  static const String orderDetailAccountInfoTitle = 'Receiving Account';
  static const String orderDetailMomoAccountLabel = 'MoMo Account';
  static const String orderDetailWalletTypeLabel = 'Wallet Provider';
  static const String orderDetailRepayNow = 'Repay Now';
  static const String orderDetailCurrencyCode = 'GHS ';
  static const String orderDetailZeroAmount = '0.00';

  // ==================== 还款卡片 ====================

  static const String repayEntryHeaderTitle = 'Total Outstanding Amount';
  static const String repayDefaultTitle = 'Repayment';
  static const String repayEntryBillTitle = 'Outstanding Bills';
  static const String repayEntryRepayAll = 'Repay All';
  static const String repayEntryEmpty = 'No outstanding bills';
  static const String repayEntryLoadFailed = 'Failed to load outstanding bills';
  static const String userRepaymentLoadFailed =
      'Failed to load repayment list';
  static const String repayEntryRetry = 'Retry';
  static const String repayBillDueDateLabel = 'Due Date';
  static const String repayBillOverdueStatus = 'Overdue';
  static const String repayBillRepayNow = 'Repay Now';
  static const String repayBillLogoFallback = '';
  static const String repayDetailTitle = 'Repayment Details';
  static const String repayDetailPendingStatus = 'To Repay';
  static const String repayDetailApplyExtension = 'Apply for Extension';
  static const String repayDetailRepayNow = 'Repay Now';

  static const String paymentTitle = 'Payment';
  static const String paymentNoOrderData = 'No payment data';
  static const String paymentGenerateFailed = 'Failed to generate payment link';
  static const String repayMultiDetailTitle = 'Repayment Details';
  static const String repayMultiTotalLoanAmountLabel = 'Total Principal';
  static const String repayMultiTotalInterestLabel = 'Total Interest';
  static const String repayMultiTotalOverdueFeeLabel = 'Total Overdue Fee';
  static const String repayExtensionTitle = 'Extension';
  static const String repayExtensionFeeLabel = 'Extension Fee';
  static const String repayExtensionInfoTitle = 'Extension Details';
  static const String repayExtensionNotice =
      'After your extension is approved, please repay by the new due date.';
  static const String repayExtensionDaysLabel = 'Extended Days';
  static const String repayExtensionNewDueDateLabel = 'New Due Date';
  static const String repayExtensionNewRepayAmountLabel =
      'Amount Due on New Due Date';
  static const String repayExtensionConfirm = 'Confirm Extension';
  static const String repayExtensionLoadFailed =
      'Failed to load extension details';
  static const String repayExtensionNoOrderData = 'No extension data';

  static const String couponEntrySubtitle =
      'Credit Limit or Interest Discount Coupon';
  static const String couponSelectedFallback = 'Coupon Selected';

  static String orderDetailDayValue(int days) =>
      '$days ${days == 1 ? 'day' : 'days'}';
  static String orderDetailCountValue(int count) => '$count';
  static String mineOrderHistoryTabCount(int count) => '($count)';
  static String orderDetailPeriodValue(int period) =>
      '$period ${period == 1 ? 'period' : 'periods'}';
  static String orderDetailOverdueDays(int days) => '$days days overdue';
  static String orderDetailRemainingDays(int days) => '$days days remaining';
  static String orderDetailCurrencyAmount(num amount) =>
      '$orderDetailCurrencyCode ${amount.toStringAsFixed(2)}';
  static String orderDetailRepayButtonText(num? amount) =>
      '$orderDetailRepayNow $orderDetailCurrencyCode ${amount?.toStringAsFixed(2) ?? orderDetailZeroAmount}';

  // ==================== 借款审核 ====================
  static const String loanReviewTitle = 'Under Review';
  static const String loanReviewAppBarTitle = 'Loan Application';
  static const String loanReviewDesc =
      'Your loan application is under review. \nThe review is usually completed within a few minutes. \nWe\'ll notify you as soon as the result is available.';
  static const String loanReviewRatingTitle = 'Rate Our App';
  static const String scoreSuccess = 'Thanks for your rating!';

  // ===================== 优惠券 ========================
  static const String couponEmptyDesc =
      'No coupons available. Repay on time to unlock more rewards.';
  static const String couponString = 'Coupons';
  static const String couponLoadFailed =
      'Failed to load coupons. Please try again.';
  static const String couponTypePre = 'Credit Limit Coupon';
  static const String couponTypePost = 'Discount Coupon';

  // ==================== 确认借款 ====================
  static const String loanConfirmTitle = 'Confirm Loan';
  static const String loanConfirmButtonText = 'Confirm Loan';
  static const String loanConfirmEmptyText = 'No loan available to confirm';
  static const String loanConfirmButtonLoadingText = 'Submitting...';
  static const String loanConfirmErrorText =
      'Submission failed. Please try again.';
  static const String loanConfirmUploadDataFailedText =
      'Failed to upload data. Please try again.';
  static const String loanConfirmActualAmountLabel = 'Amount to Receive';
  static const String loanConfirmRepayAmountLabel = 'Amount Due';
  static const String loanConfirmRepaymentDateLabel = 'Repayment Date';

  // ==================== 状态 =====================
  static const String errorMessage = 'Failed to load. Please try again.';
  static const String stateReloadAction = 'Reload';
}
