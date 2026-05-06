#import <Cocoa/Cocoa.h>

@interface LTTranscriptBlock : NSObject
{
    NSUInteger _identifier;
    NSString *_title;
    NSString *_command;
    NSString *_workingDirectory;

    NSDate *_startedAt;
    NSDate *_endedAt;

    int _exitStatus;
    NSTimeInterval _duration;

    NSMutableString *_outputText;
    NSUInteger _lineCount;

    BOOL _collapsed;
}

- (id)initWithIdentifier:(NSUInteger)identifier
                   title:(NSString *)title
                 command:(NSString *)command
        workingDirectory:(NSString *)workingDirectory;

- (NSUInteger)identifier;
- (NSString *)title;
- (NSString *)command;
- (NSString *)workingDirectory;

- (NSDate *)startedAt;
- (NSDate *)endedAt;

- (int)exitStatus;
- (NSTimeInterval)duration;

- (NSString *)outputText;
- (NSUInteger)lineCount;

- (BOOL)isCollapsed;
- (void)setCollapsed:(BOOL)collapsed;

- (void)appendOutputText:(NSString *)text;
- (void)finishWithExitStatus:(int)exitStatus duration:(NSTimeInterval)duration;

@end
