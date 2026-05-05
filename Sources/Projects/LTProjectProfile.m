#import "LTProjectProfile.h"

@implementation LTProjectProfile

- (id)initWithName:(NSString *)name rootPath:(NSString *)rootPath
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _rootPath = [rootPath copy];
        _actions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)name
{
    return _name;
}

- (NSString *)rootPath
{
    return _rootPath;
}

- (NSArray *)actions
{
    return _actions;
}

- (void)setRootPath:(NSString *)rootPath
{
    if (_rootPath != rootPath) {
        [_rootPath release];
        _rootPath = [rootPath copy];
    }
}

- (void)addAction:(id)action
{
    if (action != nil) {
        [_actions addObject:action];
    }
}

- (void)dealloc
{
    [_name release];
    [_rootPath release];
    [_actions release];
    [super dealloc];
}

@end
