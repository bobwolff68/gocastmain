#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "ViewController.h"
#import "ActionSheetStringPicker.h"

#include "Base/package.h"
#include "Math/package.h"
#include "Input/package.h"
#include "Io/package.h"
#include "OpenGL/package.h"

#include "CallcastEvent.h"
#include "CarouselEventManager.h"

#include "CarouselApp.h"

const tColor4b      kBlack  (0,0,0,255);
const tColor4b      kRed    (255,0,0,255);
const tColor4b      kBlue   (0,0,255,255);
const tColor4b      kOrange (255,165,0,255);
const tColor4b      kWhite  (255,255,255,255);

extern CarouselApp gCarouselApp;

UIWebView* gWebViewInstance = NULL;

@implementation MainViewController

@synthesize mColors             = _colors;
@synthesize mSelectedColorIndex = _selectedColorIndex;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    CGPoint tapPoint = [recognizer locationInView:self.view];

    // If there are no buttons beneath this tap then move to the next page if near the page edge
    if (![[self.view hitTest:tapPoint withEvent:nil] isKindOfClass:[OpenGLView class]])
    {
        return YES;
    }

    return NO;
}

- (void) handleSwipeLeft:(UIGestureRecognizer *) recognizer
{
    // Get the position of the point tapped in the window co-ordinate system
    CGPoint tapPoint = [recognizer locationInView:self.view];

    // If there are no buttons beneath this tap then move to the next page if near the page edge
    if (![[self.view hitTest:tapPoint withEvent:nil] isKindOfClass:[OpenGLView class]])
    {
        [self pressedNext:nil];
    }
}

- (void)handleSwipeRight:(UIGestureRecognizer*)recognizer
{
    // Get the position of the point tapped in the window co-ordinate system
    CGPoint tapPoint = [recognizer locationInView:self.view];

    // If there are no buttons beneath this tap then move to the next page if near the page edge
    if (![[self.view hitTest:tapPoint withEvent:nil] isKindOfClass:[OpenGLView class]])
    {
        [self pressedPrev:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // Set the main view to utilize the entire application frame space of the device.
    // Change this to suit your view's UI footprint needs in your application.

    UIView* rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    CGRect webViewFrame = [[[rootView subviews] objectAtIndex:0] frame];  // first subview is the UIWebView

    if (CGRectEqualToRect(webViewFrame, CGRectZero)) { // UIWebView is sized according to its parent, here it hasn't been sized yet
        self.view.frame = [[UIScreen mainScreen] applicationFrame]; // size UIWebView's parent according to application frame, which will in turn resize the UIWebView
    }

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.mColors = [NSArray arrayWithObjects:@"Blue", @"Orange", @"Black", @"Red", @"Eraser", nil];

    self.mSwipeLeftGesture = [[UISwipeGestureRecognizer alloc]
                              initWithTarget:self
                              action:@selector(handleSwipeLeft:)];
    self.mSwipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;

    self.mSwipeRightGesture = [[UISwipeGestureRecognizer alloc]
                               initWithTarget:self
                               action:@selector(handleSwipeRight:)];
    self.mSwipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;

    [self.mSwipeLeftGesture setDelegate:self];
    [self.mSwipeRightGesture setDelegate:self];
    [self.mWhiteboardSpotView addGestureRecognizer:self.mSwipeLeftGesture];
    [self.mWhiteboardSpotView addGestureRecognizer:self.mSwipeRightGesture];

    [self.mAnimateInSpot setHidden:YES];
    [self.mAnimateOutSpot setHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */

/*
 - (CDVCordovaView*) newCordovaViewWithFrame:(CGRect)bounds
 {
 return[super newCordovaViewWithFrame:bounds];
 }
 */

/* Comment out the block below to over-ride */

/*
 #pragma CDVCommandDelegate implementation

 - (id) getCommandInstance:(NSString*)className
 {
 return [super getCommandInstance:className];
 }

 - (BOOL) execute:(CDVInvokedUrlCommand*)command
 {
 return [super execute:command];
 }

 - (NSString*) pathForResource:(NSString*)resourcepath;
 {
 return [super pathForResource:resourcepath];
 }

 - (void) registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
 {
 return [super registerPlugin:plugin withClassName:className];
 }
 */

#pragma mark UIWebDelegate implementation

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    CGRect newFrame = CGRectMake(-10, -10, 5, 5);
    [webView setFrame:newFrame];
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    gWebViewInstance = theWebView;
    // only valid if ___PROJECTNAME__-Info.plist specifies a protocol to handle
//    if (self.invokeString) {
//        // this is passed before the deviceready event is fired, so you can access it in js when you receive deviceready
//        NSLog(@"DEPRECATED: window.invokeString - use the window.handleOpenURL(url) function instead, which is always called when the app is launched through a custom scheme url.");
//        NSString* jsString = [NSString stringWithFormat:@"var invokeString = \"%@\";", self.invokeString];
//        [theWebView stringByEvaluatingJavaScriptFromString:jsString];
//    }

    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];

    //    [theWebView stringByEvaluatingJavaScriptFromString:@"alert('hello');"];

    return [super webViewDidFinishLoad:theWebView];
}

/* Comment out the block below to over-ride */

/*

 - (void) webViewDidStartLoad:(UIWebView*)theWebView
 {
 return [super webViewDidStartLoad:theWebView];
 }

 - (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
 {
 return [super webView:theWebView didFailLoadWithError:error];
 }

 - (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
 {
 return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
 }
 */

-(IBAction)quitPressed:(id)sender
{
#pragma unused(sender)
    exit(0);
}

-(IBAction)loginPressed:(id)sender
{
#pragma unused(sender)
    CarouselEventManager::getInstance()->tSubject<const CallcastEvent&>::notify(CallcastEvent(CallcastEvent::kSubmitLogin,
                                                                                              [self.mNickname.text UTF8String],
                                                                                              [self.mRoomname.text UTF8String]));
    [self.view endEditing:YES];
}

-(IBAction)okayPressed:(id)sender
{
#pragma unused(sender)
    gCarouselApp.onOkayButton();
}

-(IBAction)pressed1px:(id)sender
{
#pragma unused(sender)
    gCarouselApp.onPenSizeChange(1);
}
-(IBAction)pressed3px:(id)sender
{
#pragma unused(sender)
    gCarouselApp.onPenSizeChange(3);
}

-(IBAction)pressed5px:(id)sender
{
#pragma unused(sender)
    gCarouselApp.onPenSizeChange(5);
}

-(IBAction)pressed10px:(id)sender
{
#pragma unused(sender)
    // TODO: fix SpotID
    gCarouselApp.onPenSizeChange(10);
}

-(IBAction)pressedColor:(id)sender
{
#pragma unused(sender)
    [ActionSheetStringPicker showPickerWithTitle:@"Select Color"
                                            rows:self.mColors
                                initialSelection:self.mSelectedColorIndex
                                          target:self
                                   successAction:@selector(colorWasSelected:element:)
                                    cancelAction:@selector(actionPickerCancelled:)
                                          origin:sender];
}

-(IBAction)pressedNew:(id)sender
{
#pragma unused(sender)
    gCarouselApp.onNewButton();
}

-(IBAction)pressedDelete:(id)sender
{
#pragma unused(sender)
    gCarouselApp.onDeleteButton();
}

- (void)colorWasSelected:(NSNumber *)selectedIndex element:(id)element
{
#pragma unused(element)
    self.mSelectedColorIndex = [selectedIndex intValue];

    switch (self.mSelectedColorIndex)
    {
        case 0:
            [self.mColorButton setBackgroundImage:[UIImage imageNamed:@"colorblue.png"] forState:UIControlStateNormal];
            gCarouselApp.onPenColorChange(kBlue); break;
        case 1:
            [self.mColorButton setBackgroundImage:[UIImage imageNamed:@"colororange.png"] forState:UIControlStateNormal];
            gCarouselApp.onPenColorChange(kOrange); break;
        case 2:
            [self.mColorButton setBackgroundImage:[UIImage imageNamed:@"colorblack.png"] forState:UIControlStateNormal];
            gCarouselApp.onPenColorChange(kBlack); break;
        case 3:
            [self.mColorButton setBackgroundImage:[UIImage imageNamed:@"colorred.png"] forState:UIControlStateNormal];
            gCarouselApp.onPenColorChange(kRed); break;
        case 4:
            [self.mColorButton setBackgroundImage:[UIImage imageNamed:@"colorwhite.png"] forState:UIControlStateNormal];
            gCarouselApp.onPenColorChange(kWhite); break;

        default: break;
    }
}

- (void)actionPickerCancelled:(id)sender
{
#pragma unused(sender)

}

-(IBAction)pressedPrev:(id)sender
{
#pragma unused(sender)
    gCarouselApp.onPrevButton();
}

-(IBAction)pressedNext:(id)sender
{
#pragma unused(sender)
    gCarouselApp.onNextButton();
}


@end