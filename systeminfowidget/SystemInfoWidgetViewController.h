#import <UIKit/UIKit.h>

@interface SystemInfoWidgetViewController : UIViewController
@property (nonatomic, retain) UILabel *batteryLabelPercentage;
@property (nonatomic, assign) NSUInteger previousBatteryUpdateLevel;
@property (nonatomic, retain) UIView *batteryBarPercentage;
@property (nonatomic, retain) UILabel *storageSpaceLabel;
@property (nonatomic, retain) UIView *storageSpaceBarPercentage;
@end