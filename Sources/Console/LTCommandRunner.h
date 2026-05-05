#import <Cocoa/Cocoa.h>

@class LTProjectAction;
@class LTProjectProfile;

@interface LTCommandRunner : NSObject
{
    NSTask *_task;
    NSDate *_startDate;
    int _lastTerminationStatus;
}

- (BOOL)isRunning;
- (NSString *)runAction:(LTProjectAction *)action inProject:(LTProjectProfile *)project;
- (int)lastTerminationStatus;
- (void)terminate;

@end
