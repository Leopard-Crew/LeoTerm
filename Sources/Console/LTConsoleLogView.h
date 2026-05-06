#import <Cocoa/Cocoa.h>

@interface LTConsoleLogView : NSObject
{
    NSTextView *_textView;
    NSMutableArray *_marks;
}

- (void)setTextView:(NSTextView *)textView;
- (NSTextView *)textView;

- (void)clear;
- (void)appendText:(NSString *)text;
- (void)appendLine:(NSString *)line;

- (void)appendChellHeaderLine:(NSString *)line;
- (void)appendChellMetadataLine:(NSString *)line;
- (void)appendChellSeparatorLine;

- (void)addMark:(id)mark;
- (NSArray *)marks;

@end
