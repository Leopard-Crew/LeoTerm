#import <Cocoa/Cocoa.h>

typedef enum {
    LTMarkedOutputKindPlain = 0,
    LTMarkedOutputKindCommandStart = 1,
    LTMarkedOutputKindCommandEnd = 2,
    LTMarkedOutputKindWarning = 3,
    LTMarkedOutputKindError = 4,
    LTMarkedOutputKindArtifact = 5
} LTMarkedOutputKind;

@interface LTMarkedOutput : NSObject
{
    LTMarkedOutputKind _kind;
    NSRange _range;
    NSDate *_timestamp;
    NSString *_message;
}

- (id)initWithKind:(LTMarkedOutputKind)kind
             range:(NSRange)range
           message:(NSString *)message;

- (LTMarkedOutputKind)kind;
- (NSRange)range;
- (NSDate *)timestamp;
- (NSString *)message;

@end
