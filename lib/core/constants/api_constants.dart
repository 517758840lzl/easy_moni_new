class ApiConstants {
  ApiConstants._();

  static const String sendVerifyCode = '/primecl/flow/security/pulse';
  static const String customerServiceInfo = '/primecl/support/node';
  static const String login = '/primecl/system/auth/enter';
  static const String flowStageIngest = '/primecl/flow/stage/ingest';
  static const String queryAcquisitionProgress = '/primecl/stage/progress';
  static const String queryAcpElementInfo = '/primecl/form/schema/frame';
  static const String queryProvincesCitiesArea = '/primecl/map/region/scope';
  static const String userInfoStr = '/primecl/core/profile/snapshot';
  static const String logout = '/primecl/system/session/close';
  static const String signOut = '/primecl/system/session/release';
  static const String submitAcpElementInfo = '/primecl/form/ingest/fire';
  static const String ocrVerification = '/primecl/vision/doc/decode';
  static const String home = '/primecl/hub/index';
  static const String confirmUserApplyAmountInfo = '/primecl/flow/limit/scan';
  static const String customerCouponList = '/primecl/reward/cluster';
  static const String confirmOrder = '/primecl/flow/order/commit';
  static const String userRepayment = '/primecl/ledger/pay/run';
  static const String billDetails = '/primecl/ledger/bill/view';
  static const String generatesUrl = '/primecl/store/link/create';
  static const String extension = '/primecl/ledger/term/stretch';
  static const String startupConfig = '/primecl/system/bootstrap';
  static const String uploadFile = '/primecl/store/blob/ingest';
  static const String useCouponPost = '/primecl/reward/apply';
  static const String useCouponPre = '/primecl/reward/check';
}
