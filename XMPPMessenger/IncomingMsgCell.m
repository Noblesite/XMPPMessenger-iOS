//
//  incomingMsgCell.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 5/19/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "IncomingMsgCell.h"

@implementation IncomingMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    NSLog(@"Incoming cell is selected");
    if (selected){
        self.backgroundColor = [UIColor lightGrayColor];
    }
    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
   
    [super setHighlighted:highlighted animated:NO];
    
    NSLog(@"Incomign cell is highligted");
    
    if (highlighted){
        self.backgroundColor = [UIColor lightGrayColor];
    }
}

@end
