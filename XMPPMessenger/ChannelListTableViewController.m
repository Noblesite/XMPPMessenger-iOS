//
//  MesseageUserTableTableViewController.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 4/20/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "ChannelListTableViewController.h"



static const int ddLogLevel = XMPP_LOG_FLAG_ERROR;


@interface ChannelListTableViewController ()


@end

@implementation ChannelListTableViewController


@synthesize myMucList;
@synthesize mucMesseageCounter;
@synthesize navigationItem;




- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startPresenceObserver];
    myMucList = [[NSMutableDictionary alloc]init];
    mucMesseageCounter = [[NSMutableDictionary alloc]init];
    self.navigationItem.title = @"Online";
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self setLogOutButton];
  
  //  [self setupTheView];
    
   
}

// Allocate memeory to class properties & setup the View
- (void)setupTheView {
    
    myMucList = [[NSMutableDictionary alloc]init];
    mucMesseageCounter = [[NSMutableDictionary alloc]init];
    self.navigationItem.title = @"Online";
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self setLogOutButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (void)viewWillDisappear:(BOOL)animated {
    

}

- (void)viewWillAppear:(BOOL)animated  {

    [self.tableView reloadData];

}


- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*

// Get a list of memebers in our roster & add one more for the list we will inject

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [[[self fetchedResultsController] sections] count] + 1;
}
 
 */

// Get a list of memebers in our roster & add one more for the list we will inject

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 4;
}

// Titles for the table view for each section
- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
   
        switch (sectionIndex)
        {
            case 0  : return @"Channels";
            case 1  : return @"Available";
            case 2  : return @"Away";
            case 3  : return @"Offline";
           
        }
    
    
    return @"";
}

// number of rows in each section. counted by the presents state for each JID in our roster
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    
    // Pull the list of MUC's we are currently joined and count to find how many cell's are need
    // For section 0. This is what we are currently enjecting into the array from appleCore
    // Data object we get from the XMPPFramework
    myMucList = [[self appDelegate]myMucList];
    
    if(sectionIndex == 0){
        
        return myMucList.count;
        
    }
    
    // Section 1 is a list of aviable JID's
    if(sectionIndex==1){
        
        NSArray *avaiable = [self getChannelRosterList:0];
        
        return avaiable.count;
        
    }
    
    // Section 2 is a list of Away JID's
    if(sectionIndex==2){
        
        NSArray *away = [self getChannelRosterList:1];
        
        return away.count;
        
        
    }
    
    // section 3 is a list of offline JID's
    if(sectionIndex==3){
        
        
        NSArray *unavaiable = [self getChannelRosterList:2];
        
        return unavaiable.count;
        
        
    }
    
    return 0;
}

/*
// number of rows in each section. counted by the presents state for each JID in our roster
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
   
    // Pull the list of MUC's we are currently joined and count to find how many cell's are need
    // For section 0. This is what we are currently enjecting into the array from appleCore
    // Data object we get from the XMPPFramework
    myMucList = [[self appDelegate]myMucList];
 
    if(sectionIndex == 0){
        
        return myMucList.count;
        
    }
    
    // Section 1 is a list of aviable JID's
    if(sectionIndex==1){
        
        NSArray *sections = [[self fetchedResultsController] sections];
        
        if (sectionIndex < [sections count])
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
            
            return sectionInfo.numberOfObjects;
        }

       
    }
    
    // Section 2 is a list of Away JID's
    if(sectionIndex==2){
        
        NSArray *sections = [[self fetchedResultsController] sections];
        
        if (sectionIndex < [sections count])
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = sections[1];
            
            return sectionInfo.numberOfObjects;
        }
        
        
    }
    
    // section 3 is a list of offline JID's
    if(sectionIndex==3){
        
        
        NSArray *sections = [[self fetchedResultsController] sections];
        
        if (sectionIndex < [sections count])
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = sections[2];
            
            return sectionInfo.numberOfObjects;
        }
        
        
    }

    return 0;
}
*/

// Method to setup each cell based on row and index path
// We first use our custom array for the avaiable MUC's/Confrances. Then we decrement the index by one
// For the roster list object we get from the XMPPFramework
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ChannelListCell";
    
    ChannelListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ChannelListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    
    // Set for MUC/Confrance cells
    if(indexPath.section==0){
        
        switch (indexPath.row) {
            case 0:
                cell.userStatus.text = @"The Big Box";
                cell.statusImage.image = [UIImage imageNamed:@"Message.png"];
                cell.jabberId = [NSString stringWithFormat:@"%@",[myMucList objectForKey:@"STR"]];
                cell = [self setCounterInCell:cell jabberID:cell.jabberId];
                break;
                
            case 1:
                cell.userStatus.text = @"CSM";
                cell.statusImage.image = [UIImage imageNamed:@"Message.png"];
                cell.jabberId = [NSString stringWithFormat:@"%@",[myMucList objectForKey:@"CSM"]];
                cell = [self setCounterInCell:cell jabberID:cell.jabberId];
                break;
                
            case 2:
                
                cell.userStatus.text = @"MPU";
                cell.statusImage.image = [UIImage imageNamed:@"Message.png"];
                cell.jabberId = [NSString stringWithFormat:@"%@",[myMucList objectForKey:@"MPU"]];
                cell = [self setCounterInCell:cell jabberID:cell.jabberId];
                break;
                
            case 3:
                
                cell.userStatus.text = @"Managers";
                cell.statusImage.image = [UIImage imageNamed:@"Message.png"];
                cell.jabberId = [NSString stringWithFormat:@"%@",[myMucList objectForKey:@"MNG"]];
                cell = [self setCounterInCell:cell jabberID:cell.jabberId];
                break;
                
                
        }
        
    }
    
    // Setup for Online/Avaiable Cells for jid's
    if(indexPath.section==1){
        
        
        NSArray *avaiable = [self getChannelRosterList:0];
    
        
        cell.userStatus.text = [avaiable objectAtIndex:indexPath.row];
        
        cell.jabberId = [avaiable objectAtIndex:indexPath.row];
        
        cell.statusImage.image = [UIImage imageNamed:@"greenDot.png"];
        
        cell = [self setCounterInCell:cell jabberID:cell.jabberId];
        
        
    }
    
    // Setup for Away Cells for jid's
    if(indexPath.section==2){
        
        
        NSArray *away = [self getChannelRosterList:1];
        
        cell.userStatus.text =  [away objectAtIndex:indexPath.row];
        
        cell.jabberId = [away objectAtIndex:indexPath.row];
        
        cell.statusImage.image = [UIImage imageNamed:@"orangeDot.png"];
        
        cell = [self setCounterInCell:cell jabberID:cell.jabberId];
        
    }
    
    
    
    // Setup for offline Cells for jid's
    if(indexPath.section==3){
        
        
        
        NSArray *unavaiable = [self getChannelRosterList:2];
        
        cell.userStatus.text = [unavaiable objectAtIndex:indexPath.row];
        
        cell.jabberId = [unavaiable objectAtIndex:indexPath.row];
        
        cell.statusImage.image = [UIImage imageNamed:@"redDot.png"];
        
        cell = [self setCounterInCell:cell jabberID:cell.jabberId];
        
        
        
        
    }
    
    return cell;
}
 /*
// Method to setup each cell based on row and index path
// We first use our custom array for the avaiable MUC's/Confrances. Then we decrement the index by one
// For the roster list object we get from the XMPPFramework
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ChannelListCell";
    
    ChannelListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ChannelListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:CellIdentifier];
    }

   
   // Set for MUC/Confrance cells
    if(indexPath.section==0){
    
    switch (indexPath.row) {
        case 0:
                cell.userStatus.text = @"The Big Box";
                cell.statusImage.image = [UIImage imageNamed:@"Message.png"];
                cell.jabberId = [NSString stringWithFormat:@"%@",[myMucList objectForKey:@"STR"]];
                cell = [self setCounterInCell:cell jabberID:cell.jabberId];
            break;
        
        case 1:
                cell.userStatus.text = @"CSM";
                cell.statusImage.image = [UIImage imageNamed:@"Message.png"];
                cell.jabberId = [NSString stringWithFormat:@"%@",[myMucList objectForKey:@"CSM"]];
                cell = [self setCounterInCell:cell jabberID:cell.jabberId];
            break;
            
        case 2:
            
                cell.userStatus.text = @"MPU";
                cell.statusImage.image = [UIImage imageNamed:@"Message.png"];
                cell.jabberId = [NSString stringWithFormat:@"%@",[myMucList objectForKey:@"MPU"]];
                cell = [self setCounterInCell:cell jabberID:cell.jabberId];
            break;
            
        case 3:
            
                cell.userStatus.text = @"Managers";
                cell.statusImage.image = [UIImage imageNamed:@"Message.png"];
                cell.jabberId = [NSString stringWithFormat:@"%@",[myMucList objectForKey:@"MNG"]];
                cell = [self setCounterInCell:cell jabberID:cell.jabberId];
            break;
            
    
        }
        
    }
    
    // Setup for Online/Avaiable Cells for jid's
    if(indexPath.section==1){
    
            
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        
            
         XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:newIndexPath];
            
            cell.userStatus.text = user.jidStr;
        
            cell.jabberId = user.jidStr;
        
            cell.statusImage.image = [UIImage imageNamed:@"greenDot.png"];
                    
            cell = [self setCounterInCell:cell jabberID:cell.jabberId];
                       
            
        }
    
    // Setup for Away Cells for jid's
    if(indexPath.section==2){
        
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    
        
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:newIndexPath];
        
        cell.userStatus.text = user.jidStr;
        cell.jabberId = user.jidStr;
        
        cell.statusImage.image = [UIImage imageNamed:@"redDot.png"];
        
        cell = [self setCounterInCell:cell jabberID:cell.jabberId];
        
        }
        
        
    
    // Setup for offline Cells for jid's
    if(indexPath.section==3){
        
     
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
     
        
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:newIndexPath];
        
        cell.userStatus.text = user.jidStr;
        cell.jabberId = user.jidStr;
        cell.statusImage.image = [UIImage imageNamed:@"redDot.png"];
        
        cell = [self setCounterInCell:cell jabberID:cell.jabberId];
                    
    
        
        
    }

    return cell;
}
*/

// We use didSelectRowAtIndext to trigger moving to the next middle view/confrance/muc or
// JID to JID messageing. Also used to clear the badge counter label
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    ChannelListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self clearRemoveCellBadge:cell];
    
    [[self appDelegate] setMMDCCenterViewWithJID:cell.jabberId];
}

// Remove observers running on none UI Thread
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

/*
// Pulles the appleCore Data object that we use to define most of our table view
- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1, sd2];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);

        }
        
    }
    
    return fetchedResultsController;
}

 */

/*
// When the roster has changed stored in the app Delegate we are notified to update the UI
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  
    [self.tableView reloadData];
    
}
*/


// Method used to clear the missed message badges
- (void)clearRemoveCellBadge:(ChannelListCell*)cell {

    [[self appDelegate] clearMessageCounter:cell.jabberId];
    
}

// Method to set the counter and configure the missed message badges
- (ChannelListCell*)setCounterInCell:(ChannelListCell*)cell jabberID:(NSString*)jid {
    
    mucMesseageCounter = [[self appDelegate] missedMucMesseageCounter];
    

    
    if([mucMesseageCounter objectForKey:cell.jabberId]){
        
        NSNumber *counter = [mucMesseageCounter objectForKey:cell.jabberId];
        
        if(counter > 0){
            
            [cell.badge setHidden:NO];
            cell.badge.text = [NSString stringWithFormat:@"%@",counter];
            cell.badge.textColor = [UIColor whiteColor];
            cell.badge.textAlignment = NSTextAlignmentCenter;
            cell.badge.layer.cornerRadius = 12.0f;
            cell.badge.layer.backgroundColor = [UIColor redColor].CGColor;
            cell.badge.clipsToBounds = YES;
        
            
        }else{
            
            [cell.badge setHidden:YES];
        }
        
    }else{
        
        [cell.badge setHidden:YES];

    }

    return cell;

}

// Method used to add and setup the logout & settings button in the views navigation item
- (void)setLogOutButton {
    

    UIBarButtonItem *leftLogOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    
    navigationItem.leftBarButtonItem = leftLogOutButton;
    navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    UIImage *menuImage = [UIImage imageNamed:@"settingsIcon.png"];
    CGRect frame = CGRectMake(100, 100, 30, 30);
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:frame];
    
    [rightButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(settingsButton)
          forControlEvents:UIControlEventTouchUpInside];
    [rightButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *rightSlideButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    navigationItem.rightBarButtonItem = rightSlideButton;
    
    
}

// Method that calls the logoutofXMPP public method in the App Delegate
- (void)logOut{
    
    [[self appDelegate] logOutofXMPP];
    
}

// Settings button Method. Currently not useds odvisoutly - Rick :p
- (void)settingsButton{
    
    [[self appDelegate] prsentSettingsViewInterface];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for keeping, updating and removeing roster buddy presences
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray*)getChannelRosterList:(NSInteger)channel{
    
    
    NSMutableDictionary *channelList = [[NSMutableDictionary alloc]initWithDictionary:[[self appDelegate]getRosterBuddyPresenceList]];
    
    NSMutableDictionary *channelTmp = [[NSMutableDictionary alloc]init];
   
    
    switch (channel) {
        case 0:
            if([channelList objectForKey:@"available"]){
                
                channelTmp = [channelList objectForKey:@"available"];
            
            }
            break;
            
        case 1:
            if([channelList objectForKey:@"away"]){
                
                channelTmp = [channelList objectForKey:@"away"];
                
            }
            break;
            
        case 2:
            if([channelList objectForKey:@"unavailable"]){
                
                channelTmp = [channelList objectForKey:@"unavailable"];
                
            }
            break;
        
    }
    
    NSArray *returnChannel = [channelTmp allKeys];
    
    return returnChannel;
    
}

- (void)tableDataChangeReload{
    
    [self.tableView reloadData];
    
}

- (void)startPresenceObserver {
    
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDataChangeReload) name:@"buddyPresenceChanged" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDataChangeReload) name:@"missedMessage" object:nil];
    
    
}

@end
