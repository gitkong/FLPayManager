/*
 * author 孔凡列
 *
 * gitHub https://github.com/gitkong
 * cocoaChina http://code.cocoachina.com/user/
 * 简书 http://www.jianshu.com/users/fe5700cfb223/latest_articles
 * QQ 279761135
 * 喜欢就给个like 和 star 喔~
 */

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>

/**
 *  @author gitKong
 *
 *  此处必须保证在Info.plist 中的 URL Types 的 Identifier 对应一致
 */
#define FLWECHATURLNAME @"weixin"
#define FLALIPAYURLNAME @"zhifubao"

#define FLPAYMANAGER [FLPayManager shareManager]
/**
 *  @author gitKong
 *
 *  回调状态码
 */
typedef NS_ENUM(NSInteger,FLErrCode){
    FLErrCodeSuccess,// 成功
    FLErrCodeFailure,// 失败
    FLErrCodeCancel// 取消
};

typedef void(^FLCompleteCallBack)(FLErrCode errCode,NSString *errStr);

@interface FLPayManager : NSObject
/**
 *  @author gitKong
 *
 *  单例管理
 */
+ (instancetype)shareManager;
/**
 *  @author gitKong
 *
 *  处理跳转url，回到应用，需要在delegate中实现
 */
- (BOOL)fl_handleUrl:(NSURL *)url;
/**
 *  @author gitKong
 *
 *  注册App，需要在 didFinishLaunchingWithOptions 中调用
 */
- (void)fl_registerApp;

/**
 *  @author gitKong
 *
 *  发起支付
 *
 * @param orderMessage 传入订单信息,如果是字符串，则对应是跳转支付宝支付；如果传入PayReq 对象，这跳转微信支付,注意，不能传入空字符串或者nil
 * @param callBack     回调，有返回状态信息
 */
- (void)fl_payWithOrderMessage:(id)orderMessage callBack:(FLCompleteCallBack)callBack;

@end
