#include "ViewController.h"

#include "Base/package.h"
#include "Math/package.h"
#include "Input/package.h"

#include "HUDEvent.h"
#include "HUDEventManager.h"

@interface ViewController()
{
}
@end

@implementation ViewController

#pragma mark Construction / Destruction
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizesSubviews = YES;
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark tOrientationEvent generation
- (void)viewWillLayoutSubviews
{
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#pragma unused(interfaceOrientation)
    [UIView setAnimationsEnabled:NO];

    tOrientationEvent::OrientationType type = tOrientationEvent::kPortrait;

    switch(interfaceOrientation)
    {
        default:
        case UIInterfaceOrientationPortrait:            type = tOrientationEvent::kPortrait; break;
        case UIInterfaceOrientationPortraitUpsideDown:  type = tOrientationEvent::kPortraitUpsidedown; break;
        case UIInterfaceOrientationLandscapeLeft:       type = tOrientationEvent::kLandscapeLeft; break;
        case UIInterfaceOrientationLandscapeRight:      type = tOrientationEvent::kLandscapeRight; break;
    }

    tOrientationEvent msg(tOrientationEvent::kAllowOrientation, type);
    tInputManager::getInstance()->tSubject<tOrientationEvent &>::notify(msg);

    return msg.mAllowed ? YES : NO;
}

- (void)sendOrientationChangedMessage:(UIInterfaceOrientation)toInterfaceOrientation
{
    tOrientationEvent::OrientationType type = tOrientationEvent::kPortrait;

    switch(toInterfaceOrientation)
    {
        default:
        case UIInterfaceOrientationPortrait:            type = tOrientationEvent::kPortrait; break;
        case UIInterfaceOrientationPortraitUpsideDown:  type = tOrientationEvent::kPortraitUpsidedown; break;
        case UIInterfaceOrientationLandscapeLeft:       type = tOrientationEvent::kLandscapeLeft; break;
        case UIInterfaceOrientationLandscapeRight:      type = tOrientationEvent::kLandscapeRight; break;
    }

    tOrientationEvent msg(tOrientationEvent::kOrientationChanged, type);
    tInputManager::getInstance()->tSubject<tOrientationEvent &>::notify(msg);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#pragma unused(duration)
    [UIView setAnimationsEnabled:NO];

    [self sendOrientationChangedMessage:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#pragma unused(fromInterfaceOrientation)
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark Button Presses
-(IBAction) signInPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kSignInPressed));
}

-(IBAction) registerPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kRegisterPressed));
}

-(IBAction) callPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kCallPressed));
}

-(IBAction) activeModePressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kActiveModePressed));
}

-(IBAction) settingsPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kSettingsPressed));
}

-(IBAction) addMemberPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kAddMemberPressed));
}

-(IBAction) editGroupPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kEditGroupPressed));
}


-(IBAction) liveRecordPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kLiveRecordPressed));
}

-(IBAction) livePressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kLivePressed));
}

-(IBAction) recordPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kRecordPressed));
}


-(IBAction) activePressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kActivePressed));
}

-(IBAction) silentPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kSilentPressed));
}

-(IBAction) declinePressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kDeclinePressed));
}

-(IBAction) savePressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kSavePressed));
}

-(IBAction) cancelPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kCancelPressed));
}


-(IBAction) mutePressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kMutePressed));
}

-(IBAction) hangupPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kHangupPressed));
}

-(IBAction) speakerPressed:(id)sender
{
#pragma unused(sender)
    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kSpeakerPressed));
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#pragma unused(controller, result, error)
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissModalViewControllerAnimated:YES];
    });

    HUDEventManager::getInstance()->notify(HUDEvent(HUDEvent::kMailSent));
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.mLoginEmail)
    {
        [self.mLoginEmail resignFirstResponder];
        [self.mLoginPassword becomeFirstResponder];
    }
    else if (textField == self.mLoginPassword)
    {
        [self.mLoginPassword resignFirstResponder];
    }

    return NO;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#pragma unused(tableView, section)
    return (NSInteger)5;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma unused(tableView)
    if (indexPath.row % 2)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:.8f green:.8f blue:1 alpha:1]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const char* names[5] =
    {
        "Yoji Izaki",
        "Shinzo Abe",
        "Barack Obama",
        "TJ Grant",
        "Manjesh Mallavali",
    };
#pragma unused(indexPath)

    tableView.backgroundView = nil;

    static NSString *simpleTableIdentifier = @"HUDDemoTableItem";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier] autorelease];
    }

    cell.textLabel.text = [NSString stringWithUTF8String:names[indexPath.row]];

    cell.imageView.image = nil;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma unused(tableView, indexPath)
//    JSEventManager::getInstance()->notify(JSEvent(JSEvent::kLibraryRowSelected, indexPath.row + 1));
}

@end
