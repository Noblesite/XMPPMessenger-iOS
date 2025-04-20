#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>
#import "MMDrawerController.h"
#import "ChannelListTableViewController.h"
#import "MesseageViewController.h"
#import "MucMembersViewController.h"
#import "LoginViewController.h"
#import "ApprovalViewController.h"
#import "UserSettingsViewController.h"
#import "UserSettings.h"
#import "BuddyCustomePictures.h"
#import "MessageIDFacotry.h"

#import <malloc/malloc.h>

@import XMPPFramework;





@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate,XMPPRosterDelegate,XMPPRoomDelegate,XMPPRoomHybridStorageDelegate,XMPPRoomLightDelegate,XMPPRoomMemoryStorageDelegate, XMPPStreamManagementDelegate,XMPPRegistrationDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPRoomHybridStorage *xmppRoomHybridStorage;
    XMPPRoom *xmppRoom;
    
    
    
    XMPPRoom *storeXmppRoom;
    XMPPRoom *csmXmppRoom;
    XMPPRoom *mpuXmppRoom;
    XMPPRoom *mngXmppRoom;
    
    int xmppRegState;
    int shouldLogout;
    int awayPresenceOn;
	
	NSString *password;
    NSString *myJID;

    
	BOOL customCertEvaluation;
	
	BOOL isXmppConnected;
    
    BOOL isManager;
	
	
}

//MMDrawerController Framework propertys
@property (nonatomic, strong) MMDrawerController * drawerController;


//XMPPFramework propertys 
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong) XMPPRoomHybridStorage *xmppRoomHybridStorage;
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;
@property (nonatomic, strong) XMPPRoom *xmppRoom;
@property (nonatomic, strong) XMPPMessage *chatMesseage;
@property (nonatomic, strong) XMPPMessage *groupMesseage;

@property (nonatomic, strong) XMPPRoom *storeXmppRoom;
@property (nonatomic, strong) XMPPRoom *csmXmppRoom;
@property (nonatomic, strong) XMPPRoom *mpuXmppRoom;
@property (nonatomic, strong) XMPPRoom *mngXmppRoom;


- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;


- (BOOL)sendXMPPChatMesseage:(NSString*)messeage JID:(NSString*)JID;

- (BOOL)sendXMPPGroupMesseage:(NSString*)messeage jabberID:(NSString*)mucID;




- (BOOL)sendXMPPServiceResponse:(NSString*)response messageBody:(NSString*)body msgID:(NSString*)messageID jabberID:(NSString*)mucID ldapID:(NSString*)ldapID storeNumber:(NSString*)storeNumber fromApplication:(NSString*)fromApplication;

- (void)unsubscribeToJIDAndUpdateRoster:(XMPPJID*)removeJID;

- (void)sendSubscribeMessageToUser:(NSString*)userID;

- (void)setMyMucList:(NSString*)locationNumber isManger:(BOOL)manager;

- (void)prsentSettingsViewInterface;

- (void)setMMDCCenterViewDefault;

- (void)setMMDCCenterViewWithJID:(NSString*)jabberID;

- (void)setMMDCCenterViewForApproval:(XMPPMessageArchiving_Message_CoreDataObject*)message stringJabberID:(NSString*)jid msgBody:(NSString*)body;

- (void)setUserName:(NSString *)user;

- (void)setLocationNumber:(NSString*)location;

- (void)setIsManager:(BOOL)mng;

- (void)setPictureLink:(NSString *)pic;

- (UIImage*)getMyPebbleImage;

- (void)sendCustomPictureEveryone:(UIImage*)image;

- (NSString*)theCleanerOfUserJID:(NSString*)malformedJID;

- (void)setPassword:(NSString*)psk;

- (void)clearMessageCounter:(NSString*)JabberID;
    
- (NSString*)getToUserJID;

- (void)prsentSlideViewInterface;

- (void)openRightDrawer;

- (void)openLeftDrawer;

- (void)logOutofXMPP;

- (BOOL)connectToXMPPServer;
- (void)disconnect;
- (void)setupStream;
- (BOOL)isXmppConnected;
- (void)XMPPStartUp;


- (NSMutableDictionary*)getArchivedMesseages;

- (NSMutableDictionary*)getRosterBuddyPresenceList;

@property (strong, nonatomic) NSTimer *awayTimer;
@property (strong, nonatomic) NSTimer *firstConnectTimer;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *locationNumber;
@property (strong, nonatomic) NSString *pictureLink;
@property (strong, nonatomic) NSString *myJID;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *toUserJid;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *xmppMucDomain;
@property (strong, nonatomic) NSArray *currentMucMemebers;
@property (strong, nonatomic) NSMutableDictionary *myMucList;
@property (strong, nonatomic) NSMutableDictionary *dynamicMucList;
@property (strong, nonatomic) NSMutableDictionary *mucMememberList;
@property (strong, nonatomic) NSMutableDictionary *missedMucMesseageCounter;
@property (strong, nonatomic) NSMutableDictionary *dynamicMessageIDList;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) NSMutableDictionary *rosterBuddyPresenceList;
@property (assign, nonatomic) BOOL messageViewHasLaunched;
@property (strong, nonatomic) UserSettings *userSettings;


@end
