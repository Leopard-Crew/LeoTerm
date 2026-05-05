#import "LTMarkedOutput.h"

@implementation LTMarkedOutput

- (id)initWithKind:(LTMarkedOutputKind)kind
             range:(NSRange)range
           message:(NSString *)message
{
    self = [super init];
    if (self) {
        _kind = kind;
        _range = range;
        _timestamp = [[NSDate alloc] init];
        _message = [message copy];
    }
    return self;
}

- (LTMarkedOutputKind)kind
{
    return _kind;
}

- (NSRange)range
{
    return _range;
}

- (NSDate *)timestamp
{
    return _timestamp;
}

- (NSString *)message
{
    return _message;
}

- (void)dealloc
{
    [_timestamp release];
    [_message release];
    [super dealloc];
}

@end
