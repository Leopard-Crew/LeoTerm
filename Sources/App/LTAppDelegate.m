#import "LTAppDelegate.h"
#import "LTMainWindowController.h"

@implementation LTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    _mainWindowController = [[LTMainWindowController alloc] init];
    [_mainWindowController showWindow:self];
}

- (void)dealloc
{
    [_mainWindowController release];
    [super dealloc];
}

@end
