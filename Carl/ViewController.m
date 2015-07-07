//
//  ViewController.m
//  Carl
//
//  Created by Zach Whelchel on 7/6/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "ViewController.h"
#import "CarlManager.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
#define METERS_TO_RIGHT_EDGE_OF_DEVICE 10000

@interface ViewController ()

@property (nonatomic, retain) CarlManager *carlManager;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *carlLabel;

@property (nonatomic) float metersApart;
@property (nonatomic) float metersNorth;
@property (nonatomic) float metersEast;
@property (nonatomic) double userHeading;

@end

@implementation ViewController

@synthesize carlManager = _carlManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.carlManager = [CarlManager sharedCarlManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carlUpdatedDistanceFromUser:) name:@"CarlUpdatedDistanceFromUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdatedHeading:) name:@"UserUpdatedHeading" object:nil];
}

- (void)carlUpdatedDistanceFromUser:(NSNotification *)notification
{
    self.metersApart = [[[notification object] valueForKey:@"metersApart"] floatValue];
    self.metersNorth = [[[notification object] valueForKey:@"metersNorth"] floatValue];
    self.metersEast = [[[notification object] valueForKey:@"metersEast"] floatValue];
    
    self.label.text = [NSString stringWithFormat:@"%.2f meters away", self.metersApart];
    
    [self updateCarlPositionOnMap];
}

- (void)userUpdatedHeading:(NSNotification *)notification
{
    self.userHeading = [[[notification object] valueForKey:@"newMagneticHeading"] doubleValue];

    [self updateCarlPositionOnMap];
}

- (void)updateCarlPositionOnMap
{
    float middleX = self.view.frame.size.width / 2;
    float middleY = self.view.frame.size.height / 2;
    float metersInPoint = (self.view.frame.size.width / 2) / METERS_TO_RIGHT_EDGE_OF_DEVICE;
    float maxCarlFontSize = self.view.frame.size.width / 5;
    
    float carlFontSize = maxCarlFontSize - ((self.metersApart / METERS_TO_RIGHT_EDGE_OF_DEVICE) * maxCarlFontSize);
    
    if (carlFontSize < 20) {
        carlFontSize = 20;
    }
    
    float carlWidth = carlFontSize * 1.5;
    
    self.carlLabel.font = [UIFont systemFontOfSize:carlFontSize];
    self.carlLabel.textAlignment = NSTextAlignmentCenter;
    [self.carlLabel setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.carlLabel.backgroundColor = [UIColor clearColor];
    
    float x = (metersInPoint * self.metersNorth);
    float y = (metersInPoint * self.metersEast);

    float radians = degreesToRadians(self.userHeading * -1);

    float newX = 0 + ((x-0) * cos(radians)) - ((y-0) * sin(radians));
    float newY = 0 + ((x-0) * sin(radians)) + ((y-0) * cos(radians));

    self.carlLabel.frame = CGRectMake(middleX + newX - (carlWidth / 2), middleY + newY - (carlWidth / 2), carlWidth, carlWidth);
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
