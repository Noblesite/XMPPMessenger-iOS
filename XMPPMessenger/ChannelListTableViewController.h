//
//  MesseageUserTableTableViewController.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 4/20/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//
#import "AppDelegate.h"

#import <UIKit/UIKit.h>
@import XMPPFramework;
#import "ChannelListCell.h"
#import "MesseageViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CoreData/CoreData.h>
#import <AudioToolbox/AudioServices.h>


@interface ChannelListTableViewController : UITableViewController<UIApplicationDelegate,NSFetchedResultsControllerDelegate,XMPPStreamDelegate,XMPPRosterDelegate, UINavigationBarDelegate>{
    
    NSFetchedResultsController *fetchedResultsController;
  
}


@property (strong, nonatomic) NSMutableDictionary *myMucList;
@property (strong, nonatomic) NSMutableDictionary *mucMesseageCounter;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;




@end
