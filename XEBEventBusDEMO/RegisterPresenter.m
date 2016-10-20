//
//  RegisterPresenter.m
//  XEBEventBusDEMO
//
//  Created by Chausson on 16/10/20.
//  Copyright © 2016年 Chausson. All rights reserved.
//

#import "RegisterPresenter.h"
#import "StartViewController.h"
#import "RegisterEvent.h"
@interface RegisterPresenter()
@property (weak ,nonatomic) StartViewController *onwer;
@end
@implementation RegisterPresenter

- (instancetype)initWithOwner:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        [[XEBEventBus defaultEventBus] registerSubscriber:self];
        _onwer = (StartViewController *)controller;
    }
    return self;
}
+ (NSArray<Class>* _Nonnull)handleableEventClasses{
    return @[[RegisterEvent class]];

}
- (void)onEvent:(id)event{
    RegisterEvent *registerEvent =(RegisterEvent *)event;
    UIViewController *responser =  registerEvent.responser;
    [self.onwer.registerBtn setTitle:@"注册成功" forState:UIControlStateNormal];
    [responser.navigationController popViewControllerAnimated:YES];

}
@end
