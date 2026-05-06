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
- (void)renderTranscriptView;
- (void)appendTranscriptBlock:(LTTranscriptBlock *)block;
- (LTTranscriptBlock *)transcriptBlockWithIdentifier:(NSUInteger)identifier;

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
                                                    NSResizableWindowMask)
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
    NSButton *cleanButton;
    NSButton *smokeButton;
    NSButton *revealButton;
    NSButton *collapseButton;
    NSButton *collapseSelectedButton;
    NSButton *expandButton;
    NSTextField *selectedBlockLabel;
    NSScrollView *consoleScrollView;
    NSTextView *consoleTextView;
    NSRect bounds;

    contentView = [[self window] contentView];
    bounds = [contentView bounds];

    splitView = [[NSSplitView alloc] initWithFrame:bounds];
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

    buildButton = [self buttonWithTitle:@"Build"
                                 action:@selector(runBuildAction:)
                                  frame:NSMakeRect(12, bounds.size.height - 38, 80, 26)];
    cleanButton = [self buttonWithTitle:@"Clean"
                                 action:@selector(runCleanAction:)
                                  frame:NSMakeRect(100, bounds.size.height - 38, 80, 26)];
    smokeButton = [self buttonWithTitle:@"Smoke Test"
                                 action:@selector(runSmokeTestAction:)
                                  frame:NSMakeRect(188, bounds.size.height - 38, 110, 26)];
    revealButton = [self buttonWithTitle:@"Reveal"
                                  action:@selector(revealProjectInFinder:)
                                   frame:NSMakeRect(306, bounds.size.height - 38, 80, 26)];
    collapseButton = [self buttonWithTitle:@"Collapse Last"
                                    action:@selector(collapseLastTranscriptBlock:)
                                     frame:NSMakeRect(394, bounds.size.height - 38, 120, 26)];
    collapseSelectedButton = [self buttonWithTitle:@"Collapse Selected"
                                           action:@selector(collapseSelectedTranscriptBlock:)
                                            frame:NSMakeRect(522, bounds.size.height - 38, 140, 26)];
    expandButton = [self buttonWithTitle:@"Expand All"
                                  action:@selector(expandAllTranscriptBlocks:)
                                   frame:NSMakeRect(670, bounds.size.height - 38, 100, 26)];

    selectedBlockLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(778, bounds.size.height - 34, 44, 18)];
    [selectedBlockLabel setStringValue:@"Block:"];
    [selectedBlockLabel setBezeled:NO];
    [selectedBlockLabel setDrawsBackground:NO];
    [selectedBlockLabel setEditable:NO];
    [selectedBlockLabel setSelectable:NO];
    [selectedBlockLabel setFont:[NSFont systemFontOfSize:11.0]];

    _selectedBlockField = [[NSTextField alloc] initWithFrame:NSMakeRect(826, bounds.size.height - 38, 46, 24)];
    [_selectedBlockField setStringValue:@"1"];
    [_selectedBlockField setFont:[NSFont systemFontOfSize:11.0]];

    [buildButton setAutoresizingMask:NSViewMinYMargin];
    [cleanButton setAutoresizingMask:NSViewMinYMargin];
    [smokeButton setAutoresizingMask:NSViewMinYMargin];
    [revealButton setAutoresizingMask:NSViewMinYMargin];
    [collapseButton setAutoresizingMask:NSViewMinYMargin];
    [collapseSelectedButton setAutoresizingMask:NSViewMinYMargin];
    [expandButton setAutoresizingMask:NSViewMinYMargin];
    [selectedBlockLabel setAutoresizingMask:NSViewMinYMargin];
    [_selectedBlockField setAutoresizingMask:NSViewMinYMargin];

    [rightView addSubview:buildButton];
    [rightView addSubview:cleanButton];
    [rightView addSubview:smokeButton];
    [rightView addSubview:revealButton];
    [rightView addSubview:collapseButton];
    [rightView addSubview:collapseSelectedButton];
    [rightView addSubview:expandButton];
    [rightView addSubview:selectedBlockLabel];
    [rightView addSubview:_selectedBlockField];

    [selectedBlockLabel release];

    consoleScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(12, 12,
                                                                       bounds.size.width - 220,
                                                                       bounds.size.height - 62)];
    [consoleScrollView setBorderType:NSBezelBorder];
    [consoleScrollView setHasVerticalScroller:YES];
    [consoleScrollView setHasHorizontalScroller:YES];
    [consoleScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

    consoleTextView = [[NSTextView alloc] initWithFrame:[[consoleScrollView contentView] bounds]];
    [consoleTextView setEditable:NO];
    [consoleTextView setSelectable:YES];
    [consoleTextView setFont:[NSFont fontWithName:@"Monaco" size:11.0]];
    [consoleTextView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

    [consoleScrollView setDocumentView:consoleTextView];
    [_consoleLogView setTextView:consoleTextView];
    [consoleTextView release];

    [rightView addSubview:consoleScrollView];
    [consoleScrollView release];

    [splitView addSubview:leftView];
    [splitView addSubview:rightView];
    [contentView addSubview:splitView];

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

    [_consoleLogView appendChellHeaderLine:[NSString stringWithFormat:@"[-] #%04lu · %@ · %@",
                                            (unsigned long)[block identifier],
                                            timestamp,
                                            [block title]]];
    [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"cwd: %@", [block workingDirectory]]];
    [_consoleLogView appendChellMetadataLine:@"command:"];
    [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"$ %@", [block command]]];
    [_consoleLogView appendChellMetadataLine:@""];
    [_consoleLogView appendChellMetadataLine:@"output:"];

    if ([block outputText] != nil && [[block outputText] length] > 0) {
        [_consoleLogView appendText:[block outputText]];
    }

    [_consoleLogView appendChellMetadataLine:@""];
    [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"result: Exit code %d · Duration %.2f seconds · %lu lines",
                                              [block exitStatus],
                                              [block duration],
                                              (unsigned long)[block lineCount]]];
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
    [_consoleLogView appendChellMetadataLine:@"status: running"];
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
    [_currentTranscriptBlock finishWithExitStatus:status duration:duration];

    [_consoleLogView appendChellMetadataLine:@""];
    [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"result: Exit code %d · Duration %.2f seconds · %lu lines",
                                              [_currentTranscriptBlock exitStatus],
                                              [_currentTranscriptBlock duration],
                                              (unsigned long)[_currentTranscriptBlock lineCount]]];
    [_consoleLogView appendChellSeparatorLine];

    [_currentTranscriptBlock release];
    _currentTranscriptBlock = nil;
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
    [_consoleLogView appendLine:[NSString stringWithFormat:@"Revealed: %@", rootPath]];
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
    NSInteger identifier;
    LTTranscriptBlock *block;

    if ([_commandRunner isRunning]) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:@"Cannot collapse while a command is running."];
        return;
    }

    identifier = [_selectedBlockField integerValue];

    if (identifier <= 0) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:@"Please enter a valid block ID."];
        return;
    }

    block = [self transcriptBlockWithIdentifier:(NSUInteger)identifier];

    if (block == nil) {
        [_consoleLogView appendLine:@""];
        [_consoleLogView appendChellMetadataLine:[NSString stringWithFormat:@"Block #%04ld was not found.", (long)identifier]];
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

    [super dealloc];
}

@end
