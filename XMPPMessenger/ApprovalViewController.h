//
//  ApprovalViewController.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 6/28/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface ApprovalViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIPickerView *approvalPicker;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
- (IBAction)sendButton:(id)sender;

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *currentJabberID;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) NSString *messageBody;
@property (strong, nonatomic) NSString *myJabberID;

@end
