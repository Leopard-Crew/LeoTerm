#import <Cocoa/Cocoa.h>

@class LTProjectAction;
@class LTProjectProfile;

@interface LTCommandRunner : NSObject
{
    NSTask *_task;
    NSPipe *_pipe;
    NSFileHandle *_readHandle;
    NSDate *_startDate;
    int _lastTerminationStatus;
    id _delegate;
}

- (void)setDelegate:(id)delegate;
- (id)delegate;

- (BOOL)isRunning;
- (BOOL)runAction:(LTProjectAction *)action inProject:(LTProjectProfile *)project;
- (int)lastTerminationStatus;
- (void)terminate;

@end
