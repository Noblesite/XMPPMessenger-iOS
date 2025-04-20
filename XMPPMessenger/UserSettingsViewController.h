//
//  UserSettingsViewController.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 8/30/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UserSettings.h"
#import "AppDelegate.h"

@interface UserSettingsViewController : UIViewController <UIImagePickerControllerDelegate>


@property (strong, nonatomic) UserSettings *userSettings;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) IBOutlet UIPickerView *fontSizePicker;
@property (strong, nonatomic) IBOutlet UILabel *fontSizeLabel;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) IBOutlet UIButton *selectPictureButton;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

- (IBAction)openCameraRoll:(id)sender;

@end
