//
//  BuddyCustomePictures.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 9/1/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "BuddyCustomePictures.h"

@implementation BuddyCustomePictures


- (UIImage*)getUserSavedPicture:(NSString*)userName {
    
    UIImage *tmpPic = [UIImage imageNamed:@"user-no-image.png"];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"savedBuddyImage"]){
        
        NSMutableDictionary *savedUserImage = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"savedBuddyImage"]];
        
        if([savedUserImage objectForKey:userName]){
            
            tmpPic = [UIImage imageWithData:[savedUserImage objectForKey: userName]];
            
            
        }
        
    }
    
    return tmpPic;
}

- (void)setUserImage:(NSString*)jabberID userImage:(NSString*)stringImg {
  
    
    NSError *error;
    NSData *plistData = [stringImg dataUsingEncoding:NSUTF8StringEncoding];
    NSData *imageData = [NSPropertyListSerialization propertyListWithData:plistData
                                                                     options:NSPropertyListImmutable
                                                                      format:NULL
                                                                       error:&error];
    
    if (error) {
        
        NSLog(@"Error deserializing data from plist XML: %@", error);
   
    } else {
       
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
    
        if([defaults objectForKey:@"savedBuddyImage"]){
        
            NSMutableDictionary *savedUserImage = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"savedBuddyImage"]];
        
        
            [savedUserImage setObject:imageData forKey:jabberID];
            [defaults setObject:savedUserImage forKey:@"savedBuddyImage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        
        }else{
        
            NSMutableDictionary *savedUserImage = [[NSMutableDictionary alloc]init];
        
            [savedUserImage setObject:imageData  forKey:jabberID];
            [defaults setObject:savedUserImage forKey:@"savedBuddyImage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        
        }
    
      
    
    }

}

- (void)saveBuddyPebblePicture:(XMPPMessage*)message pebbleLink:(NSString*)pebbleLink{
    
  
    
        if(pebbleLink!=NULL){
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if([defaults objectForKey:@"pebblePictureLinks"]){
                
                // NSMutableDictionary *pebblePictureLinks = [defaults objectForKey:@"pebblePictureLinks"];
                
                NSMutableDictionary *pebblePictureLinks = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"pebblePictureLinks"]];
                
                if([pebblePictureLinks objectForKey:message.fromStr]){
                    
                    
                }else{
                    
                    
                    [pebblePictureLinks setObject:pebbleLink forKey:message.from.bare];
                    [defaults setObject:pebblePictureLinks forKey:@"pebblePictureLinks"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }else{
                
                
                
                NSMutableDictionary *pebblePictureLinks = [[NSMutableDictionary alloc]init];
                [pebblePictureLinks setValue:pebbleLink forKey:message.from.bare];
                [defaults setObject:pebblePictureLinks forKey:@"pebblePictureLinks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
        }
    
}
@end
