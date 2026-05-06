#import <Cocoa/Cocoa.h>

@class LTProjectProfile;
@class LTConsoleLogView;
@class LTCommandRunner;
@class LTTranscriptBlock;

@interface LTMainWindowController : NSWindowController
{
    LTProjectProfile *_currentProject;
    LTConsoleLogView *_consoleLogView;
    LTCommandRunner *_commandRunner;

    NSMutableArray *_transcriptBlocks;
    LTTranscriptBlock *_currentTranscriptBlock;
    NSUInteger _nextTranscriptBlockIdentifier;

    NSTextField *_selectedBlockField;
    NSStepper *_selectedBlockStepper;
}

- (IBAction)runBuildAction:(id)sender;
- (IBAction)runCleanAction:(id)sender;
- (IBAction)runSmokeTestAction:(id)sender;
- (IBAction)revealProjectInFinder:(id)sender;

- (IBAction)collapseLastTranscriptBlock:(id)sender;
- (IBAction)collapseSelectedTranscriptBlock:(id)sender;
- (IBAction)expandAllTranscriptBlocks:(id)sender;
- (IBAction)selectedBlockStepperChanged:(id)sender;

@end
