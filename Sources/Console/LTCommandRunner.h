#import <Cocoa/Cocoa.h>

@class LTProjectAction;
@class LTProjectProfile;

@interface LTCommandRunner : NSObject
{
    NSTask *_task;
    NSDate *_startDate;
}

- (BOOL)isRunning;
- (void)runAction:(LTProjectAction *)action inProject:(LTProjectProfile *)project;
- (void)terminate;

@end
