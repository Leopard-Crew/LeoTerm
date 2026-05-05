#import <Cocoa/Cocoa.h>

@interface LTProjectAction : NSObject
{
    NSString *_identifier;
    NSString *_title;
    NSString *_shellCommand;
}

+ (id)shellActionWithIdentifier:(NSString *)identifier
                          title:(NSString *)title
                        command:(NSString *)shellCommand;

- (id)initWithIdentifier:(NSString *)identifier
                   title:(NSString *)title
                 command:(NSString *)shellCommand;

- (NSString *)identifier;
- (NSString *)title;
- (NSString *)shellCommand;

@end
