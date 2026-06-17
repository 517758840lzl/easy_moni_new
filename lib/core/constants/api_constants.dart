class ApiConstants {
  ApiConstants._();

  // 服务器任一接口返回 401，表示 token 过期或用户未登录。
  static const String bannerList = '/api/banner/list';
  static const String sendVerifyCode = '/api/user/sendVerifyCode';
  /*客服信息*/
  static const String customerServiceInfo =
      '/api/appExtraInfo/customerServiceInfo';
  /*login*/
  static const String login = '/api/user/login';
  /*检数据是否过期接口*/
  static const String checkUploadDataValid =
      '/api/upload/data/checkUploadDataValid';
  static const String submitUserUploadData =
      '/api/upload/data/submitUserUploadData';
  /*查询用户状态GET*/
  static const String queryAcquisitionProgress =
      '/api/user/acquisition/queryAcquisitionProgress';
  /*查询KYC步骤数据*/
  static const String queryAcpElementInfo =
      '/api/user/acquisition/acpElementInfo';
  /*查询地区和城市接口 GET*/
  static const String queryProvincesCitiesArea =
      '/api/common/provincesCitiesArea';
  static const String userInfoStr = '/api/user/userInfo';
  //注销用户账号
  static const String logout = '/api/user/logout';
  //退出登录
  static const String signOut = '/api/user/signOut';
  /*查询银行列表接口 GET*/
  static const String queryBankList = '/api/user/acquisition/queryBankList';
  /*KYC步骤上传数据接口 POST*/
  static const String submitAcpElementInfo =
      '/api/user/acquisition/submitAcpInfo';
  /*身份证上传接口  POST*/
  static const String ocrVerification = '/api/user/acquisition/ocrVerification';
  // 首页数据接口 GET
  static const String home = '/api/v4/home';
  //从首页进入贷款确认页 POST
  static const String confirmUserApplyAmountInfo =
      '/api/order/loanOrder/confirmUserApplyAmountInfo';
  //获取优惠卷列表
  static const String customerCouponList = '/api/customer/coupon/v2/list';
  //确认订单
  static const String confirmOrder = '/api/order/loanOrder/confirmOrder';
  //好评引导弹窗 GET
  static const String popconfig = '/api/common/pop/config?type=1';
  //获取待还款列表
  static const String userRepayment = '/api/order/loanOrder/userRepayment';
  //获取用户要还款的订单详情 POST
  static const String billDetails =
      '/api/order/loanOrder/api/order/billDetails';
  //还款
  static const String generatesUrl = '/api/order/loanOrder/generatesUrl';
  //获取展期详情 POST
  static const String extension = '/api/order/loanOrder/api/order/extension';
  //APP事件上报接口
  static const String event = '/api/common/event';
  //启动参数配置信息接口，主要获取KYC人脸步骤
  static const String startupConfig = '/api/common/startup/config';
  //文件上传接口
  static const String uploadFile = '/api/common/uploadFile';
  /*上传人脸视频接口*/
  static const String uploadFaceVideo = '/api/user/acquisition/uploadFaceVideo';
}
