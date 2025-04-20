//
//  MesseageCell.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 5/18/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OutGoingMsgCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *messegeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (strong, nonatomic) IBOutlet UIImageView *myJIDImage;
@property (strong, nonatomic) IBOutlet UILabel *myJIDLabel;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messeageLabelWidthConstraints;

@end
