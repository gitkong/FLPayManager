#一、前言
- **1、之前写了一篇[支付宝支付——统一wap和支付宝钱包回调](http://www.jianshu.com/p/3d4271227a17),然后有需求说也弄一个微信支付的，block回调，其实微信支付的API提供挺好的，只有一个代理方法处理支付结果，不像支付宝有两种回调，当然，使用block回调简单很多，所以我也单独封装了 [微信支付，block回调](https://github.com/gitkong/FLWXPayManager) 此处就不开篇讲解了，大家需要的话可以去我的gitHub上clone**

- **2、还有提出要整合支付宝和微信，这个提议不错，因为集成支付功能的app一般都有支付宝和微信，既然两种都需要，那么统一管理岂不是很方便！所以本篇主要讲解统一管理的工具封装。**

#二、支付宝和微信API分析
- 作者在此对比了支付宝和微信的支付API，分析一下它们接口的异同点：[支付宝官方文档](https://doc.open.alipay.com/doc2/detail.htm?treeId=204&articleId=105302&docType=1)     [微信官方文档](https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=8_5)
  -  （1）支付宝是不需要在`didFinishLaunchingWithOptions` 中注册，而微信则需要调用`registerApp` 注册

  -  （2）支付宝有web回调，而微信没有，当然这个对整合没影响（因为最终都要统一成一个回调）

  -  （3）支付宝发起支付是传入订单信息（字符串类型），而微信则传入一个`BaseReq` 类或者其子类（支付的是`PayReq` 类），此时根据这点差异性可以通过传入id 类型，然后内部做判断，进行跳转不同的支付方式，来看看他们的接口

  >**支付宝发起支付**

  ```
  /**
   *  支付接口
   *
   *  @param orderStr       订单信息
   *  @param schemeStr      调用支付的app注册在info.plist中的scheme
   *  @param completionBlock 支付结果回调Block，用于wap支付结果回调（非跳转钱包支付）
   */
  - (void)payOrder:(NSString *)orderStr
        fromScheme:(NSString *)schemeStr
          callback:(CompletionBlock)completionBlock;
  ```
  
  >**微信发起支付**

  ```
/*! @brief 发送请求到微信，等待微信返回onResp
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。支持以下类型
 * SendAuthReq、SendMessageToWXReq、PayReq等。
 * @param req 具体的发送请求，在调用函数后，请自己释放。
 * @return 成功返回YES，失败返回NO。
 */
+(BOOL) sendReq:(BaseReq*)req;
  ```
  
  -  （4）支付宝发起支付不单单传入订单信息，还需要传入appSchemes（就是在Info - URL Types 中配置的 App Schemes），而微信 发起支付只需要传入订单信息，它的appSchemes 在 `didFinishLaunchingWithOptions` 注册的时候已经传入了，因此可以考虑 我也在`didFinishLaunchingWithOptions` 中给支付宝绑定一个 appSchemes ，类似微信，然后在发起支付的时候就不需要传入，只需要在内部获取就行，当然，由于Url Scheme 是存储在`Info.plist` 文件中，因此可以用代码获取，就不需要调用者传入了，只需要按照本工具的规定就搞定

  -  （5）支付宝的支付返回状态不是以枚举类型返回，是用过回调中返回的字典中的 resultStatus 字段，而微信是通过枚举返回，此时可以统一为枚举，可参考微信
![支付宝支付返回状态码（截图来自支付宝官方文档）](http://upload-images.jianshu.io/upload_images/1085031-b8bca4159e811852.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    ![微信支付返回状态码（截图来自微信官方文档）](http://upload-images.jianshu.io/upload_images/1085031-fdb7932ac4d290db.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  -  （6）支付宝每一个状态码都对应一个状态信息，而微信则只有错误的时候（errCode = -1）才有对应状态信息，可参考支付宝，手动给微信添加返回状态信息

#三、集成
- **1、支付宝支付集成 （三个步骤）**
  -  （1）由于支付宝不支持Pod，那么[下载最新的SDK](https://doc.open.alipay.com/doc2/detail.htm?treeId=54&articleId=104509&docType=1)，拖到项目中

  ![只有两个资源文件](http://upload-images.jianshu.io/upload_images/1085031-2ba9f31933ca4de0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
  -  （2）按照支付宝官方文档，导入所需库

      ![导入所需库](http://upload-images.jianshu.io/upload_images/1085031-414ceb1b829c6646.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  -  （3）配置 `Info.plist` 中的 `Url Types` 添加支付宝跳转 Url Scheme

    ![添加Url Scheme](http://upload-images.jianshu.io/upload_images/1085031-d81ba0ffc1931385.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


- **2、微信支付集成（六个步骤）**
  -  （1）同样微信也不支持Pod，[下载最新的SDK](https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=11_1)，拖到项目中

  ![有四个文件](http://upload-images.jianshu.io/upload_images/1085031-9db84ae06b2075fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
  -  （2）按照微信官方文档，导入所需库

    ![文档比较旧，截图来自官方Demo](http://upload-images.jianshu.io/upload_images/1085031-dab2e16521a94ad9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
** *此时你运行官方Demo，发现没任何问题，但是自己项目中就可能出现下图的情况，下一步解决**

    ![如果出现这种错误，请看下一步](http://upload-images.jianshu.io/upload_images/1085031-546df925ecaf06d3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  -  （3）还是再看看官方文档，虽然旧点，你会发现，其实是少了一个libc++.tbd 库，至于CFNetwork.framework 实测不添加也是没问题的，官方Demo也没添加，当然最好也添加进去

    ![少了一个libc++.tbd 库](http://upload-images.jianshu.io/upload_images/1085031-b9b8c6b8baec4548.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
** *此时command + b 发现successfully 了，但当你高高兴兴地运行的时候，你会发现，程序崩溃了，提示如下，断点调试的时候发现其实就是 调用微信的`registerApp`方法出现的 **

    ![崩溃原因](http://upload-images.jianshu.io/upload_images/1085031-14df5f04de3faccd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  -   （4）在 `build settings` 下面的 `Other Linker Flags` 添加 `-ObjC` ，如果依然不行，改为 `-all_load`  此时应该没问题了

    ![添加-all_load](http://upload-images.jianshu.io/upload_images/1085031-4208755cadb0e2ba.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  -  （5）配置 `Info.plist` 中的 `Url Types` 添加微信跳转 Url Scheme，此时就集成完毕了

    ![添加Url Scheme](http://upload-images.jianshu.io/upload_images/1085031-480fb409f71964df.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

  -  （6）当然此时运行应该还有问题，提示少了类 `Expected a type`，其实就是 `WXApiObject.h` 和 `WXApi.h` 少导入了  `UIKit` 框架,因为微信官方Demo中用到了PCH 文件，文件中导入了 `UIKit` 框架,手动添加进去就没问题了


#四、封装 API 

 >1、单例模式，项目中唯一，方便统一管理

```
/**
 *  @author gitKong
 *
 *  单例管理
 */
+ (instancetype)shareManager;
```

>2、处理回调url，需要在AppDelegate中实现

```
/**
 *  @author gitKong
 *
 *  处理跳转url，回到应用，需要在delegate中实现
 */
- (BOOL)fl_handleUrl:(NSURL *)url;
```

>3、注册app，需要在 didFinishLaunchingWithOptions 中调用，绑定URL Scheme

```
/**
 *  @author gitKong
 *
 *  注册App，需要在 didFinishLaunchingWithOptions 中调用
 */
- (void)fl_registerApp;
```

>4、发起支付，传入订单参数类型是id，传入如果是字符串，则对应是跳转支付宝支付；如果传入PayReq 对象，这跳转微信支付,注意，不能传入空字符串或者nil，内部有对应断言;统一了回调，不管是支付宝的wap 还是 app，或者是微信支付，都是通过这个block回调，回调状态码都有对应的状态信息

```
/**
 *  @author gitKong
 *
 *  发起支付
 *
 * @param orderMessage 传入订单信息,如果是字符串，则对应是跳转支付宝支付；如果传入PayReq 对象，这跳转微信支付,注意，不能传入空字符串或者nil
 * @param callBack     回调，有返回状态信息
 */
- (void)fl_payWithOrderMessage:(id)orderMessage callBack:(FLCompleteCallBack)callBack;
```


#五、用法（基于SDK集成后）

> **1、在`AppDelegate`处理回调，一般只需要实现后面两个方法即可，为了避免不必要的麻烦，最好三个都写上**

```
/**
 *  @author gitKong
 *
 *  最老的版本，最好也写上
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [FLPAYMANAGER fl_handleUrl:url];
}

/**
 *  @author gitKong
 *
 *  iOS 9.0 之前 会调用
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [FLPAYMANAGER fl_handleUrl:url];
}

/**
 *  @author gitKong
 *
 *  iOS 9.0 以上（包括iOS9.0）
 */
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options{
    
    return [FLPAYMANAGER fl_handleUrl:url];
}
```

>**2、在`didFinishLaunchingWithOptions`中注册 app，内部绑定根据Info中对应的Url Types 绑定 `URL Scheme`**

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 注册app
    [FLPAYMANAGER fl_registerApp];
    return YES;
}
```

>3、**发起支付**

-  支付宝支付

```
NSString *orderMessage = @"Demo 中 有 可测试的 订单信息";
[FLPAYMANAGER fl_payWithOrderMessage:orderMessage callBack:^(FLErrCode errCode, NSString *errStr) {
   NSLog(@"errCode = %zd,errStr = %@",errCode,errStr);
}];
```

- 微信支付

```
//调起微信支付
 PayReq* req             = [[PayReq alloc] init];
 req.partnerId           = [dict objectForKey:@"partnerid"];
 req.prepayId            = [dict objectForKey:@"prepayid"];
 req.nonceStr            = [dict objectForKey:@"noncestr"];
 req.timeStamp           = stamp.intValue;
 req.package             = [dict objectForKey:@"package"];
 req.sign                = [dict objectForKey:@"sign"];
                
 [FLPAYMANAGER fl_payWithOrderMessage:req callBack:^(FLErrCode errCode, NSString *errStr) {
     NSLog(@"errCode = %zd,errStr = %@",errCode,errStr);
 }];
```

#六、此工具的优点
- 1、隔离框架，统一管理，维护方便

- 2、针对支付功能来封装一套API，用法简单，可读性强

- 3、融合支付宝 和 微信 接口的优点，例如完善微信返回状态码对应的状态信息

- 4、对支付宝 和 微信的 回调处理都统一 成一个 block回调

- 5、工具中添加了比较完善的断言

  ![比较完善的断言，避免不必要的错误](http://upload-images.jianshu.io/upload_images/1085031-0e74c0505083a663.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


#七、注意点：
- 1、`Info.plist` 配置 `Url Types`  的 `Identifier` 必须 保证 和 工具中的对应，默认微信的 `Identifier` 是 `weixin` ，支付宝的 `Identifier` 是 `zhifubao`，可修改

  ```
/**
 *  @author gitKong
 *
 *  此处必须保证在Info.plist 中的 URL Types 的 Identifier 对应一致
 */
#define FLWECHATURLNAME @"weixin"
#define FLALIPAYURLNAME @"zhifubao"
  ```

- 2、因为工具中添加了比较完善的断言，配置不完整或者是传参不正确，程序都会不可避免的崩溃

- 3、由于工具中都耦合可支付宝SDK 以及 微信SDK，如果项目中只需要用到单个支付，此时就不适用了，当然，独立的也有：
[支付宝支付——统一wap和支付宝钱包回调](https://github.com/gitkong/FLAlipayManager)          
[微信支付-block回调](https://github.com/gitkong/FLWXPayManager)

#八、总结
- 1、内部实现代码都比较简单，这里就不作详细分析，Demo中都有相对于的注释，给个 star 支持支持~

- 2、封装的思路以及分析都已经详细说明了，如果大家有什么疑惑或者新的想法都可以留言给我,我都会一一回复！

- 3、**欢迎大家去[简书](http://www.jianshu.com/users/fe5700cfb223/latest_articles)关注我，喜欢就给个like，打赏也会厚脸无耻地收下，我会随时更新原创干货~**
