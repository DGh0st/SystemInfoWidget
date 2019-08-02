#import "SystemInfoWidgetViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface UIStatusBar
+(NSInteger)lowBatteryLevel;
@end

@interface UIColor (SIPrivate)
+(id)systemYellowColor;
+(id)systemDarkRedColor;
+(id)systemDarkGreenColor;
+(id)systemGrayColor;
@end

@interface NCWidgetController (SIPrivate)
@end

@interface SystemInfoWidgetViewController (SIPrivate) <NCWidgetProviding>
@end

@implementation SystemInfoWidgetViewController
-(void)viewDidLoad {
    [super viewDidLoad];

    UILabel *batteryLabelTitle = [[UILabel alloc] init];
    batteryLabelTitle.text = NSLocalizedString(@"Battery", @"");
    batteryLabelTitle.textAlignment = NSTextAlignmentLeft;
    batteryLabelTitle.textColor = [UIColor blackColor];
    batteryLabelTitle.numberOfLines = 1;
    batteryLabelTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.view addSubview:batteryLabelTitle];

    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;

    self.batteryLabelPercentage = [[UILabel alloc] init];
    self.batteryLabelPercentage.textAlignment = NSTextAlignmentRight;
    self.batteryLabelPercentage.textColor = [UIColor blackColor];
    self.batteryLabelPercentage.numberOfLines = 1;
    self.batteryLabelPercentage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.view addSubview:self.batteryLabelPercentage];

    UIView *batteryBarBackground = [[UIView alloc] init];
    batteryBarBackground.backgroundColor = [UIColor systemGrayColor];
    batteryBarBackground.layer.cornerRadius = 8.0;
    [self.view addSubview:batteryBarBackground];

    self.batteryBarPercentage = [[UIView alloc] init];
    self.batteryBarPercentage.layer.cornerRadius = 8.0;
    [batteryBarBackground addSubview:self.batteryBarPercentage];

    [self updateBatteryInfoWithLevel:device.batteryLevel * 100];

    UILabel *storageLabelTitle = [[UILabel alloc] init];
    storageLabelTitle.text = NSLocalizedString(@"Storage", @"");
    storageLabelTitle.textAlignment = NSTextAlignmentLeft;
    storageLabelTitle.textColor = [UIColor blackColor];
    storageLabelTitle.numberOfLines = 1;
    storageLabelTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.view addSubview:storageLabelTitle];

    self.storageSpaceLabel = [[UILabel alloc] init];
    self.storageSpaceLabel.textAlignment = NSTextAlignmentLeft;
    self.storageSpaceLabel.textColor = [UIColor blackColor];
    self.storageSpaceLabel.numberOfLines = 1;
    self.storageSpaceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.view addSubview:self.storageSpaceLabel];

    UIView *storageSpaceBackground = [[UIView alloc] init];
    storageSpaceBackground.backgroundColor = [UIColor systemDarkGreenColor];
    storageSpaceBackground.layer.cornerRadius = 8.0;
    [self.view addSubview:storageSpaceBackground];

    self.storageSpaceBarPercentage = [[UIView alloc] init];
    self.storageSpaceBarPercentage.backgroundColor = [UIColor systemDarkRedColor];
    self.storageSpaceBarPercentage.layer.cornerRadius = 8.0;
    [storageSpaceBackground addSubview:self.storageSpaceBarPercentage];

    [self updateStorageSpace];

    CGFloat storageSpacePercentage = [self storagePercentage];
    if (storageSpacePercentage < 0.0)
        storageSpacePercentage = 1.0;

    // setup constraints for battery information UI
    batteryLabelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:batteryLabelTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:16].active = YES;
    [NSLayoutConstraint constraintWithItem:batteryLabelTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:batteryLabelTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.batteryLabelPercentage attribute:NSLayoutAttributeLeft multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:batteryLabelTitle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:16].active = YES;

    self.batteryLabelPercentage.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.batteryLabelPercentage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:batteryLabelTitle attribute:NSLayoutAttributeRight multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryLabelPercentage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryLabelPercentage attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-16].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryLabelPercentage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:16].active= YES;

    batteryBarBackground.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:batteryBarBackground attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:16].active = YES;
    [NSLayoutConstraint constraintWithItem:batteryBarBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:batteryLabelTitle attribute:NSLayoutAttributeBottom multiplier:1 constant:6].active = YES;
    [NSLayoutConstraint constraintWithItem:batteryBarBackground attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-16].active = YES;
    [NSLayoutConstraint constraintWithItem:batteryBarBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:16].active= YES;

    self.batteryBarPercentage.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.batteryBarPercentage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:batteryBarBackground attribute:NSLayoutAttributeLeft multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryBarPercentage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:batteryBarBackground attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryBarPercentage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:batteryBarBackground attribute:NSLayoutAttributeWidth multiplier:device.batteryLevel constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.batteryBarPercentage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:batteryBarBackground attribute:NSLayoutAttributeHeight multiplier:1 constant:0].active= YES;

    // setup constraints for storage space information UI
    storageLabelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:storageLabelTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:16].active = YES;
    [NSLayoutConstraint constraintWithItem:storageLabelTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:batteryBarBackground attribute:NSLayoutAttributeBottom multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:storageLabelTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.storageSpaceLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:storageLabelTitle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:16].active = YES;

    self.storageSpaceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:storageLabelTitle attribute:NSLayoutAttributeRight multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:batteryBarBackground attribute:NSLayoutAttributeBottom multiplier:1 constant:8].active = YES;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-16].active = YES;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:16].active= YES;

    storageSpaceBackground.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:storageSpaceBackground attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:16].active = YES;
    [NSLayoutConstraint constraintWithItem:storageSpaceBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:storageLabelTitle attribute:NSLayoutAttributeBottom multiplier:1 constant:6].active = YES;
    [NSLayoutConstraint constraintWithItem:storageSpaceBackground attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-16].active = YES;
    [NSLayoutConstraint constraintWithItem:storageSpaceBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:16].active= YES;
    [NSLayoutConstraint constraintWithItem:storageSpaceBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-12].active = YES;

    self.storageSpaceBarPercentage.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceBarPercentage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:storageSpaceBackground attribute:NSLayoutAttributeLeft multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceBarPercentage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:storageSpaceBackground attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceBarPercentage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:storageSpaceBackground attribute:NSLayoutAttributeWidth multiplier:storageSpacePercentage constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceBarPercentage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:storageSpaceBackground attribute:NSLayoutAttributeHeight multiplier:1 constant:0].active= YES;

    [batteryLabelTitle release];
    [batteryBarBackground release];

    [storageLabelTitle release];
    [storageSpaceBackground release];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:NSProcessInfoPowerStateDidChangeNotification object:nil];
}

-(void)batteryStatusChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self updateBatteryInfoWithLevel:[UIDevice currentDevice].batteryLevel * 100];
        } completion:nil];
    });
}

-(void)updateBatteryInfoWithLevel:(NSUInteger)newLevel {
    self.previousBatteryUpdateLevel = newLevel;
    self.batteryLabelPercentage.text = [NSString stringWithFormat:NSLocalizedString(@"%tu%%", @""), self.previousBatteryUpdateLevel];
    UIColor *color = nil;
    if ([NSProcessInfo processInfo].lowPowerModeEnabled)
        color = [UIColor systemYellowColor];
    else if (newLevel <= [UIStatusBar lowBatteryLevel])
        color = [UIColor systemDarkRedColor];
    else
        color = [UIColor systemDarkGreenColor];
    self.batteryBarPercentage.backgroundColor = color;
    [NSLayoutConstraint constraintWithItem:self.batteryBarPercentage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.batteryBarPercentage.superview attribute:NSLayoutAttributeWidth multiplier:newLevel / 100.0 constant:0].active = YES;
}

// storage percentage related logic copied from https://github.com/Shmoopi/iOS-System-Services/blob/master/System%20Services/Utilities/SSDiskInfo.m
-(CGFloat)storagePercentage {
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error == nil) {
        int64_t totalSpace = [fileAttributes objectForKey:NSFileSystemSize] ? [[fileAttributes objectForKey:NSFileSystemSize] longLongValue] : -1;
        int64_t freeSpace = [fileAttributes objectForKey:NSFileSystemFreeSize] ? [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue] : -1;
        if (totalSpace == -1 || freeSpace == -1)
            return -1.0;
        return 1.0 - (freeSpace / (CGFloat)totalSpace);
    }
    return -1.0;
}

-(NSString *)storageByteStringWithSpace:(uint64_t)space {
    CGFloat spaceBytes = (CGFloat)space;
    CGFloat spaceMB = spaceBytes / 1000.0 / 1000.0;
    CGFloat spaceGB = spaceMB / 1000.0;

    NSString *spaceString = nil;
    if (spaceGB > 1.0) {
        spaceString = [NSString localizedStringWithFormat:@"%.2f GB", spaceGB];
    } else if (spaceMB > 1.0) {
        spaceString = [NSString localizedStringWithFormat:@"%.2f MB", spaceMB];
    } else {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:NSLocalizedString(@"Bytes", @"")/*@"###,###,###,###"*/];
        NSNumber *number = [NSNumber numberWithLongLong:spaceBytes];
        spaceString = [formatter stringFromNumber:number];
    }
    return spaceString;
}

-(NSString *)storagePercentageString {
    CGFloat percentage = [self storagePercentage];
    if (percentage < 0.0)
        return NSLocalizedString(@"Unknown", @"");
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error == nil) {
        int64_t totalSpace = [fileAttributes objectForKey:NSFileSystemSize] ? [[fileAttributes objectForKey:NSFileSystemSize] longLongValue] : -1;
        int64_t freeSpace = [fileAttributes objectForKey:NSFileSystemFreeSize] ? [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue] : -1;
        if (totalSpace == -1 || freeSpace == -1 || totalSpace < freeSpace)
            return NSLocalizedString(@"Unknown", @"");

        NSString *freeSpaceString = [self storageByteStringWithSpace:totalSpace - freeSpace];
        if (freeSpaceString == nil)
            return NSLocalizedString(@"Unknown", @"");
        
        NSString *totalSpaceString = [self storageByteStringWithSpace:totalSpace];
        if (totalSpaceString == nil)
            return NSLocalizedString(@"Unknown", @"");
        
        return [NSString stringWithFormat:@"%@ / %@", freeSpaceString, totalSpaceString];
    }
    return NSLocalizedString(@"Unknown", @"");
}

-(void)updateStorageSpace {
    self.storageSpaceLabel.text = [self storagePercentageString];

    CGFloat storageSpacePercentage = [self storagePercentage];
    if (storageSpacePercentage < 0.0)
        storageSpacePercentage = 1.0;
    [NSLayoutConstraint constraintWithItem:self.storageSpaceBarPercentage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.storageSpaceBarPercentage.superview attribute:NSLayoutAttributeWidth multiplier:storageSpacePercentage constant:0].active = YES;
}

-(void)dealloc {
    [self.batteryLabelPercentage release];
    self.batteryLabelPercentage = nil;

    [self.batteryBarPercentage release];
    self.batteryBarPercentage = nil;

    [self.storageSpaceLabel release];
    self.storageSpaceLabel = nil;

    [self.storageSpaceBarPercentage release];
    self.storageSpaceBarPercentage = nil;

    [super dealloc];
}

-(void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    UIDevice *device = [UIDevice currentDevice];
    if (device == nil) {
        completionHandler(NCUpdateResultFailed);
    } else {
        NSUInteger newBatteryLevel = device.batteryLevel * 100;
        if (newBatteryLevel != self.previousBatteryUpdateLevel) {
            [UIView animateWithDuration:0.3 animations:^{
                [self updateBatteryInfoWithLevel:newBatteryLevel];
                [self updateStorageSpace];
            } completion:^(BOOL finished) {
                completionHandler(NCUpdateResultNewData);
            }];
        } else {
            completionHandler(NCUpdateResultNoData);
        }
    }
}
@end