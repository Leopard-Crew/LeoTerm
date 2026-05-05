#import <Cocoa/Cocoa.h>

@interface LTConsoleLogView : NSObject
{
    NSTextView *_textView;
    NSMutableArray *_marks;
}

- (void)setTextView:(NSTextView *)textView;
- (NSTextView *)textView;

- (void)clear;
- (void)appendLine:(NSString *)line;
- (void)addMark:(id)mark;
- (NSArray *)marks;

@end
