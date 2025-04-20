//
//  MessageIDFacotry.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 9/19/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "MessageIDFacotry.h"

@implementation MessageIDFacotry

- (NSString*)getMessageID{
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentTime];
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSString *messageID = [NSString stringWithFormat:@"%@%@", uuid, dateString];
    
    return messageID;
}

@end
