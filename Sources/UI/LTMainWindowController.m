#import "LTMainWindowController.h"
#import "../Projects/LTProjectProfile.h"
#import "../Actions/LTProjectAction.h"
#import "../Console/LTConsoleLogView.h"
#import "../Console/LTCommandRunner.h"

@interface LTMainWindowController (Private)

- (void)buildWindowInterface;
- (NSButton *)buttonWithTitle:(NSString *)title action:(SEL)action frame:(NSRect)frame;
- (NSString *)defaultProjectRootPath;
- (NSString *)projectListText;
- (void)runProjectActionWithIdentifier:(NSString *)identifier
                                 title:(NSString *)title
                               command:(NSString *)command;

@end

@implementation LTMainWindowController

- (id)init
{
    NSWindow *window;
    NSString *projectRootPath;

    window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 900, 560)
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

        [self buildWindowInterface];

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

    return self;
}

- (NSString *)defaultProjectRootPath
{
    NSFileManager *fileManager;
    NSString *candidatePath;
    NSString *gitPath;
    NSString *projectPath;
    int attempts;

    fileManager = [NSFileManager defaultManager];

    /*
     * During development the app usually lives below:
     *
     *   LeoTerm/build/Debug/LeoTerm.app
     *
     * Walk upwards until we find the real LeoTerm project root.
     */
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

    [buildButton setAutoresizingMask:NSViewMinYMargin];
    [cleanButton setAutoresizingMask:NSViewMinYMargin];
    [smokeButton setAutoresizingMask:NSViewMinYMargin];
    [revealButton setAutoresizingMask:NSViewMinYMargin];

    [rightView addSubview:buildButton];
    [rightView addSubview:cleanButton];
    [rightView addSubview:smokeButton];
    [rightView addSubview:revealButton];

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

- (void)runProjectActionWithIdentifier:(NSString *)identifier
                                 title:(NSString *)title
                               command:(NSString *)command
{
    LTProjectAction *action;
    NSString *output;

    action = [LTProjectAction shellActionWithIdentifier:identifier
                                                  title:title
                                                command:command];

    [_consoleLogView appendLine:@""];
    [_consoleLogView appendLine:[NSString stringWithFormat:@"> %@", title]];
    [_consoleLogView appendLine:[NSString stringWithFormat:@"$ %@", command]];

    output = [_commandRunner runAction:action inProject:_currentProject];

    if (output != nil && [output length] > 0) {
        [_consoleLogView appendText:output];
    }

    [_consoleLogView appendLine:[NSString stringWithFormat:@"Exit code: %d",
                                 [_commandRunner lastTerminationStatus]]];
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

- (void)dealloc
{
    [_currentProject release];
    [_consoleLogView release];
    [_commandRunner release];
    [super dealloc];
}

@end
