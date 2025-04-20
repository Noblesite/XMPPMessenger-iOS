//
//  ViewController.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 4/19/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end


@implementation LoginViewController

@synthesize userName;
@synthesize passWord;
@synthesize msgField;
@synthesize logInButton;
@synthesize loginIndicator;
@synthesize faultCodeField;
@synthesize userNameField;
@synthesize passwordField;
@synthesize isLogOut;
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the view
    [self setUpCustomeUIView];
  
    
    
   
    // Check to see if the QA setting are enabled.
    // If Enabled seed teh messageView with the values from
    // Settings bunddle If not enable continue with reguler flow
    BOOL success = [self checkTheBackDoor];
    
    if(success && !isLogOut){
       
        
        [self moveToTableMesseageView];
    
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// JP Will be removed before Pilot or anything that goes into Prod possibly.
- (BOOL)checkTheBackDoor {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL hackTheGibson = [defaults boolForKey:@"Dev_Overide"];
    
    if(hackTheGibson){
        
        NSString *location = [defaults objectForKey:@"Location_num"];
        NSString *dUserName = [defaults objectForKey:@"User_Name"];
        NSString *password = [defaults objectForKey:@"User_Password"];
        
        [[self appDelegate] setLocationNumber:location];
        [[self appDelegate] setUserName:dUserName];
        [[self appDelegate] setPassword:password];
        [[self appDelegate] setIsManager:YES];
       
        return YES;
    }
    
    return NO;
}


// Pull the LDAP ID from the interface
- (NSString*)getUserNameJID{
    
    userName = userNameField.text;
    return userName;
}

// Simple view setup
- (void)setUpCustomeUIView {
    
    [loginIndicator setHidden:TRUE];
    _ldapIcon.image = [UIImage imageNamed:@"teslaCoil.png" ];
    
    _ldapIcon.contentMode = UIViewContentModeScaleAspectFit;
    
    
}
    
// Get the hostName from bunddle settings. This will need to be moved to a plist later
// Once infrastructure layer has been defined
- (NSString*)getHostName{

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hostName = [defaults objectForKey:@"HostName_IP"];
    
    return hostName;
}

// Get the port number from bunddle settings. This will need to be moved to a plist later
// Once infrastructure layer has been defined
- (UInt16)getHostPort{
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *port = [defaults objectForKey:@"Host_Port"];
    UInt16 portNumber = [[formatter numberFromString:port] unsignedShortValue];
    
    
    return portNumber;
}

// Get LDAP password from UI
- (NSString*)getPassword{
    
    passWord = passwordField.text;
    return passWord;
}


- (void)viewWillDisappear:(BOOL)animated {

   
}


// Moves the keyboard back once field edit is done
- (IBAction)messeageKeyboard:(id)sender {
    
    [sender resignFirstResponder];
}


// Moves the keyboard back once field edit is done
- (IBAction)userNameEnter:(id)sender {
    
    [sender resignFirstResponder];
}

// Moves the keyboard back once field edit is done
- (IBAction)passwordEnter:(id)sender {
    [sender resignFirstResponder];
}
    

// Clear the values in the pw & username feild after incorrect input by user
- (void)clearTextFields {
    
    passwordField.text = @"";
    userNameField.text = @"";
    
}

// Called when a user presses the login button. Method will start LDAP authetication method
- (IBAction)logInButton:(id)sender {
    
   
    
    NSString *tempUser = [self getUserNameJID];
    NSString *tempPw = [ self getPassword];
    
    // Check if user entered the required input information
    if (tempUser.length == 0 || tempPw.length == 0){
        [msgField setText:@"Missing username or password"];
        msgField.adjustsFontSizeToFitWidth = YES;
        msgField.textColor = [UIColor whiteColor];
        [self turnActivitySpinngerOff];
    }
    else {
        // Start a new thread to start the spinner
        [self turnActivitySpinnerOn];
      // Send data to restLDAP on main Thread
        [self performSelectorOnMainThread:@selector(restLDAP) withObject:nil waitUntilDone:false];
    }

}

// Method for checking the LDAP response & moving to the messageView based on response.
- (void)restLDAP {
    
    
    BOOL success = [self sendLDAPInfo];
    
    if (success){
        
        [self moveToTableMesseageView];
        
    }else{
        
        [self turnActivitySpinngerOff];
        
    }
    
    
}

// Send's LDAP service request and returns a YES/NO if the user is autheticated
- (BOOL)sendLDAPInfo {
    
    // Create the JSON string
    NSString *jsonString=[NSString stringWithFormat:@"{\"userId\":\"%@\",\"password\":\"%@\"}",[self getUserNameJID],[ self getPassword]];
    
    // Next need to convert the string to NSData to use in the body
    NSData *jsonData = [jsonString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    

   // Allocate Memeory
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    
    
    // Current URL to LDAP services. Needs to be abstracted to a Plist - JP
    // Now build out the web request with method, URL, body & what type of data we are
    // Expecting in response
    NSString *urlString = [NSString stringWithFormat:@"http://hfdvdjmpubat1.vm.itg.corp.us.shldcorp.com:8580/v1/authenticateUser/"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    
    // Finally send the reqeust and bind it with an error object
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *returnedData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Check to see if there is an error
    if(error!=nil){
    
        [self messageFieldErrorOutPut:2];
        return NO;
        
    }
    
 
    NSString *jsonResponse = [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding];
    
    
    // Check the statusCode for  200. If succesfull then parse the LDAP date
    if ([response statusCode] == 200){
       
        
        BOOL success = [self parseLDAPData:returnedData];
        
        // Else return a NO that the response was not succesfull
        if(!success){
            
            
            return NO;
        }

    
    return YES;
        
    }else{
        
        [self messageFieldErrorOutPut:2];
        return NO;
    }
    
}


-(BOOL)parseLDAPData:(NSData*)response{
    
    // Turn the NSData object we got back in response to the LDAP request into a readable string
    NSString *LDAPReturn = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // Check for null case
    if(LDAPReturn.length==0){
        
        [self messageFieldErrorOutPut:4];
        return NO;
    }
    
    // Parse the JSON string into an array and look for the user key
    NSError *error = nil;
    NSMutableArray *ldapArray = [[NSMutableArray alloc]init];
    ldapArray = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];
    NSMutableArray *messeageArray = [[NSMutableArray alloc]init];
    
    if([ldapArray valueForKey:@"success"]){
        
        BOOL success = [[ldapArray valueForKey:@"success"]boolValue];
        
        if(!success){
            
            [self messageFieldErrorOutPut:5];
            return NO;
            
        }
    }
    
    
    // Check for Null case
    if([ldapArray valueForKey:@"user"] && [ldapArray valueForKey:@"user"]!=(NSString *)[NSNull null]){
        
        messeageArray = [ldapArray valueForKey:@"user"];
    
    }else{
        
        [self messageFieldErrorOutPut:4];
        return NO;
    }
    
    if (error){
        
        [self messageFieldErrorOutPut:4];
        return NO;
    
        // Check for NULL values that could crash the applicaiton. If values exist then set the respecteive data
        // and finally return a YES
    }else if ([messeageArray valueForKey:@"manager"] && [messeageArray valueForKey:@"storenumber"] && [messeageArray valueForKey:@"pictureLink"] && [messeageArray valueForKey:@"punchIn"] && [messeageArray valueForKey:@"corporate"]){
        
       
            [[self appDelegate]setUserName:[self getUserNameJID]];
            [[self appDelegate]setIsManager:[[messeageArray valueForKey:@"manager"]boolValue]];
            [[self appDelegate]setLocationNumber:[messeageArray valueForKey:@"storenumber"]];
            [[self appDelegate]setPictureLink:[messeageArray valueForKey:@"pictureLink"]];
            [[self appDelegate]setPassword:@"xmpp"]; //JP Remove only for development
            [self turnActivitySpinngerOff];
    
        
            BOOL isClockedIn = [[messeageArray valueForKey:@"punchIn"]boolValue];
       // BOOL isCorporate = [[messeageArray valueForKey:@"corporate"]boolValue];
        
    
        
                    // JP is Corp temp solution until the service is fixed
                    if(!isClockedIn){
                       // if(!isCorporate){
            
                    [self messageFieldErrorOutPut:3];
            
                    return NO;
                   // }
                }
        
            return YES;
        
        }
        
        [self messageFieldErrorOutPut:4];
        return NO;

}


// Actvity spinnter for logging in. There to ensure the user knows something is happening while sending the LDAP autheitcation
// request
-(void)turnActivitySpinnerOn {
    
    msgField.text = @"Checking...Please Wait";
    msgField.textColor = [UIColor whiteColor];
    loginIndicator.hidden = FALSE;
    [loginIndicator startAnimating];
    logInButton.enabled = FALSE;
   
}

// Turn off the spinner
- (void)turnActivitySpinngerOff {
   
    logInButton.enabled = TRUE;
    [self clearTextFields];
    [loginIndicator stopAnimating];
    [loginIndicator setHidden:TRUE];
}
    

// Method that allows access the the public methods & properties of teh AppDelegate
- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Change the center viewController to the messageView controller
- (void)moveToTableMesseageView {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"XMPPLoadingViewController"];
     vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
    
    [[self appDelegate] XMPPStartUp];
    
}

- (void)messageFieldErrorOutPut:(NSInteger)responseValue{
    
    msgField.textColor = [UIColor whiteColor];
    
    switch (responseValue) {
        case 1:
            msgField.text = @"Login Faild";
            break;
            
        case 2:
            msgField.text = @"Cannot connect, check network settings";
            break;
        case 3:
            msgField.text = @"Please Punch in before using this applicaiton";
            break;
        case 4:
            msgField.text = @"Login Faild, missing user info from LDAP";
            break;
        case 5:
            msgField.text = @"Invalid username or password. Please try again.";
            break;
        default: msgField.text = @"Login Faild";
            break;
    }
    
      msgField.adjustsFontSizeToFitWidth = YES;
    
}

@end
