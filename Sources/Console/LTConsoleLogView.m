#import "LTConsoleLogView.h"

@implementation LTConsoleLogView

- (id)init
{
    self = [super init];
    if (self) {
        _marks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setTextView:(NSTextView *)textView
{
    _textView = textView;
}

- (NSTextView *)textView
{
    return _textView;
}

- (void)clear
{
    [[_textView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
    [_marks removeAllObjects];
}

- (void)appendText:(NSString *)text
{
    NSAttributedString *attributedText;

    if (_textView == nil || text == nil) {
        return;
    }

    attributedText = [[[NSAttributedString alloc] initWithString:text] autorelease];

    [[_textView textStorage] appendAttributedString:attributedText];
    [_textView scrollRangeToVisible:NSMakeRange([[_textView string] length], 0)];
}

- (void)appendLine:(NSString *)line
{
    if (line == nil) {
        return;
    }

    [self appendText:[line stringByAppendingString:@"\n"]];
}

- (void)addMark:(id)mark
{
    if (mark != nil) {
        [_marks addObject:mark];
    }
}

- (NSArray *)marks
{
    return _marks;
}

- (void)dealloc
{
    [_marks release];
    [super dealloc];
}

@end
