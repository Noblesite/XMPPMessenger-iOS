#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CFNetwork/CFNetwork.h>
#import <objc/runtime.h>

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = XMPP_LOG_FLAG_ERROR;

@interface AppDelegate()

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;
- (BOOL)sendXMPPChatMesseage:(NSString*)messeage JID:(NSString*)JID;


@end


@implementation AppDelegate

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppRoomHybridStorage;
@synthesize xmppMessageArchivingModule;
@synthesize xmppRoom;



@synthesize storeXmppRoom;
@synthesize csmXmppRoom;
@synthesize mpuXmppRoom;
@synthesize mngXmppRoom;

@synthesize drawerController;

@synthesize userName;
@synthesize locationNumber;
@synthesize pictureLink;
@synthesize myJID;
@synthesize password;
@synthesize xmppMucDomain;
@synthesize myMucList;
@synthesize dynamicMucList;
@synthesize currentMucMemebers;
@synthesize mucMememberList;
@synthesize missedMucMesseageCounter;
@synthesize toUserJid;
@synthesize dynamicMessageIDList;
@synthesize awayTimer;
@synthesize firstConnectTimer;
@synthesize tapGestureRecognizer;
@synthesize rosterBuddyPresenceList;
@synthesize userSettings;
@synthesize messageViewHasLaunched;

#define NEED_REGISTRATION 0
#define HAVE_REGISTERED 1
#define REST_ON 0
#define REST_OFF 1
#define missedSoundID 1007
#define sendSoundID 1004
#define recivedSoundID 1012
#define AWAY_OFF 0
#define AWAY_ON 1
#define XMPP_CONNECTION_TIMEOUT 5



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set debugging level
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_LEVEL_VERBOSE];
   
    shouldLogout = REST_OFF;
    
     [self startGestureRecgonizer]; // JP need to move to online
    
    // Checking if app is running iOS 8
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        // Register device for iOS8
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        // Register device for iOS7
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    }
   
		
	return YES;
}

//Delegate method called for Remote Notifications
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
   
    
    // Prepare the Device Token for Registration (remove spaces and  )
    NSString *devToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    
}


// Delegate Method for getting notifications when the device is running in the background
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  

    if (userInfo) {
        // set the badge number on the applicaiton home screen view
        if ([userInfo objectForKey:@"aps"]) {
            if([[userInfo objectForKey:@"aps"] objectForKey:@"badgecount"]) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark MMDrawerController methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Present the slide view for hte first time
- (void)prsentSlideViewInterface {
    
    // We should have all the data now for setting up a XMPP connection
    // Finally Connect to the XMPP Server 
    //[self XMPPStartUp];
    
    // Pull the main storyboard object
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Instantiate the left view objet
    ChannelListTableViewController *leftView = [storyboard instantiateViewControllerWithIdentifier:@"ChannelListTableViewController"];
    
    
    //Instantiate the center view objet
    MesseageViewController *centerView = [storyboard instantiateViewControllerWithIdentifier:@"MesseageViewController"];
    
    // Instantiate the right view objet
    MucMembersViewController *rightView = [storyboard instantiateViewControllerWithIdentifier:
     @"MucMembersViewController"];
    
    // Asign to UINavigation Conroller objects
    UINavigationController *leftNav = [[UINavigationController alloc]initWithRootViewController:leftView];
    UINavigationController *centNav = [[UINavigationController alloc]initWithRootViewController:centerView];
    UINavigationController *rightNav = [[UINavigationController alloc]initWithRootViewController:rightView];
    

    // Set the toSendToJID string in the messageViewController so we know who to send the messages to.
   // centerView.toSendToJID = toUserJid;
    
    
    
    // alloc the MMDrawerConroller objet with the views
    drawerController =
    [[MMDrawerController alloc]initWithCenterViewController:centNav
                                   leftDrawerViewController:leftNav
                                  rightDrawerViewController:rightNav];
    
    
    // Set the MMDrawer options
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;

    
    // Set the DrawerConroller as the root View Controller
      _window.rootViewController = drawerController;
     [_window makeKeyAndVisible];
    [_window addGestureRecognizer:tapGestureRecognizer];
    
    
    // Seed the toSendToJID properity in the messeageViewController so we know who to talk to
    centerView.toSendToJID = toUserJid;
    rightView.mucID = toUserJid;
    
    // Also set the myJID property so we know who we are
   centerView.myJID = myJID;
    
    
   // [self openLeftDrawer];
    //[self setMMDCCenterViewWithJID:toUserJid];
}

// Set the center view conroller when using the MMDrawer Conroller & seed the view with a JID
- (void)setMMDCCenterViewWithJID:(NSString*)jabberID {
    
    
    // Because the Jabber ID we are getting sometimes has a resource with it we remove it from the string
    NSArray *Array = [jabberID componentsSeparatedByString:@"/"];
    toUserJid = [Array objectAtIndex:0];
    
    // Set the Gesture Options for MMDrawer Controller
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    
    // Close the Drawers for a better look and feel of the changing UI
    [drawerController closeDrawerAnimated:YES completion:nil];

    // Instantiate the main storyboard object
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    
    // create the new UI's view controllers that we are going to update the Drawer conrollers with
    MesseageViewController *messeageViewController;
    MucMembersViewController *mucMembersViewController;
    
    // Instantiate rthe views using the storyboard identifiers
    messeageViewController = [storyboard instantiateViewControllerWithIdentifier: @"MesseageViewController"];
    
    mucMembersViewController = [storyboard instantiateViewControllerWithIdentifier: @"MucMembersViewController"];
    
    // Add the objects as UINavigationControllers
    UINavigationController *centNav = [[UINavigationController alloc]initWithRootViewController:messeageViewController];
    UINavigationController *rightNav = [[UINavigationController alloc]initWithRootViewController:mucMembersViewController];
    
    // Finally set the new view/UI
    [drawerController setCenterViewController:centNav withCloseAnimation:YES completion:nil];
    [drawerController setRightDrawerViewController:rightNav];
    
   // Seed the toSendToJID properity in the messeageViewController so we know who to talk to
    messeageViewController.toSendToJID = [NSString stringWithFormat:@"%@",jabberID];

    // Also set the myJID property so we know who we are
    messeageViewController.myJID = myJID;
   
    // For the Muc Memember List View we need to set the JID in which we are currently communiating with
    mucMembersViewController.mucID = jabberID;
    
   

    
}

// Set the center view conroller when using the MMDrawer Conroller & seed the view with a JID
- (void)setMMDCCenterViewDefault{
    
    
    // Because the Jabber ID we are getting sometimes has a resource with it we remove it from the string
    NSArray *Array = [toUserJid componentsSeparatedByString:@"/"];
    toUserJid = [Array objectAtIndex:0];
    
    // Set the Gesture Options for MMDrawer Controller
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    
    // Close the Drawers for a better look and feel of the changing UI
    [drawerController closeDrawerAnimated:YES completion:nil];
    
    // Instantiate the main storyboard object
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    // create the new UI's view controllers that we are going to update the Drawer conrollers with
    MesseageViewController *messeageViewController;
    MucMembersViewController *mucMembersViewController;
    
    // Instantiate rthe views using the storyboard identifiers
    messeageViewController = [storyboard instantiateViewControllerWithIdentifier: @"MesseageViewController"];
    
    mucMembersViewController = [storyboard instantiateViewControllerWithIdentifier: @"MucMembersViewController"];
    
    // Add the objects as UINavigationControllers
    UINavigationController *centNav = [[UINavigationController alloc]initWithRootViewController:messeageViewController];
    UINavigationController *rightNav = [[UINavigationController alloc]initWithRootViewController:mucMembersViewController];
    
    // Finally set the new view/UI
    [drawerController setCenterViewController:centNav withCloseAnimation:NO completion:nil];
    [drawerController setRightDrawerViewController:rightNav];
    
    // Seed the toSendToJID properity in the messeageViewController so we know who to talk to
    messeageViewController.toSendToJID = [NSString stringWithFormat:@"%@",toUserJid];
    
    // Also set the myJID property so we know who we are
    messeageViewController.myJID = myJID;
    
    // For the Muc Memember List View we need to set the JID in which we are currently communiating with
    mucMembersViewController.mucID = toUserJid;
    
    
    
    
    
}
// Move the center view to the approval view for tools like Punch Tool for Authorization & returnes.
// Called by the messageViewcontroller when selecting on a response cell
- (void)setMMDCCenterViewForApproval:(XMPPMessageArchiving_Message_CoreDataObject*)message stringJabberID:(NSString*)jid msgBody:(NSString*)body {
    
   
    // Set the Dreawer Conroller guesture options
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    
    // Close the Drawers on the view for a better look & feel
    [drawerController closeDrawerAnimated:YES completion:nil];
    
    // Pull an object copy of the main storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    // Instantiate the ApprovalViewcontroller with a instince of the object and load it with
    // The storyboard identifier
    ApprovalViewController *approvalViewController;
    
    approvalViewController = [storyboard instantiateViewControllerWithIdentifier: @"ApprovalViewController"];
    
    UINavigationController *centNav = [[UINavigationController alloc]initWithRootViewController:approvalViewController];
    
    // Set the center Drawer view
    [drawerController setCenterViewController:centNav withCloseAnimation:YES completion:nil];
   
   // Sead the class with the selected message from the message view & and needed jabber ID's
    approvalViewController.message = message.messageStr;
    
    approvalViewController.myJabberID = myJID;
    approvalViewController.currentJabberID = jid;
    
    // Issues with look & feel went setting the values inside the class.
    // Called from here & seems to work correctly
    approvalViewController.messageLabel.text = body;
    [approvalViewController.messageLabel setNumberOfLines:0];
    approvalViewController.messageLabel.adjustsFontSizeToFitWidth = YES;
    //[approvalViewController.messageLabel sizeToFit];
 
    
}

// Method for setting the logout view. Called by the logout button & XMPP Admin's mass logout message
- (void)prsentLogOutViewInterface {
    
    // Set the MMDrawewr conroller guesture options
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    
    // Close the MDDrawer conroller animiated for a better look & feel
    [drawerController closeDrawerAnimated:YES completion:nil];
    
    // Create a copy of the Main storyboard class & instantiate the loginViewConroller from the storyboard
    // identifier then set as a UINavigation controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    UINavigationController *centNav = [[UINavigationController alloc]initWithRootViewController:loginViewController];
  
    // Finally, set the cneter view & set the left and right Drawers to nil so that only the
    // login view is accessable
    [drawerController setCenterViewController:centNav withCloseAnimation:YES completion:nil];
    
    // Seed the bool value to let the loginViewConroller know this is for loging out to overide the bundle settings QA info
    loginViewController.isLogOut = YES;
    [drawerController setRightDrawerViewController:nil];
    [drawerController setLeftDrawerViewController:nil];
    
   
    
}

- (void)prsentSettingsViewInterface {
    
    // Set the MMDrawewr conroller guesture options
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    
    // Close the MDDrawer conroller animiated for a better look & feel
    [drawerController closeDrawerAnimated:YES completion:nil];
    
    // Create a copy of the Main storyboard class & instantiate the loginViewConroller from the storyboard
    // identifier then set as a UINavigation controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserSettingsViewController *userSettingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserSettingsViewController"];
    UINavigationController *centNav = [[UINavigationController alloc]initWithRootViewController:userSettingsViewController];
    
    // Finally, set the cneter view & set the left and right Drawers to nil so that only the
    // login view is accessable
    [drawerController setCenterViewController:centNav withCloseAnimation:YES completion:nil];
    
    // Seed the bool value to let the loginViewConroller know this is for loging out to overide the bundle settings QA info
  //  [drawerController setRightDrawerViewController:nil];
   // [drawerController setLeftDrawerViewController:nil];
    
}

// Method to open the left Drawer in the UI called by the messeageViewController
- (void)openLeftDrawer {
    
    [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

// Method to open the right Drawer in the UI called by the messeageViewController
- (void)openRightDrawer {
    
     [drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark close the stream down
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Method for presenting the logout interface & closing the stream
- (void)logOutofXMPP {
    
    [self goOffline];
    [self prsentLogOutViewInterface];
    [self teardownStream];
    
}

// Closes the XMPP stream when the applicaitons is deallocated
- (void)dealloc {
    
	[self teardownStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Application State
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Flag set to determin if the application has attempted to register to the XMPP Server
// Called by the AppDelegate when first connecting to any XMPP server 
- (void)applicaitonState {
    
    xmppRegState = NEED_REGISTRATION;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster {
    
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities {
    
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Basic propertie setter Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Set the user name from ldap called by the LoginViewController
- (void)setUserName:(NSString *)user{
    
    userName = user;
    myJID = [NSString stringWithFormat:@"%@@localhost",userName];
    userSettings = [[UserSettings alloc]userSettings:userName];
}

//set the password from ldap called by the loginViewController
- (void)setPassword:(NSString *)psk {
    
    password = psk;
}

//value to be set if the assoicate logged into the application is a manager or supervisor or whoever we decied to have access
//to all the managment muc's or confrances
- (void)setIsManager:(BOOL)mng {
    
    isManager = mng;
    
    //added for logging
    if(mng){
        
       
    }else{
        
        
    }
}

//Set the locaiton/Store number called by the loginViewController
- (void)setLocationNumber:(NSString*)location {
    
    NSLog(@"Location number: %@", location);
    locationNumber = location;
    
}

//Set the users picture called by the loginViewConroller & from Ravi's LDAP return
- (void)setPictureLink:(NSString *)pic{
    
    pictureLink = pic;
    
}

- (void)setupFirstToUserJID{
    
    // set Initial Jabber ID we want to communicate to as the whole store jabber ID
    toUserJid = [NSString stringWithFormat:@"store%@@conference.localhost",locationNumber];
    
}

- (void)setToUserJID:(NSString*)stringJID{
    
    // set Initial Jabber ID we want to communicate to as the whole store jabber ID
    toUserJid = stringJID;
    
}

- (NSString*)getToUserJID{
    
    return toUserJid;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark connection logic
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Method Called to setup and connect to the XMPP Stream
- (void)XMPPStartUp {
    
    [self setupStream];
    
}

- (void)setupStream {
    
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
    isXmppConnected = NO;
    messageViewHasLaunched = NO;
    // Want xmpp to run in the background?
    //
    
    xmppStream.enableBackgroundingOnSocket = YES;
    
    
    
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    
    // Setup storage for saving messeages
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    //By this line all your messages are stored in CoreData
    
    if(xmppRoomHybridStorage == nil){
        
    xmppRoomHybridStorage = [[XMPPRoomHybridStorage alloc]init];
   
    }
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    
    
    
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
   
    [xmppMessageArchivingModule activate:xmppStream];
    
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
   
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    [xmppStream setHostName:[self getHostName]];
    [xmppStream setHostPort:[self getHostPort]];
    
    
    // Instantiate & allocate class object properities
    
    myMucList = [[NSMutableDictionary alloc]init];
    dynamicMucList = [[NSMutableDictionary alloc] init];
    currentMucMemebers = [[NSArray alloc]init];
    mucMememberList = [[NSMutableDictionary alloc]init];
    missedMucMesseageCounter = [[NSMutableDictionary alloc]init];
    dynamicMessageIDList = [[NSMutableDictionary alloc]init];
    rosterBuddyPresenceList = [[NSMutableDictionary alloc]init];
    
    [self setupFirstToUserJID];
    
    // You may need to alter these settings depending on the server you're connecting to - JP need to fix
    customCertEvaluation = NO;
    
    xmppRegState = NEED_REGISTRATION;
    [self connectToXMPPServer];

}


// Close the XMPP Stream connection & clear objects
- (void)teardownStream {
    
    // XMPP Framework objects cleanup
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
   // xmppRoomHybridStorage = nil;
    
    
    [self teardownMUCStreams];
    
    // AppDelegate Class properites clean up JP
    /*  myMucList = nil;
     dynamicMucList = nil;
     mucMememberList = nil;
     missedMucMesseageCounter = nil;
     dynamicMessageIDList = nil; */
    
}

- (void)teardownMUCStreams{
    
    for (NSString* key in dynamicMucList) {
        
        
        XMPPRoom *xmppMuc = [dynamicMucList objectForKey:key];
        
        
        [xmppMuc leaveRoom];
        [xmppMuc deactivate];
        [xmppMuc removeDelegate:self];
        
    }
    
    
    
    
}

// Method to register the current jabber ID to the server. This is always done once per connection
- (void)registerJID {
    
    // Send Registartion request to the xmpp server with password. JP - Further engening needs to be done.
    NSError *error = nil;
    if(![xmppStream registerWithPassword:@"xmpp" error:&error]){
        
        NSLog(@"XMPP Registration Error: %@", [error localizedDescription]);
        
    }else{
        
         NSLog(@"XMPP Registration Error: %@", [error localizedDescription]);
        xmppRegState = HAVE_REGISTERED;
        
        NSLog(@"We have registered the jabber ID: %@", [xmppStream myJID]);
        [xmppStream disconnect];
    }
    
}


// As it states, called to connect to the XMPP server. The server is based on the IP adddress from the setup
// the stream method called earlier in the flow
- (BOOL)connectToXMPPServer {
    
    // Check to see if we are already connected/disconnected
    if (![xmppStream isDisconnected]) {
        NSLog(@"Connected returning yes");
        return YES;
    }
    
    // check to make sure we have the needed xmpp authetication values, if not return a No and do not proceed further in the flow
    if (myJID == nil || password == nil) {
        
        NSLog(@"Password is not set, returning no");
        return NO;
    }
    
    // set the our JID
    NSLog(@"SETTING MYJID: %@", myJID);
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    
    NSError *error = nil;
    
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]){
    
        NSLog(@"Error connecting to the server Error: %@", [error localizedDescription]);
        
        return NO;
        
    }
    
    NSLog(@"Attempted to conenct to the server");
    return YES;
    
}

// Called when the xmppStream connects to the server
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    NSLog(@"xmppStream did Connect");
    
    [firstConnectTimer invalidate];
    firstConnectTimer = nil;
    
    if(xmppRegState == NEED_REGISTRATION){
        
        NSLog(@"Calleding xmpp registerID");
        
        [self registerJID];
        
    }else{
        
        NSLog(@"Attempting to Autheticate");
        isXmppConnected = YES;
        DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
        NSError *error = nil;
        
        NSLog(@"Connecting with password: %@", password);
        
        if (![[self xmppStream] authenticateWithPassword:password error:&error])
        {
            DDLogError(@"Error authenticating: %@", [error localizedDescription]);
            
        }
    }
    
}

// Called when the stream has succesfully Authenticated
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"Stream did Autheticate");
    
    if(!messageViewHasLaunched){
        NSLog(@"Autheticated, moving to messageView");
        
        isXmppConnected = YES;
        
        NSTimer *lunch =  [NSTimer scheduledTimerWithTimeInterval:5
                                                           target:self
                                                         selector:@selector(presentSlideViewQueeded)
                                                         userInfo:nil
                                                          repeats:NO];
        // Send online presence
        
    }
    
    [self goOnline];
  //  [self startGestureRecgonizer];
}

-(void)presentSlideViewQueeded{
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        messageViewHasLaunched = YES;
        [self prsentSlideViewInterface];
    });
    
}

-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    
    NSLog(@"xmppStrea connection Timeout Called");
    isXmppConnected = NO;
   // [self retryToConnectAlert];
    
}

// XMPPStream disconect delegate Method
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    
    if(!isXmppConnected){
    
        isXmppConnected = NO;
        
        if(![firstConnectTimer isValid]){
          
            firstConnectTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                     target:self
                                                   selector:@selector(connectToXMPPServer)
                                                   userInfo:nil
                                                    repeats:NO];
    
            NSLog(@"xmppStream Did Disconnect. Attempting to Reconnect in 5 sec's");
    
        }
    
    }
}


// XMPP Disconnect Method
/*
- (void)disconnect {
    
    [self goOffline];
    
    [xmppStream disconnect];
}

*/
// Go Online method Sends presence out to roster & MUC/confrance
- (void)goOnline {
    
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit & will be sent unless overided
    
    // Check the domain of the xmpp Server JP - Currently hardcoded for localhost
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
    
    // set what the current doamin is
    [self setXmppMucDomain];
    
    // Now that we are connected & have the domain we call setMyMucList to create the list of Muc's
    [self setMyMucList:locationNumber isManger:isManager];
    
    // Count setup in another thread outside the UI thread that is updated by every UI press
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startUpdateAwayThread)];
    tapGestureRecognizer.delegate = self;
}

// Method to set the XMPP Domain. Needs to be configured for production JP
- (void)setXmppMucDomain {
    
    // xmppMucDomain = [NSString stringWithFormat:@"muc.%@", [xmppStream.myJID domain]]; //JP Add for Ejabber
    
    xmppMucDomain = [NSString stringWithFormat:@"conference.%@", [xmppStream.myJID domain]];
    
}

//Go offline method, sends presence to everyone with unavailable
- (void)goOffline {
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}


- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error;{
    NSLog(@"Did not authenticate error: %@", error.stringValue);
    
    [xmppStream registerWithPassword:@"xmpp"error:nil];
    
    NSError * err = nil;
    
    if(![[self xmppStream] registerWithPassword:password error:&err])
    {
        NSLog(@"Error registering: %@", err);
    }
    
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    NSLog(@"I'm in register method");
    
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement*)error{
    
    NSLog(@"Sorry the registration is failed error: %@", error);
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Register JID
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
	// Use this method to release shared resources, save user data, invalidate timers, and store
	// enough application state information to restore your application to its current state in case
	// it is terminated later.
	// 
	// If your application supports background execution,
	// called instead of applicationWillTerminate: when the user quits.
	
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	

	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]) 
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    [self teardownStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Connection Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
	
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
   
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
    
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSLog(@"xmppStream willSecureWithSettings");
	
	NSString *expectedCertName = [xmppStream.myJID domain];
	if (expectedCertName)
	{
		settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
	}
	
	if (customCertEvaluation)
	{
		settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
	}
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 * 
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 * 
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 * 
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 * 
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
**/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
                                      completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSLog(@"xmppStream didReciveTrust");
	
	// The delegate method should likely have code similar to this,
	// but will presumably perform some extra security code stuff.
	// For example, allowing a specific self-signed certificate that is known to the app.
	
	dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(bgQueue, ^{
		
		SecTrustResultType result = kSecTrustResultDeny;
		OSStatus status = SecTrustEvaluate(trust, &result);
		
		if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
			completionHandler(YES);
		}
		else {
			completionHandler(YES); // JP need to set back to NO for Produciton. Set to YES because we could not connect to
            // Ravi's Ejabber server
		}
	});
}

// Called when the xmppstream did connect securelly
- (void)xmppStreamDidSecure:(XMPPStream *)sender {
    
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
  

}
/*
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    NSLog(@"xmppStream did Register");
    NSError *error = nil;
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        DDLogError(@"Error authenticating: %@", [error localizedDescription]);
        
    }
    
    
}*/






/* - (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    
    NSLog(@"Did Not Autheticate: %@", error.stringValue);
    
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
   
}*/

// Delegate Method When XmppFramework receives a information Query request
// Currently not being used for anything

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
  
    NSLog(@"Did Receive IQ: %@", iq.stringValue);
    /*
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if([iq isResultIQ])
    {
        if([iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"])
        {
            NSXMLElement *query = [iq childElement];
            NSArray *items = [query children];
            for(NSXMLElement *item in items)
            {
                NSError *error = nil;
                NSXMLElement *sendQuery = [[NSXMLElement alloc] initWithXMLString:@"<query xmlns='http://jabber.org/protocol/disco#info'/>"
                                                                            error:&error];
                XMPPIQ *sendIQ = [XMPPIQ iqWithType:@"get"
                                                 to:[XMPPJID jidWithString:[item attributeStringValueForName:@"jid"]]
                                          elementID:[xmppStream generateUUID]
                                              child:sendQuery];
                [xmppStream sendElement:sendIQ];
                
            }
            
        }else if([iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"])
        {
            NSXMLElement *query = [iq childElement];
            NSXMLElement *identity = [query elementForName:@"identity"];
            if([[identity attributeStringValueForName:@"category"] isEqualToString:@"conference"])
            {
               
                
               
            }
        }
    }
    
	*/
	return NO;
}


// XMPPFramework delegate method for Receiving a message. Will show Chat and GroupChat message
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
   

        
      BOOL success = [self checkForPebblePictureRequest:message];
        
        if(success){
            
            userSettings = [[UserSettings alloc]userSettings:userName];
            
            if(userSettings.useCustomePicture){
                
                [self sendCustomPicture:message.from.bareJID];
                
            }else{
            
                [self sendPebblePictureLink:message.from.bareJID];
            
            }
        
        }
        
        [self checkSavePebblePictureLink:message];
    
    
        
    NSLog(@"DidRecive chat Message");
    
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    // Create a string value & XMPPJID value for sender
    NSString *from = [NSString stringWithFormat:@"%@",message.fromStr];


    // Check if the app is in the forground & which jabber ID we are currently commuincating with
    // if it's not our current to Jabber ID then send the message to the miss counter
    // if current jabber ID Post new message to be recived by the messageViewController
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
        
        
        if([message isChatMessageWithBody] && [from containsString:toUserJid]){
        
            
            AudioServicesPlaySystemSound(recivedSoundID);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"chatMesseage" object:message];
        
            
        }else if ([message isChatMessageWithBody] && [from containsString:myJID]){
            

            
             [[NSNotificationCenter defaultCenter] postNotificationName:@"chatMesseage" object:message];
            
        }else if ([message isChatMessageWithBody]){
        
            [self addSetMessageMIssedCounter:[self theCleanerOfUserJID:from]];
     
        
    }
    
    
    }else{
        
        
    /*    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];

       // [self showAlert:displayName messeageBody:body];
        
        
    /*    // We are not active, so use a local notification instead
        //JP use to call when the application is in the background
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Ok";
        localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification]; */
        
    }
    
    
/*    if ([message isChatMessageWithBody] || [message isGroupChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *type = [[message elementForName:@"type"] stringValue];
        NSString *displayName = [user displayName];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:displayName forKey:@"SentByJID"];
            [defaults setValue:body forKey:@"MesseageBodyFrom"];
            [defaults setObject:type forKey:@"type"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            /* UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
             message:body
             delegate:nil
             cancelButtonTitle:@"Ok"
             otherButtonTitles:nil];
             [alertView show]; */ /*
        }
        else
        {
            // We are not active, so use a local notification instead
            //JP use to call when the application is in the background
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    } */
}

// XMPPFramework deleage Method for receiving MUC/Confrance Messages
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    
   NSLog(@"xmppRoom did Recieve GROUP Message Room: %@ From: %@ With: %@ \n\n\n",sender.roomJID, occupantJID, message);
    
    [self checkForLogOutMessage:message];
    [self checkSavePebblePictureLink:message];
    
    // Create a string value of the JID sender and check to see if our current messageViewController is set
    // to the same JID. If the JID is not the same add to the message counter if it is the
    // same then send the message to the messageViewController
 
    
    if([message isGroupChatMessageWithBody] && [sender.roomJID.bare containsString:toUserJid]){
        
       
        
        if(![message.fromStr containsString:userName]){
            
           
            AudioServicesPlaySystemSound(recivedSoundID);
        }
        
        NSLog(@"Group Chat notification sent");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"groupMesseage" object:message];
        
        // Check to make sure it's a message with a body & update the counter
    }else if ([message isGroupChatMessageWithBody]){
        

        [self addSetMessageMIssedCounter:sender.roomJID.bare];
    
        
    }
    
}


//JP Start Here Fix Muc list and set Key to Muc Name FFS
- (void)addSetMessageMIssedCounter:(NSString*)JabberID {
    
    // Play missed mesage sound. Check for the JID in the counter. If the JID is not in the dictinary
    // create the key bassed off the JID & add to the count by 1
    AudioServicesPlaySystemSound(missedSoundID);

    
    if(![missedMucMesseageCounter valueForKey:JabberID]){
        
        [missedMucMesseageCounter setValue:[NSNumber numberWithInt:1] forKey:JabberID];
        
    }else{
        
        NSNumber *oldCounter = [missedMucMesseageCounter objectForKey:JabberID];
        NSNumber *newCount = [NSNumber numberWithInt:[oldCounter intValue] + 1];
        
        [missedMucMesseageCounter setValue:newCount forKey:JabberID];
        
      
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"missedMessage" object:missedMucMesseageCounter];
    
}

// Method to clear the missed message counter in the UI. Called by MessageUserTabletableViewConroller
// Cleared by pressing on the cell which shows the number or counter badge
- (void)clearMessageCounter:(NSString*)JabberID {
    
    // Check to see if the object exists & remove it
    if([missedMucMesseageCounter valueForKey:JabberID]){
        
        [missedMucMesseageCounter removeObjectForKey:JabberID];
        
    }
    
    
}


// XMPPFramework delaget Method that is called when we recive a presence from a JID
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
	
    
    
    if ([presence.fromStr containsString:@"@muc"] || [presence.fromStr containsString:@"@conference"] || [presence.fromStr containsString:xmppStream.myJID.bare] || [presence.fromStr containsString:@"admin@"]){
    
        
    }else{
        
            [self XMPPRosterPresenceStatus:presence.from.bareJID presence:presence];
        
            BOOL success = [self checkForRosterUserPebblePicture:presence.from];
            
            if(!success){
                
                [self sendPebblePictureLinkRequest:presence.from];
            
            
        }
    }
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
   
}



- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// XMPPFramework delegate method for receiving a Buddy Request
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// Pull who the user is/Where the reqeust is coming from
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
    
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
    
    // Check to see if the user we are reciving he buddy reqeust is part of the roster
    // if the user is not part of the roster then we display the info to the user?
    // JP need to look into
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body 
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	} 
	else 
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Get Server Info From NSUserDefaults
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Get host name from NSUserDefaults when QA options are turned on
- (NSString*)getHostName{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hostName = [defaults objectForKey:@"HostName_IP"];
   
    return hostName;
}

// Get host Port from NSUserDefaults when QA Options are turned on
- (UInt16)getHostPort{
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *port = [defaults objectForKey:@"Host_Port"];
    UInt16 portNumber = [[formatter numberFromString:port] unsignedShortValue];
    
    return portNumber;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPP Messeages Logic
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Method for sending a normal chat message to a user
- (BOOL)sendXMPPChatMesseage:(NSString*)messeage JID:(NSString*)JID {
    
    // Create teh XMPPMessage and set the type to chat. After just add the string message to the body
    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:JID]];
    
    [msg addAttributeWithName:@"from" stringValue:xmppStream.myJID.bare];
    
    [msg addBody:messeage];
    
    NSLog(@"Out Going Messaget to the stream: %@", msg);
    // Send the message to the stream which will send to the specified jabber ID
    [xmppStream sendElement:msg];
    
    AudioServicesPlaySystemSound(sendSoundID);
    
    return YES;
    
}
// Method to pull the messageID from the list
- (void)checkForLogOutMessage:(XMPPMessage*)message {
    
    NSString *isTimeOut;
    double timer = 0.0;
    
    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.XMLString error:nil];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    NSArray *properties = [prop elementsForName:@"property"];
    
    
    // itierate over the array to find the messageID element
    // If it does not exist then return with NULL
    for(id object in properties){
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        if([name.stringValue isEqualToString:@"userLogOut"]){
            
            isTimeOut = value.stringValue;
            
        }
        if([name.stringValue isEqualToString:@"userLogoutTime"]){
            
            timer = [value.stringValue doubleValue];
            
        }

    }
    
    if([isTimeOut isEqualToString:@"true"] && timer > 0 && shouldLogout == REST_OFF){
        
       
        [self startAutoLogOut:timer];
        
    }
}

// Method to start the logout of the applicaiton. We pass the timer in mintues then covert to seconds.
// Action is done on a separet thread
- (void)startAutoLogOut:(double)delayInMinutes {
    
    shouldLogout = REST_ON;
    double secondsInMinutes = 60.0;
    double delayInSeconds = delayInMinutes * secondsInMinutes;
    
   
    
    [NSTimer scheduledTimerWithTimeInterval:delayInSeconds
                                     target:self
                                   selector:@selector(logOutofXMPP)
                                   userInfo:nil
                                    repeats:NO];
    

    
}
// Method to add the properites elements to responsed to Ravi's service
- (XMPPMessage*)makeXMPPMessageFromString:(NSString*)response msgID:(NSString*)messageID mucJabberID:(XMPPJID*)mucJID storeNumber:(NSString*)storeNumber ldapID:(NSString*)ldapID messageBody:(NSString*)body fromApplication:(NSString*)fromApplication {
    
  
    //Create the groupchat xmppMessage
     XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"groupchat" to:mucJID];
    
    
   // Add the body to the message
    [msg addBody:body];
    
    // Only proceed if we have a mesageID
    if(messageID!=NULL){
        
         [msg addAttributeWithName:@"from" stringValue:xmppStream.myJID.bare];
        // Create the parent properties element
        NSXMLElement *properties = [NSXMLElement elementWithName:@"properties"];
        
        // Set the ejabber protocal type for Smack
        [properties addAttributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
        
        // Create the messageID Properity with name and value
        NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *name = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"messageID"];
        NSXMLElement *value = [[NSXMLElement alloc] initWithName:@"value" stringValue:messageID];
        [value addAttributeWithName:@"type" stringValue:@"string"];
        
        
        // Create the CSM property with name and value
        NSXMLElement *CsmProperty = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *csmName = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"csmResponseCode"];
        NSXMLElement *CsmValue = [[NSXMLElement alloc] initWithName:@"value" stringValue:response];
        [CsmValue addAttributeWithName:@"type" stringValue:@"string"];
        
        // Create the LDAP property with name and value
        NSXMLElement *LDAPProperty = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *LDAPName = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"ldapID"];
        NSXMLElement *LDAPValue = [[NSXMLElement alloc] initWithName:@"value" stringValue:ldapID];
        [LDAPValue addAttributeWithName:@"type" stringValue:@"string"];
        
        
        // Create the storeNumber property with name and value
        NSXMLElement *storeNumberProperty = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *storeNumberName = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"storenumber"];
        NSXMLElement *storeNumberValue = [[NSXMLElement alloc] initWithName:@"value" stringValue:storeNumber];
        [storeNumberValue addAttributeWithName:@"type" stringValue:@"string"];
        
        
        
        // Create the authorizer property with name and value
        NSXMLElement *authorizerProperty = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *authorizerName = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"authorizer"];
        NSXMLElement *authorizerValue = [[NSXMLElement alloc] initWithName:@"value" stringValue:myJID];
        [authorizerValue addAttributeWithName:@"type" stringValue:@"string"];
        
        // Create the isReturnResponseProperty property with name and value
        NSXMLElement *isReturnResponseProperty = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *isReturnResponseName = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"isReturnResponse"];
        NSXMLElement *isReturnResponseValue = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"YES"];
        [isReturnResponseValue addAttributeWithName:@"type" stringValue:@"string"];
        
        // Create the fromApplicationProperty property with name and value
        NSXMLElement *fromApplicationProperty = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *fromApplicationName = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"fromApplication"];
        NSXMLElement *fromApplicationValue = [[NSXMLElement alloc] initWithName:@"value" stringValue:fromApplication];
        [fromApplicationValue addAttributeWithName:@"type" stringValue:@"string"];
        
        
        
        // Add all the name and value elements to their respective property
        [property addChild:name];
        [property addChild:value];
        
        [CsmProperty addChild:csmName];
        [CsmProperty addChild:CsmValue];
        
        [LDAPProperty addChild:LDAPName];
        [LDAPProperty addChild:LDAPValue];
        
        [storeNumberProperty addChild:storeNumberName];
        [storeNumberProperty addChild:storeNumberValue];
        
        [authorizerProperty addChild:authorizerName];
        [authorizerProperty addChild:authorizerValue];
        
        [isReturnResponseProperty addChild:isReturnResponseName];
        [isReturnResponseProperty addChild:isReturnResponseValue];
        
        [fromApplicationProperty addChild:fromApplicationName];
        [fromApplicationProperty addChild:fromApplicationValue];
        
        // Finally add all the child properity to the properties parent
        [properties addChild:property];
        [properties addChild:CsmProperty];
        [properties addChild:LDAPProperty];
        [properties addChild:storeNumberProperty];
        [properties addChild:authorizerProperty];
        [properties addChild:isReturnResponseProperty];
        [properties addChild:fromApplicationProperty];
        
        // Ad the child properites to the whole xml element "message"
        [msg addChild:properties];
        
    
    }

    NSLog(@" ******** XMPP Service Response *************** \n %@", msg);
    return msg;
}




// Temp Group messeage sending Method to hardcoded muc's
- (BOOL)sendXMPPGroupMesseage:(NSString*)messeage jabberID:(NSString*)mucID {
    
    NSLog(@"Sending Group Chat Message to the XMPPStream");
    
    XMPPJID *mucJID = [XMPPJID jidWithString:mucID];
    XMPPMessage *message = [[XMPPMessage alloc] initWithType:@"groupchat" to:mucJID];
    // Add the body to the message
    [message addBody:messeage];
    [message addAttributeWithName:@"from" stringValue:xmppStream.myJID.bare];
    
    NSString *messageID = [[MessageIDFacotry alloc]getMessageID];
    
    [message addAttributeWithName:@"id" stringValue:messageID];
    
    if([mucID containsString:@"store"]){
        
            [storeXmppRoom sendMessage:message];
        
        
    }else if ([mucID containsString:@"csm"]){
        
        
            [csmXmppRoom sendMessage:message];
        
      
        
    }else if ([mucID containsString:@"mpu"]){
        
            
            [mpuXmppRoom sendMessage:message];
        
    
    }else if ([mucID containsString:@"manager"]){
        
        
            [mngXmppRoom sendMessage:message];
        

        
    }else{
        
        return NO;
    }
    
    AudioServicesPlaySystemSound(sendSoundID);
    return YES;
    
}

//Temp: Send response back to service request like punchtool. Need to be updated to send it dynamicly based on the jabberd ID
- (BOOL)sendXMPPServiceResponse:(NSString*)response messageBody:(NSString*)body msgID:(NSString*)messageID jabberID:(NSString*)mucID ldapID:(NSString*)ldapID storeNumber:(NSString*)storeNumber fromApplication:(NSString*)fromApplication {
    
  
    
    if([mucID containsString:@"store"]){
        

        [storeXmppRoom sendMessage: [self makeXMPPMessageFromString:response msgID:messageID mucJabberID:[XMPPJID jidWithString: mucID] storeNumber:storeNumber ldapID:ldapID messageBody:body fromApplication:fromApplication]];
        
    }else if ([mucID containsString:@"csm"]){
        
            [csmXmppRoom sendMessage: [self makeXMPPMessageFromString:response msgID:messageID mucJabberID:[XMPPJID jidWithString: mucID] storeNumber:storeNumber ldapID:ldapID messageBody:body fromApplication:fromApplication]];
        
    }else if ([mucID containsString:@"mpu"]){
        
            [mpuXmppRoom sendMessage: [self makeXMPPMessageFromString:response msgID:messageID mucJabberID:[XMPPJID jidWithString: mucID] storeNumber:storeNumber ldapID:ldapID messageBody:body fromApplication:fromApplication]];
      
    }else if ([mucID containsString:@"manager"]){
        
            [mngXmppRoom sendMessage: [self makeXMPPMessageFromString:response msgID:messageID mucJabberID:[XMPPJID jidWithString: mucID] storeNumber:storeNumber ldapID:ldapID messageBody:body fromApplication:fromApplication]];
        
        
    }else{
        
        return NO;
    }
    
    
    return YES;
    
}

// XMPPFramework Delegate called when a message fails to be sent
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    
    NSLog(@" xmppStream did fail to send message: %@ with error: %@", message, error);
   
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark MUC Logic
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Get current MUC's from the xmpp server using a IQ (XMPP Server Info Query. Currently not being used

/*
- (void)getChatRooms {

    NSString* server = @"conference.localhost";
    XMPPJID *servrJID = [XMPPJID jidWithString:server];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    
    [iq addAttributeWithName:@"id" stringValue:@"chatroom_list"];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
}

*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Send Send Local Notification. Dose not work. Need to use APNS to trigger
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*- (void)setUserNotifications {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (error) {
                                  NSLog(@"Error When getting Authorization of NotificaitonCenter: %@",error);
                                  ///[self showAlert];
                              }
                          }];
    
    
} */


/*- (void)showAlert :(NSString*)JID messeageBody:(NSString*)body {
    
    
    NSLog(@"showAlert called");
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:JID
                                                          arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:body
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    // 4. update application icon badge number
    content.badge = [NSNumber numberWithInteger:([UIApplication sharedApplication].applicationIconBadgeNumber + 1)];
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:5.f
                                                  repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                          content:content
                                                                          trigger:trigger];
    /// 3. schedule localNotification
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"add NotificationRequest succeeded!");
        }
    }];
} */


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Manage JID in Roster & unsubscribe
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// XMPPFramework delegate method that is called when we receive a presence  sub request from a JID
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    
    BOOL success = [self checkRosterForUser:[presence from]];
    
    if(success){
        
    [sender acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
    
    }
}

// Unsubscribe to a JID and remove JID from Roster Currently not implemented
- (void)unsubscribeToJIDAndUpdateRoster:(XMPPJID*)removeJID {
    
    [xmppRoster removeUser: removeJID];
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unsubscribed" to:removeJID];
    [xmppStream sendElement:presence];
    
}

// Send subscribe reqeust to a JID
- (void)sendSubscribeMessageToUser:(NSString*)userID {
   
    XMPPJID* jbid=  [XMPPJID jidWithString:userID];
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"subscribe" to:jbid];
    [xmppStream sendElement:presence];
   
}

// Each time we get a presence reqeust from a JID in one of our MUC's
// We check to see if we are subbed to that user & if they are in our roseter
// If not we send a subscription to them
- (BOOL)checkRosterForUser:(XMPPJID*)userFromJID {
    
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:userFromJID
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
   
  
    // evaluate the JID to make sure it's not a muc.
    if (![displayName isEqualToString:userFromJID.bare] && ![userFromJID.bare containsString:@"@muc"] && ![userFromJID.bare containsString:@"@confrance"]) {
        
        
        [self sendSubscribeMessageToUser:userFromJID.bare];
        
        return YES;
        
    }else if ([userFromJID.bare containsString:@"@muc"] || [userFromJID.bare containsString:@"@conference"]){
        
       
        [self unsubscribeToJIDAndUpdateRoster:user.jid];

    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark MUC Logic
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// xmppRoom delegate method fire from fetchMembersList
-(void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items {
    
    
}

// xmppRoom delegate method fire from fetchModeratorList
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items {
    
    
    
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult {
    
   
    
}


- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
    
    
}


// XMPPFramework Delegate method called when a JID leaves a MUC/Confrance
- (void)xmppRoomDidLeave:(XMPPRoom *)sender {
 
 
    
}

// XMPPFramework Delegate method called when a muc/confrance is destoryed
- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {
    
 
    NSLog(@"XMPP Room has been distoryed: %@", sender.roomJID.bare);
}

// XMPPFramework Delegate method called when privileges have changed in a muc the user is in.
- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult {
    

}

// XMPPFramework Delegate method called when a JID enters a MUC/Confrance
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    
    //Check to make sure we are subed to eachother.
    //If not then send a subscription reqeust to that JID
    
    
    [self checkRosterForUser:[presence from]];
   
    // Create string value of roomJID
    NSString *stringJID = [NSString stringWithFormat:@"%@",sender.roomJID];
    
    if(![stringJID containsString:@"admin@"]){
   
    //Check to see if the muc JID exits in the NSMutableDictionary
    if([mucMememberList objectForKey:stringJID]){
        
        NSMutableDictionary *mucMemembers = [[NSMutableDictionary alloc]init];
        mucMemembers = [mucMememberList objectForKey:stringJID];
        
        // Since this is a Muc JID we are getting we just need the
        // resourse ID associated with it so we are pulling only the
        // string after the "/"
        NSString *tempJID = [NSString stringWithFormat:@"%@",occupantJID];
        NSArray *array = [tempJID componentsSeparatedByString:@"/"];
        
        // Check for Null issues in the Array
        if([array objectAtIndex:1]) {
        
        tempJID = [array objectAtIndex:1];
        
           
            
            [self checkRosterForUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",tempJID,[xmppStream.myJID domain]]]];
            
        }else{
            
            // Set to Unknown if the there is no data passed the "/" in sender
            tempJID = @"Unknown";
        }
     
        //now check to see if the JID is in the NSMutableArray we pulled from the Dictionary. If not there add it
        if(![mucMemembers objectForKey:tempJID]){
        
            [mucMemembers setObject:tempJID forKey:tempJID];
            [mucMememberList setObject:mucMemembers forKey:stringJID];
            
        }
    
    }else{
        
        // Since this is a Muc JID we are getting we just need the
        // resourse ID associated with it so we are pulling only the
        // string after the "/"
        NSString *tempJID = [NSString stringWithFormat:@"%@",occupantJID];
        NSArray *array = [tempJID componentsSeparatedByString:@"/"];
        
        if([array objectAtIndex:1]) {
            
        
        tempJID = [array objectAtIndex:1];
            
        }else{
            
            tempJID = @"Unknown";
        }
        
        // Add the JID name to the member list
        NSMutableDictionary *mucMembers = [[NSMutableDictionary alloc]init];
        [mucMembers setObject:tempJID forKey:tempJID];
        [mucMememberList setObject:mucMembers forKey:stringJID];
        
    
    }
    
    // Post the udpated muc memeber list consumed by the "CreateMucVeiwController" JP - Needs class name udpate
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mucMememberChange" object:mucMememberList];

    }
}

// XMPPFramework Delegate Method that is called each time a JID leaves a MUC the users is part of
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    
    // Create string value of roomJID
    NSString *stringRoomJID = [NSString stringWithFormat:@"%@",sender.roomJID];
    
    //Check to see if the muc JID exits in the NSMutableDictionary
    if([mucMememberList objectForKey:stringRoomJID]){
        
        NSMutableDictionary *mucMemembers = [[NSMutableDictionary alloc]init];
        mucMemembers = [mucMememberList objectForKey:stringRoomJID];
        
        NSString *tempJID = [NSString stringWithFormat:@"%@",occupantJID];
        NSArray *array = [tempJID componentsSeparatedByString:@"/"];
        
        if([array objectAtIndex:1]) {
            
            tempJID = [array objectAtIndex:1];
            
        }else{
            
            tempJID = @"Unknown";
        }

        
        //now check to see if the JID is in the NSMutableArray we pulled from the Dictionary. If not there add it
        if([mucMemembers objectForKey:tempJID]){
            
            [mucMemembers removeObjectForKey:tempJID];
            [mucMememberList setObject:mucMemembers forKey:stringRoomJID];
            
            // Post the cange in the muc member
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mucMememberChange" object:mucMememberList];
            
        }
        
    }
    
 
}


// Method to setup the MUC's. It's currently hardcodded and needs to be updated to be dynamic
// Will be called by MesseageUserTableView or Left slide View After LDAP login
- (void)setMyMucList:(NSString*)locationnumber isManger:(BOOL)manager {
    
    
    // setup list of MUC's if a mamanger logs into CSM
    if(manager){
        
        
        NSString *tempStore = [NSString stringWithFormat:@"Store%@",locationnumber];
        
        
        XMPPJID *STRJID = [XMPPJID jidWithUser:tempStore
                                        domain:xmppMucDomain
                                      resource:nil];
        
        
        
        NSString *tempCSM = [NSString stringWithFormat:@"CSM%@",locationnumber];
        
    
        
        XMPPJID *CSMJID = [XMPPJID jidWithUser:tempCSM
                                        domain:xmppMucDomain
                                      resource:nil];
        
        NSString *tempMPU = [NSString stringWithFormat:@"MPU%@",locationnumber];
        
      
        
        XMPPJID *MPUJID = [XMPPJID jidWithUser:tempMPU
                                        domain:xmppMucDomain
                                      resource:nil];
        
        NSString *tempMNG = [NSString stringWithFormat:@"Manager%@",locationnumber];
        
     
        
        XMPPJID *MNGJID = [XMPPJID jidWithUser:tempMNG
                                       domain:xmppMucDomain
                                     resource:nil];
        
        [myMucList setObject:STRJID forKey:@"STR"];
        [myMucList setObject:CSMJID forKey:@"CSM"];
        [myMucList setObject:MPUJID forKey:@"MPU"];
        [myMucList setObject:MNGJID forKey:@"MNG"];
        
        // Join the muc based on Hardcoded Muc's JP - Needs to be udpated to be dynamic
        [self createJoinStoreMuc];
        [self createJoinCSMMuc];
        [self createJoinMPUMuc];
        [self createJoinMNGMuc];
        
        //Default the user into the store MUC on load
      //  toUserJid = [myMucList objectForKey:@"STR"];
        
        
    }else{
        
        //Setup MUC if none Manager Logs into CSM
        XMPPJID *STRJID = [XMPPJID jidWithUser:@"Store"
                                        domain:xmppMucDomain
                                      resource:myJID];
        
        [myMucList setObject:STRJID forKey:@"STR"];
        
        [self createJoinStoreMuc];
        
    }
    
}


// JP need to find a better way
// create or Join the store Muc
- (void)createJoinStoreMuc {
    
    NSLog(@"CreateJoinStoreMuc with ID: %@", [myMucList objectForKey:@"STR"]);
    

    
    storeXmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomHybridStorage jid:[myMucList objectForKey:@"STR"] dispatchQueue:dispatch_get_main_queue()];
    [storeXmppRoom activate:xmppStream];
    
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"0"];
    
    [storeXmppRoom joinRoomUsingNickname:xmppStream.myJID.user history:history];
    [storeXmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [dynamicMucList setObject:storeXmppRoom forKey:storeXmppRoom.roomJID.bare];
}


// JP need to find a better way
// create or Join the store CSM Muc
- (void)createJoinCSMMuc {
    
  
    
    csmXmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomHybridStorage jid:[myMucList objectForKey:@"CSM"] dispatchQueue:dispatch_get_main_queue()];
    [csmXmppRoom activate:xmppStream];
    
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"0"];
    
    [csmXmppRoom joinRoomUsingNickname:xmppStream.myJID.user history:history];
    [csmXmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [dynamicMucList setObject:csmXmppRoom forKey:csmXmppRoom.roomJID.bare];
    
}


// JP need to find a better way
// create or Join the store MPU Muc
- (void)createJoinMPUMuc {
    
   
    
    mpuXmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomHybridStorage jid:[myMucList objectForKey:@"MPU"] dispatchQueue:dispatch_get_main_queue()];
    [mpuXmppRoom activate:xmppStream];
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"0"];
    [mpuXmppRoom joinRoomUsingNickname:xmppStream.myJID.user history:history];
    [mpuXmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [dynamicMucList setObject:mpuXmppRoom forKey:mpuXmppRoom.roomJID.bare];
    
}

// JP need to find a better way
// create or Join the store CSM Muc
- (void)createJoinMNGMuc {
    
    
    mngXmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomHybridStorage jid:[myMucList objectForKey:@"MNG"] dispatchQueue:dispatch_get_main_queue()];
    [mngXmppRoom activate:xmppStream];
    
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"0"];
    
    [mngXmppRoom joinRoomUsingNickname:xmppStream.myJID.user history:history];
    [mngXmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [dynamicMucList setObject:mngXmppRoom forKey:mngXmppRoom.roomJID.bare];
    
}

// Update Method to Join muc's that is Dynamic
- (void)createJoinDynamicMuc:(NSString*)mucID {
    
    XMPPRoom  *dynamicRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomHybridStorage jid:[myMucList objectForKey:mucID] dispatchQueue:dispatch_get_main_queue()];
    
    [dynamicMucList setObject:dynamicRoom forKey:mucID];
    [[dynamicMucList objectForKey:mucID] joinRoomUsingNickname:xmppStream.myJID.user history:nil password:@"xmpp"];
    [[dynamicMucList objectForKey:mucID] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}


// XMPPFramework delegate method called when a room is created by the user
- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    
    
}

// XMPPFramework delegate method called when a room is joined by the user
// Can be used to configure the room if needed
- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    
    // Sending the request to get the rooms configurations
    [sender fetchConfigurationForm];
    
    // Sending presence to memembers of the muc with Avaiable
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    
    
}


// XMPPFramework Delegate Method called when a [xmpproom fetchConfigurationForm] is used
// Method is used to configure a room/muc/confrance but xmpp server needs to configred to allow
// users to modify the rooms configurations
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
 
    /*
    NSXMLElement *newConfig = [configForm copy];
    NSArray* fields = [newConfig elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
            
        }else if ([var isEqualToString:@"muc#roomconfig_roomname"]){
            [field removeChildAtIndex:0];
            NSString *temp = [NSString stringWithFormat:@"%@",sender.roomJID];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:temp]];
            
        }
        else if ([var isEqualToString:@"muc#roomconfig_publicroom"]){
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
        else if ([var isEqualToString:@"muc#roomconfig_whois"]) {
            [field removeChildAtIndex:0];
            [field insertChild:[NSXMLElement elementWithName:@"value" stringValue:@"anyone"] atIndex:0];
        }
        else if ([var isEqualToString:@"muc#roomconfig_allow_subscription"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
        else if ([var isEqualToString:@"muc#roomconfig_membersonly"]){
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
        }
        else if ([var isEqualToString:@"public_list"]){
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
        else if ([var isEqualToString:@"muc#roomconfig_allowinvites"]){
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
   
    [sender configureRoomUsingOptions:newConfig];
    
     */
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Archived Messeage logic
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Method used to get Archived Messages from Apple corde Data
// Called by the MessageviewConroller
- (NSMutableDictionary*)getArchivedMesseages {
    

    NSArray *tmp = [[NSArray alloc]init];
    tmp = [self retrivePastMesseages];
    
    NSMutableArray *aTemp = [[NSMutableArray alloc]init];
    aTemp = [NSMutableArray arrayWithArray:tmp];
   
    NSMutableDictionary *messeagesbyJID = [[NSMutableDictionary alloc]init];
    messeagesbyJID = [self setCoreDataMesseages:aTemp];
    
  
    
    return messeagesbyJID;
}


//Pull old messeages that where stored by coreData
- (NSArray*)retrivePastMesseages {
    
    // Pull ALL messages
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [self.xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    
    fetchRequest.entity = messageEntity;
   
    // Sort the data based on time stamp
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    return results;
}

// Method to set the core data return Array to a NSMutable Dict using the jabberd ID as a key
// Only save messages that are not duplicates i.e. messages the framework recives that we send
- (NSMutableDictionary*)setCoreDataMesseages:(NSMutableArray*)coreDataMesseageObject{
    
    
    NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc]init];
    
    for (XMPPMessageArchiving_Message_CoreDataObject *message in coreDataMesseageObject) {
        
        NSXMLElement *xmlMessage = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
        
       // NSString *from = [xmlMessage attributeStringValueForName:@"from"];
        NSXMLNode *type = [xmlMessage attributeForName:@"type"];
        NSXMLNode *from = [xmlMessage attributeForName:@"from"];
        NSXMLNode *to = [xmlMessage attributeForName:@"to"];
        
      
        
        
        NSString *lowUserName = [userName lowercaseString];
        
        
        
        
        
        if([type.stringValue isEqualToString:@"chat"]){
            
            
            if(message.isOutgoing && [from.stringValue containsString:lowUserName]){
                
                NSMutableArray *msgSet = [[NSMutableArray alloc]init];
                
                if(![messageDictionary  objectForKey:message.bareJidStr]){
                    
                    [msgSet addObject:message];
                    [messageDictionary  setObject:msgSet forKey:message.bareJidStr];
                    
                }else{
                    
                    msgSet = [messageDictionary  objectForKey:message.bareJidStr];
                    [msgSet addObject:message];
                    [messageDictionary setObject:msgSet forKey:message.bareJidStr];
                    
                }
                
            }else if(!message.isOutgoing && [to.stringValue containsString:lowUserName]){
                
                NSMutableArray *msgSet = [[NSMutableArray alloc]init];
                
                if(![messageDictionary  objectForKey:message.bareJidStr]){
                    
                    [msgSet addObject:message];
                    [messageDictionary  setObject:msgSet forKey:message.bareJidStr];
                    
                }else{
                    
                    msgSet = [messageDictionary  objectForKey:message.bareJidStr];
                    [msgSet addObject:message];
                    [messageDictionary setObject:msgSet forKey:message.bareJidStr];
                    
                    }
            }
        }
        
        if([type.stringValue isEqualToString:@"groupchat"]){
            
        
            if(message.isOutgoing && [from.stringValue containsString:lowUserName]){
             
                NSMutableArray *msgSet = [[NSMutableArray alloc]init];
                
                if(![messageDictionary  objectForKey:message.bareJidStr]){
                    
                    [msgSet addObject:message];
                    [messageDictionary  setObject:msgSet forKey:message.bareJidStr];
                    
                }else{
                    
                    msgSet = [messageDictionary  objectForKey:message.bareJidStr];
                    [msgSet addObject:message];
                    [messageDictionary setObject:msgSet forKey:message.bareJidStr];
                    
                }
                
            }else if(!message.isOutgoing && ![from.stringValue containsString:lowUserName]){
            
                NSMutableArray *msgSet = [[NSMutableArray alloc]init];
                
                if(![messageDictionary  objectForKey:message.bareJidStr]){
                    
                    [msgSet addObject:message];
                    [messageDictionary  setObject:msgSet forKey:message.bareJidStr];
                    
                }else{
                    
                    msgSet = [messageDictionary  objectForKey:message.bareJidStr];
                    [msgSet addObject:message];
                    [messageDictionary setObject:msgSet forKey:message.bareJidStr];
                    
                }
            }

        }
    }
    return messageDictionary;
}

/*-(NSMutableDictionary*)setCoreDataMesseages:(NSMutableArray*)coreDataMesseageObject{
    
    
    NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc]init];
    
    for (XMPPMessageArchiving_Message_CoreDataObject *message in coreDataMesseageObject) {
        
        NSXMLElement *xmlMessage = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
        
        NSString *from = [xmlMessage attributeStringValueForName:@"from"];
        NSXMLNode *type = [xmlMessage attributeForName:@"type"];
        NSXMLNode *to = [xmlMessage attributeForName:@"to"];
        
          NSLog(@"****** from value in message: %@", from);
          NSLog(@"****** to value in message: %@", to.stringValue);
          NSLog(@"****** Message Types being pulled from Archive: %@",type.stringValue);
        
        NSString *newLower = [userName lowercaseString];
        
 
 
 
 //////////
 if(message.isOutgoing && [from.stringValue containsString:lowUserName]){
 
 NSLog(@"Outgoing message bellow");
 NSLog(@"My user name: %@", lowUserName);
 NSLog(@"****** from value in message: %@", from);
 NSLog(@"****** value for message.bareJid: %@", message.bareJidStr);
 NSLog(@"****** Message Types being pulled from Archive: %@",type.stringValue);
 NSLog(@"****** to value in message: %@", to.stringValue);
 NSLog(@"****** the whole msg ***** : %@", message.messageStr);
 NSMutableArray *msgSet = [[NSMutableArray alloc]init];
 
 if(![messageDictionary  objectForKey:message.bareJidStr]){
 
 [msgSet addObject:message];
 [messageDictionary  setObject:msgSet forKey:message.bareJidStr];
 
 }else{
 
 msgSet = [messageDictionary  objectForKey:message.bareJidStr];
 [msgSet addObject:message];
 [messageDictionary setObject:msgSet forKey:message.bareJidStr];
 
 }
 
 }else if(![from.stringValue containsString:lowUserName]){
 
 NSLog(@"Incoming message data bellow");
 NSLog(@"My user name: %@", lowUserName);
 NSLog(@"****** from value in message: %@", from);
 NSLog(@"****** value for message.bareJid: %@", message.bareJidStr);
 NSLog(@"****** Message Types being pulled from Archive: %@",type.stringValue);
 NSLog(@"****** to value in message: %@", to.stringValue);
 NSLog(@"****** the whole msg ***** : %@", message.messageStr);
 NSMutableArray *msgSet = [[NSMutableArray alloc]init];
 
 if(![messageDictionary  objectForKey:message.bareJidStr]){
 
 [msgSet addObject:message];
 [messageDictionary  setObject:msgSet forKey:message.bareJidStr];
 
 }else{
 
 msgSet = [messageDictionary  objectForKey:message.bareJidStr];
 [msgSet addObject:message];
 [messageDictionary setObject:msgSet forKey:message.bareJidStr];
 
 }
 
 }
 
/////////
 
        //check incoming messeages
        if(!message.isOutgoing){
 
 
            if(![from containsString:newLower]) {
 
                NSMutableArray *msgSet = [[NSMutableArray alloc]init];
 
                if(![messageDictionary  objectForKey:message.bareJidStr]){
 
                    [msgSet addObject:message];
                    [messageDictionary  setObject:msgSet forKey:message.bareJidStr];
 
                }else{
 
                    msgSet = [messageDictionary  objectForKey:message.bareJidStr];
                    [msgSet addObject:message];
                    [messageDictionary setObject:msgSet forKey:message.bareJidStr];
 
                }
                
            }
            
            // get and store outgoing messages
        }else{
            
            NSMutableArray *msgSet = [[NSMutableArray alloc]init];
            
            if(![messageDictionary objectForKey:message.bareJidStr]){
                
                [msgSet addObject:message];
                [messageDictionary setObject:msgSet forKey:message.bareJidStr];
                
            }else{
                
                msgSet = [messageDictionary objectForKey:message.bareJidStr];
                [msgSet addObject:message];
                [messageDictionary setObject:msgSet forKey:message.bareJidStr];
                
            }
            
        }
        
    }
    return messageDictionary;
}

*/
- (BOOL)isXmppConnected {
    
    
    return isXmppConnected;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for Auto send away presence after 15min of inactivity
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Main method for starting/cancling & restarting the away timer
- (void)startUpdateAwayThread{
    
    // check to see if we are already set to away & 
    if(awayPresenceOn == AWAY_ON){
        
        [self sendAvaiablePresence];
        
    }
    
    if ([awayTimer isValid]) {
        
        [awayTimer invalidate];
        
    }
    
      awayTimer = nil;
    
    double secondsInMinutes = 60.0;
    double delayInSeconds = 5 * secondsInMinutes;
    
  
    
    awayTimer = [NSTimer scheduledTimerWithTimeInterval:delayInSeconds
                                     target:self
                                   selector:@selector(sendAwayPresence)
                                   userInfo:nil
                                    repeats:NO];
    

}

- (void)sendAvaiablePresence {
    
    
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)sendAwayPresence {
    
    awayPresenceOn = AWAY_ON;
    
    
    XMPPPresence *presence = [XMPPPresence presence];
    
    
    // Initialize XML element <show/> for specifying your status
    NSXMLElement *show = [NSXMLElement elementWithName:@"show"];
    
    // Initialize XML element <status/> for describing your status
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
 
    [show setStringValue:@"away"];
    [status setStringValue:@"Away"];

  
    [presence addChild:status];
    [presence addChild:show];
    [[self xmppStream] sendElement:presence];
}


- (void)startGestureRecgonizer {
    
   
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startUpdateAwayThread)];
    tapGestureRecognizer.delegate = self;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
   
    [self startUpdateAwayThread];
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for saving and requesting Pebble Picture Links
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (UIImage*)getMyPebbleImage {
    
    UIImage *myPicture = NULL;
    
    if(pictureLink.length <= 0){
        
        myPicture = [UIImage imageNamed:@"user-no-image.png"];
        
       
        
    }else{
    
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:pictureLink]];
    
        myPicture = [UIImage imageWithData: imageData];
        
      
        
    }
    
    return myPicture;
    
}

- (BOOL)checkForRosterUserPebblePicture:(XMPPJID*)jid{
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"pebblePictureLinks"]){
        
        NSMutableDictionary *pebblePictureLinks = [defaults objectForKey:@"pebblePictureLinks"];
        
        if([pebblePictureLinks objectForKey:jid.bare]){
            
            return YES;
        }
    }
   
    return NO;
}

- (BOOL)checkForPebblePictureRequest:(XMPPMessage*)message {
    

    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.XMLString error:nil];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    NSArray *properties = [prop elementsForName:@"property"];
    
    
    // itierate over the array to find the messageID element
    // If it does not exist then return with NULL
    for(id object in properties){
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        if([name.stringValue isEqualToString:@"isPebblePicLinkRequest"] && [value.stringValue isEqualToString:@"YES"] ){
            
            
            return YES;
        }
        
    }
    
    return NO;
}



- (void)sendPebblePictureLinkRequest:(XMPPJID*)jid{
    
   
    
    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"headline" to:jid.bareJID];
    
    // Create the parent properties element
    NSXMLElement *properties = [NSXMLElement elementWithName:@"properties"];
        
    // Set the ejabber protocal type for Smack
    [properties addAttributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
        
    // Create the messageID Properity with name and value
    NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
    NSXMLElement *name = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"isPebblePicLinkRequest"];
    NSXMLElement *value = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"YES"];
    [value addAttributeWithName:@"type" stringValue:@"string"];
        
        
    [property addChild:name];
    [property addChild:value];
        
    
    // Finally add all the child properity to the properties parent
    [properties addChild:property];
    
        
    // Ad the child properites to the whole xml element "message"
    [msg addChild:properties];
    
    [xmppStream sendElement:msg];
    
}

- (void)sendCustomPicture:(XMPPJID*)jid{
    
  //  NSXMLElement *imageMessage = [[UserSettings alloc]userImageToElement:userSettings.userImage];
    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"headline" to:jid.bareJID];
   
    NSXMLElement *properties = [[UserSettings alloc]userImageToElementProperties:userSettings.userImage];
   
    [msg addChild:properties];
    
   
    [xmppStream sendElement:msg];
    
    
}

- (void)sendCustomPictureEveryone:(UIImage*)image{
    
  
   // XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:@"jpoe1@localhost"]];
    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"chat"];
    
    NSXMLElement *properties = [[UserSettings alloc]userImageToElementProperties:image];
    
    [msg addChild:properties];
    
    [msg addAttributeWithName:@"from" stringValue:xmppStream.myJID.bare];
 
    [storeXmppRoom sendMessage:msg];
   // [xmppStream sendElement:msg];
}

- (void)sendPebblePictureLink:(XMPPJID*)jid{
    
    // JP added because of QA overide would pass a null
    if(pictureLink.length <= 0){
       
        pictureLink = @"https://pebble.searshc.com/Images/no-image.png";
       
    }
    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"headline" to:jid.bareJID];
    
    // Create the parent properties element
    NSXMLElement *properties = [NSXMLElement elementWithName:@"properties"];
    
    // Set the ejabber protocal type for Smack
    [properties addAttributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
    
    // Create the messageID Properity with name and value
    NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
    NSXMLElement *name = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"pebblePicLink"];
    NSXMLElement *value = [[NSXMLElement alloc] initWithName:@"value" stringValue:pictureLink];
    [value addAttributeWithName:@"type" stringValue:@"string"];
    
    
    [property addChild:name];
    [property addChild:value];
    
    
    // Finally add all the child properity to the properties parent
    [properties addChild:property];
    
    
    // Ad the child properites to the whole xml element "message"
    [msg addChild:properties];
    
  
    [xmppStream sendElement:msg];
        
    
}

- (void)checkSavePebblePictureLink:(XMPPMessage*)message {
    
    BOOL success = NO;
    BOOL customeSuccess = NO;
    
    NSString *pebbleLink = NULL;
    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.XMLString error:nil];
    NSXMLNode *from = [element attributeForName:@"from"];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    NSArray *properties = [prop elementsForName:@"property"];
    
    
    // itierate over the array to find the messageID element
    // If it does not exist then return with NULL
    for(id object in properties){
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        if([name.stringValue isEqualToString:@"pebblePicLink"]){
            
           pebbleLink = value.stringValue;
            success = YES;
            break;
        }
        if([name.stringValue isEqualToString:@"customPicture"]){
            
            pebbleLink = value.stringValue;
            customeSuccess = YES;
            break;
        }
        
    }
    
    if(success){
       
        [[BuddyCustomePictures alloc]saveBuddyPebblePicture:message pebbleLink:pebbleLink];
    }
    
    if(customeSuccess){
        
        [[BuddyCustomePictures alloc]setUserImage:[self theCleanerOfUserJID: from.stringValue] userImage:pebbleLink];
    }
    
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for removing or returning or adding the XMPPStreams Domain to Users JID's
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)theCleanerOfUserJID:(NSString*)malformedJID {
    
    NSString *cleanJabberID = malformedJID;
    
    
    if ([malformedJID containsString:@"@muc"] || ([malformedJID containsString:@"@conference"] && [malformedJID containsString:@"/"]) ){
        
            NSArray *tmp = [malformedJID componentsSeparatedByString:@"/"];
            
            if([tmp objectAtIndex:1]){
                
                cleanJabberID = [NSString stringWithFormat:@"%@@%@", [tmp objectAtIndex:1], [xmppStream.myJID domain]];
                
                return cleanJabberID;
            }

    }
    
    if(![malformedJID containsString:[xmppStream.myJID domain]]){
        
        cleanJabberID = [NSString stringWithFormat:@"%@@%@", malformedJID, [xmppStream.myJID domain]];
        
        return cleanJabberID;
        
        
    }else if([malformedJID containsString:@"/"] && [malformedJID containsString:[xmppStream.myJID domain]]){
        
        NSArray *tmp = [malformedJID componentsSeparatedByString:@"/"];
        cleanJabberID = [tmp objectAtIndex:0];
        
        return cleanJabberID;
    }
    
    return cleanJabberID;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logice for keeping, updating and removeing roster buddy presences
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)XMPPRosterPresenceStatus:(XMPPJID*)from presence:(XMPPPresence*)presence{
    
   
    [self checkInstinceRosterBuddyPresenceDictionary];
    
    
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:presence.XMLString error:nil];
    
    //pull the properties element value
    NSXMLElement *xmlPresence = [element elementForName:@"show"];
    
    
  
    if([xmlPresence.stringValue isEqualToString:@"away"]){
        
        [self udpateRosterBuddyPresenceAway:presence from:from];
        
    }else{
        
        if([presence.type isEqualToString:@"unavailable"]){
        
        [self udpateRosterBuddyPresenceUnavailable:presence from:from];
        
        }
        
         if([presence.type isEqualToString:@"available"]){
        
        [self udpateRosterBuddyPresenceAvailable:presence from:from];
        
         }
    }
    
    
}

- (void)udpateRosterBuddyPresenceUnavailable:(XMPPPresence*)presence from:(XMPPJID*)from{
    
    NSMutableDictionary *available = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"available"]];
    
    NSMutableDictionary *away = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"away"]];
    
    NSMutableDictionary *unavailable = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"unavailable"]];
    
    
    
    if(![unavailable objectForKey:from.bare]){
        
        
        [unavailable setObject:presence.type forKey:from.bare];
        [rosterBuddyPresenceList setObject:unavailable forKey:@"unavailable"];
        
        
        if([available objectForKey:from.bare]){
            
            [available removeObjectForKey:from.bare];
            
            [rosterBuddyPresenceList setObject:available forKey:@"available"];
            
        }
        
        if([away objectForKey:from.bare]){
            
            
            [away removeObjectForKey:from.bare];
            [rosterBuddyPresenceList setObject:away forKey:@"away"];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"buddyPresenceChanged" object:rosterBuddyPresenceList];
    }
    
   
    
   
    
    
}

- (void)udpateRosterBuddyPresenceAway:(XMPPPresence*)presence from:(XMPPJID*)from{
    
    NSMutableDictionary *available = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"available"]];
    
    NSMutableDictionary *away = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"away"]];
    
    NSMutableDictionary *unavailable = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"unavailable"]];
    
    if(![away objectForKey:from.bare]){
        
        
        [away setObject:@"away" forKey:from.bare];
        [rosterBuddyPresenceList setObject:away forKey:@"away"];
        
        if([available objectForKey:from.bare]){
            
            [available removeObjectForKey:from.bare];
            [rosterBuddyPresenceList setObject:available forKey:@"available"];
            
        }
        
        if([unavailable objectForKey:from.bare]){
            
            
            [unavailable removeObjectForKey:from.bare];
            [rosterBuddyPresenceList setObject:unavailable forKey:@"unavailable"];
        }
     
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"buddyPresenceChanged" object:rosterBuddyPresenceList];
    }
    
    
   
    
    
}

- (void)udpateRosterBuddyPresenceAvailable:(XMPPPresence*)presence from:(XMPPJID*)from{
    
    NSMutableDictionary *available = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"available"]];
    
    NSMutableDictionary *away = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"away"]];
    
    NSMutableDictionary *unavailable = [[NSMutableDictionary alloc]initWithDictionary:[rosterBuddyPresenceList objectForKey:@"unavailable"]];
    
    if(![available objectForKey:from.bare]){
        
        
        [available setObject:presence.type forKey:from.bare];
        [rosterBuddyPresenceList setObject:available forKey:@"available"];
        
        if([away objectForKey:from.bare]){
            
            
            [away removeObjectForKey:from.bare];
            [rosterBuddyPresenceList setObject:away forKey:@"away"];
            
        }
        
        if([unavailable objectForKey:from.bare]){
            
            
            [unavailable removeObjectForKey:from.bare];
            [rosterBuddyPresenceList setObject:unavailable forKey:@"unavailable"];
        }
     
       [[NSNotificationCenter defaultCenter] postNotificationName:@"buddyPresenceChanged" object:rosterBuddyPresenceList];
        
    }
    
   
    
    
}


- (void)checkInstinceRosterBuddyPresenceDictionary {
    
    if(![rosterBuddyPresenceList objectForKey:@"available"]){
        
        
        NSMutableDictionary *available = [[NSMutableDictionary alloc]init];
        
        [rosterBuddyPresenceList setObject:available forKey:@"available"];
        
    }
    
    if(![rosterBuddyPresenceList objectForKey:@"away"]){
        
        
        NSMutableDictionary *away = [[NSMutableDictionary alloc]init];
        
        [rosterBuddyPresenceList setObject:away forKey:@"away"];
        
    }
    
    if(![rosterBuddyPresenceList objectForKey:@"unavailable"]){
        
        
        NSMutableDictionary *unavailable = [[NSMutableDictionary alloc]init];
        
        [rosterBuddyPresenceList setObject:unavailable forKey:@"unavailable"];
        
    }
    
}

- (NSMutableDictionary*)getRosterBuddyPresenceList {
    
    
    return rosterBuddyPresenceList;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark JP test logic for duplciate messages
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/*
- (void)xmppStreamManagement:(XMPPStreamManagement *)sender wasEnabled:(DDXMLElement *)enabled{
    
    NSLog(@"xmppStreamManagment was Enabled: %@ \n\n\n", enabled.stringValue);
}

- (void)xmppStreamManagementDidRequestAck:(XMPPStreamManagement *)sender{
    
    NSLog(@"xmppStreamManagmentDidRequestAck has been called \n\n\n");
}

- (void)xmppStreamManagement:(XMPPStreamManagement *)sender wasNotEnabled:(DDXMLElement *)failed{
    
      NSLog(@"xmppStreamManagment wasNotEnabled: %@ \n\n\n", failed.stringValue);
    
}

- (void)xmppStreamManagement:(XMPPStreamManagement *)sender didReceiveAckForStanzaIds:(NSArray *)stanzaIds{
    
    
    NSLog(@"xmppStreamManagement StanzaID's Items in Array %i \n\n\n", stanzaIds.count);
   
    for (NSString *string in stanzaIds) {
        NSLog(@"xmppStreamManagement DidRecieveAckForStanzaIDs: %@ \n\n\n", string);
    }
    

}


- (void)xmppStreamManagement:(XMPPStreamManagement *)sender getIsHandled:(BOOL *)isHandledPtr stanzaId:(__autoreleasing id *)stanzaIdPtr forReceivedElement:(XMPPElement *)element{
   

    
    NSLog(@" xmppStreamManagement getIsHandled forReceivedElement: %@ getisHandled Bool: %s \n\n\n", element.stringValue,  isHandledPtr);
    
}
 
 */


@end
