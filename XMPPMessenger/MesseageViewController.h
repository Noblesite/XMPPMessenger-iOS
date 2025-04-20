//
//  MesseageViewController.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 4/21/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <UIKit/UIKit.h>
@import XMPPFramework;
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "OutGoingMsgCell.h"
#import "IncomingMsgCell.h"
#import "UserSettings.h"
#import "BuddyCustomePictures.h"

@interface MesseageViewController : UIViewController<UIApplicationDelegate,UITableViewDelegate,UITableViewDataSource, UINavigationBarDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>{
    
    
    CGRect originalmessageInputFrame;
    CGSize keyboardSize;
    CGRect keyboardFrame;
    double initialTVHeight;
    
    NSInteger totalMessageCount;
    NSInteger currentMessageCount;
    double messageInputYorigin;
    


}

@property (strong, nonatomic) UserSettings *userSettings;

//- (IBAction)hitEnter:(id)sender;
- (IBAction)sendButtonEntered:(id)sender;

//@property (strong, nonatomic) IBOutlet UITextView *messeageField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextView *messageInput;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) NSString *myJID;
@property (strong, nonatomic) NSString *toSendToJID;
@property (strong, nonatomic) NSMutableArray *messegesForCurrentView;
@property (strong, nonatomic) NSMutableArray *respondedMessageIDList;
@property (strong, nonatomic) NSMutableDictionary *pebblePictures;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) NSInteger totalMsgCount;
@property (strong, nonatomic) UIImage *myImage;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGestureRecognizer;

@end
