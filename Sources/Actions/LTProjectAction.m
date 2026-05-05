#import "LTProjectAction.h"

@implementation LTProjectAction

+ (id)shellActionWithIdentifier:(NSString *)identifier
                          title:(NSString *)title
                        command:(NSString *)shellCommand
{
    return [[[self alloc] initWithIdentifier:identifier
                                       title:title
                                     command:shellCommand] autorelease];
}

- (id)initWithIdentifier:(NSString *)identifier
                   title:(NSString *)title
                 command:(NSString *)shellCommand
{
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _title = [title copy];
        _shellCommand = [shellCommand copy];
    }
    return self;
}

- (NSString *)identifier
{
    return _identifier;
}

- (NSString *)title
{
    return _title;
}

- (NSString *)shellCommand
{
    return _shellCommand;
}

- (void)dealloc
{
    [_identifier release];
    [_title release];
    [_shellCommand release];
    [super dealloc];
}

@end
