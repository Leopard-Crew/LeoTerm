#import "LTCommandRunner.h"
#import "../Actions/LTProjectAction.h"
#import "../Projects/LTProjectProfile.h"

@implementation LTCommandRunner

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

- (id)delegate
{
    return _delegate;
}

- (BOOL)isRunning
{
    return (_task != nil && [_task isRunning]);
}

- (BOOL)runAction:(LTProjectAction *)action inProject:(LTProjectProfile *)project
{
    NSString *rootPath;
    NSString *command;
    NSMutableDictionary *environment;
    NSString *path;

    if ([self isRunning]) {
        if (_delegate != nil &&
            [_delegate respondsToSelector:@selector(commandRunner:didReceiveOutput:)]) {
            [_delegate commandRunner:self didReceiveOutput:@"A command is already running.\n"];
        }

        return NO;
    }

    command = [action shellCommand];
    if (command == nil || [command length] == 0) {
        if (_delegate != nil &&
            [_delegate respondsToSelector:@selector(commandRunner:didReceiveOutput:)]) {
            [_delegate commandRunner:self didReceiveOutput:@"No command configured.\n"];
        }

        return NO;
    }

    _pipe = [[NSPipe alloc] init];
    _readHandle = [[_pipe fileHandleForReading] retain];

    _task = [[NSTask alloc] init];
    [_task setLaunchPath:@"/bin/sh"];
    [_task setArguments:[NSArray arrayWithObjects:@"-lc", command, nil]];
    [_task setStandardOutput:_pipe];
    [_task setStandardError:_pipe];

    /*
     * GUI applications launched from Finder or Xcode do not reliably inherit
     * the same PATH as an interactive Terminal session on Leopard.
     *
     * Keep LeoTerm command execution deterministic by explicitly exposing
     * Leopard's usual system paths, MacPorts, and /usr/local.
     */
    environment = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
    path = @"/usr/local/bin:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin";

    [environment setObject:path forKey:@"PATH"];
    [_task setEnvironment:environment];

    rootPath = [project rootPath];
    if (rootPath != nil && [rootPath length] > 0) {
        [_task setCurrentDirectoryPath:rootPath];
    }

    _startDate = [[NSDate alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readCompleted:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:_readHandle];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskTerminated:)
                                                 name:NSTaskDidTerminateNotification
                                               object:_task];

    [_readHandle readInBackgroundAndNotify];

    @try {
        [_task launch];
    }
    @catch (NSException *exception) {
        NSString *message;

        message = [NSString stringWithFormat:@"Failed to launch command: %@\n", [exception reason]];

        if (_delegate != nil &&
            [_delegate respondsToSelector:@selector(commandRunner:didReceiveOutput:)]) {
            [_delegate commandRunner:self didReceiveOutput:message];
        }

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSFileHandleReadCompletionNotification
                                                      object:_readHandle];

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSTaskDidTerminateNotification
                                                      object:_task];

        [_readHandle release];
        _readHandle = nil;

        [_pipe release];
        _pipe = nil;

        [_task release];
        _task = nil;

        [_startDate release];
        _startDate = nil;

        return NO;
    }

    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(commandRunnerDidStart:)]) {
        [_delegate commandRunnerDidStart:self];
    }

    return YES;
}

- (void)readCompleted:(NSNotification *)notification
{
    NSData *data;
    NSString *output;

    data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];

    if (data == nil || [data length] == 0) {
        return;
    }

    output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    if (output == nil) {
        output = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
    }

    if (output != nil &&
        _delegate != nil &&
        [_delegate respondsToSelector:@selector(commandRunner:didReceiveOutput:)]) {
        [_delegate commandRunner:self didReceiveOutput:output];
    }

    if ([self isRunning]) {
        [_readHandle readInBackgroundAndNotify];
    }
}

- (void)taskTerminated:(NSNotification *)notification
{
    NSTimeInterval duration;

    _lastTerminationStatus = [_task terminationStatus];

    duration = 0.0;
    if (_startDate != nil) {
        duration = -[_startDate timeIntervalSinceNow];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleReadCompletionNotification
                                                  object:_readHandle];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTaskDidTerminateNotification
                                                  object:_task];

    /*
     * Read remaining buffered data after the task has terminated.
     */
    {
        NSData *data;
        NSString *output;

        data = [_readHandle readDataToEndOfFile];

        if (data != nil && [data length] > 0) {
            output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

            if (output == nil) {
                output = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
            }

            if (output != nil &&
                _delegate != nil &&
                [_delegate respondsToSelector:@selector(commandRunner:didReceiveOutput:)]) {
                [_delegate commandRunner:self didReceiveOutput:output];
            }
        }
    }

    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(commandRunner:didFinishWithStatus:duration:)]) {
        [_delegate commandRunner:self
             didFinishWithStatus:_lastTerminationStatus
                         duration:duration];
    }

    [_readHandle release];
    _readHandle = nil;

    [_pipe release];
    _pipe = nil;

    [_task release];
    _task = nil;

    [_startDate release];
    _startDate = nil;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self terminate];

    [_readHandle release];
    [_pipe release];
    [_task release];
    [_startDate release];

    [super dealloc];
}

@end
