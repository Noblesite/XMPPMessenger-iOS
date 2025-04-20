//
//  BuddyCustomePictures.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 9/1/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import XMPPFramework;

@interface BuddyCustomePictures : NSObject

- (UIImage*)getUserSavedPicture:(NSString*)userName;
- (void)setUserImage:(NSString*)jabberID userImage:(NSString*)stringImg;
- (void)saveBuddyPebblePicture:(XMPPMessage*)message pebbleLink:(NSString*)pebbleLink;

@end
