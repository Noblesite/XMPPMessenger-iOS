//
//  CreateMucViewController.m
//  XMPPMessenger
//
//  Created by Jonathon Poe on 5/1/17.
//  Copyright © 2017 Noblesite. All rights reserved.
//

#import "MucMembersViewController.h"

@interface MucMembersViewController ()

@end

@implementation MucMembersViewController

@synthesize mucID;
@synthesize viewTitle;
@synthesize allMucMememberList;
@synthesize currentMucmemeberList;
@synthesize memeberList;


- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self startObservers];
   
    NSArray *Array = [mucID componentsSeparatedByString:@"@"];
    viewTitle = [Array objectAtIndex:0];
    
    NSLog(@"mucMemember mucID: %", mucID);
    NSString *title = [NSString stringWithFormat:@"Channel: %@", viewTitle];
    
    [self getMucList];
    self.navigationItem.title = title;

   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    
    return @"Members";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    
    
  
    
    NSMutableDictionary *mucMemeberList = [allMucMememberList objectForKey:mucID];
    
    NSLog(@"Number of memebers in the muc: %i", mucMemeberList.count);
    
    return mucMemeberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"JIDRosterCell";
    
    
    CreateMucCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[CreateMucCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:CellIdentifier];
    }
    
    cell.JIDImage.image = [UIImage imageNamed:@"greenDot.png"];
    cell.JIDLabel.text =  [memeberList objectAtIndex:indexPath.row];
   
    
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

//get the Muc Memember List from the app Delegate
- (void)getMucList {
    
    allMucMememberList = [[NSMutableDictionary alloc]init];
    
    allMucMememberList = [[self appDelegate] mucMememberList];
    
    currentMucmemeberList = [[NSMutableDictionary alloc]init];
    
    currentMucmemeberList = [allMucMememberList objectForKey:mucID];
    
    memeberList = [[NSArray alloc]init];
    
    memeberList = [currentMucmemeberList allKeys];
    

    [self.tableView reloadData];

}


- (void)startObservers {
    
    
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mucMemeberListChanged) name:@"mucMememberChange" object:nil];
}

- (void)mucMemeberListChanged {
    
    allMucMememberList = [[self appDelegate] mucMememberList];
    currentMucmemeberList = [allMucMememberList objectForKey:mucID];
     memeberList = [currentMucmemeberList allKeys];
    
    [self.tableView reloadData];
}



@end
