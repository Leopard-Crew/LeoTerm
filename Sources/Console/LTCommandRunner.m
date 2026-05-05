#import "LTCommandRunner.h"
#import "../Actions/LTProjectAction.h"
#import "../Projects/LTProjectProfile.h"

@implementation LTCommandRunner

- (BOOL)isRunning
{
    return (_task != nil && [_task isRunning]);
}

- (NSString *)runAction:(LTProjectAction *)action inProject:(LTProjectProfile *)project
{
    NSString *rootPath;
    NSString *command;
    NSPipe *pipe;
    NSData *data;
    NSString *output;

    if ([self isRunning]) {
        return @"A command is already running.\n";
    }

    command = [action shellCommand];
    if (command == nil || [command length] == 0) {
        return @"No command configured.\n";
    }

    pipe = [NSPipe pipe];

    _task = [[NSTask alloc] init];
    [_task setLaunchPath:@"/bin/sh"];
    [_task setArguments:[NSArray arrayWithObjects:@"-lc", command, nil]];
    [_task setStandardOutput:pipe];
    [_task setStandardError:pipe];

    /*
     * GUI applications launched from Finder or Xcode do not reliably inherit
     * the same PATH as an interactive Terminal session on Leopard.
     *
     * Keep LeoTerm command execution deterministic by explicitly exposing
     * Leopard's usual system paths, MacPorts, and /usr/local.
     */
    {
        NSMutableDictionary *environment;
        NSString *path;

        environment = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
        path = @"/usr/local/bin:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin";

        [environment setObject:path forKey:@"PATH"];
        [_task setEnvironment:environment];
    }

    rootPath = [project rootPath];
    if (rootPath != nil && [rootPath length] > 0) {
        [_task setCurrentDirectoryPath:rootPath];
    }

    _startDate = [[NSDate alloc] init];

    [_task launch];
    [_task waitUntilExit];

    _lastTerminationStatus = [_task terminationStatus];

    data = [[pipe fileHandleForReading] readDataToEndOfFile];
    output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    if (output == nil) {
        output = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
    }

    [_startDate release];
    _startDate = nil;

    [_task release];
    _task = nil;

    if (output == nil) {
        return @"";
    }

    return output;
}

- (int)lastTerminationStatus
{
    return _lastTerminationStatus;
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
