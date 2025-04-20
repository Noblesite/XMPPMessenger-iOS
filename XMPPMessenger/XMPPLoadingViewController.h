//
//  XMPPLoadingViewController.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 9/26/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMPPLoadingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (assign, nonatomic) NSInteger logoCounter;
@property (strong, nonatomic) NSTimer *logoTimer;
@property (strong, nonatomic) NSTimer *labelUpdateTimer;
@property (assign, nonatomic) NSInteger labelUpdateCounter;
@property (assign, nonatomic) BOOL shouldRotate;

@property (strong, nonatomic) IBOutlet UILabel *connectionUpdaterLabel;

@end
