//
//  MesseageViewController.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 4/21/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "MesseageViewController.h"

@interface MesseageViewController ()

@end

static const int pullMessagesBy = 20;

@implementation MesseageViewController



@synthesize toSendToJID;
@synthesize messageInput;
@synthesize myJID;
@synthesize messegesForCurrentView;
@synthesize respondedMessageIDList;
@synthesize tableView;
@synthesize refreshControl;
@synthesize navigationBar;
@synthesize navigationItem;
@synthesize totalMsgCount;
@synthesize pebblePictures;
@synthesize myImage;
@synthesize sendButton;
@synthesize swipeGestureRecognizer;
@synthesize userSettings;

#define kOFFSET_FOR_KEYBOARD 250.0
#define isKeyboardOrigin 0




- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resizeViewForDevice];
    
    [self setupViewAndProperties];
    
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated  {
   
    userSettings = [[UserSettings alloc]userSettings:[[self appDelegate]userName]];
    
    messageInputYorigin = isKeyboardOrigin;
    
    [self checkToSendTo];
   //Set message Counter to Zero
    currentMessageCount = 0;
    
    // alloc mem for pebble Pic's
    pebblePictures = [[NSMutableDictionary alloc]init];
    
    // set myImage to Null
    myImage = NULL;
    
    // setup for textView
    [self textViewConfiguration];
    
    //Setup Observers for reciving new messsages
    [self startObservers];
    
    //get all messages from Apple CoreData objects
    [self getMesseages];
    
    
    
}
// Method for taking care of random tasks at the start of the view
- (void)setupViewAndProperties {
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    messegesForCurrentView = [[NSMutableArray alloc]init];
    
    [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    respondedMessageIDList = [[NSMutableArray alloc]init];
    
    [self initializeTablePullDown];
    [self setSlideMenuButtons];
    [self setTitlefromToJID];
    
}



- (void)checkToSendTo{
    
 
    
}
// Remove all observers not running on the UI thread
- (void)viewWillDisappear:(BOOL)animated {
    

    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

// Get all past messages & parce them by JID and amount of messages to keep in mem
- (void)getMesseages {
    
    
   
    // Check to make sure we are connected to the server first. This is for QA settings.
    // If not connected, pulling the messages from coreData will produce a null for the Array and
    // Cause the applicaiton to crash
    BOOL success = [[self appDelegate]isXmppConnected];
    if(success){
        
        NSMutableDictionary  *allPastMesseages = [[NSMutableDictionary alloc]init];
        allPastMesseages = [[self appDelegate]getArchivedMesseages];
        
        
        if([allPastMesseages objectForKey:toSendToJID]){
            
            
            // Get them messages for the JID we are currently messaging
            [messegesForCurrentView removeAllObjects];
            
            messegesForCurrentView = [allPastMesseages objectForKey:toSendToJID];
            
            totalMsgCount = messegesForCurrentView.count;
            // Cap the amount of messages we are keeping in memeory and discard the rest
            messegesForCurrentView = [self setInitialNumberOfMessages:messegesForCurrentView];
            
            [self.tableView reloadData];
           
            [self moveTableViewToBottomCell];
            
        }else{
            
          
            
        }
        
        
    }else{
        
   
    }
}



// Pulling the initial set of messages. Only called once per presnting the view
- (NSMutableArray*)setInitialNumberOfMessages:(NSMutableArray*)messages{
    
   
    totalMessageCount = messages.count;
    currentMessageCount = pullMessagesBy;
    
    // Check to make sure the amount of messages we currently have & are about to dispaly are more then
    // our desired amount. If not to set the amount of messages to the amount we have had retured to us
    // so as an example if we have only 10 messages but want 20 to make what we want to be 10
    if(currentMessageCount > totalMessageCount){
        
        currentMessageCount = totalMessageCount;
    }
    
    NSMutableArray *newMessages = [[messages subarrayWithRange:NSMakeRange(([messages count]-currentMessageCount), currentMessageCount)] mutableCopy];
    
    return newMessages;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for table refresh i.e. get more messages
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Setup the pulldown on the table view to refesh event & to pull the next set of messages from CoreData
- (void)initializeTablePullDown {
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(pullNextSetOfMessages) forControlEvents:UIControlEventValueChanged];
    
}

// Method to pull the next set of messages by a specific amount
- (void)pullNextSetOfMessages{
    
    // Pull the current amount of messages we have in the view
    NSInteger tmp = currentMessageCount;
    
    // End the refresh or the table will forever stay in this state
    [refreshControl endRefreshing];
    
    // Make sure we are connected to the XMPP Server still or the applicaiton will crash
    // When attempting to pull the archived messages from coreData
    BOOL success = [[self appDelegate]isXmppConnected];
    
    if(success){
        
        NSMutableDictionary  *allPastMesseages = [[NSMutableDictionary alloc]init];
        
        allPastMesseages = [[self appDelegate]getArchivedMesseages];
        
        // Check to make sure there are messages for the current JID we are messaging
        // & ensure the current count of messages are within scope
        if([allPastMesseages objectForKey:toSendToJID]){
            
            [messegesForCurrentView removeAllObjects];
            
            messegesForCurrentView = [allPastMesseages objectForKey:toSendToJID];
            totalMessageCount = messegesForCurrentView.count;
            currentMessageCount = currentMessageCount + pullMessagesBy;
            
            if(currentMessageCount > totalMessageCount){
                
                currentMessageCount = totalMessageCount;
            }
            
            if(currentMessageCount != messegesForCurrentView.count){
            
            // Get the amount of messages we want to display within the array
            messegesForCurrentView = [[messegesForCurrentView subarrayWithRange:NSMakeRange(([messegesForCurrentView count]-currentMessageCount), currentMessageCount)] mutableCopy];
           
            // Reload the table & set the scroll postion to where the user was when they
            // Refreshed the tableview to load the extra messages
            [self.tableView reloadData];
            
            tmp = currentMessageCount - tmp;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tmp inSection:0];
            [tableView scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:UITableViewScrollPositionTop
                                         animated:NO];
            }
            
        }
        
    }


}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for the table view
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



-(void)moveTableViewToBottomCell {
    
    if(messegesForCurrentView.count > 0 ){
        
   [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messegesForCurrentView.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
}

// Set the number of sections within the table. For this view it should always be one
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

// Number of rows in the message view based on the amount of messages we currently have to display
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    
    
    return messegesForCurrentView.count;
}

// Apple Deleget method to set the hight for each cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if([messegesForCurrentView objectAtIndex:indexPath.row]){
        
        XMPPMessageArchiving_Message_CoreDataObject *messeage = [messegesForCurrentView objectAtIndex:indexPath.row];
        
        if([messeage isOutgoing]){
            
            // Outgoing message Cell
            static NSString *cellIdentifier = @"OutGoingMsgCell";
            OutGoingMsgCell *outGoingMsgCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (outGoingMsgCell == nil)
            {
                outGoingMsgCell = [[OutGoingMsgCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:cellIdentifier];
            }
            
           CGRect frame = CGRectMake(outGoingMsgCell.frame.origin.x, outGoingMsgCell.frame.origin.x, [[UIScreen mainScreen] bounds].size.width * 0.99,outGoingMsgCell.frame.size.height );
            
            outGoingMsgCell.frame = frame;
            outGoingMsgCell.messegeLabel.frame = [self calculateOutGoingCellWidth:outGoingMsgCell.frame msgText:messeage.body msgLabelFrame:outGoingMsgCell.messegeLabel];
            
            outGoingMsgCell.myJIDLabel = [self calculateMyJIDLabel: outGoingMsgCell.myJIDLabel cellFrame:outGoingMsgCell.frame];
            
            outGoingMsgCell.timeStampLabel = [self calculateTimeStampFrame:outGoingMsgCell.timeStampLabel cellFrame:outGoingMsgCell.frame];
            
            outGoingMsgCell.myJIDImage = [self calculateOutgoingImageLocation:outGoingMsgCell.myJIDImage cellFrame:outGoingMsgCell.frame];
            
            
            
            
            double cellHight = 1.1 * (outGoingMsgCell.messegeLabel.frame.size.height + outGoingMsgCell.myJIDLabel.frame.size.height + outGoingMsgCell.timeStampLabel.frame.size.height + outGoingMsgCell.myJIDImage.frame.size.height);
            
            
            if (cellHight < 115){
                
                cellHight = 115.0;
            }
            
            
           self.view.translatesAutoresizingMaskIntoConstraints = YES;
            return cellHight;
            
             
             
        }else{
            
            
            // Incomming Message Cell
            static NSString *secondCellIdentifier = @"IncomingMsgCell";
            IncomingMsgCell *incomingMsgCell = [tableView dequeueReusableCellWithIdentifier:secondCellIdentifier];
            if (incomingMsgCell == nil)
            {
                incomingMsgCell = [[IncomingMsgCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:secondCellIdentifier];
            }
            
           
            CGRect frame = CGRectMake(incomingMsgCell.frame.origin.x, incomingMsgCell.frame.origin.x, [[UIScreen mainScreen] bounds].size.width * 0.99,incomingMsgCell.frame.size.height );
            
            incomingMsgCell.frame = frame;
            incomingMsgCell.messegeLabel.frame = [self calculateIncomingCellWidth:incomingMsgCell.frame msgText:messeage.body msgLabelFrame:incomingMsgCell.messegeLabel];
            
            incomingMsgCell.fromJIDLabel = [self calculateIncomingJIDLabel:incomingMsgCell.fromJIDLabel cellFrame:incomingMsgCell.frame];
            
            incomingMsgCell.timeStampLabel = [self calculateTimeStampFrame:incomingMsgCell.timeStampLabel cellFrame:incomingMsgCell.frame];
            
            incomingMsgCell.fromJIDImage = [self calculateOutgoingImageLocation:incomingMsgCell.fromJIDImage cellFrame:incomingMsgCell.frame];
            
            double cellHight = 1.1*(incomingMsgCell.messegeLabel.frame.size.height + incomingMsgCell.fromJIDLabel.frame.size.height + incomingMsgCell.timeStampLabel.frame.size.height);
            

            
            if (cellHight < 115){
                
                cellHight = 115.0;
            }
            
            
            incomingMsgCell.translatesAutoresizingMaskIntoConstraints = YES;
            return cellHight;
            
      
            
        }
    
    }
    
    return 160;
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Outgoing message Cell 
    static NSString *CellIdentifier = @"OutGoingMsgCell";
    OutGoingMsgCell *outGoingMsgCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (outGoingMsgCell == nil)
    {
        outGoingMsgCell = [[OutGoingMsgCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:CellIdentifier];
    }
    
    // Incomming Message Cell
    static NSString *secondCellIdentifier = @"IncomingMsgCell";
    IncomingMsgCell *incomingMsgCell = [tableView dequeueReusableCellWithIdentifier:secondCellIdentifier];
    if (incomingMsgCell == nil)
    {
        incomingMsgCell = [[IncomingMsgCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:CellIdentifier];
    }
    
 
    
    
        // Pull a copy of the message we are currently working with to display in the view
    if([messegesForCurrentView objectAtIndex:indexPath.row]){
    
        XMPPMessageArchiving_Message_CoreDataObject *messeage = [messegesForCurrentView objectAtIndex:indexPath.row];
        
        // Check if the message is outgoing to incoming
        if([messeage isOutgoing]){
            
            NSXMLElement *xmlMessage = [[NSXMLElement alloc] initWithXMLString:messeage.messageStr error:nil];
            
            // Check to see if this message is from Admin services
            [self checkForMessageID:xmlMessage];

            
            
            outGoingMsgCell.frame = [tableView rectForRowAtIndexPath:indexPath];
            
            
            ////////////////////////////////////////////////////////
            // Msg Body setup
            ///////////////////////////////////////////////////////
            
            [self calculateOutGoingCellWidth:outGoingMsgCell.frame msgText:messeage.body msgLabelFrame:outGoingMsgCell.messegeLabel];
            
            outGoingMsgCell.messegeLabel.text = messeage.body;
            outGoingMsgCell.messegeLabel.textColor = [UIColor whiteColor];
            outGoingMsgCell.messegeLabel.layer.backgroundColor = [UIColor colorWithRed:67.0/255 green:109.0/255 blue:245.0/255 alpha:1].CGColor;
            outGoingMsgCell.messegeLabel.layer.cornerRadius = 6.0f;
            outGoingMsgCell.messegeLabel.textAlignment = NSTextAlignmentCenter;
            
            
        
            
            ////////////////////////////////////////////////////////
            // myJIDLabel Setup
            ///////////////////////////////////////////////////////
           
            
            if([myJID containsString:@"@"]){
                
                NSArray *tmp = [myJID componentsSeparatedByString:@"@"];
                
                if([tmp objectAtIndex:0]){
                    
                    outGoingMsgCell.myJIDLabel.text = [tmp objectAtIndex:0];
                    
                }
                
            }else{
                
                outGoingMsgCell.myJIDLabel.text = myJID;
            }

            outGoingMsgCell.myJIDLabel.textColor = [UIColor lightGrayColor];
            outGoingMsgCell.myJIDLabel.adjustsFontSizeToFitWidth = YES;
            outGoingMsgCell.myJIDLabel.textAlignment = NSTextAlignmentRight;
            
           outGoingMsgCell.myJIDLabel = [self calculateMyJIDLabel: outGoingMsgCell.myJIDLabel cellFrame:outGoingMsgCell.frame];
            
            ////////////////////////////////////////////////////////
            // Timestamp setup label setup
            ///////////////////////////////////////////////////////
            
            
            outGoingMsgCell.timeStampLabel = [self calculateTimeStampFrame:outGoingMsgCell.timeStampLabel cellFrame:outGoingMsgCell.frame];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"YYYY MMM d, h:mm a"];
            
            NSString *tmpTime = [dateFormat stringFromDate:messeage.timestamp];
            
            if([outGoingMsgCell.timeStampLabel.text isEqualToString:@"(null)"]){
                
                [outGoingMsgCell.timeStampLabel setHidden:YES];
                
            }else{
            
                [outGoingMsgCell.timeStampLabel setHidden:NO];
                
            outGoingMsgCell.timeStampLabel.text = tmpTime;
            outGoingMsgCell.timeStampLabel.textColor = [UIColor lightGrayColor];
        
                
            }
            
            
            ////////////////////////////////////////////////////////
            // myJIDImage image Setup
            ///////////////////////////////////////////////////////
            
            outGoingMsgCell.myJIDImage = [self calculateOutgoingImageLocation:outGoingMsgCell.myJIDImage cellFrame:outGoingMsgCell.frame];
            
            
            double cellHight = 1.1 * (outGoingMsgCell.messegeLabel.frame.size.height + outGoingMsgCell.myJIDLabel.frame.size.height + outGoingMsgCell.timeStampLabel.frame.size.height + outGoingMsgCell.myJIDImage.frame.size.height);
            
            CGRect Frame = CGRectMake(outGoingMsgCell.frame.origin.x, outGoingMsgCell.frame.origin.y, [[UIScreen mainScreen] bounds].size.width * .99, cellHight);
            
           // [[outGoingMsgCell contentView] setFrame:Frame];
            outGoingMsgCell.translatesAutoresizingMaskIntoConstraints = YES;
            // Cell is now configured and ready to be returned
            return outGoingMsgCell;
        
        
        }else{
        
            // Message is a incoming message so we need to pull who it's from and check to see if it's a MUC
            // Message or if it's JID to JID
            NSXMLElement *xmlMessage = [[NSXMLElement alloc] initWithXMLString:messeage.messageStr error:nil];
            NSXMLNode *from = [xmlMessage attributeForName:@"from"];
            
            // We chek to see if its a muc message by looking to see if the string containts
            // confrance or MUC in the JID
            // Better way would be to look at the message "type" for groupChat JP Fix
            if ([toSendToJID containsString:@"@muc"] || [toSendToJID containsString:@"@conference"]){
                
                // If the message if a groupChat we look to see if there is a resouse added
                // to the JID so we can pull the name of the sender from it to display
                // In the cell. If there is no resouse then we set the send to Unknown
                if([from.stringValue containsString:@"/"]){
                
                    NSArray *tmp = [from.stringValue componentsSeparatedByString:@"/"];
                
                    if([tmp objectAtIndex:1]){
                    
                        incomingMsgCell.fromJIDLabel.text = [tmp objectAtIndex:1];
                        
                        incomingMsgCell.fullStringJid = [[self appDelegate]theCleanerOfUserJID:[tmp objectAtIndex:1]];
               
                    }
                
                }else{
                    
                    incomingMsgCell.fromJIDLabel.text = @"Unknown";
                    incomingMsgCell.fullStringJid = @"Unknown";
                    
                }
                 
            }else{
                
                // if the messeage is not a groupChat then we
                
               if ([from.stringValue containsString:@"@"]){
                    
                    NSArray *tmp = [from.stringValue componentsSeparatedByString:@"@"];
                    
                   if([tmp objectAtIndex:0]){
                       
                          incomingMsgCell.fromJIDLabel.text = [tmp objectAtIndex:0];
                       
                        incomingMsgCell.fullStringJid = [[self appDelegate]theCleanerOfUserJID:from.stringValue];
                   }
                   
               }else{
                   
                   incomingMsgCell.fromJIDLabel.text = from.stringValue;
                   incomingMsgCell.fullStringJid = [[self appDelegate]theCleanerOfUserJID:from.stringValue];
                   
               }
                   
            }
            // Here we check if there is a messeageID property within the messeage sent by the SMACK Java Admin
            // and enable the cell for user interaction & change it's color so that the user knows there is something
            // That needs to be actioned
            BOOL success;
          
            
            incomingMsgCell.userInteractionEnabled = [self checkForMessageID:xmlMessage];
            
            success = incomingMsgCell.userInteractionEnabled;
            
            if(success){
                
                incomingMsgCell.messegeLabel.layer.backgroundColor = [UIColor greenColor].CGColor;
                incomingMsgCell.messegeLabel.textColor = [UIColor whiteColor];
           
            }else{
               
                incomingMsgCell.messegeLabel.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
                incomingMsgCell.messegeLabel.textColor = [UIColor blackColor];
                
            }
        
            incomingMsgCell.frame = [tableView rectForRowAtIndexPath:indexPath];
            
            ////////////////////////////////////////////////////////
            // messeageLabel Info
            ///////////////////////////////////////////////////////
          [self calculateIncomingCellWidth:incomingMsgCell.frame msgText:messeage.body msgLabelFrame:incomingMsgCell.messegeLabel];
            
            incomingMsgCell.messegeLabel.textAlignment = NSTextAlignmentCenter;
            incomingMsgCell.messegeLabel.layer.cornerRadius = 6.0f;
            incomingMsgCell.messegeLabel.text = messeage.body;
            ////////////////////////////////////////////////////////
            // fromJID Info
            ///////////////////////////////////////////////////////
           incomingMsgCell.fromJIDLabel = [self calculateIncomingJIDLabel:incomingMsgCell.fromJIDLabel cellFrame:incomingMsgCell.frame];
            incomingMsgCell.fromJIDLabel.textColor = [UIColor lightGrayColor];
            incomingMsgCell.fromJIDLabel.adjustsFontSizeToFitWidth = YES;
            incomingMsgCell.fromJIDLabel.textAlignment = NSTextAlignmentLeft;
            
            ////////////////////////////////////////////////////////
            // timestamp Info
            ///////////////////////////////////////////////////////
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"YYYY MMM d, h:mm a"];
            NSString *newDate = [dateFormat stringFromDate:messeage.timestamp];
            incomingMsgCell.timeStampLabel.text = [NSString stringWithFormat:@"%@",newDate];
            
            incomingMsgCell.timeStampLabel = [self calculateTimeStampFrame:incomingMsgCell.timeStampLabel cellFrame:incomingMsgCell.frame];
            
            if([incomingMsgCell.timeStampLabel.text isEqualToString:@"(null)"]){
                
                [incomingMsgCell.timeStampLabel setHidden:YES];
          
            }else{
            
                [incomingMsgCell.timeStampLabel setHidden:NO];
                incomingMsgCell.timeStampLabel.textColor = [UIColor lightGrayColor];

            }
            
            ////////////////////////////////////////////////////////
            // fromJIDImage Info
            ///////////////////////////////////////////////////////
            
            incomingMsgCell.fromJIDImage = [self calculateIncomingImageLocation:incomingMsgCell.fromJIDImage cellFrame:incomingMsgCell.frame fromJID:incomingMsgCell.fullStringJid];
        
            
            incomingMsgCell.translatesAutoresizingMaskIntoConstraints = YES;
            
            return incomingMsgCell;
        }
    }
    
    return outGoingMsgCell;

}

// Apple Delegate Method called when the user selects a cell that is actionable
// if the cell can be scelected by a user we find the message at that index to seed & trigger
// the change to the ApprovalViewController
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // pull a copy of the message
    XMPPMessageArchiving_Message_CoreDataObject *messeage = [messegesForCurrentView objectAtIndex:indexPath.row];
    
    BOOL success;
    
    // Check to see if the QA settings are enable to send duplicate responses
    BOOL allowDuplicateResponses = [self allowDupResponses];
    
    // Find the message ID within the string message
    NSString *messageID = [self getMessageIDFromMessage:messeage.messageStr];
    
    if(messageID != NULL){
        
        // Now check to see if has already been responded to & if not continue in the flow
        success = [self checkRespondedMessageInIDList:messageID];
        
        if(success || allowDuplicateResponses){
            
            [[self appDelegate] setMMDCCenterViewForApproval:messeage stringJabberID:toSendToJID msgBody:messeage.body];
            
        }else{
            
            // Aleft shown to the user that the message has already been responsed on.
            // JP should come up with a better way or flow of doing this maybe
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oh Noes!"
                                                                message:@"Thank you but another Manager Has already responsed to the request"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }
        
        
    }else{
        
        // Error aleft shown if we can't find the message ID which should not happen
        // But placed in to handle this behavior
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Message ID cannot be found"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for checking messageID's from services
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Method to check if there is a messageID within the XML message
- (BOOL)checkForMessageID:(NSXMLElement*)xmlMessage {
    
    //pull the parent properties element to get the child property elements
    NSXMLElement *prop = [xmlMessage elementForName:@"properties"];
    NSArray *properties = [prop elementsForName:@"property"];
    
    NSString *messageID;
    BOOL isReturnResponse = NO;
    BOOL isActionable = NO;
    
    // iteirate over the whole array looking for messageID values & isReturnResponse
    // If needed values are found, return YES to make the cell actuable or NO to make it not executable
    for(id object in properties){
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        
        if([name.stringValue isEqualToString:@"messageID"] && value.stringValue.length > 0 ){
            
            messageID = value.stringValue;
            
        }
        
        
        
        if([name.stringValue isEqualToString:@"isReturnResponse"] && [value.stringValue isEqualToString:@"YES"] ){
            
            isReturnResponse = YES;
            
        }
        
        
        if([name.stringValue isEqualToString:@"isActionable"] && [value.stringValue isEqualToString:@"YES"] ){
            
            isActionable = YES;
            
        }
        

    }
    
    if(isActionable && !isReturnResponse){
        
        return YES;
   
    
    }else if (messageID.length > 0 && isReturnResponse){
        
        // If we find isReturnResponse we add that messageID to a list
        // of message ID's that has already been responded to
        // so that managers cannot' keep sending duplicate responses to the services
        [self addRespondedMessageIDToList:messageID];
        
    }
    
    return NO;
}

// Method to add to the list of messageID's users have responsed to
// If the ID is not found within the dictionary then we add it
// This list is capped by the amount of messages within the view
- (void)addRespondedMessageIDToList:(NSString*)messageID{
    
    if (![respondedMessageIDList containsObject:messageID]){
        
        [respondedMessageIDList addObject:messageID];
    }
    
    
}



// Method to check if a message ID is in the list or responsed messages
- (BOOL)checkRespondedMessageInIDList:(NSString*)messageID{
    
    if (![respondedMessageIDList containsObject:messageID]){
    
        //return YES if the messageID does not exist in the Array
        return YES;
    }
    
    //Return NO if it does exist
    return NO;
}

// Method to pull the messageID from the list
- (NSString*)getMessageIDFromMessage:(NSString*)message {
    
    
    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message error:nil];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    NSArray *properties = [prop elementsForName:@"property"];
    
    NSString *messageID;
    
    // itierate over the array to find the messageID element
    // If it does not exist then return with NULL
    for(id object in properties){
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        if([name.stringValue isEqualToString:@"messageID"]){
            
            messageID = value.stringValue;
            
            return messageID;
            
        }
        
        
    }
    return NULL;
}


// Simple Method to setup the title on the navigation item.
// Since we are passed the whole JID we have to remove part of the string to fit
// within the title area
- (void)setTitlefromToJID{
   
  
    if(toSendToJID.length <=0){
        
        toSendToJID = [[self appDelegate]getToUserJID];
        
    }
    
    NSArray *myArray = [toSendToJID componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];

    
    if([myArray objectAtIndex:0]){
        
       navigationItem.title = [myArray objectAtIndex:0];

        
    }else{
        
       navigationItem.title = @"Error";
    }
    

}

// Method to access the instince of the appDelegate class
- (AppDelegate *)appDelegate {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice used we the App Delegate recives a new message
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Method to observe the notificaiton center for changes in the groupMessage & chatMessage
// Any new messeages recivied by the XMPPFramework will trigger these methods
- (void)startObservers {
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupMesseageChanged:) name:@"groupMesseage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMesseageChanged:) name:@"chatMesseage" object:nil];
    [self keyboardObserver];
    [self swipeLeftObserver];
    
}



// Notification method trigger by reciving new groupMessage
- (void)groupMesseageChanged:(NSNotification*)notification {
    
    
    NSLog(@"FOUND NEW GROUP MESSAGE RELOADING TABLE");
    // Get all messages
    [self getMesseages];
    
    // Reload the table
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
    // Move the table view postion to the bottom of the table
   // [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messegesForCurrentView.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    // Because sometimes the messages are still not archived by the XMPPFramework in itme there is a latency
    // To temp fix that we reload everything again and it seems to work
    // Best way would be to count the amount of total messages & if the count is the same to reload then
    // JP fix
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messegesForCurrentView.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    
    // Because sometimes the messages are still not archived by the XMPPFramework in itme there is a latency
    // To temp fix that we reload everything again and it seems to work
    // Best way would be to count the amount of total messages & if the count is the same to reload then
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
    
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
    
  //  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messegesForCurrentView.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
}


// Dumb identical method. Need to consolidate into one method JP - Fix
- (void)chatMesseageChanged:(NSNotification*)notification {
    
    NSLog(@"FOUND NEW CHAT MESSAGE RELOADING TABLE");
    
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
   // [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messegesForCurrentView.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
   // [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messegesForCurrentView.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
    
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
}

// Dumb identical method. Need to consolidate into one method JP - Fix
- (void)tmpChatMesseageChanged{
    
    NSLog(@"TMP chate mssage notification called");
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messegesForCurrentView.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messegesForCurrentView.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
    
    [self getMesseages];
    [self.tableView reloadData];
    [self moveTableViewToBottomCell];
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for inputting the message
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// JP New Code for new messageInput view
// All new code should go here
-(void)textViewConfiguration {
    
    
    messageInput.layer.borderWidth = 2.0f;
    messageInput.layer.cornerRadius = 6.0f;
    messageInput.layer.borderColor = [[UIColor grayColor] CGColor];
    messageInput.scrollEnabled = NO;
    
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [txtView resignFirstResponder];
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self setMessageInputFiledSize:textView];
    
}

-(void)setMessageInputFiledSize:(UITextView *)textView{
   
    if (messageInputYorigin == isKeyboardOrigin){
        
        messageInputYorigin = textView.frame.origin.y;
        originalmessageInputFrame = textView.frame;
        
    }
    
    [UITextView beginAnimations:nil context:NULL];
    [UITextView setAnimationDuration:0.6];
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;

    
    float rows = (textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / textView.font.lineHeight;
    
    if(rows <= 1.9){
        
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        messageInput.scrollEnabled = NO;
        newFrame.origin.y = messageInputYorigin;
        
    }else if(rows >= 2 && rows <= 2.9){
        
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        messageInput.scrollEnabled = NO;
        newFrame.origin.y =  messageInputYorigin - (.5 * newFrame.size.height);
  
    }else if(rows >= 3){
        
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), textView.frame.size.height);
        messageInput.scrollEnabled = YES;
        newFrame.origin.y =  messageInputYorigin - (.5 * newFrame.size.height);
        
    }
    
    textView.frame = newFrame;
    [UITextView commitAnimations];
    
}

- (void)setMessageInputToOriginalFrame {
    
    [UITextView beginAnimations:nil context:NULL];
    [UITextView setAnimationDuration:0.6];
    
    messageInput.frame = originalmessageInputFrame;
    
    [UITextView commitAnimations];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    if([messageInput.text isEqualToString:@""]){
        
        messageInput.text = @"Enter message . . . ";
    }
    
  
    [self setMessageInputFiledSize:textView];
    
    return YES;
}



- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if([messageInput.text isEqualToString:@"Enter message . . . "] ){
        
        messageInput.text = @"";
    }
    return YES;
}


- (void)keyboardObserver {
   
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)keyboardDidShown:(NSNotification*)notification {
    
    NSDictionary* keyboardData = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardData valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardFrame = [keyboardFrameBegin CGRectValue];
    
    [self setViewMovedUp:YES];
    
}

- (void)keyboardDidHide:(NSNotification*)notification {
    
    NSDictionary* keyboardData = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardData valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardFrame = [keyboardFrameBegin CGRectValue];
    [self setViewMovedUp:NO];
}

// method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    
    // Animation setup for moving the view
    // Adds a better look and feel
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6];
    
    
    // Get the rect of the whole view. JP Need to get the size of the keyboard from the sender
    // In doing so we can acutally know the size of the keyboard for any device
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= keyboardFrame.size.height;
        rect.size.height += keyboardFrame.size.height;
        
    }
    else if (!movedUp)
    {
        // revert back to the normal state.
        rect.origin.y += keyboardFrame.size.height;
        rect.size.height -= keyboardFrame.size.height;
        
    }
    
    // Set the new fram for the view & animate the change
    self.view.frame = rect;
    [UIView commitAnimations];
    
}

// Method that is called when the user has pressed the send button
- (IBAction)sendButtonEntered:(id)sender {
    
    if(![messageInput.text isEqualToString:@"Enter message . . . "] && messageInput.text.length > 0){
        
    
        //get messeage from UI
        NSString *body = messageInput.text;
    
        // We need to evaluate what type of jid we are communicating with groupchat or chat
        BOOL succes;
        
        if ([toSendToJID containsString:@"@muc."] || [toSendToJID containsString:@"@conference."]){
       
            
            // if it's a group chat we send the message to the AppDelegat the has the open XMPP
            // Stream connection to be sent to the specific JID
            succes = [ [self appDelegate] sendXMPPGroupMesseage:body jabberID:toSendToJID ];
            
            NSLog(@"Sent Group Chat");
            
            [self tmpChatMesseageChanged];
        
        }else{
            
            succes = [[self appDelegate] sendXMPPChatMesseage:body JID:toSendToJID];
            [self tmpChatMesseageChanged];
            
            NSLog(@"Sending Chat message");
        }
    
        if(!succes){
        
            // If there is an issue with sending the message we let the user know
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messeage Error"
                                                            message:@"Messeage was not sent"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alertView show];
        
        } else {
        
            // Finally we clear the message field of the old message
            // to get ready for a new message from the user
            messageInput.text = @"";
            [self setMessageInputToOriginalFrame];
           
        
        }

    }
}

// Method to check if the QA settings are active in iOS's bundle settings
- (BOOL)allowDupResponses {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL hackTheGibson = [defaults boolForKey:@"Dev_Overide"];
    
    BOOL dupMessageResponse = [defaults boolForKey:@"AllowDuplicateMessageResponses"];
    
    if(hackTheGibson && dupMessageResponse){
        
       return YES;
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for the slid menu buttons
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Method called to setup the menu slide out buttons on the navigation item
- (void)setSlideMenuButtons {
    
    UIImage *menuImage = [UIImage imageNamed:@"menuIcon.png"];
    CGRect frame = CGRectMake(100, 100, 40, 20);
   
    UIButton *leftButton = [[UIButton alloc] initWithFrame:frame];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:frame];
    
    [leftButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(slidLeftMenu)
         forControlEvents:UIControlEventTouchUpInside];
    [leftButton setShowsTouchWhenHighlighted:YES];
    
    [rightButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(slidRightMenu)
         forControlEvents:UIControlEventTouchUpInside];
    [rightButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *leftSlideButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    navigationItem.leftBarButtonItem = leftSlideButton;
    
    UIBarButtonItem *rightSlideButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    navigationItem.rightBarButtonItem = rightSlideButton;
  
}

- (void)swipeLeftObserver {
    
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didSwipeLeft)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    swipeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
   
    if([messageInput isFirstResponder]){
        
        [messageInput resignFirstResponder];
        
    }
    
       return YES;
}
       
       
-(void)didSwipeLeft {
    
 
    if([messageInput isFirstResponder]){
        
        [messageInput resignFirstResponder];
        
    }
}
// Method that calls the appDelgate method to open the slide out left
- (void)slidLeftMenu{
    
    if([messageInput isFirstResponder]){
        
        
        [messageInput resignFirstResponder];
        
    }
    
    
    [[self appDelegate]openLeftDrawer];
    
}

// Method that calls the appDelgate method to open the slide out right
- (void)slidRightMenu{
    
    if([messageInput isFirstResponder]){
        
       
        [messageInput resignFirstResponder];
        
    }
    
    [[self appDelegate]openRightDrawer];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for resizing objects in the cells
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Method for calucalting the with of the view and setting the width of each message cell
- (CGRect)calculateOutGoingCellWidth:(CGRect)cellFrame msgText:(NSString*)text msgLabelFrame:(UILabel*)msgLabel {
    
    
    double msgLabelBoundsRight = [[UIScreen mainScreen] bounds].size.width * .85;
    double msgLabelBoundsLeft = [[UIScreen mainScreen] bounds].size.width * .15;
    double maxWidth = cellFrame.size.width * 0.80;
    double minWidth = cellFrame.size.width * 0.15;
    double maxHight = [[UIScreen mainScreen] bounds].size.height * 0.8;
    double cellHeightMid = cellFrame.size.height /2;
    
    
    
    msgLabel.text = text;
    [msgLabel setFont:[UIFont systemFontOfSize:userSettings.fontSize]];
    
    
    CGSize widthMaxHeight = CGSizeMake(maxWidth, maxHight);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingRect = [msgLabel.text boundingRectWithSize:widthMaxHeight
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:msgLabel.font}
                                                      context:context].size;
    
    size = CGSizeMake(ceil(boundingRect.width), ceil(boundingRect.height));
    
    
   
    double frameWidth = size.width * 1.1;
    double frameHight = size.height * 1.1;
    double halfFrameHight = frameHight / 2;
    double frameXOrigin = maxWidth - frameWidth;
    double frameYOrigin = cellHeightMid - halfFrameHight;
    
    if (frameXOrigin < minWidth){
        
        frameXOrigin = msgLabelBoundsLeft;
        frameWidth = msgLabelBoundsRight * .80;
      
    }
    
    if(frameWidth > maxWidth){
        
        frameXOrigin = msgLabelBoundsLeft;
        frameWidth = msgLabelBoundsRight * .80;
        
    }
    
    
    
    CGRect tempFrame = CGRectMake(frameXOrigin, frameYOrigin, frameWidth, frameHight);
    
    msgLabel.frame = tempFrame;
    
    return msgLabel.frame;
}

// Method for calucalting the with of the view and setting the width of each message cell
- (CGRect)calculateIncomingCellWidth:(CGRect)cellFrame msgText:(NSString*)text msgLabelFrame:(UILabel*)msgLabel {
    
   
    
    double viewWidth = [[UIScreen mainScreen] bounds].size.width;
    double maxWidth = viewWidth * 0.75;
    double minWidth = viewWidth * 0.18;
    double maxHight = cellFrame.size.height * 0.80;
    double cellHeightMid = cellFrame.size.height /2;
  
    
    
    
    msgLabel.text = text;
    [msgLabel setFont:[UIFont systemFontOfSize:userSettings.fontSize]];
    
    
    CGSize widthMaxHeight = CGSizeMake(maxWidth, maxHight);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingRect = [msgLabel.text boundingRectWithSize:widthMaxHeight
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:msgLabel.font}
                                                   context:context].size;
    
    size = CGSizeMake(ceil(boundingRect.width), ceil(boundingRect.height));
    
   
    double frameWidth = size.width * 1.1;
    double frameHight = size.height * 1.1;
    double halfFrameHight = frameHight / 2;
    double frameXOrigin = minWidth;
    double frameYOrigin = cellHeightMid - halfFrameHight;
    
    if(frameWidth > maxWidth){
        
        frameWidth = maxWidth;
        
    }
    
    if(frameHight > maxHight){
        
        frameWidth = maxWidth;
    }
    
    
    CGRect tempFrame = CGRectMake(frameXOrigin, frameYOrigin, frameWidth, frameHight);
    
    msgLabel.frame = tempFrame;
    
    
    
   
    
    return msgLabel.frame;
}


- (UIImageView*)calculateOutgoingImageLocation:(UIImageView*)outGoingImage cellFrame:(CGRect)cellFrame {
    
    double imageXOrigin = .99 * cellFrame.size.width - outGoingImage.frame.size.width;
    double imageYOrigin = cellFrame.size.height / 2 - outGoingImage.frame.size.height;
    
    
    if(myImage == NULL){
        
        myImage = [[self appDelegate]getMyPebbleImage];
    }
    
    if(userSettings.useCustomePicture){
        
        
        myImage = userSettings.userImage;
    }
    
    outGoingImage.image = myImage;
    outGoingImage.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect newFrame = CGRectMake(imageXOrigin, imageYOrigin, outGoingImage.frame.size.width, outGoingImage.frame.size.height);
    
    outGoingImage.frame = newFrame;
    
    return outGoingImage;
}

- (UIImageView*)calculateIncomingImageLocation:(UIImageView*)incomingImage cellFrame:(CGRect)cellFrame fromJID:(NSString*)jid {
    
    //incomingImage.image = [self getIncomingCellPicture:jid];
    incomingImage.image = [[BuddyCustomePictures alloc]getUserSavedPicture:jid];
    incomingImage.contentMode = UIViewContentModeScaleAspectFit;
    
    double imageXOrigin = cellFrame.size.width * 0.01;
    double imageYOrigin = cellFrame.size.height / 2 - incomingImage.frame.size.height;
    
    CGRect newFrame = CGRectMake(imageXOrigin, imageYOrigin, incomingImage.frame.size.width, incomingImage.frame.size.height);
    
    incomingImage.frame = newFrame;
    
    return incomingImage;
}

- (UILabel*)calculateTimeStampFrame:(UILabel*)timeStamp cellFrame:(CGRect)cellFrame {
    
    double cellHeight = cellFrame.size.height;
    double cellWidth = cellFrame.size.width;
    double timeStampHeight = timeStamp.frame.size.height;
    double timeStampWidth = timeStamp.frame.size.width;
    
    double timeXOrigin = cellWidth /2 - timeStampWidth / 2;
    double timeYOrigin = cellHeight - timeStampHeight;
  
    CGRect newFrame = CGRectMake(timeXOrigin, timeYOrigin, timeStampWidth, timeStampHeight);
    
    timeStamp.frame = newFrame;
    
    return timeStamp;
}

- (UILabel*)calculateMyJIDLabel:(UILabel*)myJIDLabel cellFrame:(CGRect)cellFrame {
    
   
    double myJIDLabelHeight = myJIDLabel.frame.size.height;
    double myJIDLabelWidth = myJIDLabel.frame.size.width;
    
    double myJIDXOrigin = .99 * cellFrame.size.width - myJIDLabelWidth;
    double myJIDYOrigin = 0;
    
    
    myJIDLabel.frame = CGRectMake(myJIDXOrigin, myJIDYOrigin, myJIDLabelWidth, myJIDLabelHeight);
    
    return myJIDLabel;
}

- (UILabel*)calculateIncomingJIDLabel:(UILabel*)incomingJIDLabel cellFrame:(CGRect)cellFrame {
    
    double cellWidth = cellFrame.size.width;
    double myJIDLabelHeight = incomingJIDLabel.frame.size.height;
    double myJIDLabelWidth = incomingJIDLabel.frame.size.width;
    
    double myJIDXOrigin = cellFrame.size.width * .01;
    double myJIDYOrigin = 0;
    
    CGRect newFrame = CGRectMake(myJIDXOrigin, myJIDYOrigin, myJIDLabelWidth, myJIDLabelHeight);
    
    incomingJIDLabel.frame = newFrame;
    
    return incomingJIDLabel;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for Users Pebble Pictures
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (UIImage*)getIncomingCellPicture:(NSString*)jid {
    
    UIImage *pebPicture = NULL;
    
    if([pebblePictures objectForKey:jid]){
        pebPicture = [pebblePictures objectForKey:jid];
        
        return pebPicture;
   
    }else{
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if([defaults objectForKey:@"pebblePictureLinks"]){
        
            NSMutableDictionary *pebblePictureLinks = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"pebblePictureLinks"]];
            
             NSString *picURL = [pebblePictureLinks objectForKey:jid];
            
            
        
            
            if(picURL.length > 0){
                
               
                NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:picURL]];
                
                    pebPicture = [UIImage imageWithData: imageData];
                
                    [pebblePictures setObject:pebPicture forKey:jid];
                
                return pebPicture;
                
            }
    

        }

    }
    
    if(pebPicture == NULL){
        
        pebPicture = [UIImage imageNamed:@"user-no-image.png"];
    }
    
    return pebPicture;
}



- (void)resizeViewForDevice {
    
    double viewWidth = [[UIScreen mainScreen] bounds].size.width;
    double viewHeight = [[UIScreen mainScreen] bounds].size.height;
    double messageInputHeight = messageInput.frame.size.height * 1.2;
    double tableHeight = viewHeight - messageInputHeight;
    double messageAndSendYorigin = viewHeight - messageInputHeight;
    double messageXorigin = .05 * [[UIScreen mainScreen] bounds].size.width;
    double messageInputWidth = [[UIScreen mainScreen] bounds].size.width * .65;
    double sendButtonWidth = [[UIScreen mainScreen] bounds].size.width * .20;
    double sendButtonXorigin = messageXorigin + messageInputWidth + messageXorigin;
    
    
    // Resize the whole view to matach the size of the device
    self.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    
    // resize the table to have the width of the device but the hight - the messageInputView
    self.tableView.frame = CGRectMake(0, 0, viewWidth, tableHeight);
    
    // Re-postion the message Inputview
    self.messageInput.frame = CGRectMake(messageXorigin, messageAndSendYorigin, messageInputWidth , self.messageInput.frame.size.height);
    
    self.sendButton.frame = CGRectMake(sendButtonXorigin, messageAndSendYorigin, sendButtonWidth , self.messageInput.frame.size.height);
    
    
}
@end
