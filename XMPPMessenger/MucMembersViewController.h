//
//  CreateMucViewController.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 5/1/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CreateMucCell.h"

@import XMPPFramework;


@interface MucMembersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate>{
    
      NSFetchedResultsController *fetchedResultsController;
    
    
}

@property (strong, nonatomic) NSString *mucID;
@property (strong, nonatomic) NSString *viewTitle;
@property (strong, nonatomic) NSMutableDictionary *allMucMememberList;
@property (strong, nonatomic) NSMutableDictionary *currentMucmemeberList;
@property (strong, nonatomic) NSArray *memeberList;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
