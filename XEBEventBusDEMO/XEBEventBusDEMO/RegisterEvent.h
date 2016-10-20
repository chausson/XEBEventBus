//
//  RegisterEvent.h
//  XEBEventBusDEMO
//
//  Created by Chausson on 16/10/20.
//  Copyright © 2016年 Chausson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterEvent : NSObject
@property (copy ,nonatomic) NSString *account;
@property (copy ,nonatomic) NSString *password;
@property (strong ,nonatomic) id responser;
@end
