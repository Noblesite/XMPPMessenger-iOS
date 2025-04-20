//
//  MesseageUserCellTableViewCell.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 4/21/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *userStatus;
@property (strong, nonatomic) IBOutlet UIImageView *statusImage;
@property (strong, nonatomic) NSString *jabberId;
@property (strong, nonatomic) IBOutlet UILabel *badge;


@end
