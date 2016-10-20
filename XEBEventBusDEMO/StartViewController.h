//
//  StartViewController.h
//  XEBEventBusDEMO
//
//  Created by Chausson on 16/10/20.
//  Copyright © 2016年 Chausson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterPresenter.h"

@interface StartViewController : UIViewController

@property (strong , nonatomic )RegisterPresenter *presenter;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

