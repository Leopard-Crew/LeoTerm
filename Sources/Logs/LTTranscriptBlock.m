#import "LTTranscriptBlock.h"

@implementation LTTranscriptBlock

- (id)initWithIdentifier:(NSUInteger)identifier
                   title:(NSString *)title
                 command:(NSString *)command
        workingDirectory:(NSString *)workingDirectory
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _title = [title copy];
        _command = [command copy];
        _workingDirectory = [workingDirectory copy];

        _startedAt = [[NSDate alloc] init];
        _endedAt = nil;

        _exitStatus = -1;
        _duration = 0.0;

        _outputText = [[NSMutableString alloc] init];
        _lineCount = 0;

        _collapsed = NO;
    }

    return self;
}

- (NSUInteger)identifier
{
    return _identifier;
}

- (NSString *)title
{
    return _title;
}

- (NSString *)command
{
    return _command;
}

- (NSString *)workingDirectory
{
    return _workingDirectory;
}

- (NSDate *)startedAt
{
    return _startedAt;
}

- (NSDate *)endedAt
{
    return _endedAt;
}

- (int)exitStatus
{
    return _exitStatus;
}

- (NSTimeInterval)duration
{
    return _duration;
}

- (NSString *)outputText
{
    return _outputText;
}

- (NSUInteger)lineCount
{
    return _lineCount;
}

- (BOOL)isCollapsed
{
    return _collapsed;
}

- (void)setCollapsed:(BOOL)collapsed
{
    _collapsed = collapsed;
}

- (void)appendOutputText:(NSString *)text
{
    NSUInteger index;
    NSUInteger length;

    if (text == nil || [text length] == 0) {
        return;
    }

    [_outputText appendString:text];

    length = [text length];

    for (index = 0; index < length; index++) {
        if ([text characterAtIndex:index] == '\n') {
            _lineCount++;
        }
    }

    if ([text characterAtIndex:(length - 1)] != '\n') {
        _lineCount++;
    }
}

- (void)finishWithExitStatus:(int)exitStatus duration:(NSTimeInterval)duration
{
    _exitStatus = exitStatus;
    _duration = duration;

    [_endedAt release];
    _endedAt = [[NSDate alloc] init];
}

- (void)dealloc
{
    [_title release];
    [_command release];
    [_workingDirectory release];

    [_startedAt release];
    [_endedAt release];

    [_outputText release];

    [super dealloc];
}

@end
