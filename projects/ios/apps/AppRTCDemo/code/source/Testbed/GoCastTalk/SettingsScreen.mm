#include "Base/package.h"
#include "Io/package.h"
#include "Audio/package.h"

#include "package.h"

#include "SettingsVC.h"

#pragma mark Constructor / Destructor
SettingsScreen::SettingsScreen(SettingsVC* newVC)
: mPeer(newVC)
{
	ConstructMachine();
}

SettingsScreen::~SettingsScreen()
{
	DestructMachine();
}

#pragma mark Public methods

void SettingsScreen::registeredNamePressed()
{
    update(SettingsScreenMessage(kRegisteredNameSelected));
}

void SettingsScreen::changePasswordPressed()
{
    update(SettingsScreenMessage(kChangePasswordSelected));
}

void SettingsScreen::logOutPressed()
{
    update(SettingsScreenMessage(kLogOutSelected));
}

void SettingsScreen::aboutThisAppPressed()
{
    update(SettingsScreenMessage(kAboutThisAppSelected));
}

#pragma mark Start / End / Invalid
void SettingsScreen::startEntry()
{
    URLLoader::getInstance()->attach(this);
    GCTEventManager::getInstance()->attach(this);
}

void SettingsScreen::endEntry()
{
}

void SettingsScreen::invalidStateEntry()
{
	assert("Event is invalid for this state" && 0);
}

#pragma mark Idling
void SettingsScreen::idleEntry()
{
}

#pragma mark Peer Communication
void SettingsScreen::peerPushAboutEntry()
{
    [mPeer pushAbout];
}

void SettingsScreen::peerPushChangePasswordEntry()
{
    [mPeer pushChangePassword];
}

void SettingsScreen::peerPushChangeRegisteredNameEntry()
{
    JSONObject initObject;

    for(size_t i = 0; i < InboxScreen::mContacts.size(); i++)
    {
        if (InboxScreen::mContacts[i].mObject["email"].mString == InboxScreen::mEmailAddress)
        {
            initObject = InboxScreen::mContacts[i].mObject;
            break;
        }
    }

    initObject["email"] = InboxScreen::mEmailAddress;

    [mPeer pushChangeRegisteredName:initObject];
}

#pragma mark Queries
void SettingsScreen::wasLogoutSuccessfulEntry()
{
    bool result = false;

    if (mLogoutJSON["status"].mString == std::string("success"))
    {
        result = true;
    }

    SetImmediateEvent(result ? kYes : kNo);
}

#pragma mark Actions
void SettingsScreen::destroyStoredTokenEntry()
{
    tFile(tFile::kPreferencesDirectory, "token.txt").remove();
    InboxScreen::mToken.clear();
}

void SettingsScreen::sendLogoutToServerEntry()
{
    char buf[512];

    sprintf(buf, "%s?action=logout&name=%s&authToken=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            InboxScreen::mToken.c_str());

    URLLoader::getInstance()->loadString(this, buf);
}

#pragma mark UI
void SettingsScreen::setWaitForLogoutEntry()
{
    [mPeer setBlockingViewVisible:true];
}

void SettingsScreen::showConfirmLogoutEntry()
{
    tConfirm("Are you sure you want to logout?");
}

void SettingsScreen::showErrorWithLogoutEntry()
{
    tAlert("Logout failed");
}

void SettingsScreen::showSuccessWithLogoutEntry()
{
    tAlert("You have been successfully logged out");
}

#pragma mark Sending messages to other machines
void SettingsScreen::sendForceLogoutToVCEntry()
{
    GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kForceLogout));
}

#pragma mark State wiring
void SettingsScreen::CallEntry()
{
	switch(mState)
	{
		case kDestroyStoredToken: destroyStoredTokenEntry(); break;
		case kEnd: EndEntryHelper(); break;
		case kIdle: idleEntry(); break;
		case kInvalidState: invalidStateEntry(); break;
		case kPeerPushAbout: peerPushAboutEntry(); break;
		case kPeerPushChangePassword: peerPushChangePasswordEntry(); break;
		case kPeerPushChangeRegisteredName: peerPushChangeRegisteredNameEntry(); break;
		case kSendForceLogoutToVC: sendForceLogoutToVCEntry(); break;
		case kSendLogoutToServer: sendLogoutToServerEntry(); break;
		case kSetWaitForLogout: setWaitForLogoutEntry(); break;
		case kShowConfirmLogout: showConfirmLogoutEntry(); break;
		case kShowErrorWithLogout: showErrorWithLogoutEntry(); break;
		case kShowSuccessWithLogout: showSuccessWithLogoutEntry(); break;
		case kStart: startEntry(); break;
		case kWasLogoutSuccessful: wasLogoutSuccessfulEntry(); break;
		default: break;
	}
}

void SettingsScreen::CallExit()
{
}

int  SettingsScreen::StateTransitionFunction(const int evt) const
{
	if ((mState == kDestroyStoredToken) && (evt == kNext)) return kShowSuccessWithLogout; else
	if ((mState == kIdle) && (evt == kAboutThisAppSelected)) return kPeerPushAbout; else
	if ((mState == kIdle) && (evt == kChangePasswordSelected)) return kPeerPushChangePassword; else
	if ((mState == kIdle) && (evt == kLogOutSelected)) return kShowConfirmLogout; else
	if ((mState == kIdle) && (evt == kRegisteredNameSelected)) return kPeerPushChangeRegisteredName; else
	if ((mState == kPeerPushAbout) && (evt == kNext)) return kIdle; else
	if ((mState == kPeerPushChangePassword) && (evt == kNext)) return kIdle; else
	if ((mState == kPeerPushChangeRegisteredName) && (evt == kNext)) return kIdle; else
	if ((mState == kSendForceLogoutToVC) && (evt == kNext)) return kIdle; else
	if ((mState == kSendLogoutToServer) && (evt == kFail)) return kShowErrorWithLogout; else
	if ((mState == kSendLogoutToServer) && (evt == kSuccess)) return kWasLogoutSuccessful; else
	if ((mState == kSetWaitForLogout) && (evt == kNext)) return kSendLogoutToServer; else
	if ((mState == kShowConfirmLogout) && (evt == kNo)) return kIdle; else
	if ((mState == kShowConfirmLogout) && (evt == kYes)) return kSetWaitForLogout; else
	if ((mState == kShowErrorWithLogout) && (evt == kYes)) return kIdle; else
	if ((mState == kShowSuccessWithLogout) && (evt == kYes)) return kSendForceLogoutToVC; else
	if ((mState == kStart) && (evt == kNext)) return kIdle; else
	if ((mState == kWasLogoutSuccessful) && (evt == kNo)) return kShowErrorWithLogout; else
	if ((mState == kWasLogoutSuccessful) && (evt == kYes)) return kDestroyStoredToken;

	return kInvalidState;
}

bool SettingsScreen::HasEdgeNamedNext() const
{
	switch(mState)
	{
		case kDestroyStoredToken:
		case kPeerPushAbout:
		case kPeerPushChangePassword:
		case kPeerPushChangeRegisteredName:
		case kSendForceLogoutToVC:
		case kSetWaitForLogout:
		case kStart:
			return true;
		default: break;
	}
	return false;
}

#pragma mark Messages
void SettingsScreen::update(const SettingsScreenMessage& msg)
{
	process(msg.mEvent);
}

void SettingsScreen::update(const URLLoaderEvent& msg)
{
    if (msg.mId == this)
    {
        [mPeer setBlockingViewVisible:false];

        switch (msg.mEvent)
        {
            case URLLoaderEvent::kLoadFail: process(kFail); break;
            case URLLoaderEvent::kLoadedString:
            {
                switch (getState())
                {
                    case kSendLogoutToServer:
                        mLogoutJSON = JSONUtil::extract(msg.mString);
                        break;

                    default:
                        break;
                }
                process(kSuccess);
            }
                break;

            case URLLoaderEvent::kLoadedFile: process(kSuccess); break;

            default:
                break;
        }
    }
}

void SettingsScreen::update(const GCTEvent& msg)
{
    switch(getState())
    {
        case kShowConfirmLogout:
        case kShowErrorWithLogout:
        case kShowSuccessWithLogout:
            switch(msg.mEvent)
            {
                case GCTEvent::kOKYesAlertPressed:  process(kYes); break;
                case GCTEvent::kNoAlertPressed:     process(kNo); break;

                default:
                    break;
            }
            break;
    }
}

