//
//  ViewController.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "ViewController.h"
#import "CarlManager.h"

@interface ViewController ()

@property (nonatomic, retain) CarlManager *carlManager;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

@synthesize carlManager = _carlManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.carlManager = [CarlManager sharedCarlManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carlUpdatedDistanceFromUser:) name:@"CarlUpdatedDistanceFromUser" object:nil];
}

- (void)carlUpdatedDistanceFromUser:(NSNotification *)notification
{
    NSNumber *metersApart = [notification object];
    self.label.text = [NSString stringWithFormat:@"👾 %.2f meters away", [metersApart floatValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
