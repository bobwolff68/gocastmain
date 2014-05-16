#include "Base/package.h"
#include "Io/package.h"
#include "Audio/package.h"

#include "package.h"

#include "InboxMessageVC.h"

#define kScreenName "InboxMessage"

#pragma mark Constructor / Destructor
InboxMessageScreen::InboxMessageScreen(InboxMessageVC* newVC, const JSONObject& initObject)
:   mPeer(newVC),
    mInitObject(initObject)
{
	ConstructMachine();
}

InboxMessageScreen::~InboxMessageScreen()
{
	DestructMachine();
}

#pragma mark Public methods
size_t InboxMessageScreen::getToCount()
{
    return mInitObject["to"].mArray.size();
}

std::string InboxMessageScreen::getTo(const size_t& i)
{
    return mInitObject["to"].mArray[i].mString;
}

void InboxMessageScreen::playPressed()
{
    update(kPlayPressed);
}

void InboxMessageScreen::pastPressed()
{
    update(kPastSelected);
}

void InboxMessageScreen::replyPressed()
{
    update(kReplySelected);
}

void InboxMessageScreen::deletePressed()
{
    update(kDeleteSelected);
}

#pragma mark Start / End / Invalid
void InboxMessageScreen::startEntry()
{
    GoogleAnalytics::getInstance()->trackScreenEntry(kScreenName);

    mWasPlaying = false;
    mSound = NULL;

    GCTEventManager::getInstance()->attach(this);
    URLLoader::getInstance()->attach(this);

    mSliderUpdateTimer = new tTimer(30);
    mSliderUpdateTimer->attach(this);
}

void InboxMessageScreen::endEntry()
{
    if (mSliderUpdateTimer) { delete mSliderUpdateTimer; mSliderUpdateTimer = NULL; }
    if (mSound) { delete mSound; mSound = NULL; }
}

void InboxMessageScreen::invalidStateEntry()
{
	assert("Event is invalid for this state" && 0);
}

#pragma mark Idling
void InboxMessageScreen::idleEntry()
{
    [mPeer setSliderPercentage:0.0f];
}

void InboxMessageScreen::pausedIdleEntry()
{
}

void InboxMessageScreen::playingIdleEntry()
{
}

#pragma mark Peer Communication

void InboxMessageScreen::peerPopSelfEntry()
{
    [mPeer popSelf];
}

void InboxMessageScreen::peerPushMessageHistoryEntry()
{
    [mPeer pushMessageHistory:mInitObject];
}

#pragma mark Queries
void InboxMessageScreen::doesAudioExistLocallyEntry()
{
    SetImmediateEvent(tFile(tFile::kTemporaryDirectory, mInitObject["audio"].mString).exists() ? kYes : kNo);
}

void InboxMessageScreen::wasDeleteMessageValidEntry()
{
    bool result = false;
    bool expired = false;

    if (mDeleteMessageJSON["status"].mString == std::string("success"))
    {
        result = true;
    }

    if (mDeleteMessageJSON["status"].mString == std::string("expired"))
    {
        expired = true;
    }

    SetImmediateEvent(expired ? kExpired : (result ? kYes : kNo));
}


void InboxMessageScreen::wereWeGoingToPlayEntry()
{
    SetImmediateEvent(mWasPlaying ? kYes : kNo);
}

#pragma mark Actions
void InboxMessageScreen::fixRecipientListEntry()
{
    JSONArray arr = mInitObject["to"].mArray;
    JSONArray arr2;

    for (size_t i = 0; i < arr.size(); i++)
    {
        if (!arr[i].mString.empty())
        {
            arr2.push_back(arr[i]);
        }
    }

    mInitObject["to"].mArray = arr2;
}

void InboxMessageScreen::sendDeleteMessageToServerEntry()
{
    char buf[512];

    sprintf(buf, "%s?action=deleteMessage&name=%s&audio=%s&authToken=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            mInitObject["audio"].mString.c_str(),
            InboxScreen::mToken.c_str());

    URLLoader::getInstance()->loadString(this, buf);
}

void InboxMessageScreen::sendMarkReadToServerEntry()
{
    char buf[512];

    sprintf(buf, "%s?action=markRead&name=%s&audio=%s&authToken=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            mInitObject["audio"].mString.c_str(),
            InboxScreen::mToken.c_str());

    URLLoader::getInstance()->loadString(this, buf);
}


void InboxMessageScreen::sendDownloadRequestToServerEntry()
{
    char buf[512];

    sprintf(buf, "%s?action=getFile&name=%s&audio=%s&authToken=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            mInitObject["audio"].mString.c_str(),
            InboxScreen::mToken.c_str());

    URLLoader::getInstance()->loadFile(this, buf, tFile(tFile::kTemporaryDirectory, mInitObject["audio"].mString.c_str()));
}

void InboxMessageScreen::setWasPlayingToFalseEntry()
{
    mWasPlaying = false;
}

void InboxMessageScreen::setWasPlayingToTrueEntry()
{
    mWasPlaying = true;
}

void InboxMessageScreen::pauseSoundEntry()
{
    [mPeer setButtonImagePlay];

    if (mSound)
    {
        mAlreadyPlayedTimeMS = tTimer::getTimeMS() - mStartTimeMS;

        mSound->pause();
    }
}

void InboxMessageScreen::resumeSoundEntry()
{
    [mPeer setButtonImagePause];

    if (mSound)
    {
        mStartTimeMS = tTimer::getTimeMS() - mAlreadyPlayedTimeMS;

        mSound->resume();
    }
}

void InboxMessageScreen::playSoundEntry()
{
    [mPeer setButtonImagePause];

    if (!mSound)
    {

        mSound = new tSound(tFile(tFile::kTemporaryDirectory, mInitObject["audio"].mString));
        mSound->attach(this);
    }

    mSound->play();

    mStartTimeMS = tTimer::getTimeMS();
    mSliderUpdateTimer->start();
}

void InboxMessageScreen::stopSoundEntry()
{
    [mPeer setButtonImagePlay];

    if (mSound)
    {
        mSliderUpdateTimer->stop();

        mSound->stop();
    }
}

void InboxMessageScreen::copyDownloadToLocalFilesEntry()
{
//    tFile(tFile::kTemporaryDirectory, mInitObject["audio"].mString).rename(tFile::kTemporaryDirectory, mInitObject["audio"].mString);
}

#pragma mark User Interface
void InboxMessageScreen::updateTimeLabelEntry()
{
    if (!mSound)
    {
        mSound = new tSound(tFile(tFile::kTemporaryDirectory, mInitObject["audio"].mString));
        mSound->attach(this);
    }

    tUInt32 durationMS = mSound->getDurationMS();

    size_t sec = (durationMS / 1000) % 60;
    size_t min = ((durationMS / 1000) - sec) / 60;

    char buf[10];
    sprintf(buf, "%02d:%02d", (int)min, (int)sec);

    [mPeer setTimeLabel:buf];
}

void InboxMessageScreen::setWaitForDeleteMessageEntry()
{
    [mPeer setBlockingViewVisible:true];
}

void InboxMessageScreen::setWaitForDownloadEntry()
{
    [mPeer setBlockingViewVisible:true];
}

void InboxMessageScreen::setWaitForMarkReadEntry()
{
    [mPeer setBlockingViewVisible:true];
}

void InboxMessageScreen::showErrorDeletingMessageEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showErrorDeletingMessageEntry");
    tAlert("There was an error deleting a message from the server");
}

void InboxMessageScreen::showRetryDownloadEntry()
{
    GoogleAnalytics::getInstance()->trackConfirm(kScreenName, "showRetryDownloadEntry");
    tConfirm("Couldn't contact server, retry download?");
}

#pragma mark Sending messages to other machines
void InboxMessageScreen::sendForceLogoutToVCEntry()
{
    GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kForceLogout));
}
void InboxMessageScreen::sendNewMessageToGroupToVCEntry()
{
    JSONArray arr = mInitObject["to"].mArray;
    arr.push_back(mInitObject["from"].mString);

    GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kNewMessageToGroup, arr, NULL));
}

void InboxMessageScreen::sendReloadInboxToVCEntry()
{
    GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kReloadInbox));
}

void InboxMessageScreen::sendReloadInboxToVCForMarkReadEntry()
{
    GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kReloadInbox));
}

#pragma mark State wiring
void InboxMessageScreen::CallEntry()
{
	switch(mState)
	{
		case kCopyDownloadToLocalFiles: copyDownloadToLocalFilesEntry(); break;
		case kDoesAudioExistLocally: doesAudioExistLocallyEntry(); break;
		case kEnd: EndEntryHelper(); break;
		case kFixRecipientList: fixRecipientListEntry(); break;
		case kIdle: idleEntry(); break;
		case kInvalidState: invalidStateEntry(); break;
		case kPauseSound: pauseSoundEntry(); break;
		case kPausedIdle: pausedIdleEntry(); break;
		case kPeerPopSelf: peerPopSelfEntry(); break;
		case kPeerPushMessageHistory: peerPushMessageHistoryEntry(); break;
		case kPlaySound: playSoundEntry(); break;
		case kPlayingIdle: playingIdleEntry(); break;
		case kResumeSound: resumeSoundEntry(); break;
		case kSendDeleteMessageToServer: sendDeleteMessageToServerEntry(); break;
		case kSendDownloadRequestToServer: sendDownloadRequestToServerEntry(); break;
		case kSendForceLogoutToVC: sendForceLogoutToVCEntry(); break;
		case kSendMarkReadToServer: sendMarkReadToServerEntry(); break;
		case kSendNewMessageToGroupToVC: sendNewMessageToGroupToVCEntry(); break;
		case kSendReloadInboxToVC: sendReloadInboxToVCEntry(); break;
		case kSendReloadInboxToVCForMarkRead: sendReloadInboxToVCForMarkReadEntry(); break;
		case kSetWaitForDeleteMessage: setWaitForDeleteMessageEntry(); break;
		case kSetWaitForDownload: setWaitForDownloadEntry(); break;
		case kSetWaitForMarkRead: setWaitForMarkReadEntry(); break;
		case kSetWasPlayingToFalse: setWasPlayingToFalseEntry(); break;
		case kSetWasPlayingToTrue: setWasPlayingToTrueEntry(); break;
		case kShowErrorDeletingMessage: showErrorDeletingMessageEntry(); break;
		case kShowRetryDownload: showRetryDownloadEntry(); break;
		case kStart: startEntry(); break;
		case kStopSound: stopSoundEntry(); break;
		case kUpdateTimeLabel: updateTimeLabelEntry(); break;
		case kWasDeleteMessageValid: wasDeleteMessageValidEntry(); break;
		case kWereWeGoingToPlay: wereWeGoingToPlayEntry(); break;
		default: break;
	}
}

void InboxMessageScreen::CallExit()
{
}

int  InboxMessageScreen::StateTransitionFunction(const int evt) const
{
	if ((mState == kCopyDownloadToLocalFiles) && (evt == kNext)) return kUpdateTimeLabel; else
	if ((mState == kDoesAudioExistLocally) && (evt == kNo)) return kSetWaitForDownload; else
	if ((mState == kDoesAudioExistLocally) && (evt == kYes)) return kUpdateTimeLabel; else
	if ((mState == kFixRecipientList) && (evt == kNext)) return kSetWasPlayingToFalse; else
	if ((mState == kIdle) && (evt == kDeleteSelected)) return kSetWaitForDeleteMessage; else
	if ((mState == kIdle) && (evt == kPastSelected)) return kPeerPushMessageHistory; else
	if ((mState == kIdle) && (evt == kPlayPressed)) return kSetWasPlayingToTrue; else
	if ((mState == kIdle) && (evt == kReplySelected)) return kSendNewMessageToGroupToVC; else
	if ((mState == kPauseSound) && (evt == kNext)) return kPausedIdle; else
	if ((mState == kPausedIdle) && (evt == kPlayPressed)) return kResumeSound; else
	if ((mState == kPeerPushMessageHistory) && (evt == kNext)) return kIdle; else
	if ((mState == kPlaySound) && (evt == kNext)) return kPlayingIdle; else
	if ((mState == kPlayingIdle) && (evt == kFinishedPlaying)) return kStopSound; else
	if ((mState == kPlayingIdle) && (evt == kPlayPressed)) return kPauseSound; else
	if ((mState == kResumeSound) && (evt == kNext)) return kPlayingIdle; else
	if ((mState == kSendDeleteMessageToServer) && (evt == kFail)) return kShowErrorDeletingMessage; else
	if ((mState == kSendDeleteMessageToServer) && (evt == kSuccess)) return kWasDeleteMessageValid; else
	if ((mState == kSendDownloadRequestToServer) && (evt == kFail)) return kShowRetryDownload; else
	if ((mState == kSendDownloadRequestToServer) && (evt == kSuccess)) return kCopyDownloadToLocalFiles; else
	if ((mState == kSendForceLogoutToVC) && (evt == kNext)) return kPeerPopSelf; else
	if ((mState == kSendMarkReadToServer) && (evt == kFail)) return kDoesAudioExistLocally; else
	if ((mState == kSendMarkReadToServer) && (evt == kSuccess)) return kSendReloadInboxToVCForMarkRead; else
	if ((mState == kSendNewMessageToGroupToVC) && (evt == kNext)) return kIdle; else
	if ((mState == kSendReloadInboxToVC) && (evt == kNext)) return kPeerPopSelf; else
	if ((mState == kSendReloadInboxToVCForMarkRead) && (evt == kNext)) return kDoesAudioExistLocally; else
	if ((mState == kSetWaitForDeleteMessage) && (evt == kNext)) return kSendDeleteMessageToServer; else
	if ((mState == kSetWaitForDownload) && (evt == kNext)) return kSendDownloadRequestToServer; else
	if ((mState == kSetWaitForMarkRead) && (evt == kNext)) return kSendMarkReadToServer; else
	if ((mState == kSetWasPlayingToFalse) && (evt == kNext)) return kSetWaitForMarkRead; else
	if ((mState == kSetWasPlayingToTrue) && (evt == kNext)) return kDoesAudioExistLocally; else
	if ((mState == kShowErrorDeletingMessage) && (evt == kYes)) return kIdle; else
	if ((mState == kShowRetryDownload) && (evt == kNo)) return kIdle; else
	if ((mState == kShowRetryDownload) && (evt == kYes)) return kSetWaitForDownload; else
	if ((mState == kStart) && (evt == kNext)) return kFixRecipientList; else
	if ((mState == kStopSound) && (evt == kNext)) return kSetWasPlayingToFalse; else
	if ((mState == kUpdateTimeLabel) && (evt == kNext)) return kWereWeGoingToPlay; else
	if ((mState == kWasDeleteMessageValid) && (evt == kExpired)) return kSendForceLogoutToVC; else
	if ((mState == kWasDeleteMessageValid) && (evt == kNo)) return kShowErrorDeletingMessage; else
	if ((mState == kWasDeleteMessageValid) && (evt == kYes)) return kSendReloadInboxToVC; else
	if ((mState == kWereWeGoingToPlay) && (evt == kNo)) return kIdle; else
	if ((mState == kWereWeGoingToPlay) && (evt == kYes)) return kPlaySound;

	return kInvalidState;
}

bool InboxMessageScreen::HasEdgeNamedNext() const
{
	switch(mState)
	{
		case kDoesAudioExistLocally:
		case kEnd:
		case kIdle:
		case kInvalidState:
		case kPausedIdle:
		case kPeerPopSelf:
		case kPlayingIdle:
		case kSendDeleteMessageToServer:
		case kSendDownloadRequestToServer:
		case kSendMarkReadToServer:
		case kShowErrorDeletingMessage:
		case kShowRetryDownload:
		case kWasDeleteMessageValid:
		case kWereWeGoingToPlay:
			return false;
		default: break;
	}
	return true;
}

#pragma mark Messages
void InboxMessageScreen::update(const InboxMessageScreenMessage& msg)
{
    switch (msg.mEvent)
    {
        case kPlayPressed:      GoogleAnalytics::getInstance()->trackButton(kScreenName, "kPlayPressed"); break;
        case kFinishedPlaying:  GoogleAnalytics::getInstance()->trackEvent(kScreenName,  "kFinishedPlaying"); break;
        case kReplySelected:    GoogleAnalytics::getInstance()->trackButton(kScreenName, "kReplySelected"); break;
        case kDeleteSelected:   GoogleAnalytics::getInstance()->trackButton(kScreenName, "kDeleteSelected"); break;
        case kPastSelected:     GoogleAnalytics::getInstance()->trackButton(kScreenName, "kPastSelected"); break;
        default: break;
    }

    switch (msg.mEvent)
    {
        case kYes:
            GoogleAnalytics::getInstance()->trackConfirmYes(kScreenName, "showRetryDownloadEntry");
            break;
        case kNo:
            GoogleAnalytics::getInstance()->trackConfirmNo(kScreenName, "showRetryDownloadEntry");
            break;

        default:
            break;
    }

	process(msg.mEvent);
}

void InboxMessageScreen::update(const tSoundEvent& msg)
{
    switch (msg.mEvent)
    {
        case tSoundEvent::kSoundPlayingComplete:    update(kFinishedPlaying); break;

        default:
            break;
    }
}

void InboxMessageScreen::update(const URLLoaderEvent& msg)
{
    if (msg.mId == this)
    {
        [mPeer setBlockingViewVisible:false];

        switch (msg.mEvent)
        {
            case URLLoaderEvent::kLoadFail: update(kFail); break;
            case URLLoaderEvent::kLoadedString:
            {
                switch (getState())
                {
                    case kSendDeleteMessageToServer:
                        mDeleteMessageJSON = JSONUtil::extract(msg.mString);
                        break;

                    default:
                        break;
                }
            }
                update(kSuccess);
                break;

            case URLLoaderEvent::kLoadedFile: update(kSuccess); break;

            default:
                break;
        }
    }
}

void InboxMessageScreen::update(const GCTEvent& msg)
{
    if (msg.mEvent == GCTEvent::kLanguageChanged)
    {
        [mPeer refreshLanguage];
    }

    switch (getState())
    {
        case kPlayingIdle:
            switch (msg.mEvent)
            {
                case GCTEvent::kInboxTabPressed:
                case GCTEvent::kNewMemoTabPressed:
                case GCTEvent::kContactsTabPressed:
                case GCTEvent::kSettingsTabPressed:
                    update(kPlayPressed);
                        break;
                        
                    default:
                        break;
            }
            break;

        case kShowErrorDeletingMessage:
        case kShowRetryDownload:
            switch(msg.mEvent)
            {
                case GCTEvent::kOKYesAlertPressed:  update(kYes); break;
                case GCTEvent::kNoAlertPressed:     update(kNo); break;

                default:
                    break;
            }
            break;

        default:
            break;
    }
}

void InboxMessageScreen::update(const tTimerEvent& msg)
{
    switch (msg.mEvent)
    {
        case tTimer::kTimerTick:
            if (getState() == kPlayingIdle)
            {
                if (mSound)
                {
                    [mPeer setSliderPercentage: float(tTimer::getTimeMS() - mStartTimeMS) / float(mSound->getDurationMS()) * 100.0f];
                }
            }
            break;

        default:
            break;
    }
}