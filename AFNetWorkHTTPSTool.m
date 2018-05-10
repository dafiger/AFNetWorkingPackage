//
//  AFNetWorkHTTPSTool.m
//  App_iOS
//
//  Created by Dafiger on 16/12/26.
//  Copyright © 2016年 wpf. All rights reserved.
//

#import "AFNetWorkHTTPSTool.h"
#import "AFNetworking.h"

// 测试
#define BasePathUrlStr_test @"http://"
// 发布
#define BasePathUrlStr @"http://"

@interface AFNetWorkHTTPSTool()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation AFNetWorkHTTPSTool

#pragma mark - 获取单例
+ (AFNetWorkHTTPSTool *)sharedClient
{
    static AFNetWorkHTTPSTool *sharedManagerInstance = nil;
    static dispatch_once_t predicate = 0;
    dispatch_once( &predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

- (id)init
{
    self = [super init];
    if(self){
        [self initManager];
    }
    return self;
}

#pragma mark - 初始化AFHTTPSessionManager
- (void)initManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 设置请求格式 AFJSONRequestSerializer / AFHTTPRequestSerializer
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 设置请求超时时间
    [manager.requestSerializer setTimeoutInterval:6.0f];
    // 设置请求编码方式
    [manager.requestSerializer setStringEncoding:NSUTF8StringEncoding];
    // 设置请求头报文格式
    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"OS"];
    [manager.requestSerializer setValue:ThisAppVersion forHTTPHeaderField:@"Ver"];
    // 设置响应格式 AFJSONResponseSerializer / AFHTTPResponseSerializer
    // manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置响应类型
    NSSet *setting = [NSSet setWithObjects:@"application/json",@"application/x-javascript",@"application/javascript",@"text/json",@"text/javascript",@"text/html",@"text/css",@"text/plain", nil];
    [manager.responseSerializer setAcceptableContentTypes:setting];
    
    self.manager = manager;
}

#pragma mark - 2、获取奖励列表
- (void)reqAwardListSuccess:(void(^)(id response, BOOL verify))success
                    failure:(void(^)(id errorStr))failure
               showProgress:(BOOL)showProgress
                    showMsg:(BOOL)showMsg
{
    NSDictionary *paramDic = @{@"command":@"AwardType",
                               @"ver":ThisAppVersion,
                               @"device":@"iOS"};
    [self req_PostWithUrlStr:BasePathUrlStr
                    paramDic:paramDic
                     success:success
                     failure:failure
                showProgress:showProgress
                     showMsg:showMsg];
}

#pragma mark - 1、请求广告数据
- (void)adsReqWithSuccess:(void(^)(id response, BOOL verify))success
                  failure:(void(^)(id errorStr))failure
{
    NSString *urlString = @"";
    NSString *numStr = [ToolForCoding generateTradeNO:9];
    [self req_GetWithUrlStr:urlString
                   paramDic:@{@"v":numStr}
                    success:success
                    failure:failure
               showProgress:NO
                    showMsg:NO];
}

#pragma mark - 请求框架
#pragma mark Post请求
- (void)req_PostWithUrlStr:(NSString *)urlStr
                  paramDic:(NSDictionary *)paramDic
                   success:(void(^)(id response, BOOL verify))success
                   failure:(void(^)(id error))failure
              showProgress:(BOOL)isShowProgress
                   showMsg:(BOOL)isShowMsg
{
    if (isShowProgress) {
        [MBProgressHUD showInWindow];
    }else{
        [MBProgressHUD hideFromWindow];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self.manager POST:url.absoluteString
       parameters:paramDic
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [MBProgressHUDTool hideFromWindow];
         NSString *responseStr = [[NSString alloc] initWithData:responseObject
                                                       encoding:NSUTF8StringEncoding];
#ifdef App_Log
         NSLog(@"POST请求成功接口:%@，数据--->:%@",[paramDic objectForKey:@"command"], responseStr);
#endif
         if (StringIsEmpty(responseStr)) {
             if (isShowMsg) {
                 [SVProgress showInWindowText:@"返回数据为空"];
             }
             success(nil, 0);
         }else{
             NSDictionary *responseDic = [ToolForCoding jsonStrToObject:responseStr];
             if (DictIsEmpty(responseDic)) {
                 if (isShowMsg) {
                     [SVProgressHUD showInWindowText:@"返回数据格式错误"];
                 }
                 success(nil, 0);
             }else{
                 success(responseDic, 1);
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [MBProgressHUD hideFromWindow];
#ifdef App_Log
         NSLog(@"POST请求出错接口:%@，原因-->:%@",[paramDic objectForKey:@"command"], [error localizedDescription]);
#endif
         if (isShowMsg) {
             [SVProgressHUD showInWindowText:@"请求失败，请稍后重试"];
         }
         failure(error);
     }];
}

#pragma mark Get请求
- (void)req_GetWithUrlStr:(NSString *)urlStr
                 paramDic:(NSDictionary *)paramDic
                  success:(void(^)(id response, BOOL verify))success
                  failure:(void(^)(id error))failure
             showProgress:(BOOL)isShowProgress
                  showMsg:(BOOL)isShowMsg
{
    if (isShowProgress) {
        [MBProgressHUD showInWindow];
    }else{
        [MBProgressHUD hideFromWindow];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self.manager GET:url.absoluteString
      parameters:paramDic
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [MBProgressHUD hideFromWindow];
         NSString *responseStr = [[NSString alloc] initWithData:responseObject
                                                       encoding:NSUTF8StringEncoding];
#ifdef App_Log
         NSLog(@"Get请求成功接口:%@，数据-->:%@",[paramDic objectForKey:@"command"], responseStr);
#endif
         if (StringIsEmpty(responseStr)) {
             if (isShowMsg) {
                 [SVProgressHUD showInWindowText:@"返回数据为空"];
             }
             success(nil, 0);
         }else{
             NSDictionary *responseDic = [ToolForCoding jsonStrToObject:responseStr];
             if (DictIsEmpty(responseDic)) {
                 if (isShowMsg) {
                     [SVProgressHUD showInWindowText:@"返回数据格式错误"];
                 }
                 success(nil, 0);
             }else{
                 success(responseStr, 1);
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [MBProgressHUD hideFromWindow];
#ifdef App_Log
         NSLog(@"Get请求出错接口:%@，原因-->:%@",[paramDic objectForKey:@"command"], [error localizedDescription]);
#endif
         if (isShowMsg) {
             [SVProgressHUD showInWindowText:@"请求失败，请稍后重试"];
         }
         failure(error);
     }];
}

#pragma mark GET HTTPS请求
- (void)httpsReq_GetWithUrlStr:(NSString *)urlStr
                      paramDic:(NSDictionary *)paramDic
                       success:(void(^)(id response, BOOL verify))success
                       failure:(void(^)(id error))failure
                  showProgress:(BOOL)isShowProgress
                       showMsg:(BOOL)isShowMsg
{
    if (isShowProgress) {
        [MBProgressHUD showInWindow];
    }else{
        [MBProgressHUD hideFromWindow];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = NO;
    securityPolicy.validatesDomainName = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // >>>>>>>>>>HTTPS设置
    manager.securityPolicy = securityPolicy;
    
    // 设置请求格式 AFJSONRequestSerializer / AFHTTPRequestSerializer
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 设置请求超时时间
    [manager.requestSerializer setTimeoutInterval:6.0f];
    // 设置请求编码方式
    [manager.requestSerializer setStringEncoding:NSUTF8StringEncoding];
    // 设置请求头报文格式
    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"OS"];
    [manager.requestSerializer setValue:ThisAppVersion forHTTPHeaderField:@"Ver"];
    // 设置响应格式 AFJSONResponseSerializer / AFHTTPResponseSerializer
    // manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置响应类型
    NSSet *setting = [NSSet setWithObjects:@"application/json",@"application/x-javascript",@"application/javascript",@"text/json",@"text/javascript",@"text/html",@"text/css",@"text/plain", nil];
    [manager.responseSerializer setAcceptableContentTypes:setting];
    
    [manager GET:url.absoluteString
      parameters:paramDic
        progress:^(NSProgress * _Nonnull downloadProgress)
     {
         if (isShowProgress) {
             [MBProgressHUDTool showInWindow];
         }else{
             [MBProgressHUDTool hideFromWindow];
         }
         // NSLog(@"请求完成度:--->%f",downloadProgress.fractionCompleted);
         // NSLog(@"请求完成数量:--->%lli",downloadProgress.completedUnitCount);
         // NSLog(@"请求的总数量:--->%lli",downloadProgress.totalUnitCount);
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [MBProgressHUD hideFromWindow];
         NSString *responseStr = [[NSString alloc] initWithData:responseObject
                                                       encoding:NSUTF8StringEncoding];
#ifdef App_Log
         NSLog(@"HTTPS_GET请求成功--->:\n%@",responseStr);
#endif
         if (StringIsEmpty(responseStr)) {
             if (isShowMsg) {
                 [SVProgressHUD showInWindowText:@"返回数据为空"];
             }
             success(nil, 0);
         }else{
             NSDictionary *responseDic = [ToolForCoding jsonStrToObject:responseStr];
             if (DictIsEmpty(responseDic)) {
                 if (isShowMsg) {
                     [SVProgressHUD showInWindowText:@"返回数据格式错误"];
                 }
                 success(nil, 0);
             }else{
                 success(responseStr, 1);
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [MBProgressHUD hideFromWindow];
#ifdef App_Log
         NSLog(@"HTTPS_GET请求出错的原因--->:%@",[error localizedDescription]);
#endif
         if (isShowMsg) {
             [SVProgressHUD showInWindowText:@"请求失败，请稍后重试"];
         }
         failure(error);
     }];
}

#pragma mark POST HTTPS请求
- (void)httpsReq_POSTWithUrlStr:(NSString *)urlStr
                       paramDic:(NSDictionary *)paramDic
                        success:(void(^)(id response, BOOL verify))success
                        failure:(void(^)(id error))failure
                   showProgress:(BOOL)isShowProgress
                        showMsg:(BOOL)isShowMsg
{
    if (isShowProgress) {
        [MBProgressHUD showInWindow];
    }else{
        [MBProgressHUD hideFromWindow];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = NO;
    securityPolicy.validatesDomainName = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // >>>>>>>>>>HTTPS设置
    manager.securityPolicy = securityPolicy;
    
    // 设置请求格式 AFJSONRequestSerializer / AFHTTPRequestSerializer
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 设置请求超时时间
    [manager.requestSerializer setTimeoutInterval:6.0f];
    // 设置请求编码方式
    [manager.requestSerializer setStringEncoding:NSUTF8StringEncoding];
    // 设置请求头报文格式
    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"OS"];
    [manager.requestSerializer setValue:ThisAppVersion forHTTPHeaderField:@"Ver"];
    // 设置响应格式 AFJSONResponseSerializer / AFHTTPResponseSerializer
    // manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置响应类型
    NSSet *setting = [NSSet setWithObjects:@"application/json",@"application/x-javascript",@"application/javascript",@"text/json",@"text/javascript",@"text/html",@"text/css",@"text/plain", nil];
    [manager.responseSerializer setAcceptableContentTypes:setting];
    
    [manager POST:url.absoluteString
       parameters:paramDic
         progress:^(NSProgress * _Nonnull uploadProgress)
     {
         if (isShowProgress) {
             [MBProgressHUD showInWindow];
         }else{
             [MBProgressHUD hideFromWindow];
         }
         // NSLog(@"请求完成度:--->%f",downloadProgress.fractionCompleted);
         // NSLog(@"请求完成数量:--->%lli",downloadProgress.completedUnitCount);
         // NSLog(@"请求的总数量:--->%lli",downloadProgress.totalUnitCount);
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [MBProgressHUD hideFromWindow];
         NSString *responseStr = [[NSString alloc] initWithData:responseObject
                                                       encoding:NSUTF8StringEncoding];
#ifdef App_Log
         NSLog(@"HTTPS_POST请求成功--->:\n%@",responseStr);
#endif
         if (StringIsEmpty(responseStr)) {
             if (isShowMsg) {
                 [SVProgressHUD showInWindowText:@"返回数据为空"];
             }
             success(nil, 0);
         }else{
             NSDictionary *responseDic = [ToolForCoding jsonStrToObject:responseStr];
             if (DictIsEmpty(responseDic)) {
                 if (isShowMsg) {
                      [SVProgressHUD showInWindowText:@"返回数据格式错误"];
                 }
                 success(nil, 0);
             }else{
                 success(responseStr, 1);
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [MBProgressHUD hideFromWindow];
#ifdef App_Log
         NSLog(@"HTTPS_POST请求出错的原因--->:%@",[error localizedDescription]);
#endif
         if (isShowMsg) {
             [SVProgressHUD showInWindowText:@"请求失败，请稍后重试"];
         }
         failure(error);
     }];
}

#pragma mark 配置请求HTTPS
- (void)configHTTPS
{
    // 1.SSLPinningMode 定义了https连接时，如何去校验服务器端给予的证书。
    // AFSSLPinningModeNone: 代表客户端无条件地信任服务器端返回的证书。
    // AFSSLPinningModePublicKey: 代表客户端会将服务器端返回的证书与本地保存的证书中，
    // PublicKey的部分进行校验；如果正确，才继续进行。
    // AFSSLPinningModeCertificate: 代表客户端会将服务器端返回的证书和本地保存的证书中的所有内容，
    // 包括PublicKey和证书部分，全部进行校验；如果正确，才继续进行。
    // 2.pinnedCertificates
    // pinnedCertificates 就是用来校验服务器返回证书的证书。通常都保存在mainBundle 下。
    // 通常默认情况下，AFNetworking会自动寻找在mainBundle的根目录下所有的.cer文件
    // 并保存在pinnedCertificates数组里，以校验服务器返回的证书。
    // 3.allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    // securityPolicy.allowInvalidCertificates = YES;
    // 4.validatesDomainName 是否需要验证域名，默认为YES；
    // 假如证书的域名与你请求的域名不一致，需把该项设置为NO；
    // 如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    // 置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。
    // 因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，
    // 那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    // 如置为NO，建议自己添加对应域名的校验逻辑。
    // 5.validatesCertificateChain 是否验证整个证书链，默认为YES
    // 设置为YES，会将服务器返回的Trust Object上的证书链与本地导入的证书进行对比，这就意味着，假如你的证书链是这样的：
    // GeoTrust Global CA
    // Google Internet Authority G2
    // *.google.com
    // 那么，除了导入*.google.com之外，还需要导入证书链上所有的CA证书（GeoTrust Global CA, Google Internet Authority G2）；
    // 如是自建证书的时候，可以设置为YES，增强安全性；
    // 假如是信任的CA所签发的证书，则建议关闭该验证，因为整个证书链一一比对是完全没有必要（请查看源代码）；
    // securityPolicy.validatesCertificateChain = NO;
    
    // >>>>>>>>>>安全证书配置
    // NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
    // NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // NSLog(@"%@", cerData);
    // AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSArray alloc] initWithObjects:cerData, nil]];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = NO;
    securityPolicy.validatesDomainName = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // >>>>>>>>>>HTTPS设置
    manager.securityPolicy = securityPolicy;
    
    // 设置请求格式 AFJSONRequestSerializer / AFHTTPRequestSerializer
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 设置请求超时时间
    [manager.requestSerializer setTimeoutInterval:6.0f];
    // 设置请求编码方式
    [manager.requestSerializer setStringEncoding:NSUTF8StringEncoding];
    // 设置请求头报文格式
    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"OS"];
    [manager.requestSerializer setValue:ThisAppVersion forHTTPHeaderField:@"Ver"];
    // 设置响应格式 AFJSONResponseSerializer / AFHTTPResponseSerializer
    // manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置响应类型
    NSSet *setting = [NSSet setWithObjects:@"application/json",@"application/x-javascript",@"application/javascript",@"text/json",@"text/javascript",@"text/html",@"text/css",@"text/plain", nil];
    [manager.responseSerializer setAcceptableContentTypes:setting];
}

- (void)AFNetworkStatus
{
    // 创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,      未知
     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
     };
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //这里是监测到网络改变的block  可以写成switch方便
        //在里面可以随便写事件
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络状态");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝数据网");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi网络");
                break;
            default:
                break;
        }
    }] ;
}

- (NSString *)getNetWorkStates
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"无网络";
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                    state = @"WIFI";
                    break;
                default:
                    break;
            }
        }
    }
    //根据状态选择
    return state;
}

@end
