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
    NSDictionary *attributes;
    NSFont *font;

    if (_textView == nil || text == nil) {
        return;
    }

    font = [_textView font];

    if (font == nil) {
        font = [NSFont fontWithName:@"Monaco" size:11.0];
    }

    if (font == nil) {
        font = [NSFont userFixedPitchFontOfSize:11.0];
    }

    attributes = nil;
    if (font != nil) {
        attributes = [NSDictionary dictionaryWithObject:font
                                                 forKey:NSFontAttributeName];
    }

    attributedText = [[[NSAttributedString alloc] initWithString:text
                                                      attributes:attributes] autorelease];

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
