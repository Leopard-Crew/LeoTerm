#import <Cocoa/Cocoa.h>

@interface LTProjectProfile : NSObject
{
    NSString *_name;
    NSString *_rootPath;
    NSMutableArray *_actions;
}

- (id)initWithName:(NSString *)name rootPath:(NSString *)rootPath;

- (NSString *)name;
- (NSString *)rootPath;
- (NSArray *)actions;

- (void)setRootPath:(NSString *)rootPath;
- (void)addAction:(id)action;

@end
