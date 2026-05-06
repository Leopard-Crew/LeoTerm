#import "LTMainWindowController.h"
#import "../Projects/LTProjectProfile.h"
#import "../Actions/LTProjectAction.h"
#import "../Console/LTConsoleLogView.h"
#import "../Console/LTCommandRunner.h"
#import "../Logs/LTTranscriptBlock.h"

@interface LTMainWindowController (Private)

- (void)buildWindowInterface;
- (NSButton *)buttonWithTitle:(NSString *)title action:(SEL)action frame:(NSRect)frame;
- (NSString *)defaultProjectRootPath;
- (NSString *)projectListText;
- (NSString *)chellTimestampStringForDate:(NSDate *)date;

- (void)appendWelcomeText;
- (void)setStatusText:(NSString *)statusText;
- (void)renderTranscriptView;
- (void)appendTranscriptBlock:(LTTranscriptBlock *)block;
- (LTTranscriptBlock *)transcriptBlockWithIdentifier:(NSUInteger)identifier;

- (NSString *)sanitizedBlockIdentifierString:(NSString *)string;
- (NSUInteger)selectedBlockIdentifier;
- (void)setSelectedBlockIdentifier:(NSUInteger)identifier;
- (void)updateSelectedBlockControls;

- (void)runProjectActionWithIdentifier:(NSString *)identifier
                                 title:(NSString *)title
                               command:(NSString *)command;

@end

@implementation LTMainWindowController

- (id)init
{
    NSWindow *window;
    NSString *projectRootPath;

    window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 980, 560)
                                         styleMask:(NSTitledWindowMask |
                                                    NSClosableWindowMask |
                                                    NSMiniaturizableWindowMask |
                                                    NSResizableWindowMask |
                                                    NSUnifiedTitleAndToolbarWindowMask)
                                           backing:NSBackingStoreBuffered
                                             defer:NO];

    [window setTitle:@"LeoTerm Developer Console"];

    self = [super initWithWindow:window];
    [window release];

    if (self) {
        projectRootPath = [self defaultProjectRootPath];

        _currentProject = [[LTProjectProfile alloc] initWithName:@"LeoTerm"
                                                        rootPath:projectRootPath];
        _consoleLogView = [[LTConsoleLogView alloc] init];
        _commandRunner = [[LTCommandRunner alloc] init];
        [_commandRunner setDelegate:self];

        _transcriptBlocks = [[NSMutableArray alloc] init];
        _currentTranscriptBlock = nil;
        _nextTranscriptBlockIdentifier = 1;
        _selectedBlockField = nil;
        _selectedBlockStepper = nil;
        _statusTextField = nil;
        _actionsPopUpButton = nil;

        [self buildWindowInterface];
        [self appendWelcomeText];
    }

    return self;
}

- (void)appendWelcomeText
{
    NSString *projectRootPath;

    projectRootPath = [_currentProject rootPath];

    [_consoleLogView appendLine:@"LeoTerm Developer Console"];
    [_consoleLogView appendLine:@"Native Leopard command workbench skeleton is alive."];
    [_consoleLogView appendLine:@""];

    if (projectRootPath != nil) {
        [_consoleLogView appendLine:[NSString stringWithFormat:@"Default project: %@", projectRootPath]];
    } else {
        [_consoleLogView appendLine:@"Default project: not found"];
    }

    [_consoleLogView appendLine:@""];
    [_consoleLogView appendLine:@"V1 scope: project actions, build logs, Finder integration."];
    [_consoleLogView appendLine:@"Not a Windows Terminal port. Not a PowerShell clone."];
}

- (void)setStatusText:(NSString *)statusText
{
    if (_statusTextField == nil) {
        return;
    }

    if (statusText == nil) {
        statusText = @"";
    }

    [_statusTextField setStringValue:statusText];
}

- (NSString *)defaultProjectRootPath
{
    NSFileManager *fileManager;
    NSString *candidatePath;
    NSString *gitPath;
    NSString *projectPath;
    int attempts;

    fileManager = [NSFileManager defaultManager];

    candidatePath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];

    attempts = 0;
    while (candidatePath != nil && [candidatePath length] > 1 && attempts < 12) {
        gitPath = [candidatePath stringByAppendingPathComponent:@".git"];
        projectPath = [candidatePath stringByAppendingPathComponent:@"LeoTerm.xcodeproj"];

        if ([fileManager fileExistsAtPath:gitPath] &&
            [fileManager fileExistsAtPath:projectPath]) {
            return candidatePath;
        }

        candidatePath = [candidatePath stringByDeletingLastPathComponent];
        attempts++;
    }

    return nil;
}

- (NSString *)projectListText
{
    NSString *rootPath;

    rootPath = [_currentProject rootPath];

    if (rootPath == nil || [rootPath length] == 0) {
        return @"LeoTerm\n\nNo project profile loaded yet.";
    }

    return [NSString stringWithFormat:@"LeoTerm\n\n%@", rootPath];
}

- (void)buildWindowInterface
{
    NSView *contentView;
    NSSplitView *splitView;
    NSView *leftView;
    NSView *rightView;
    NSTextField *projectTitle;
    NSScrollView *projectScrollView;
    NSTextView *projectTextView;
    NSButton *buildButton;
    NSButton *collapseSelectedButton;
    NSTextField *selectedBlockLabel;
    NSScrollView *consoleScrollView;
    NSTextView *consoleTextView;
    NSTextField *statusTextField;
    NSRect bounds;

    contentView = [[self window] contentView];
    bounds = [contentView bounds];

    splitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 24,
                                                               bounds.size.width,
                                                               bounds.size.height - 24)];
    [splitView setVertical:YES];
    [splitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

    leftView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 190, bounds.size.height)];
    rightView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, bounds.size.width - 190, bounds.size.height)];

    projectTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(12, bounds.size.height - 34, 160, 20)];
    [projectTitle setStringValue:@"Projects"];
    [projectTitle setBezeled:NO];
    [projectTitle setDrawsBackground:NO];
    [projectTitle setEditable:NO];
    [projectTitle setSelectable:NO];
    [projectTitle setFont:[NSFont boldSystemFontOfSize:12.0]];
    [projectTitle setAutoresizingMask:NSViewMinYMargin];
    [leftView addSubview:projectTitle];
    [projectTitle release];

    projectScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 10, 170, bounds.size.height - 52)];
    [projectScrollView setBorderType:NSBezelBorder];
    [projectScrollView setHasVerticalScroller:YES];
    [projectScrollView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];

    projectTextView = [[NSTextView alloc] initWithFrame:[[projectScrollView contentView] bounds]];
    [projectTextView setEditable:NO];
    [projectTextView setSelectable:YES];
    [projectTextView setString:[self projectListText]];
    [projectTextView setFont:[NSFont systemFontOfSize:11.0]];
    [projectTextView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

    [projectScrollView setDocumentView:projectTextView];
    [projectTextView release];

    [leftView addSubview:projectScrollView];
    [projectScrollView release];

    buildButton = [self buttonWithTitle:@"Build & Go"
                                 action:@selector(runBuildAction:)
                                  frame:NSMakeRect(12, bounds.size.height - 38, 100, 26)];

    _actionsPopUpButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(122, bounds.size.height - 39, 150, 26)
                                                     pullsDown:NO];
    [_actionsPopUpButton addItemWithTitle:@"Actions"];
    [_actionsPopUpButton addItemWithTitle:@"Smoke Test"];
    [_actionsPopUpButton addItemWithTitle:@"Clean"];
    [_actionsPopUpButton addItemWithTitle:@"Reveal"];
    [_actionsPopUpButton addItemWithTitle:@"Collapse Last"];
    [_actionsPopUpButton addItemWithTitle:@"Expand All"];
    [_actionsPopUpButton selectItemAtIndex:0];
    [_actionsPopUpButton setTarget:self];
    [_actionsPopUpButton setAction:@selector(runSelectedAction:)];

    selectedBlockLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(288, bounds.size.height - 34, 44, 18)];
    [selectedBlockLabel setStringValue:@"Block:"];
    [selectedBlockLabel setBezeled:NO];
    [selectedBlockLabel setDrawsBackground:NO];
    [selectedBlockLabel setEditable:NO];
    [selectedBlockLabel setSelectable:NO];
    [selectedBlockLabel setFont:[NSFont systemFontOfSize:11.0]];

    _selectedBlockField = [[NSTextField alloc] initWithFrame:NSMakeRect(336, bounds.size.height - 38, 46, 24)];
    [_selectedBlockField setStringValue:@"1"];
    [_selectedBlockField setFont:[NSFont systemFontOfSize:11.0]];
    [_selectedBlockField setAlignment:NSRightTextAlignment];
    [_selectedBlockField setDelegate:self];

    _selectedBlockStepper = [[NSStepper alloc] initWithFrame:NSMakeRect(384, bounds.size.height - 38, 18, 24)];
    [_selectedBlockStepper setMinValue:1.0];
    [_selectedBlockStepper setMaxValue:1.0];
    [_selectedBlockStepper setIncrement:1.0];
    [_selectedBlockStepper setDoubleValue:1.0];
    [_selectedBlockStepper setValueWraps:NO];
    [_selectedBlockStepper setAutorepeat:YES];
    [_selectedBlockStepper setTarget:self];
    [_selectedBlockStepper setAction:@selector(selectedBlockStepperChanged:)];

    collapseSelectedButton = [self buttonWithTitle:@"Collapse"
                                           action:@selector(collapseSelectedTranscriptBlock:)
                                            frame:NSMakeRect(412, bounds.size.height - 38, 90, 26)];

    [buildButton setAutoresizingMask:NSViewMinYMargin];
    [_actionsPopUpButton setAutoresizingMask:NSViewMinYMargin];
    [collapseSelectedButton setAutoresizingMask:NSViewMinYMargin];
    [selectedBlockLabel setAutoresizingMask:NSViewMinYMargin];
    [_selectedBlockField setAutoresizingMask:NSViewMinYMargin];
    [_selectedBlockStepper setAutoresizingMask:NSViewMinYMargin];

    [rightView addSubview:buildButton];
    [rightView addSubview:_actionsPopUpButton];
    [rightView addSubview:selectedBlockLabel];
    [rightView addSubview:_selectedBlockField];
    [rightView addSubview:_selectedBlockStepper];
    [rightView addSubview:collapseSelectedButton];

    [selectedBlockLabel release];

    [self updateSelectedBlockControls];

    consoleScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(12, 12,
                                                                       bounds.size.width - 220,
                                                                       bounds.size.height - 72)];
    [consoleScrollView setBorderType:NSBezelBorder];
    [consoleScrollView setHasVerticalScroller:YES];
    [consoleScrollView setHasHorizontalScroller:NO];
    [consoleScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

    consoleTextView = [[NSTextView alloc] initWithFrame:[[consoleScrollView contentView] bounds]];
    [consoleTextView setEditable:NO];
    [consoleTextView setSelectable:YES];
    [consoleTextView setFont:[NSFont fontWithName:@"Monaco" size:11.0]];
    [consoleTextView setHorizontallyResizable:NO];
    [consoleTextView setVerticallyResizable:YES];
    [[consoleTextView textContainer] setWidthTracksTextView:YES];
    [[consoleTextView textContainer] setContainerSize:NSMakeSize([[consoleScrollView contentView] bounds].size.width,
                                                                 10000000.0)];
    [consoleTextView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

    [consoleScrollView setDocumentView:consoleTextView];
    [_consoleLogView setTextView:consoleTextView];
    [consoleTextView release];

    [rightView addSubview:consoleScrollView];
    [consoleScrollView release];

    [splitView addSubview:leftView];
    [splitView addSubview:rightView];
    [contentView addSubview:splitView];

    statusTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(12, 3,
                                                                    bounds.size.width - 24,
                                                                    18)];
    [statusTextField setStringValue:@"Ready"];
    [statusTextField setBezeled:NO];
    [statusTextField setDrawsBackground:NO];
    [statusTextField setEditable:NO];
    [statusTextField setSelectable:NO];
    [statusTextField setFont:[NSFont systemFontOfSize:11.0]];
    [statusTextField setAutoresizingMask:(NSViewWidthSizable | NSViewMaxYMargin)];

    _statusTextField = [statusTextField retain];

    [contentView addSubview:statusTextField];
    [statusTextField release];

    [leftView release];
    [rightView release];
    [splitView release];
}

- (NSButton *)buttonWithTitle:(NSString *)title action:(SEL)action frame:(NSRect)frame
{
    NSButton *button;

    button = [[[NSButton alloc] initWithFrame:frame] autorelease];
    [button setTitle:title];
    [button setTarget:self];
    [button setAction:action];
    [button setBezelStyle:NSRoundedBezelStyle];

    return button;
}

- (NSString *)chellTimestampStringForDate:(NSDate *)date
{
    NSDateFormatter *formatter;
    NSString *timestamp;

    formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    timestamp = [formatter stringFromDate:date];

    if (timestamp == nil) {
        timestamp = @"unknown time";
    }

    return timestamp;
}

- (void)renderTranscriptView
{
    NSUInteger index;

    [_consoleLogView clear];
    [self appendWelcomeText];

    for (index = 0; index < [_transcriptBlocks count]; index++) {
        [self appendTranscriptBlock:[_transcriptBlocks objectAtIndex:index]];
    }
}

- (void)appendTranscriptBlock:(LTTranscriptBlock *)block
{
    NSString *timestamp;

    if (block == nil) {
        return;
    }

    timestamp = [self chellTimestampStringForDate:[block startedAt]];

    [_consoleLogView appendLine:@""];
    [_consoleLogView appendChellSeparatorLine];

    if ([block isCollapsed]) {
        [_consoleLogView appendChellHeaderLine:[NSString stringWithFormat:@"[+] #%04lu · %@ · %@ · Exit %d · %.2f seconds · %lu lines",
                                                (unsigned long)[block identifier],
                                                timestamp,
                                                [block title],
                                                [block exitStatus],
                                                [block duration],
                                                (unsigned long)[block lineCount]]];
        [_consoleLogView appendChellSeparatorLine];
        return;
    }

    if ([block endedAt] != nil) {
        [_consoleLogView appendChellHeaderLine:[NSString stringWithFormat:@"[-] #%04lu · %@ · %@ · Exit %d · %.2f seconds · %lu lines",
                                                (unsigned long)[block identifier],
                                                timestamp,
                                                [block title],
                                                [block exitStatus],
                                                [block duration],
                                                (unsigned long)[block lineCount]]];
    } else {
        [_consoleLogView appendChellHeaderLine:[NSString stringWithFormat:@"[-] #%04lu · %@ · %@",
                                                (unsigned long)[block identifier],
                                                timestamp,
                                                [block title]]];
    }
    [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"cwd: %@", [block workingDirectory]]];
    [_consoleLogView appendChellMetadataLine:@"command:"];
    [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"$ %@", [block command]]];
    [_consoleLogView appendChellMetadataLine:@""];
    [_consoleLogView appendChellMetadataLine:@"output:"];

    if ([block outputText] != nil && [[block outputText] length] > 0) {
        [_consoleLogView appendText:[block outputText]];
    }

    [_consoleLogView appendChellSeparatorLine];
}

- (LTTranscriptBlock *)transcriptBlockWithIdentifier:(NSUInteger)identifier
{
    NSUInteger index;
    LTTranscriptBlock *block;

    for (index = 0; index < [_transcriptBlocks count]; index++) {
        block = [_transcriptBlocks objectAtIndex:index];

        if ([block identifier] == identifier) {
            return block;
        }
    }

    return nil;
}

- (NSString *)sanitizedBlockIdentifierString:(NSString *)string
{
    NSMutableString *digits;
    NSUInteger index;
    NSUInteger length;
    unichar character;

    digits = [NSMutableString string];

    if (string == nil) {
        return @"1";
    }

    length = [string length];

    for (index = 0; index < length && [digits length] < 4; index++) {
        character = [string characterAtIndex:index];

        if (character >= '0' && character <= '9') {
            [digits appendFormat:@"%C", character];
        }
    }

    if ([digits length] == 0) {
        return @"1";
    }

    return digits;
}

- (NSUInteger)selectedBlockIdentifier
{
    NSString *sanitizedString;
    NSUInteger identifier;
    NSUInteger count;

    sanitizedString = [self sanitizedBlockIdentifierString:[_selectedBlockField stringValue]];
    identifier = (NSUInteger)[sanitizedString intValue];

    if (identifier < 1) {
        identifier = 1;
    }

    count = [_transcriptBlocks count];

    if (count > 0 && identifier > count) {
        identifier = count;
    }

    [self setSelectedBlockIdentifier:identifier];

    return identifier;
}

- (void)setSelectedBlockIdentifier:(NSUInteger)identifier
{
    NSUInteger count;

    count = [_transcriptBlocks count];

    if (identifier < 1) {
        identifier = 1;
    }

    if (count > 0 && identifier > count) {
        identifier = count;
    }

    if (_selectedBlockField != nil) {
        [_selectedBlockField setStringValue:[NSString stringWithFormat:@"%lu",
                                             (unsigned long)identifier]];
    }

    if (_selectedBlockStepper != nil) {
        [_selectedBlockStepper setMinValue:1.0];
        [_selectedBlockStepper setMaxValue:(double)(count > 0 ? count : 1)];
        [_selectedBlockStepper setDoubleValue:(double)identifier];
    }
}

- (void)updateSelectedBlockControls
{
    [self setSelectedBlockIdentifier:[self selectedBlockIdentifier]];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSString *currentString;
    NSString *sanitizedString;

    if ([notification object] != _selectedBlockField) {
        return;
    }

    currentString = [_selectedBlockField stringValue];
    sanitizedString = [self sanitizedBlockIdentifierString:currentString];

    if (![currentString isEqualToString:sanitizedString]) {
        [_selectedBlockField setStringValue:sanitizedString];
    }

    [self updateSelectedBlockControls];
}

- (IBAction)selectedBlockStepperChanged:(id)sender
{
    [self setSelectedBlockIdentifier:(NSUInteger)[_selectedBlockStepper intValue]];
}

- (void)runProjectActionWithIdentifier:(NSString *)identifier
                                 title:(NSString *)title
                               command:(NSString *)command
{
    LTProjectAction *action;
    NSString *rootPath;
    NSString *timestamp;

    if ([_commandRunner isRunning]) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:@"A command is already running."];
        return;
    }

    action = [LTProjectAction shellActionWithIdentifier:identifier
                                                  title:title
                                                command:command];

    rootPath = [_currentProject rootPath];
    if (rootPath == nil) {
        rootPath = @"";
    }

    [_currentTranscriptBlock release];
    _currentTranscriptBlock = [[LTTranscriptBlock alloc] initWithIdentifier:_nextTranscriptBlockIdentifier
                                                                      title:title
                                                                    command:command
                                                           workingDirectory:rootPath];
    [_transcriptBlocks addObject:_currentTranscriptBlock];
    _nextTranscriptBlockIdentifier++;

    [self setSelectedBlockIdentifier:[_currentTranscriptBlock identifier]];

    timestamp = [self chellTimestampStringForDate:[_currentTranscriptBlock startedAt]];

    [_consoleLogView appendLine:@""];
    [_consoleLogView appendChellSeparatorLine];
    [_consoleLogView appendChellHeaderLine:[NSString stringWithFormat:@"[-] #%04lu · %@ · %@",
                                            (unsigned long)[_currentTranscriptBlock identifier],
                                            timestamp,
                                            [_currentTranscriptBlock title]]];
    [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"cwd: %@",
                                              [_currentTranscriptBlock workingDirectory]]];
    [_consoleLogView appendChellMetadataLine:@"command:"];
    [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"$ %@",
                                              [_currentTranscriptBlock command]]];
    [_consoleLogView appendChellMetadataLine:@""];
    [_consoleLogView appendChellMetadataLine:@"output:"];

    [_commandRunner runAction:action inProject:_currentProject];
}

- (void)commandRunnerDidStart:(LTCommandRunner *)runner
{
    if (_currentTranscriptBlock != nil) {
        [self setStatusText:[NSString stringWithFormat:@"Running: %@",
                             [_currentTranscriptBlock title]]];
    } else {
        [self setStatusText:@"Running command..."];
    }
}

- (void)commandRunner:(LTCommandRunner *)runner didReceiveOutput:(NSString *)output
{
    [_currentTranscriptBlock appendOutputText:output];
    [_consoleLogView appendText:output];
}

- (void)commandRunner:(LTCommandRunner *)runner
  didFinishWithStatus:(int)status
             duration:(NSTimeInterval)duration
{
    NSString *stateText;

    [_currentTranscriptBlock finishWithExitStatus:status duration:duration];

    if (status == 0) {
        stateText = @"succeeded";
    } else {
        stateText = @"failed";
    }

    [self setStatusText:[NSString stringWithFormat:@"%@ %@ · Exit %d · %.2f seconds · %lu lines",
                         [_currentTranscriptBlock title],
                         stateText,
                         [_currentTranscriptBlock exitStatus],
                         [_currentTranscriptBlock duration],
                         (unsigned long)[_currentTranscriptBlock lineCount]]];

    [_consoleLogView appendChellSeparatorLine];

    [_currentTranscriptBlock release];
    _currentTranscriptBlock = nil;
}

- (IBAction)runSelectedAction:(id)sender
{
    NSString *title;

    title = [_actionsPopUpButton titleOfSelectedItem];

    if ([title isEqualToString:@"Smoke Test"]) {
        [self runSmokeTestAction:sender];
    } else if ([title isEqualToString:@"Clean"]) {
        [self runCleanAction:sender];
    } else if ([title isEqualToString:@"Reveal"]) {
        [self revealProjectInFinder:sender];
    } else if ([title isEqualToString:@"Collapse Last"]) {
        [self collapseLastTranscriptBlock:sender];
    } else if ([title isEqualToString:@"Expand All"]) {
        [self expandAllTranscriptBlocks:sender];
    }

    [_actionsPopUpButton selectItemAtIndex:0];
}

- (IBAction)runBuildAction:(id)sender
{
    [self runProjectActionWithIdentifier:@"org.quietcode.leoterm.action.build"
                                   title:@"Build"
                                 command:@"/usr/bin/xcodebuild -project LeoTerm.xcodeproj -configuration Debug"];
}

- (IBAction)runCleanAction:(id)sender
{
    [self runProjectActionWithIdentifier:@"org.quietcode.leoterm.action.clean"
                                   title:@"Clean"
                                 command:@"/usr/bin/xcodebuild -project LeoTerm.xcodeproj clean"];
}

- (IBAction)runSmokeTestAction:(id)sender
{
    [self runProjectActionWithIdentifier:@"org.quietcode.leoterm.action.smokeTest"
                                   title:@"Smoke Test"
                                 command:@"pwd; echo ''; if command -v git >/dev/null 2>&1; then git status --short; echo ''; git log --oneline -3; else echo 'git not found'; fi"];
}

- (IBAction)revealProjectInFinder:(id)sender
{
    NSString *rootPath;

    rootPath = [_currentProject rootPath];

    [_consoleLogView appendLine:@""];
    [_consoleLogView appendLine:@"> Reveal"];

    if (rootPath == nil || [rootPath length] == 0) {
        [_consoleLogView appendLine:@"No project path is configured yet."];
        return;
    }

    [[NSWorkspace sharedWorkspace] selectFile:rootPath inFileViewerRootedAtPath:nil];
    [self setStatusText:[NSString stringWithFormat:@"Revealed: %@", rootPath]];
}

- (IBAction)collapseLastTranscriptBlock:(id)sender
{
    LTTranscriptBlock *block;

    if ([_commandRunner isRunning]) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:@"Cannot collapse while a command is running."];
        return;
    }

    if ([_transcriptBlocks count] == 0) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:@"No transcript block available."];
        return;
    }

    block = [_transcriptBlocks lastObject];
    [block setCollapsed:YES];

    [self renderTranscriptView];
}

- (IBAction)collapseSelectedTranscriptBlock:(id)sender
{
    NSUInteger identifier;
    LTTranscriptBlock *block;

    if ([_commandRunner isRunning]) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:@"Cannot collapse while a command is running."];
        return;
    }

    if ([_transcriptBlocks count] == 0) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:@"No transcript block available."];
        return;
    }

    [[self window] makeFirstResponder:nil];

    identifier = [self selectedBlockIdentifier];
    block = [self transcriptBlockWithIdentifier:identifier];

    if (block == nil) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"Block #%04lu was not found.",
                                                  (unsigned long)identifier]];
        return;
    }

    [block setCollapsed:YES];

    [self renderTranscriptView];
}

- (IBAction)expandAllTranscriptBlocks:(id)sender
{
    NSUInteger index;

    if ([_commandRunner isRunning]) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:@"Cannot expand while a command is running."];
        return;
    }

    for (index = 0; index < [_transcriptBlocks count]; index++) {
        [[_transcriptBlocks objectAtIndex:index] setCollapsed:NO];
    }

    [self updateSelectedBlockControls];
    [self renderTranscriptView];
}

- (void)dealloc
{
    [_currentProject release];
    [_consoleLogView release];
    [_commandRunner release];

    [_transcriptBlocks release];
    [_currentTranscriptBlock release];
    [_selectedBlockField release];
    [_selectedBlockStepper release];
    [_statusTextField release];
    [_actionsPopUpButton release];

    [super dealloc];
}

@end
