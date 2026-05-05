//
//  main.m
//  LeoTerm
//

#import <Cocoa/Cocoa.h>
#import "Sources/App/LTAppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool;
    LTAppDelegate *delegate;

    pool = [[NSAutoreleasePool alloc] init];

    [NSApplication sharedApplication];

    delegate = [[LTAppDelegate alloc] init];
    [NSApp setDelegate:delegate];

    [NSApp run];

    [delegate release];
    [pool release];

    return 0;
}
