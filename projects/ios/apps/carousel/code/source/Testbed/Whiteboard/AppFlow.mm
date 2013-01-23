#include "Base/package.h"
#include "Math/package.h"

#include "CallcastEvent.h"
#include "CallcastManager.h"

#include "AppFlow.h"

#include "AppDelegate.h"

AppFlow gAppFlow;
extern AppDelegate* gAppDelegateInstance;
extern UIWebView*   gWebViewInstance;

AppFlow::AppFlow()
:   mNickname("nick"),
    mRoomname("room")
{
    ConstructMachine();
}
AppFlow::~AppFlow()
{
    DestructMachine();
}

void AppFlow::startEntry()
{
    CallcastManager::getInstance()->attach(this);
}

void AppFlow::startExit() { }

void AppFlow::endEntry() { }
void AppFlow::endExit() { }

void AppFlow::waitForWebViewLoadedEntry() { }
void AppFlow::waitForWebViewLoadedExit() { }

void AppFlow::loadLoginScreenEntry()
{
    [gAppDelegateInstance loadLoginScreen];
//    CallcastManager::getInstance()->notify(CallcastEvent(CallcastEvent::kSubmitLogin));
}

void AppFlow::loadLoginScreenExit()
{
    [gAppDelegateInstance unloadLoginScreen];

    [gWebViewInstance stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"startCallcast('%s','%s')", mNickname.c_str(), mRoomname.c_str()]];
}

void AppFlow::showWaitingForLoginEntry()
{
    [gAppDelegateInstance loadLoadingScreen];
//    CallcastManager::getInstance()->notify(CallcastEvent(CallcastEvent::kLoggedIn));
}

void AppFlow::showWaitingForLoginExit()
{
    [gAppDelegateInstance unloadLoadingScreen];
}

void AppFlow::showWhiteboardEntry()
{
    [gAppDelegateInstance loadWhiteboardScreen];
}

void AppFlow::showWhiteboardExit()
{
    [gAppDelegateInstance unloadWhiteboardScreen];
}

void AppFlow::update(const AppFlowMessage& msg)
{
    process(msg.event);
}

void AppFlow::update(const CallcastEvent& msg)
{
    switch (msg.mEvent)
    {
        case CallcastEvent::kWebViewLoaded: process(AppFlow::kWebViewLoaded); break;
        case CallcastEvent::kSubmitLogin:
            mNickname = msg.mNickname;
            mRoomname = msg.mRoomname;
            process(AppFlow::kLoginPressed);
            break;
        case CallcastEvent::kLoggedIn:      process(AppFlow::kLoginSuccess); break;
        default: break;
    }
}
