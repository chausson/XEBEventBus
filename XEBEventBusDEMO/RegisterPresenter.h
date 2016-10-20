//
//  RegisterPresenter.h
//  XEBEventBusDEMO
//
//  Created by Chausson on 16/10/20.
//  Copyright © 2016年 Chausson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XEBEventBus.h"
#import "XEBSubscriber.h"

@class StartViewController;

@interface RegisterPresenter : NSObject<XEBSubscriber>

- (instancetype)initWithOwner:(StartViewController *)controller;


@end
