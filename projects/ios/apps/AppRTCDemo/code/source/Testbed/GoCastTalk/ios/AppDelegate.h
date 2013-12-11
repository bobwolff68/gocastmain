#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#include <vector>
#include <string>


@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow*         window;
@property (strong, nonatomic) ViewController*   viewController;

-(void)hideAllViews;

-(void)setInboxViewVisible:(bool)newVisible;
-(void)setNewMemoViewVisible:(bool)newVisible;
-(void)setContactsViewVisible:(bool)newVisible;
-(void)setGroupsViewVisible:(bool)newVisible;
-(void)setSettingsViewVisible:(bool)newVisible;

-(void)setNavigationBarTitle:(const std::string&)newTitle;

-(void)setBlockingViewVisible:(bool)newVisible;

-(void)startRecorder;
-(void)stopRecorder;

@end
