#import "LTAppDelegate.h"
#import "../UI/LTMainWindowController.h"

@implementation LTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    _mainWindowController = [[LTMainWindowController alloc] init];
    [_mainWindowController showWindow:self];
    [[_mainWindowController window] makeKeyAndOrderFront:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)dealloc
{
    [_mainWindowController release];
    [super dealloc];
}

@end
