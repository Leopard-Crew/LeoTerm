#import "LTMainWindowController.h"
#import "LTProjectProfile.h"
#import "LTProjectAction.h"
#import "LTConsoleLogView.h"
#import "LTCommandRunner.h"

@implementation LTMainWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    if (self) {
        _currentProject = [[LTProjectProfile alloc] initWithName:@"LeoTerm" rootPath:nil];
        _consoleLogView = [[LTConsoleLogView alloc] init];
        _commandRunner = [[LTCommandRunner alloc] init];
    }
    return self;
}

- (IBAction)runBuildAction:(id)sender
{
    LTProjectAction *action;

    action = [LTProjectAction shellActionWithIdentifier:@"org.quietcode.leoterm.action.build"
                                                  title:@"Build"
                                                command:@"echo 'Build action placeholder'"];

    [_commandRunner runAction:action inProject:_currentProject];
}

- (IBAction)runCleanAction:(id)sender
{
    LTProjectAction *action;

    action = [LTProjectAction shellActionWithIdentifier:@"org.quietcode.leoterm.action.clean"
                                                  title:@"Clean"
                                                command:@"echo 'Clean action placeholder'"];

    [_commandRunner runAction:action inProject:_currentProject];
}

- (IBAction)runSmokeTestAction:(id)sender
{
    LTProjectAction *action;

    action = [LTProjectAction shellActionWithIdentifier:@"org.quietcode.leoterm.action.smokeTest"
                                                  title:@"Smoke Test"
                                                command:@"echo 'Smoke test action placeholder'"];

    [_commandRunner runAction:action inProject:_currentProject];
}

- (IBAction)revealProjectInFinder:(id)sender
{
    NSString *rootPath;

    rootPath = [_currentProject rootPath];
    if (rootPath == nil) {
        return;
    }

    [[NSWorkspace sharedWorkspace] selectFile:rootPath inFileViewerRootedAtPath:nil];
}

- (void)dealloc
{
    [_currentProject release];
    [_consoleLogView release];
    [_commandRunner release];
    [super dealloc];
}

@end
