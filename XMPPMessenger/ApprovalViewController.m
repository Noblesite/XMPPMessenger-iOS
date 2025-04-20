//
//  ApprovalViewController.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 6/28/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "ApprovalViewController.h"

@interface ApprovalViewController ()

@end



@implementation ApprovalViewController


@synthesize approvalPicker;
@synthesize messageLabel;
@synthesize message;
@synthesize currentJabberID;
@synthesize messageBody;
@synthesize navigationBar;
@synthesize navigationItem;
@synthesize myJabberID;

- (void)viewDidLoad {
  
    [super viewDidLoad];
    
    [self setupBackButton];

}

// Simple Method to setup the back button on the navigation item
- (void)setupBackButton {
    
    //setup the back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:self action:@selector(backButton)];
    navigationItem.leftBarButtonItem = backButton;
    
}

// Method that calles the instince of the AppDelegate to move the view back to the previous messageViewController based on JID
- (void)backButton {
    
     [[self appDelegate] setMMDCCenterViewWithJID:currentJabberID];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Set the number of componets in the pickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

// Set the number of rows in the picker view based on the amount of response codes we recived in
// The message passed by the Admin service
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSArray *json = [self getResponseCodesFromMessage];
    
    return json.count;
}

// Set the titles for each picker by getting the respose codes in the messages
// We then parse each string in the array and take out all special characters
// Need to create a method to just give an array output based on row to index
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    
                NSArray *json = [self getResponseCodesFromMessage];
    
                NSString *tmp = [NSString stringWithFormat:@"%@",[json objectAtIndex:row]];
    
    // to ensure there is no null case we check for the bellow string
    if([tmp containsString:@"responseDesc ="]){
    
            NSArray *tmpArray = [tmp componentsSeparatedByString:@"responseDesc ="];
    
            if([tmpArray objectAtIndex:1]){
        
                    tmp = [tmpArray objectAtIndex:1];
                
                tmp = [[tmp componentsSeparatedByCharactersInSet:
                        [[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "];
        
                }else{
                    
                    // if no data is found we put Unknown
                    tmp = @"Unknown Code";
                    
                }
   
    }else{
        
       tmp = @"Unknown Code";
        
    }
    
    return tmp;
    
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    // Here, like the table view you can get the each section of each row if you've multiple sections
  
}

// Apple picker Delegate method to set the view of each picker
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        
        tView.textAlignment = NSTextAlignmentCenter;
        
        tView.adjustsFontSizeToFitWidth = YES;
        // Setup label properties - frame, font, colors etc
    }
    
    
    tView.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return tView;
}

// Method to get the current selected picker to define the users input. Sinc but the picker index and the response code index
// are seeded with the same count, we can pull a copy of the responses & use the postion of the picker to determin the users
// requested response
- (NSString*)getCurrentPickerValue {
    
    NSString *responseCode;
    NSArray *json = [self getResponseCodesFromMessage];
    
    NSString *messageID = [self getMessageIDFromMessage];
    
    
    if((json != NULL) && (messageID != NULL) ){
        
        
        NSInteger row = [approvalPicker selectedRowInComponent:0];
        
        
        NSString *tmp = [NSString stringWithFormat:@"%@",[json objectAtIndex:row]];
        
        
        if([tmp containsString:@"responseCode ="]){
            
            
            NSArray *tmpArray = [tmp componentsSeparatedByString:@"responseCode = "];
        
                    tmp = [tmpArray objectAtIndex:1];
        
                    tmpArray = [tmp componentsSeparatedByString:@";"];
                    
                    tmp = [tmpArray objectAtIndex:0];
                    
                    responseCode = [NSString stringWithFormat:@"%@",tmp];
        
        }else{
        
        responseCode = @"Unknown Code";
        
        }
    }else{
    
        responseCode = @"Unknown Code";
            
    }

    return responseCode;
}

// Auto Message body we create to let everyone in the muc know this requste has been responsed to
// by the user that has sent it
-(NSString*)createResponesBody {
    
    NSString *responseBody;
    
    NSString *ldapID = [self getLDAPIDFromMessage];
    
    NSArray *json = [self getResponseCodesFromMessage];
    
    NSInteger row = [approvalPicker selectedRowInComponent:0];
    
    NSString *tmp = [NSString stringWithFormat:@"%@",[json objectAtIndex:row]];
    
    
    if(![tmp isEqualToString:@"Unknown Code"]){
    
        if([tmp containsString:@"responseDesc ="]){
        
            NSArray *tmpArray = [tmp componentsSeparatedByString:@"responseDesc ="];
            
            tmp = [tmpArray objectAtIndex:1];
        
            tmp = [[tmp componentsSeparatedByCharactersInSet:
                                [[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "];
        
            responseBody = [NSString stringWithFormat:@"%@: has responded with: %@for the bellow Message: \n\n%@ \n\n", myJabberID,tmp,messageLabel.text];
            
        
        }else{
        
            responseBody = @"Unknown Code";
        
        }
        
        
    }else{
        
        responseBody = @"Unknown Code";
    }
    
    return responseBody;
}

// Method called when the user presses the send button. Starts the response flow to send a message to the
// respective service
- (IBAction)sendButton:(id)sender {
    
            // Pull information needed to send the respective response
            NSString *responseCode = [self getCurrentPickerValue];
            NSString *messageID = [self getMessageIDFromMessage];
            NSString *storeNumber = [self getStoreNumberFromMessage];
            NSString *ldapID = [self getLDAPIDFromMessage];
            NSString *body = [self createResponesBody];
            NSString *fromApplication = [self getFromApplicationFromMessage];
    
    // Evaluate to ensure there are no null cases
    if((responseCode != NULL) && (messageID != NULL) && (storeNumber != NULL) && (ldapID != NULL) && (fromApplication != NULL)){
        
            
        [ [self appDelegate] sendXMPPServiceResponse:responseCode messageBody:body msgID:messageID jabberID:currentJabberID ldapID:ldapID storeNumber:storeNumber fromApplication:fromApplication];
        
            [[self appDelegate] setMMDCCenterViewWithJID:currentJabberID];
                
            
        }else{
            
            // If we encounter an error in pulling the nesseary information for the response we let the user know
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Messeage Error"
                                                                message:@"Missing Response Codes or MessageID"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        
        }

}
// JP start here

// Method for parseing and returning response codes from the message
- (NSArray*)getResponseCodesFromMessage {
    
    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message error:nil];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    
    NSArray *properties = [prop elementsForName:@"property"];
    
    
    for(id object in properties){
        
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        if([name.stringValue isEqualToString:@"csmResponseCode"]){
            
            NSString *tmp = value.stringValue;
            NSError *jsonError;
            NSData *objectData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            
            return json;
            

        }
    
    }
        
        return NULL;
}

// Method to get the store number from the XML message
- (NSString*)getStoreNumberFromMessage {
    
    
    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message error:nil];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    
    
    NSArray *properties = [prop elementsForName:@"property"];
    
    NSString *storeNumber;
    
    
    for(id object in properties){
        
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        
        
        if([name.stringValue isEqualToString:@"storenumber"]){
            
            
            
            storeNumber = value.stringValue;
            
            return storeNumber;
            
        }
        
    }
    return NULL;
}

// Method to get the LDAP from the message
- (NSString*)getFromApplicationFromMessage {
    
    
    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message error:nil];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    
    
    NSArray *properties = [prop elementsForName:@"property"];
    
    NSString *fromApplication;
    
    
    for(id object in properties){
        
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        
        
        if([name.stringValue isEqualToString:@"fromApplication"]){
            
            
            fromApplication = value.stringValue;
            
            return fromApplication;
            
        }
        
    }
    
    if (fromApplication == NULL){
        
        
        fromApplication = @"Application Name not found";
    }
    return fromApplication;
}

// Method to get the LDAP from the message
- (NSString*)getLDAPIDFromMessage {
    
    
    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message error:nil];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    
    
    NSArray *properties = [prop elementsForName:@"property"];
    
    NSString *ldapID;
    
    
    for(id object in properties){
        
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        
        
        if([name.stringValue isEqualToString:@"ldapID"]){
            
            
            ldapID = value.stringValue;
            
            return ldapID;
            
        }
        
    }
    
    if (ldapID == NULL){
        
        
        ldapID = @"noLDAP";
    }
    return ldapID;
}

// Method to get the messageID from the message
- (NSString*)getMessageIDFromMessage {
    
    
    //create the NSXMLEment from the message
    NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message error:nil];
    
    //pull the properties element value
    NSXMLElement *prop = [element elementForName:@"properties"];
    
    
    NSArray *properties = [prop elementsForName:@"property"];
    NSString *messageID;

    
    for(id object in properties){
        
        
        NSXMLElement *property = [[NSXMLElement alloc] init];
        
        property = object;
        
        NSXMLElement *name = [property elementForName:@"name"];
        NSXMLElement *value = [property elementForName:@"value"];
        
        
        
        if([name.stringValue isEqualToString:@"messageID"]){
            
            
            messageID = value.stringValue;
            
            return messageID;
            
        }
        
        if([name.stringValue isEqualToString:@"csmResponseCode"]){
            
            
            messageID = value.stringValue;
            
            return messageID;
            
        }
        
    }
        return NULL;
}


- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


@end
