//
//  ViewController.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 4/19/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "AppDelegate.h"

#import <foundation/foundation.h>

@import XMPPFramework;


@interface LoginViewController : UIViewController<UITextFieldDelegate,NSXMLParserDelegate,NSURLConnectionDelegate>{
    
    
 
}



@property (strong, nonatomic) IBOutlet UIImageView *ldapIcon;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *passWord;
@property (strong, nonatomic) IBOutlet UITextField *userNameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) IBOutlet UILabel *msgField;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicator;
@property (nonatomic, retain) NSString *faultCodeField;
@property (nonatomic, assign) BOOL isLogOut;

    
- (IBAction)userNameEnter:(id)sender;
- (IBAction)passwordEnter:(id)sender;

- (IBAction)logInButton:(id)sender;




@end

