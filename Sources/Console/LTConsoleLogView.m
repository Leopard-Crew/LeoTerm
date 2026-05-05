#import "LTConsoleLogView.h"

@interface LTConsoleLogView (Private)

- (NSDictionary *)terminalDefaultProfile;
- (id)unarchivedTerminalPreferenceObject:(id)object;
- (NSFont *)consoleFontFromTerminalProfile:(NSDictionary *)profile;
- (NSColor *)consoleColorFromTerminalProfile:(NSDictionary *)profile key:(NSString *)key;
- (void)applyTerminalStyleToTextView;

@end

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
    [self applyTerminalStyleToTextView];
}

- (NSTextView *)textView
{
    return _textView;
}

- (NSDictionary *)terminalDefaultProfile
{
    NSString *preferencesPath;
    NSDictionary *terminalPreferences;
    NSDictionary *windowSettings;
    NSString *defaultProfileName;
    NSDictionary *profile;

    preferencesPath = [@"~/Library/Preferences/com.apple.Terminal.plist" stringByExpandingTildeInPath];

    terminalPreferences = [NSDictionary dictionaryWithContentsOfFile:preferencesPath];
    if (terminalPreferences == nil) {
        return nil;
    }

    windowSettings = [terminalPreferences objectForKey:@"Window Settings"];
    if (![windowSettings isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    /*
     * Terminal.app stores two relevant profile choices:
     *
     * - Startup Window Settings: profile used when Terminal.app starts
     * - Default Window Settings: profile used for default new windows
     *
     * For LeoTerm we prefer the startup profile because it best represents
     * the user's actively chosen Terminal look. On this Leopard system this
     * correctly selects "Homebrew" even when the default profile is "Basic".
     */
    defaultProfileName = [terminalPreferences objectForKey:@"Startup Window Settings"];

    if (defaultProfileName != nil) {
        profile = [windowSettings objectForKey:defaultProfileName];
        if ([profile isKindOfClass:[NSDictionary class]]) {
            return profile;
        }
    }

    defaultProfileName = [terminalPreferences objectForKey:@"Default Window Settings"];

    if (defaultProfileName != nil) {
        profile = [windowSettings objectForKey:defaultProfileName];
        if ([profile isKindOfClass:[NSDictionary class]]) {
            return profile;
        }
    }

    /*
     * Conservative fallback:
     * If Terminal.app has profiles but no readable default key,
     * use the first available profile instead of inventing a LeoTerm theme.
     */
    if ([[windowSettings allValues] count] > 0) {
        profile = [[windowSettings allValues] objectAtIndex:0];
        if ([profile isKindOfClass:[NSDictionary class]]) {
            return profile;
        }
    }

    return nil;
}

- (id)unarchivedTerminalPreferenceObject:(id)object
{
    id decodedObject;

    if (![object isKindOfClass:[NSData class]]) {
        return object;
    }

    decodedObject = nil;

    @try {
        decodedObject = [NSUnarchiver unarchiveObjectWithData:object];
    }
    @catch (NSException *exception) {
        decodedObject = nil;
    }

    if (decodedObject != nil) {
        return decodedObject;
    }

    @try {
        decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:object];
    }
    @catch (NSException *exception) {
        decodedObject = nil;
    }

    return decodedObject;
}

- (NSFont *)consoleFontFromTerminalProfile:(NSDictionary *)profile
{
    id fontObject;
    NSFont *font;

    font = nil;

    fontObject = [profile objectForKey:@"Font"];
    fontObject = [self unarchivedTerminalPreferenceObject:fontObject];

    if ([fontObject isKindOfClass:[NSFont class]]) {
        font = fontObject;
    }

    if (font == nil) {
        font = [NSFont fontWithName:@"Monaco" size:11.0];
    }

    if (font == nil) {
        font = [NSFont userFixedPitchFontOfSize:11.0];
    }

    return font;
}

- (NSColor *)consoleColorFromTerminalProfile:(NSDictionary *)profile key:(NSString *)key
{
    id colorObject;

    colorObject = [profile objectForKey:key];
    colorObject = [self unarchivedTerminalPreferenceObject:colorObject];

    if ([colorObject isKindOfClass:[NSColor class]]) {
        return colorObject;
    }

    return nil;
}

- (void)applyTerminalStyleToTextView
{
    NSDictionary *profile;
    NSFont *font;
    NSColor *textColor;
    NSColor *backgroundColor;

    if (_textView == nil) {
        return;
    }

    profile = [self terminalDefaultProfile];

    font = [self consoleFontFromTerminalProfile:profile];
    textColor = [self consoleColorFromTerminalProfile:profile key:@"TextColor"];
    backgroundColor = [self consoleColorFromTerminalProfile:profile key:@"BackgroundColor"];

    if (font != nil) {
        [_textView setFont:font];
    }

    if (textColor != nil) {
        [_textView setTextColor:textColor];
        [_textView setInsertionPointColor:textColor];
    }

    if (backgroundColor != nil) {
        [_textView setDrawsBackground:YES];
        [_textView setBackgroundColor:backgroundColor];
    }
}

- (void)clear
{
    [[_textView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
    [_marks removeAllObjects];
}

- (void)appendText:(NSString *)text
{
    NSAttributedString *attributedText;
    NSMutableDictionary *attributes;
    NSFont *font;
    NSColor *textColor;

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

    textColor = [_textView textColor];

    attributes = [NSMutableDictionary dictionary];

    if (font != nil) {
        [attributes setObject:font forKey:NSFontAttributeName];
    }

    if (textColor != nil) {
        [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
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
