#import "SIRootViewController.h"

@implementation SIRootViewController
-(void)viewDidLoad {
	[super viewDidLoad];

	// enable battery monintoring so we can get battery related information
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;

	self.batteryPercentangeLabel = [[UILabel alloc] init];
    self.batteryPercentangeLabel.text = [NSString stringWithFormat:@"%tu%%", (NSUInteger)([UIDevice currentDevice].batteryLevel * 100)];
    self.batteryPercentangeLabel.textAlignment = NSTextAlignmentCenter;
    self.batteryPercentangeLabel.textColor = [UIColor whiteColor];
    self.batteryPercentangeLabel.numberOfLines = 1;
    self.batteryPercentangeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self.view addSubview:self.batteryPercentangeLabel];

    self.batteryPercentangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.batteryPercentangeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryPercentangeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryPercentangeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryPercentangeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0].active = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}

-(void)batteryLevelChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.batteryPercentangeLabel.text = [NSString stringWithFormat:@"%tu%%", (NSUInteger)([UIDevice currentDevice].batteryLevel * 100)];
        } completion:nil];
    });
}

-(BOOL)prefersStatusBarHidden {
	return YES; // hide status bar for seemless black screen
}

-(void)dealloc {
	[self.batteryPercentangeLabel release];
	self.batteryPercentangeLabel = nil;

	[super dealloc];
}
@end