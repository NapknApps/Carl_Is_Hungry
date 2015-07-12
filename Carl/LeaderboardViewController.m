//
//  LeaderboardViewController.m
//  Carl
//
//  Created by Zach Whelchel on 7/11/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "LeaderboardViewController.h"
#import <Firebase/Firebase.h>
#import "LeaderTableViewCell.h"

@interface LeaderboardViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, retain) NSMutableArray *leaders;
@property (nonatomic, retain) NSArray *orderedLeaders;

@end

@implementation LeaderboardViewController

@synthesize leaders = _leaders;
@synthesize orderedLeaders = _orderedLeaders;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.backButton.titleLabel.font = [UIFont fontWithName:@"Coder's Crux" size:40];
    [self.backButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)backSelected:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.leaders = [NSMutableArray array];
    self.orderedLeaders = [NSArray array];
    
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://carlishungry.firebaseio.com/users"];
    [[[ref queryOrderedByChild:@"confirmedSecondsAlive"] queryLimitedToLast:100] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.leaders addObject:[NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"facebookId",[snapshot.value valueForKey:@"confirmedSecondsAlive"],@"confirmedSecondsAlive",[snapshot.value valueForKey:@"name"],@"name",[snapshot.value valueForKey:@"eatenDate"],@"eatenDate", nil]];
        
        [self reload];
    }];
}

- (void)reload
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"confirmedSecondsAlive" ascending:NO];
    NSArray *array = [[[self.leaders copy] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] copy];
    
    NSMutableArray *array2 = [NSMutableArray array];
    
    for (NSDictionary *leader in array) {
        
        NSDate *appLaunchDate = [NSDate dateWithTimeIntervalSince1970:1437264000];
        NSDate *currentDate = [NSDate date];
        
        // Check for cheaters, doesnt solve whole problem, but at least can't cheat past the anticipated launch maximum time app is out.
        // They might show up on their own leaderboard weirdly, but not on everyone else's becasue their date change will also affect this checker.
        
        int mostPossibleSecondsLived = [currentDate timeIntervalSinceDate:appLaunchDate];

        if ([[leader valueForKey:@"confirmedSecondsAlive"] intValue] <= mostPossibleSecondsLived) {
            [array2 addObject:leader];
        }
    }
    
    self.orderedLeaders = [array2 subarrayWithRange:NSMakeRange(0, array2.count > 100 ? 100 : array2.count)];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderedLeaders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    LeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderCell" forIndexPath:indexPath];
    
    NSDictionary *leader = [self.orderedLeaders objectAtIndex:indexPath.row];
    
    cell.leaderLabel.font = [UIFont fontWithName:@"Coder's Crux" size:30];
    [cell.leaderLabel setTextColor:[UIColor greenColor]];

    cell.aliveLabel.font = [UIFont fontWithName:@"Coder's Crux" size:30];
    [cell.aliveLabel setTextColor:[UIColor greenColor]];

    if ([leader valueForKey:@"eatenDate"] != nil) {
        [cell.leaderLabel setText:[NSString stringWithFormat:@"Eaten - %@", [leader valueForKey:@"name"]]];
    }
    else {
        [cell.leaderLabel setText:[NSString stringWithFormat:@"Alive - %@", [leader valueForKey:@"name"]]];
    }
    
    [cell.aliveLabel setText:[NSString stringWithFormat:@"Survived: %i hours", [[leader valueForKey:@"confirmedSecondsAlive"] intValue] / 60 / 60]];

    return cell;
}

@end
