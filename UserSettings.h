//
//  UserSettings.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 8/30/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <malloc/malloc.h>
@import XMPPFramework;

@interface UserSettings : NSObject {
    
    
  
}

- (UserSettings*)userSettings:(NSString*)userName;
- (void)setUserFontSize:(NSString*)userName fontSize:(NSInteger)fontSize;
- (void)setUserImage:(NSString*)userName userImage:(UIImage*)image;
- (void)setUseCustomePicture:(NSString*)userName boolValue:(BOOL)usePicture;
- (BOOL)getUseCustomePic:(NSString*)userName;
- (NSXMLElement*)userImageToElementProperties:(UIImage*)image;

@property (nonatomic, assign) NSInteger fontSize;
@property (strong, nonatomic) UIImage *userImage;
@property (nonatomic, assign) BOOL useCustomePicture;

@end
