//
//  XMPPLoadingViewController.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 9/26/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "XMPPLoadingViewController.h"

@interface XMPPLoadingViewController ()

@end

@implementation XMPPLoadingViewController

@synthesize logoCounter;
@synthesize logoTimer;
@synthesize labelUpdateTimer;
@synthesize labelUpdateCounter;
@synthesize connectionUpdaterLabel;
@synthesize shouldRotate;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startLoadAnimation];
    [self startConnectionLabelTimer];
    shouldRotate = YES;
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated{
    
    shouldRotate = NO;
    [labelUpdateTimer invalidate];
    [logoTimer invalidate];
    
    labelUpdateTimer = nil;
    logoTimer = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startConnectionLabelTimer {
    
    connectionUpdaterLabel.textColor = [UIColor grayColor];
    connectionUpdaterLabel.textAlignment = NSTextAlignmentCenter;
    connectionUpdaterLabel.font = [UIFont systemFontOfSize:45];
  labelUpdateTimer =  [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(updateConnectionLabel)
                                   userInfo:nil
                                    repeats:YES];
    labelUpdateCounter = 0;
}

- (void)updateConnectionLabel {
    
    if(labelUpdateCounter == 4){
        
        labelUpdateCounter = 0;
    }
    
    switch (labelUpdateCounter) {
        case 0:
            connectionUpdaterLabel.text = @" . ";
            break;
            
        case 1:
            connectionUpdaterLabel.text = @" . . ";
            break;
            
        case 2:
            connectionUpdaterLabel.text = @" . . . ";
            break;
            
        case 3:
            connectionUpdaterLabel.text = @" . . . . ";
            break;
    }
    
    labelUpdateCounter ++;
    
}

- (void)startLoadAnimation {
    
    
    _loadingImageView.image = [UIImage imageNamed:@"searsKmartLogo.png"];
    _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self performRotationAnimated];
    logoCounter = 0;
    logoTimer = nil;
  
    logoTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                 target:self
                                               selector:@selector(changeLogoImage)
                                               userInfo:nil
                                                repeats:YES];
    if([logoTimer isValid]){
        
        
        NSLog(@"Timer shouwld be on");
    }
    
}

- (void)performRotationAnimated {
    
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         _loadingImageView.transform = CGAffineTransformMakeRotation(M_PI);
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.8
                                               delay:0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              
                                              _loadingImageView.transform = CGAffineTransformMakeRotation(0);
                                          }
                                          completion:^(BOOL finished){
                                              
                                              if (shouldRotate) {
                                                  
                                                  [self performRotationAnimated];
                                              }
                                          }];
                     }];
}

-(void)changeLogoImage {
    
    
    if(logoCounter >= 12){
        
        logoCounter = 0;
    }
    
    switch (logoCounter) {
        case 0:
            _loadingImageView.image = [UIImage imageNamed:@"newSearsLogo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 1:
            _loadingImageView.image = [UIImage imageNamed:@"kmartNewLogo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
        case 2:
            _loadingImageView.image = [UIImage imageNamed:@"searsHoldingsLogo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
        case 3:
            _loadingImageView.image = [UIImage imageNamed:@"kmartBigLogo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 4:
            _loadingImageView.image = [UIImage imageNamed:@"kmartLogoOldOne.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 5:
            _loadingImageView.image = [UIImage imageNamed:@"searsOldLogoRed.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 6:
            _loadingImageView.image = [UIImage imageNamed:@"kmartLogoOldTwo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 7:
            _loadingImageView.image = [UIImage imageNamed:@"searsLogoOldTwo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 8:
            _loadingImageView.image = [UIImage imageNamed:@"craftsmanLogo.jpeg"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 9:
            _loadingImageView.image = [UIImage imageNamed:@"shopYourWayLogo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 10:
            _loadingImageView.image = [UIImage imageNamed:@"searsLogoOldThree.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
        case 11:
            _loadingImageView.image = [UIImage imageNamed:@"searsKmartLogo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
            
            
            
        default:
            _loadingImageView.image = [UIImage imageNamed:@"newSearsLogo.png"];
            _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
    }
    
    
    logoCounter ++;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
