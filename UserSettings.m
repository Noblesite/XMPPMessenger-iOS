//
//  UserSettings.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 8/30/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "UserSettings.h"

@implementation UserSettings

#define defaultFontSize 16

- (UserSettings*)userSettings:(NSString*)userName {
    
    
    self.fontSize = [self getUserFontSize:userName];
    self.userImage = [self getUserSavedPicture:userName];
    self.useCustomePicture = [self getUseCustomePic:userName];
    
    return self;
}

- (void)setUseCustomePicture:(NSString*)userName boolValue:(BOOL)usePicture {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"useCustomePicture"]){
        
        NSMutableDictionary *useCustomePicture = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"useCustomePicture"]];
        
        
        [useCustomePicture setObject:[NSNumber numberWithBool:usePicture]  forKey:userName];
        [defaults setObject:useCustomePicture forKey:@"useCustomePicture"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        
        NSMutableDictionary *useCustomePicture = [[NSMutableDictionary alloc]init];
        
        [useCustomePicture setObject:[NSNumber numberWithBool:usePicture]  forKey:userName];
        [defaults setObject:useCustomePicture forKey:@"useCustomePicture"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    
    
}

- (BOOL)getUseCustomePic:(NSString*)userName {
    
    BOOL usePicture = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"useCustomePicture"]){
        
        NSMutableDictionary *useCustomePicture = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"useCustomePicture"]];
        
        if([useCustomePicture objectForKey:userName]){
            
            usePicture = [[useCustomePicture objectForKey:userName]boolValue];
            
           
        }
        
    }
    
    return usePicture;
}


- (NSInteger)getUserFontSize:(NSString*)userName {
    
    NSInteger tmpFontSize = defaultFontSize;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"savedFontSize"]){
        
        NSMutableDictionary *savedFontSize = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"savedFontSize"]];
        
        if([savedFontSize objectForKey:userName]){
            
            tmpFontSize = [[savedFontSize objectForKey:userName]integerValue];
            
         
        }
        
    }
    
    return tmpFontSize;
}

- (void)setUserFontSize:(NSString*)userName fontSize:(NSInteger)fontSize {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   
    if([defaults objectForKey:@"savedFontSize"]){
        
        NSMutableDictionary *savedFontSize = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"savedFontSize"]];

            
            [savedFontSize setObject:[NSNumber numberWithInteger:fontSize]  forKey:userName];
            [defaults setObject:savedFontSize forKey:@"savedFontSize"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        
        NSMutableDictionary *savedFontSize = [[NSMutableDictionary alloc]init];
        
        [savedFontSize setObject:[NSNumber numberWithInteger:fontSize]  forKey:userName];
        [defaults setObject:savedFontSize forKey:@"savedFontSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
  

}

- (UIImage*)getUserSavedPicture:(NSString*)userName {
    
    UIImage *tmpPic = [UIImage imageNamed:@"user-no-image.png"];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"savedUserImage"]){
        
        NSMutableDictionary *savedUserImage = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"savedUserImage"]];
        
        if([savedUserImage objectForKey:userName]){
            
            tmpPic = [UIImage imageWithData:[savedUserImage objectForKey: userName]];
            
            
        }
        
    }
    
    return tmpPic;
}

- (void)setUserImage:(NSString*)userName userImage:(UIImage*)image {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.userImage = image;
    NSData *imageData = UIImageJPEGRepresentation(self.userImage, 1);
    

    
    if([defaults objectForKey:@"savedUserImage"]){
        
        NSMutableDictionary *savedUserImage = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"savedUserImage"]];
        
        
        [savedUserImage setObject:imageData forKey:userName];
        [defaults setObject:savedUserImage forKey:@"savedUserImage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        
        NSMutableDictionary *savedUserImage = [[NSMutableDictionary alloc]init];
        
        [savedUserImage setObject:imageData  forKey:userName];
        [defaults setObject:savedUserImage forKey:@"savedUserImage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    
}

- (NSXMLElement*)userImageToElementProperties:(UIImage*)image {
    
    NSXMLElement *imageElement;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    
  
    
    
    
    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:imageData
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                                  options:0
                                                                    error:&error];
    if (error) {
        
        NSLog(@"Error serializing data to plist XML: %@", error);
        
    } else {
        
        NSString *pictureString = [[NSString alloc] initWithData:plistData encoding:NSUTF8StringEncoding];
        
       /* NSArray *tmp = [pictureString componentsSeparatedByString:@"<data>"];
        
        if([tmp objectAtIndex:1]){
            
            pictureString = [tmp objectAtIndex:1];
        }
        
        tmp = [pictureString componentsSeparatedByString:@"</data>"];
        
        if([tmp objectAtIndex:0]){
            
            pictureString = [tmp objectAtIndex:0];
        }*/
        
       


    
    
        
        // Create the parent properties element
        NSXMLElement *properties = [NSXMLElement elementWithName:@"properties"];
        
        // Set the ejabber protocal type for Smack
        [properties addAttributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
        
        // Create the messageID Properity with name and value
        NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *name = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"customPicture"];
        NSXMLElement *value = [[NSXMLElement alloc] initWithName:@"value" stringValue:pictureString];
        [value addAttributeWithName:@"type" stringValue:@"string"];
        
        
        [property addChild:name];
        [property addChild:value];
        
        
        // Finally add all the child properity to the properties parent
        [properties addChild:property];
        
     
        return properties;
    }
   
    
    
    return imageElement;
    
}
@end
