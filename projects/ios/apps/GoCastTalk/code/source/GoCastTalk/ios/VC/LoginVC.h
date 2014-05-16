#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

#include <map>
class JSONValue;
typedef std::map<std::string, JSONValue> JSONObject;

class LoginScreen;

@interface LoginVC : UIViewController
<
    UITableViewDelegate,
    UITableViewDataSource,
    MFMailComposeViewControllerDelegate
>
{
    LoginScreen* mPeer;
}

//mInboxView
@property (nonatomic, strong) IBOutlet UIScrollView*    mScrollView;
@property (nonatomic, strong) IBOutlet UITextField*     mBaseURL;
@property (nonatomic, strong) IBOutlet UITextField*     mEmail;
@property (nonatomic, strong) IBOutlet UITextField*     mPassword;
@property (nonatomic, strong) IBOutlet UIView*          mBlockingView;

@property (nonatomic, strong) IBOutlet UIButton*        mSignInButton;
@property (nonatomic, strong) IBOutlet UIButton*        mSignUpButton;
@property (nonatomic, strong) IBOutlet UIButton*        mTroubleButton;
@property (nonatomic, strong) IBOutlet UIImageView*     mBackgroundImage;

#pragma mark Construction / Destruction
- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)animated;

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)setBlockingViewVisible:(bool)newVisible;

#pragma mark -

-(IBAction) signInPressed;
-(IBAction) signUpPressed;
-(IBAction) troublePressed;

-(void) sendEmailTo:(const std::string&)newTo;

-(void) setLoginName:(const std::string&)newName;
-(void) popSelf;

-(void) refreshLanguage;

@end