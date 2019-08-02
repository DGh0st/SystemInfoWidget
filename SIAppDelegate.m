#import "SIAppDelegate.h"

@implementation SIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.backgroundColor = [UIColor blackColor];
	self.viewController = [[SIRootViewController alloc] init];
	self.window.rootViewController = self.viewController;

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
	[self.window release];
	self.window = nil;

	[self.viewController release];
	self.viewController = nil;

	[super dealloc];
}

@end
