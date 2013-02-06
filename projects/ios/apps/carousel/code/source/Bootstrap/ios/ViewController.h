
#import <UIKit/UIKit.h>

#import <Cordova/CDVViewController.h>

@interface MainViewController : CDVViewController
{
}
@property (nonatomic, strong) IBOutlet UIView* mWebLoadingView;
@property (nonatomic, strong) IBOutlet UIView* mLoginView;
@property (nonatomic, strong) IBOutlet UIView* mLoggingInView;
@property (nonatomic, strong) IBOutlet UIView* mNicknameInUseView;
@property (nonatomic, strong) IBOutlet UIView* mBlankSpotView;
@property (nonatomic, strong) IBOutlet UIView* mChatSpotView;
@property (nonatomic, strong) IBOutlet UIView* mWhiteboardSpotView;

@property (nonatomic, strong) IBOutlet UIView* mWBView;
@property (nonatomic, strong) IBOutlet UITextField* mNickname;
@property (nonatomic, strong) IBOutlet UITextField* mRoomname;

-(IBAction)loginPressed:(id)sender;
-(IBAction)okayPressed:(id)sender;

-(IBAction)pressed1px:(id)sender;
-(IBAction)pressed3px:(id)sender;
-(IBAction)pressed5px:(id)sender;
-(IBAction)pressed10px:(id)sender;
-(IBAction)pressedColor:(id)sender;
-(IBAction)pressedErase:(id)sender;

-(IBAction)pressedPrev:(id)sender;
-(IBAction)pressedNext:(id)sender;

@end
