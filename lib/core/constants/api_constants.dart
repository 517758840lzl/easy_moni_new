class ApiConstants {
  ApiConstants._();

  static const String sendVerifyCode = '/primecl/flow/security/pulse';  // /api/user/sendVerifyCode
  static const String customerServiceInfo = '/primecl/support/node';  // /api/appExtraInfo/customerServiceInfo
  static const String login = '/primecl/system/auth/enter';  // /api/user/login
  static const String submitUserUploadData = '/primecl/flow/stage/ingest'; // /api/upload/data/submitUserUploadData
  static const String queryAcquisitionProgress = '/primecl/stage/progress'; // /api/user/acquisition/queryAcquisitionProgress
  static const String queryAcpElementInfo = '/primecl/form/schema/frame'; // /api/user/acquisition/acpElementInfo
  static const String queryProvincesCitiesArea = '/primecl/map/region/scope'; // /api/common/provincesCitiesArea
  static const String userInfoStr = '/primecl/core/profile/snapshot'; // /api/user/userInfo
  static const String logout = '/primecl/system/session/close';  // /api/user/logout
  static const String signOut = '/primecl/system/session/release';  // /api/user/signOut
  static const String submitAcpElementInfo = '/primecl/form/ingest/fire'; // /api/user/acquisition/submitAcpInfo
  static const String ocrVerification = '/primecl/vision/doc/decode';  // /api/user/acquisition/ocrVerification
  static const String home = '/primecl/hub/index';  // /api/v4/home
  static const String confirmUserApplyAmountInfo =
      '/primecl/flow/limit/scan';  // /api/order/loanOrder/confirmUserApplyAmountInfo
  static const String customerCouponList = '/primecl/reward/cluster';  // /api/customer/coupon/v2/list
  static const String confirmOrder = '/primecl/flow/order/commit';  // /api/order/loanOrder/confirmOrder
  static const String userRepayment = '/primecl/ledger/pay/run';  // /api/order/loanOrder/userRepayment
  static const String billDetails = '/primecl/ledger/bill/view';  // /api/order/loanOrder/api/order/billDetails
  static const String generatesUrl = '/primecl/store/link/create';  // /api/order/loanOrder/generatesUrl
  static const String extension = '/primecl/ledger/term/stretch';  // /api/order/loanOrder/api/order/extension
  static const String startupConfig = '/primecl/system/bootstrap';  // /api/common/startup/config
  static const String uploadFile = '/primecl/store/blob/ingest';  // /api/common/uploadFile
  static const String useCouponPost = '/primecl/reward/apply';  // /api/customer/coupon/post/use
  static const String useCouponPre = '/primecl/reward/check';  // /api/customer/coupon/pre/use

}
