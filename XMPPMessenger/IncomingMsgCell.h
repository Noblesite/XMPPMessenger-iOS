//
//  incomingMsgCell.h
//  XMPPMessenger
//
//  Created by Jonathon Poe on 5/19/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncomingMsgCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *messegeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (strong, nonatomic) IBOutlet UIImageView *fromJIDImage;
@property (strong, nonatomic) IBOutlet UILabel *fromJIDLabel;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *fullStringJid;

//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messeageLabelWidthConstraints;


@end
