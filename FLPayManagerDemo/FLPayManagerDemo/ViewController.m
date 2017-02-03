//
//  ViewController.m
//  FLPayManagerDemo
//
//  Created by clarence on 16/11/30.
//  Copyright © 2016年 gitKong. All rights reserved.
//

#import "ViewController.h"
#import "FLPayManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"gitKong 你好！";
    
    CGFloat width = self.view.bounds.size.width;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((width - 100) / 2, 200, 100, 40)];
    [btn setTitle:@"微信支付" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:self action:@selector(wechatPay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake((width - 100) / 2, 400, 100, 40)];
    [btn1 setTitle:@"支付宝支付" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor grayColor];
    [btn1 addTarget:self action:@selector(aliPay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}


- (void)wechatPay {
//    NSLog(@"%@",[self jumpToBizPay]);
    PayReq* req             = [[PayReq alloc] init];
    //                req.partnerId           = [dict objectForKey:@"partnerid"];
    //                req.prepayId            = [dict objectForKey:@"prepayid"];
    //                req.nonceStr            = [dict objectForKey:@"noncestr"];
    //                req.timeStamp           = stamp.intValue;
    //                req.package             = [dict objectForKey:@"package"];
    //                req.sign                = [dict objectForKey:@"sign"];
    
    req.partnerId = @"10000100";
    req.prepayId= @"1101000000140415649af9fc314aa427";
    req.package = @"Sign=WXPay";
    req.nonceStr= @"a462b76e7436e98e0ed6e13c64b4fd1c";
    req.timeStamp= @"1397527777".intValue;
    req.sign= @"582282D72DD2B03AD892830965F428CB16E7A256";
    
    [FLPAYMANAGER fl_payWithOrderMessage:req callBack:^(FLErrCode errCode, NSString *errStr) {
        NSLog(@"errCode = %zd,errStr = %@",errCode,errStr);
    }];

}

- (void)aliPay{
    /**
     *  @author gitKong
     *
     *  来自支付宝文档数据
     */
    NSString *orderMessage = @"app_id=2015052600090779&biz_content=%7B%22timeout_express%22%3A%2230m%22%2C%22seller_id%22%3A%22%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22total_amount%22%3A%220.02%22%2C%22subject%22%3A%221%22%2C%22body%22%3A%22%E6%88%91%E6%98%AF%E6%B5%8B%E8%AF%95%E6%95%B0%E6%8D%AE%22%2C%22out_trade_no%22%3A%22314VYGIAGG7ZOYY%22%7D&charset=utf-8&method=alipay.trade.app.pay&sign_type=RSA&timestamp=2016-08-15%2012%3A12%3A15&version=1.0&sign=MsbylYkCzlfYLy9PeRwUUIg9nZPeN9SfXPNavUCroGKR5Kqvx0nEnd3eRmKxJuthNUx4ERCXe552EV9PfwexqW%2B1wbKOdYtDIb4%2B7PL3Pc94RZL0zKaWcaY3tSL89%2FuAVUsQuFqEJdhIukuKygrXucvejOUgTCfoUdwTi7z%2BZzQ%3D";
    [FLPAYMANAGER fl_payWithOrderMessage:orderMessage callBack:^(FLErrCode errCode, NSString *errStr) {
        NSLog(@"errCode = %zd,errStr = %@",errCode,errStr);
    }];
}


- (NSString *)jumpToBizPay {
    
    
    
    //============================================================
    /**
     *  @author Clarence
     *
     *  来自微信文档数据
     */
    //============================================================
    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
    //解析服务端返回json数据
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if ( response != nil) {
        NSMutableDictionary *dict = NULL;
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        
        NSLog(@"url:%@",urlString);
        if(dict != nil){
            NSMutableString *retcode = [dict objectForKey:@"retcode"];
            if (retcode.intValue == 0){
                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                req.partnerId           = [dict objectForKey:@"partnerid"];
                req.prepayId            = [dict objectForKey:@"prepayid"];
                req.nonceStr            = [dict objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.package             = [dict objectForKey:@"package"];
                req.sign                = [dict objectForKey:@"sign"];
                
                
                [FLPAYMANAGER fl_payWithOrderMessage:req callBack:^(FLErrCode errCode, NSString *errStr) {
                    NSLog(@"errCode = %zd,errStr = %@",errCode,errStr);
                }];
                
                //日志输出
                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                return @"";
            }else{
                return [dict objectForKey:@"retmsg"];
            }
        }else{
            return @"服务器返回错误，未获取到json对象";
        }
    }else{
        return @"服务器返回错误";
    }
    
}



@end
