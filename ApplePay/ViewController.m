//
//  ViewController.m
//  ApplePay
//
//  Created by 谢小御 on 16/2/29.
//  Copyright © 2016年 谢小御. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>
#import <AddressBook/AddressBook.h>
@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


/**
 *  和后台交互代理方法
 *
 *  @param controller 推出的控制器
 *  @param payment    订单的支付信息,包含订单的地址,订单的token
 *  @param completion 用这个block块用来指定显示的支付结果
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    //支付信息
    NSString *cityName = payment.billingContact.postalAddress.city;
    //信息验证
    PKPaymentToken *payToken = payment.token;
    //支付凭据
    PKContact *billingContact = payment.billingContact;//账单信息
    //将自己的信息和token信息发送到服务器,由自己的服务器返回结果
    PKPaymentAuthorizationStatus status = PKPaymentAuthorizationStatusSuccess;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //将变量的值显示在界面上
        completion(status);
    });
}


//支付完成代理
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//支付按钮点击事件
- (IBAction)buttonDidClicked:(id)sender {
    //设备判断是否支持
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        NSLog(@"设备不支持");
        return;
    }
    //创建支付请求对象
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    //配置商品
    PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem summaryItemWithLabel:@"支付对象1" amount:([NSDecimalNumber decimalNumberWithString:@"0.01"])];
    PKPaymentSummaryItem *item2 = [PKPaymentSummaryItem summaryItemWithLabel:@"支付对象2" amount:([NSDecimalNumber decimalNumberWithString:@"0.02"])];
    //将商品添加到request,置顶界面上显示那些商品
    request.paymentSummaryItems = @[item1,item2];
    //指定国家编码  中国
    request.countryCode = @"CN";
    //指定币种  RMB
    request.currencyCode = @"CNY";
    //指定网联支付类型  支付的卡
    request.supportedNetworks = @[PKPaymentNetworkVisa,PKPaymentNetworkMasterCard,PKPaymentNetworkChinaUnionPay];
    //支付证书ID
    request.merchantIdentifier = @"merchant.xiexiaoyu.app";
    //范围 支付规范EMV
    request.merchantCapabilities = PKMerchantCapabilityEMV;
    
    //账单地址
    request.requiredBillingAddressFields = PKAddressFieldAll;
    //创建用于显示信息的控制器
    PKPaymentAuthorizationViewController *PKVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    //设置代理
    PKVC.delegate = self;
    if (!PKVC) {
        NSLog(@"出问题啦");
        /*
        //会抛出一个异常,始程序崩掉,少用
        @throw [NSException exceptionWithName:@"CQ_Error" reason:@"创建失败" userInfo:nil];
         */
        return;
    }
    //模态出控制器
    [self presentViewController:PKVC animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
