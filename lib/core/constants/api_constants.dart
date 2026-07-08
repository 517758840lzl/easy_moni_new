class ApiConstants {
  ApiConstants._();

  static const String sendVerifyCode = '/easy/flow/security/pulse';
  // 客服信息
  static const String customerServiceInfo = '/easy/support/node';
  // 登录or注册
  static const String login = '/easy/system/auth/enter';
  // 检数据是否过期接口
  static const String checkUploadDataValid = '/easy/flow/stage/audit';
  // 上传必要数据
  static const String submitUserUploadData = '/easy/flow/stage/ingest';
  // 查询用户填写进度
  static const String queryAcquisitionProgress = '/easy/stage/progress';
  // 查询KYC步骤数据
  static const String queryAcpElementInfo = '/easy/form/schema/frame';
  // 查询地区和城市接口
  static const String queryProvincesCitiesArea = '/easy/map/region/scope';
  // 查询用户信息
  static const String userInfoStr = '/easy/core/profile/snapshot';
  //注销用户账号
  static const String logout = '/easy/system/session/close';
  //退出登录
  static const String signOut = '/easy/system/session/release';
  // KYC步骤上传数据接口
  static const String submitAcpElementInfo = '/easy/form/ingest/fire';
  // 身份证上传接口
  static const String ocrVerification = '/easy/vision/doc/decode';
  // 首页数据接口 GET
  static const String home = '/easy/hub/index';
  //从首页进入贷款确认页 POST
  static const String confirmUserApplyAmountInfo =
      '/easy/flow/limit/scan';
  //获取优惠卷列表
  static const String customerCouponList = '/easy/reward/cluster';
  //确认订单
  static const String confirmOrder = '/easy/flow/order/commit';
  //好评引导弹窗 GET
  static const String popconfig = '/easy/system/pop?type=1';
  //获取待还款列表
  static const String userRepayment = '/easy/ledger/pay/run';
  //获取用户要还款的订单详情 POST
  static const String billDetails = '/easy/ledger/bill/view';
  //还款
  static const String generatesUrl = '/easy/store/link/create';
  //获取展期详情 POST
  static const String extension = '/easy/ledger/term/stretch';
  //启动参数配置信息接口，主要获取KYC人脸步骤
  static const String startupConfig = '/easy/system/bootstrap';
  //文件上传接口
  static const String uploadFile = '/easy/store/blob/ingest';
  // 使用还款优惠券预览金额接口
  static const String useCouponPost = '/easy/reward/apply';
  // 使用贷前优惠券预览金额接口
  static const String useCouponPre = '/easy/reward/check';

  // 测试地址到正式地址映射
  static const Map<String, String> testToProductionPathMap = {
    '/api/user/sendVerifyCode': sendVerifyCode,
    '/api/appExtraInfo/customerServiceInfo': customerServiceInfo,
    '/api/user/login': login,
    '/api/upload/data/checkUploadDataValid': checkUploadDataValid,
    '/api/upload/data/submitUserUploadData': submitUserUploadData,
    '/api/user/acquisition/queryAcquisitionProgress':
        queryAcquisitionProgress,
    '/api/user/acquisition/acpElementInfo': queryAcpElementInfo,
    '/api/common/provincesCitiesArea': queryProvincesCitiesArea,
    '/api/user/userInfo': userInfoStr,
    '/api/user/logout': logout,
    '/api/user/signOut': signOut,
    '/api/user/acquisition/submitAcpInfo': submitAcpElementInfo,
    '/api/user/acquisition/ocrVerification': ocrVerification,
    '/api/v4/home': home,
    '/api/order/loanOrder/confirmUserApplyAmountInfo':
        confirmUserApplyAmountInfo,
    '/api/customer/coupon/v2/list': customerCouponList,
    '/api/order/loanOrder/confirmOrder': confirmOrder,
    '/api/common/pop/config?type=1': popconfig,
    '/api/order/loanOrder/userRepayment': userRepayment,
    '/api/order/loanOrder/api/order/billDetails': billDetails,
    '/api/order/loanOrder/generatesUrl': generatesUrl,
    '/api/order/loanOrder/api/order/extension': extension,
    '/api/common/startup/config': startupConfig,
    '/api/common/uploadFile': uploadFile,
    '/api/customer/coupon/post/use': useCouponPost,
    '/api/customer/coupon/pre/use': useCouponPre,
  };
}
