#import <Cocoa/Cocoa.h>

@class LTProjectProfile;
@class LTConsoleLogView;
@class LTCommandRunner;

@interface LTMainWindowController : NSWindowController
{
    LTProjectProfile *_currentProject;
    LTConsoleLogView *_consoleLogView;
    LTCommandRunner *_commandRunner;

    NSUInteger _nextTranscriptBlockIdentifier;
    NSUInteger _currentTranscriptBlockIdentifier;
    NSUInteger _currentTranscriptLineCount;
}

- (IBAction)runBuildAction:(id)sender;
- (IBAction)runCleanAction:(id)sender;
- (IBAction)runSmokeTestAction:(id)sender;
- (IBAction)revealProjectInFinder:(id)sender;

@end
