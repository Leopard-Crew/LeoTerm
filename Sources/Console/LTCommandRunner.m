#import "LTCommandRunner.h"
#import "LTProjectAction.h"
#import "LTProjectProfile.h"

@implementation LTCommandRunner

- (BOOL)isRunning
{
    return (_task != nil && [_task isRunning]);
}

- (void)runAction:(LTProjectAction *)action inProject:(LTProjectProfile *)project
{
    NSString *rootPath;
    NSString *command;

    if ([self isRunning]) {
        return;
    }

    command = [action shellCommand];
    if (command == nil || [command length] == 0) {
        return;
    }

    _task = [[NSTask alloc] init];
    [_task setLaunchPath:@"/bin/sh"];
    [_task setArguments:[NSArray arrayWithObjects:@"-lc", command, nil]];

    rootPath = [project rootPath];
    if (rootPath != nil && [rootPath length] > 0) {
        [_task setCurrentDirectoryPath:rootPath];
    }

    _startDate = [[NSDate alloc] init];

    [_task launch];
    [_task waitUntilExit];

    [_startDate release];
    _startDate = nil;

    [_task release];
    _task = nil;
}

- (void)terminate
{
    if ([self isRunning]) {
        [_task terminate];
    }
}

- (void)dealloc
{
    [self terminate];
    [_task release];
    [_startDate release];
    [super dealloc];
}

@end
