//
//  RegisterViewController.m
//  XEBEventBusDEMO
//
//  Created by Chausson on 16/10/20.
//  Copyright © 2016年 Chausson. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)regist:(UIButton *)sender {

    if (self.account.text.length > 0  && self.password.text.length > 0) {
        RegisterEvent *event = [RegisterEvent new];
        event.account = self.account.text;
        event.responser = self;
        event.password = self.password.text;
        [[XEBEventBus defaultEventBus] postEvent:event];
    }

}




@end
