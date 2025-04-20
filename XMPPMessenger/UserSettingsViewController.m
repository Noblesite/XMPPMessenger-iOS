//
//  UserSettingsViewController.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 8/30/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "UserSettingsViewController.h"

@interface UserSettingsViewController ()

@end


@implementation UserSettingsViewController

@synthesize userSettings;
@synthesize userName;
@synthesize fontSizePicker;
@synthesize fontSizeLabel;
@synthesize selectPictureButton;
@synthesize userImageView;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    userName = [[self appDelegate]userName];
    userSettings = [[UserSettings alloc]userSettings:userName];
    [self setupBackButton];
    [self setViewLabels];
    [self setFontSizePickerToUsersDefaults:userSettings.fontSize];
    [self setUserImageViewImage:userSettings.userImage];
   
    
}



- (void)setFontSizePickerToUsersDefaults:(NSInteger)fontSize{
    
    
    NSInteger row;
    
    switch (fontSize) {
        case 16:
            row = 0;
            break;
            
        case 18:
            row = 1;
            break;
        case 20:
            row = 2;
            break;
        default:
            row = 0;
            break;
    }
    
    [fontSizePicker selectRow:row inComponent:0 animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[UserSettings alloc]setUserFontSize:userName fontSize:[self getCurrentFontSizePickerValue]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBackButton {
    
    self.navigationItem.title = @"Settings";
    //setup the back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:self action:@selector(backButtonPress)];
    backButton.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = backButton;
   
   
    
}

// Method that calles the instince of the AppDelegate to move the view back to the previous messageViewController based on JID
- (void)backButtonPress {
    
    
    [[self appDelegate] setMMDCCenterViewDefault];
    
}

- (AppDelegate *)appDelegate {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Set the number of componets in the pickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

// Set the number of rows in the picker view based on the amount of response codes we recived in
// The message passed by the Admin service
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
   
    return 3;
}

// Set the titles for each picker by getting the respose codes in the messages
// We then parse each string in the array and take out all special characters
// Need to create a method to just give an array output based on row to index
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
   
    switch (row) {
        case 0:
            title = @"16";
            break;
            
        case 1:
            title = @"18";
            break;
        case 2:
            title = @"20";
            break;
        default:
            title = @"16";
            break;
    }
    
    
    return title;
    
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    // Here, like the table view you can get the each section of each row if you've multiple sections
    
}

// Apple picker Delegate method to set the view of each picker
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        
        tView = [[UILabel alloc] init];
        [tView setTextColor:[UIColor whiteColor]];
        
        tView.textAlignment = NSTextAlignmentCenter;
        
        tView.adjustsFontSizeToFitWidth = YES;
        // Setup label properties - frame, font, colors etc
    }
    
    
    tView.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return tView;
}

// Method to get the current selected picker to define the users input. Sinc but the picker index and the response code index
// are seeded with the same count, we can pull a copy of the responses & use the postion of the picker to determin the users
// requested response
- (NSInteger)getCurrentFontSizePickerValue {
    
    
    NSInteger row = [fontSizePicker selectedRowInComponent:0];
    NSInteger fontSize;
    
    switch (row) {
        case 0:
            fontSize = 16;
            break;
        case 1:
            fontSize = 18;
            break;
        case 2:
            fontSize = 20;
            break;
            
        default:
            fontSize = 16;
            break;
    }
    
        
    return fontSize;
}

- (void)setViewLabels {
    
    fontSizePicker.layer.borderColor = [UIColor darkGrayColor].CGColor;
    fontSizePicker.layer.borderWidth = 2.0f;
    fontSizePicker.tintColor = [UIColor whiteColor];
    
    fontSizeLabel.text = @"Message Font Size";
    fontSizeLabel.adjustsFontSizeToFitWidth = YES;
    fontSizeLabel.layer.borderWidth = 2.0f;
    fontSizeLabel.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    fontSizeLabel.clipsToBounds = YES;
    
    
    
    selectPictureButton.layer.borderWidth = 2.0f;
    selectPictureButton.titleLabel.text = @"Select a Picture";
    selectPictureButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    selectPictureButton.tintColor = [UIColor blackColor];
    selectPictureButton.clipsToBounds = YES;
    selectPictureButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
}


- (void)setUserImageViewImage:(UIImage*)userImage {
    
    
   // userImageView.layer.borderWidth = 3.0f;
 
    userImageView.image = userImage;
     userImageView.contentMode = UIViewContentModeScaleAspectFit;
   // userImageView.layer.cornerRadius = userImageView.frame.size.width / 4;
   
}


- (IBAction)openCameraRoll:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
  
   
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];

    
    userSettings.userImage = chosenImage;
    userImageView.image = chosenImage;
    userImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [[UserSettings alloc]setUserImage:userName userImage:chosenImage];
    [[UserSettings alloc]setUseCustomePicture:userName boolValue:YES];
    [[self appDelegate]sendCustomPictureEveryone:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
