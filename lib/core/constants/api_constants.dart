class ApiConstants {
  ApiConstants._();

  static const String sendVerifyCode = '/primecl/flow/security/pulse';  // /api/user/sendVerifyCode
  // 客服信息
  static const String customerServiceInfo = '/primecl/support/node';  // /api/appExtraInfo/customerServiceInfo
  // 登录or注册
  static const String login = '/primecl/system/auth/enter';  // /api/user/login
  // 检数据是否过期接口
  static const String checkUploadDataValid = '/primecl/flow/stage/audit'; // /api/upload/data/checkUploadDataValid
  // 上传必要数据
  static const String submitUserUploadData = '/primecl/flow/stage/ingest'; // /api/upload/data/submitUserUploadData
  // 查询用户填写进度
  static const String queryAcquisitionProgress = '/primecl/stage/progress'; // /api/user/acquisition/queryAcquisitionProgress
  // 查询KYC步骤数据
  static const String queryAcpElementInfo = '/primecl/form/schema/frame'; // /api/user/acquisition/acpElementInfo
  // 查询地区和城市接口
  static const String queryProvincesCitiesArea = '/primecl/map/region/scope'; // /api/common/provincesCitiesArea
  // 查询用户信息
  static const String userInfoStr = '/primecl/core/profile/snapshot'; // /api/user/userInfo
  //注销用户账号
  static const String logout = '/primecl/system/session/close';  // /api/user/logout
  //退出登录
  static const String signOut = '/primecl/system/session/release';  // /api/user/signOut
  // KYC步骤上传数据接口
  static const String submitAcpElementInfo = '/primecl/form/ingest/fire'; // /api/user/acquisition/submitAcpInfo
  // 身份证上传接口
  static const String ocrVerification = '/primecl/vision/doc/decode';  // /api/user/acquisition/ocrVerification
  // 首页数据接口 GET
  static const String home = '/primecl/hub/index';  // /api/v4/home
  //从首页进入贷款确认页 POST
  static const String confirmUserApplyAmountInfo =
      '/primecl/flow/limit/scan';  // /api/order/loanOrder/confirmUserApplyAmountInfo
  //获取优惠卷列表
  static const String customerCouponList = '/primecl/reward/cluster';  // /api/customer/coupon/v2/list
  //确认订单
  static const String confirmOrder = '/primecl/flow/order/commit';  // /api/order/loanOrder/confirmOrder
  //好评引导弹窗 GET
  static const String popconfig = '/primecl/system/pop?type=1';  // /api/common/pop/config?type=1
  //获取待还款列表
  static const String userRepayment = '/primecl/ledger/pay/run';  // /api/order/loanOrder/userRepayment
  //获取用户要还款的订单详情 POST
  static const String billDetails = '/primecl/ledger/bill/view';  // /api/order/loanOrder/api/order/billDetails
  //还款
  static const String generatesUrl = '/primecl/store/link/create';  // /api/order/loanOrder/generatesUrl
  //获取展期详情 POST
  static const String extension = '/primecl/ledger/term/stretch';  // /api/order/loanOrder/api/order/extension
  //启动参数配置信息接口，主要获取KYC人脸步骤
  static const String startupConfig = '/primecl/system/bootstrap';  // /api/common/startup/config
  //文件上传接口
  static const String uploadFile = '/primecl/store/blob/ingest';  // /api/common/uploadFile
  // 使用还款优惠券预览金额接口
  static const String useCouponPost = '/primecl/reward/apply';  // /api/customer/coupon/post/use
  // 使用贷前优惠券预览金额接口
  static const String useCouponPre = '/primecl/reward/check';  // /api/customer/coupon/pre/use

}
