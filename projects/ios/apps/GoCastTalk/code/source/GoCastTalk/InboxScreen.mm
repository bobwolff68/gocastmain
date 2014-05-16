#include "Base/package.h"
#include "Io/package.h"
#include "Audio/package.h"

#include "package.h"

#include "InboxVC.h"

#define kScreenName "Inbox"

JSONArray   InboxScreen::mInbox;
JSONArray   InboxScreen::mContacts;
JSONArray   InboxScreen::mGroups;

std::string InboxScreen::mEmailAddress;
std::string InboxScreen::mToken;
std::string InboxScreen::mDeviceToken;

bool InboxScreen::mFirstRun                         = true;

bool sortByDate (JSONValue i, JSONValue j);
bool sortByDate (JSONValue i, JSONValue j)
{
    return i.mObject["date"].mString > j.mObject["date"].mString;
}

bool sortByKana (JSONValue i, JSONValue j);
bool sortByKana (JSONValue i, JSONValue j)
{
    if (i.mObject["kana"].mString == j.mObject["kana"].mString)
    {
        return i.mObject["email"].mString < j.mObject["email"].mString;
    }

    return i.mObject["kana"].mString < j.mObject["kana"].mString;
}

bool sortByGroupName (JSONValue i, JSONValue j);
bool sortByGroupName (JSONValue i, JSONValue j)
{
    return i.mObject["name"].mString < j.mObject["name"].mString;
}

std::string InboxScreen::getGmtString()
{
    char buf[80];
    time_t curTime;
    tm* timeStruct;

    curTime=time(NULL);
    timeStruct = gmtime(&curTime);

    sprintf(buf, "%04d%02d%02d%02d%02d%02d%02d",
            timeStruct->tm_year+1900,   timeStruct->tm_mon+1,   timeStruct->tm_mday,
            timeStruct->tm_hour,        timeStruct->tm_min,     timeStruct->tm_sec,
            tTimer::getTimeMS() % 100);

    return buf;
}

std::string InboxScreen::gmtToLocal(const std::string& gmtTime)
{
    if (gmtTime.size() == 16)
    {
        std::string appleTime = gmtTime.substr(0, 14) + " UTC";
        NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
        fmt.dateFormat = @"yyyyMMddHHmmss zzz";
        NSDate *utc = [fmt dateFromString:[NSString stringWithUTF8String:appleTime.c_str()]];
        fmt.timeZone = [NSTimeZone systemTimeZone];
        std::string local = [[fmt stringFromDate:utc] UTF8String];

        return local.substr(0, 14) + "00";
    }

    return gmtTime;
}

std::string InboxScreen::nameFromEmail(const std::string& email)
{
    bool found = false;
    size_t i;

    for(i = 0; i < mContacts.size(); i++)
    {
        if (mContacts[i].mObject["email"].mType == JSONValue::kString &&
            mContacts[i].mObject["email"].mString == email)
        {
            found = true;
            break;
        }
    }

    if (found)
    {
        if (mContacts[i].mObject["kanji"].mType == JSONValue::kString &&
            !mContacts[i].mObject["kanji"].mString.empty())
        {
            return mContacts[i].mObject["kanji"].mString;
        }
        if (mContacts[i].mObject["kana"].mType == JSONValue::kString &&
            !mContacts[i].mObject["kana"].mString.empty())
        {
            return mContacts[i].mObject["kana"].mString;
        }
    }

    return email;
}

#pragma mark Constructor / Destructor
InboxScreen::InboxScreen(InboxVC* newVC)
:   mPeer(newVC),
    mNewMessageSound(NULL)
{
	ConstructMachine();
}

InboxScreen::~InboxScreen()
{
	DestructMachine();
}

#pragma mark public methods
size_t  InboxScreen::getInboxSize()
{
    return mInbox.size();
}

std::string InboxScreen::getFrom(const size_t& i)
{
    std::string email   = mInbox[i].mObject["from"].mString;
    std::string result  = InboxScreen::nameFromEmail(email);

    if (result.empty())
    {
        result = email;
    }

    return result;
}

std::string InboxScreen::getDate(const size_t& i)
{
#pragma unused(i)
    std::string date = InboxScreen::gmtToLocal(mInbox[i].mObject["date"].mString);

    std::string result = "xx/xx xx:xx";

    if (date.size() == 16)
    {
        result = date.substr(4,2) + "/" + date.substr(6,2) + " " + date.substr(8,2) + ":" + date.substr(10,2);
    }

    return result;
}

std::string InboxScreen::getTranscription(const size_t& i)
{
    if (!mInbox[i].mObject["transcription"].mObject["ja"].mString.empty())
    {
        return mInbox[i].mObject["transcription"].mObject["ja"].mString;
    }

    return I18N::getInstance()->retrieve("Transcription not available");
}

bool        InboxScreen::getIsReceive(const size_t& i)
{
    return mInbox[i].mObject["from"].mString != InboxScreen::mEmailAddress;
}

bool        InboxScreen::getIsGroup(const size_t& i)
{
#pragma unused(i)
    return false;
}

bool        InboxScreen::getIsRead(const size_t& i)
{
    return mInbox[i].mObject["read"].mString == "yes";
}

void        InboxScreen::selectItem(const size_t& i)
{
    mItemSelected = i;

    update(InboxScreenMessage(InboxScreen::kItemSelected));
}

void       InboxScreen::refreshPressed()
{
    if (getState() == kIdle)
    {
        update(kRefreshSelected);
    }
}

void       InboxScreen::deletePressed(const size_t& i)
{
    if (getState() == kIdle)
    {
        mDeleteSelected = i;
        update(kDeleteSelected);
    }
}

#pragma mark Start / End / Invalid
void InboxScreen::startEntry()
{
    GoogleAnalytics::getInstance()->trackScreenEntry(kScreenName);

    mForceLogout        = false;
    mManualLogout       = false;
    mFirstLogin         = true;
    mDidVersionCheck    = false;

    URLLoader::getInstance()->attach(this);
    GCTEventManager::getInstance()->attach(this);

    mNewMessageSound = new tSound(tFile(tFile::kBundleDirectory, "newmessage.wav"));

    mRefreshTimer = new tTimer(30000);
    mRefreshTimer->attach(this);
    mRefreshTimer->start();
}

void InboxScreen::endEntry()
{
    if (mRefreshTimer) { delete mRefreshTimer; mRefreshTimer = NULL; }
    if (mNewMessageSound) { delete mNewMessageSound; mNewMessageSound = NULL; }
}

void InboxScreen::invalidStateEntry()
{
	assert("Event is invalid for this state" && 0);
}

#pragma mark Idling
void InboxScreen::idleEntry()
{
    if (mForceLogout)
    {
        SetImmediateEvent(kForceLogout);
    }
}

void InboxScreen::waitForLoginSuccessIdleEntry()
{
    mForceLogout = false;
    mManualLogout = false;
}

#pragma mark Queries
void InboxScreen::canRegisterDeviceEntry()
{
    tFile deviceTokenFile(tFile::kPreferencesDirectory, "device.txt");

    if (deviceTokenFile.exists())
    {
        mDeviceToken = deviceTokenFile;
    }

    SetImmediateEvent(!mDeviceToken.empty() ? kYes : kNo);
}

void InboxScreen::isThisAdhocAndFirstRunEntry()
{
#ifdef ADHOC
    SetImmediateEvent(mFirstRun ? kYes : kNo);
#else
    SetImmediateEvent(kNo);
#endif
    mFirstRun = false;
}

void InboxScreen::isThisTheCorrectVersionEntry()
{
    SetImmediateEvent((mVersionJSON["version"].mString == "1") ? kYes : kNo);
}

void InboxScreen::didWeDoAVersionCheckEntry()
{
    SetImmediateEvent(mDidVersionCheck ? kYes : kNo);
}

void InboxScreen::didWeDoAVersionCheckExit()
{
    mDidVersionCheck = true;
}

void InboxScreen::areThereNewMessagesEntry()
{
    size_t newUnread = 0;

    for(size_t i = 0; i < mInbox.size(); i++)
    {
        if (!getIsRead(i))
        {
            newUnread++;
        }
    }

    SetImmediateEvent((newUnread > mPriorUnreadCount) ? kYes : kNo);
}

void InboxScreen::didWeDownloadContactsEntry()
{
    SetImmediateEvent(!mContacts.empty() ? kYes : kNo);
}

void InboxScreen::didWeDownloadGroupsEntry()
{
    SetImmediateEvent(!mGroups.empty() ? kYes : kNo);
}

void InboxScreen::doWeHaveATokenEntry()
{
    SetImmediateEvent(InboxScreen::mEmailAddress.empty() ? kNo : kYes);
}

void InboxScreen::isThisTheFirstLoginEntry()
{
    SetImmediateEvent(mFirstLogin ? kYes : kNo);
}

void InboxScreen::wasDeleteMessageValidEntry()
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

void InboxScreen::wasGetContactsValidEntry()
{
    bool result = false;
    bool expired = false;

    mContacts.clear();

    if (mGetContactsJSON["status"].mString == std::string("success"))
    {
        mContacts = mGetContactsJSON["contacts"].mArray;

        result = true;
    }

    if (mGetContactsJSON["status"].mString == std::string("expired"))
    {
        expired = true;
    }

    SetImmediateEvent(expired ? kExpired : (result ? kYes : kNo));
}

void InboxScreen::wasGetGroupsValidEntry()
{
    bool result = false;
    bool expired = false;

    mGroups.clear();

    if (mGetGroupsJSON["status"].mString == std::string("success"))
    {
        mGroups = mGetGroupsJSON["groups"].mArray;

        result = true;
    }

    if (mGetGroupsJSON["status"].mString == std::string("expired"))
    {
        expired = true;
    }

    SetImmediateEvent(expired ? kExpired : (result ? kYes : kNo));
}

void InboxScreen::wasListMessagesValidEntry()
{
    bool result     = false;
    bool expired    = false;

    if (mListMessagesJSON["status"].mString == std::string("success"))
    {
        result = true;
    }

    if (mListMessagesJSON["status"].mString == std::string("expired"))
    {
        expired = true;
    }

    SetImmediateEvent(expired ? kExpired : (result ? kYes : kNo));
}

void InboxScreen::wasVersionValidEntry()
{
    bool result     = false;

    if (mVersionJSON["status"].mString == std::string("success"))
    {
        result = true;
    }

    SetImmediateEvent(result ? kYes : kNo);
}

void InboxScreen::wasThisAManualLogoutEntry()
{
    SetImmediateEvent(mManualLogout ? kYes : kNo);
}

#pragma mark Peer communication

void InboxScreen::peerPushInboxMessageEntry()
{
    [mPeer pushInboxMessage:mInbox[mItemSelected].mObject];
}

void InboxScreen::peerPushLoginScreenEntry()
{
    [mPeer pushLoginScreen];
}

void InboxScreen::peerReloadTableEntry()
{
    [mPeer reloadTable];
}

void InboxScreen::peerResetAllTabsEntry()
{
    [mPeer resetAllTabs];
}

void InboxScreen::peerSwitchToInboxTabEntry()
{
    [mPeer switchToInboxTab];
}

#pragma mark Actions
void InboxScreen::launchAppStoreEntry()
{
    tLaunchBrowser("https://itunes.apple.com/us/app/gocast-talk/id853983927?ls=1&mt=8");
}

void InboxScreen::addFakeContactsEntry()
{
    JSONObject  entry;
    bool        hasFeedback = false;
    bool        hasWelcome  = false;

    for (size_t i = 0; i < mContacts.size(); i++)
    {
        if (mContacts[i].mObject["email"].mString == "feedback@gocast.it")
        {
            hasFeedback = true;
        }
        else if (mContacts[i].mObject["email"].mString == "gocast.team@gocast.it")
        {
            hasWelcome = true;
        }
    }

    if (!hasFeedback)
    {
        entry["kana"] = I18N::getInstance()->retrieve("Feedback");
        entry["email"] = std::string("feedback@gocast.it");

        mContacts.push_back(entry);
    }

    if (!hasWelcome)
    {
        entry["kana"] = I18N::getInstance()->retrieve("GoCast Team");
        entry["email"] = std::string("gocast.team@gocast.it");

        mContacts.push_back(entry);
    }

}

void InboxScreen::clearAllDataAndReloadTableEntry()
{
    mInbox.clear();
    mContacts.clear();
    mGroups.clear();

    [mPeer reloadTable];
}

void InboxScreen::loadLoginNameAndTokenEntry()
{
    bool result = true;

    mEmailAddress.clear();
    mToken.clear();

    tFile loginInfo(tFile::kPreferencesDirectory, "login.txt");

    if (loginInfo.exists())
    {
        mEmailAddress = loginInfo;
    }

    loginInfo = tFile(tFile::kPreferencesDirectory, "token.txt");

    if (loginInfo.exists())
    {
        mToken = loginInfo;
    }

    loginInfo = tFile(tFile::kPreferencesDirectory, "baseURL.txt");

    if (loginInfo.exists())
    {
        LoginScreen::mBaseURL = loginInfo;
    }
    else
    {
        LoginScreen::mBaseURL = "https://chat.gocast.it/memoappserver/";
    }

    result &= !mEmailAddress.empty();
    result &= !mToken.empty();

    SetImmediateEvent(result ? kSuccess : kFail);
}

void InboxScreen::playNewMessageSoundEntry()
{
    if (mNewMessageSound)
    {
        mNewMessageSound->play();
    }
}

void InboxScreen::sortContactsByKanaEntry()
{
    std::sort(mContacts.begin(), mContacts.end(), sortByKana);
}

void InboxScreen::sortGroupsByGroupNameEntry()
{
    std::sort(mGroups.begin(), mGroups.end(), sortByGroupName);
}

void InboxScreen::sortTableByDateEntry()
{
    mInbox = mListMessagesJSON["list"].mArray;

//Fake message
    JSONObject welcomeMessage;
    welcomeMessage["from"]  = std::string("gocast.team@gocast.it");
    welcomeMessage["date"]  = std::string("2001010201010101");
    welcomeMessage["to"]    = JSONArray();
    welcomeMessage["to"].mArray.push_back(InboxScreen::mEmailAddress);
    welcomeMessage["audio"] = std::string("welcome-feedback@gocast.it");
    welcomeMessage["read"]  = std::string("yes");
    welcomeMessage["transcription"] = JSONObject();
    welcomeMessage["transcription"].mObject["ja"] = I18N::getInstance()->retrieve("welcome message");

    mInbox.push_back(welcomeMessage);

    std::sort(mInbox.begin(), mInbox.end(), sortByDate);
}

void InboxScreen::sendGetContactsToServerEntry()
{
    [mPeer setBlockingViewVisible:true];

    char buf[512];

    sprintf(buf, "%s?action=getContacts&name=%s&authToken=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            InboxScreen::mToken.c_str());

    URLLoader::getInstance()->loadString(this, buf);
}

void InboxScreen::sendGetGroupsToServerEntry()
{
    [mPeer setBlockingViewVisible:true];

    char buf[512];

    sprintf(buf, "%s?action=getGroups&name=%s&authToken=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            InboxScreen::mToken.c_str());

    URLLoader::getInstance()->loadString(this, buf);
}

void InboxScreen::sendListMessagesToServerEntry()
{
    [mPeer setBlockingViewVisible:true];

    mPriorUnreadCount = 0;
    for(size_t i = 0; i < mInbox.size(); i++)
    {
        if (!getIsRead(i))
        {
            mPriorUnreadCount++;
        }
    }

    char buf[512];

    sprintf(buf, "%s?action=listMessages&name=%s&authToken=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            InboxScreen::mToken.c_str());

    URLLoader::getInstance()->loadString(this, buf);
}

void InboxScreen::sendDeleteMessageToServerEntry()
{
    [mPeer setBlockingViewVisible:true];

    char buf[512];

    sprintf(buf, "%s?action=deleteMessage&name=%s&audio=%s&authToken=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            mInbox[mDeleteSelected].mObject["audio"].mString.c_str(),
            InboxScreen::mToken.c_str());

    URLLoader::getInstance()->loadString(this, buf);
}

void InboxScreen::sendRegisterDeviceToServerEntry()
{
    [mPeer setBlockingViewVisible:true];

    char buf[512];

    sprintf(buf, "%s?action=registerDevice&name=%s&authToken=%s&device=%s",
            kMemoAppServerURL,
            InboxScreen::mEmailAddress.c_str(),
            InboxScreen::mToken.c_str(),
            InboxScreen::mDeviceToken.c_str());

    URLLoader::getInstance()->loadString(this, buf);
}

void InboxScreen::sendVersionToServerEntry()
{
    [mPeer setBlockingViewVisible:true];

    char buf[512];

    sprintf(buf, "%s?action=version",
            kMemoAppServerURL);

    URLLoader::getInstance()->loadString(this, buf);
}

#pragma mark User Interface
void InboxScreen::showErrorDeletingMessageEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showErrorDeletingMessageEntry");
    tAlert("There was an error deleting a message from the server");
}

void InboxScreen::showErrorLoadingContactsEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showErrorLoadingContactsEntry");
    tAlert("There was an error loading contacts from the server");
}

void InboxScreen::showErrorLoadingGroupsEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showErrorLoadingGroupsEntry");
    tAlert("There was an error loading groups from the server");
}

void InboxScreen::showErrorLoadingInboxEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showErrorLoadingInboxEntry");
    tAlert("There was an error loading inbox from the server");
}

void InboxScreen::showRetryListMessagesEntry()
{
    GoogleAnalytics::getInstance()->trackConfirm(kScreenName, "showRetryListMessagesEntry");
    tConfirm("Couldn't contact server, retry refresh inbox?");
}

void InboxScreen::showYourTokenExpiredEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showYourTokenExpiredEntry");
    tAlert("Your session has expired.");
}

void InboxScreen::showErrorContactVersionEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showErrorContactVersionEntry");
    tAlert("Error contacting server");
}

void InboxScreen::showMustUpgradeEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showMustUpgradeEntry");
    tAlert("Please upgrade to the latest version of GoCast Talk in the App Store.");
}

void InboxScreen::showThisIsAdhocEntry()
{
    GoogleAnalytics::getInstance()->trackAlert(kScreenName, "showThisIsAdhocEntry");
    tAlert("TestFlight version.");
}

#pragma mark Sending messages to other machines
void InboxScreen::sendForceLoginToVCEntry()
{
    GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kForceLogin));
}

void InboxScreen::sendForceLogoutToVCEntry()
{
    GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kForceLogout));
}

#pragma mark State wiring
void InboxScreen::CallEntry()
{
	switch(mState)
	{
		case kAddFakeContacts: addFakeContactsEntry(); break;
		case kAreThereNewMessages: areThereNewMessagesEntry(); break;
		case kCanRegisterDevice: canRegisterDeviceEntry(); break;
		case kClearAllDataAndReloadTable: clearAllDataAndReloadTableEntry(); break;
		case kDidWeDoAVersionCheck: didWeDoAVersionCheckEntry(); break;
		case kDidWeDownloadContacts: didWeDownloadContactsEntry(); break;
		case kDidWeDownloadGroups: didWeDownloadGroupsEntry(); break;
		case kDoWeHaveAToken: doWeHaveATokenEntry(); break;
		case kEnd: EndEntryHelper(); break;
		case kIdle: idleEntry(); break;
		case kInvalidState: invalidStateEntry(); break;
		case kIsThisAdhocAndFirstRun: isThisAdhocAndFirstRunEntry(); break;
		case kIsThisTheCorrectVersion: isThisTheCorrectVersionEntry(); break;
		case kIsThisTheFirstLogin: isThisTheFirstLoginEntry(); break;
		case kLaunchAppStore: launchAppStoreEntry(); break;
		case kLoadLoginNameAndToken: loadLoginNameAndTokenEntry(); break;
		case kPeerPushInboxMessage: peerPushInboxMessageEntry(); break;
		case kPeerPushLoginScreen: peerPushLoginScreenEntry(); break;
		case kPeerReloadTable: peerReloadTableEntry(); break;
		case kPeerResetAllTabs: peerResetAllTabsEntry(); break;
		case kPeerSwitchToInboxTab: peerSwitchToInboxTabEntry(); break;
		case kPlayNewMessageSound: playNewMessageSoundEntry(); break;
		case kSendDeleteMessageToServer: sendDeleteMessageToServerEntry(); break;
		case kSendForceLoginToVC: sendForceLoginToVCEntry(); break;
		case kSendForceLogoutToVC: sendForceLogoutToVCEntry(); break;
		case kSendGetContactsToServer: sendGetContactsToServerEntry(); break;
		case kSendGetGroupsToServer: sendGetGroupsToServerEntry(); break;
		case kSendListMessagesToServer: sendListMessagesToServerEntry(); break;
		case kSendRegisterDeviceToServer: sendRegisterDeviceToServerEntry(); break;
		case kSendVersionToServer: sendVersionToServerEntry(); break;
		case kShowErrorContactVersion: showErrorContactVersionEntry(); break;
		case kShowErrorDeletingMessage: showErrorDeletingMessageEntry(); break;
		case kShowErrorLoadingContacts: showErrorLoadingContactsEntry(); break;
		case kShowErrorLoadingGroups: showErrorLoadingGroupsEntry(); break;
		case kShowErrorLoadingInbox: showErrorLoadingInboxEntry(); break;
		case kShowMustUpgrade: showMustUpgradeEntry(); break;
		case kShowRetryListMessages: showRetryListMessagesEntry(); break;
		case kShowThisIsAdhoc: showThisIsAdhocEntry(); break;
		case kShowYourTokenExpired: showYourTokenExpiredEntry(); break;
		case kSortContactsByKana: sortContactsByKanaEntry(); break;
		case kSortGroupsByGroupName: sortGroupsByGroupNameEntry(); break;
		case kSortTableByDate: sortTableByDateEntry(); break;
		case kStart: startEntry(); break;
		case kWaitForLoginSuccessIdle: waitForLoginSuccessIdleEntry(); break;
		case kWasDeleteMessageValid: wasDeleteMessageValidEntry(); break;
		case kWasGetContactsValid: wasGetContactsValidEntry(); break;
		case kWasGetGroupsValid: wasGetGroupsValidEntry(); break;
		case kWasListMessagesValid: wasListMessagesValidEntry(); break;
		case kWasThisAManualLogout: wasThisAManualLogoutEntry(); break;
		case kWasVersionValid: wasVersionValidEntry(); break;
		default: break;
	}
}

void InboxScreen::CallExit()
{
	switch(mState)
	{
		case kDidWeDoAVersionCheck: didWeDoAVersionCheckExit(); break;
		default: break;
	}
}

int  InboxScreen::StateTransitionFunction(const int evt) const
{
	if ((mState == kAddFakeContacts) && (evt == kNext)) return kSortContactsByKana; else
	if ((mState == kAreThereNewMessages) && (evt == kNo)) return kPeerReloadTable; else
	if ((mState == kAreThereNewMessages) && (evt == kYes)) return kPlayNewMessageSound; else
	if ((mState == kCanRegisterDevice) && (evt == kNo)) return kDidWeDownloadContacts; else
	if ((mState == kCanRegisterDevice) && (evt == kYes)) return kSendRegisterDeviceToServer; else
	if ((mState == kClearAllDataAndReloadTable) && (evt == kNext)) return kPeerPushLoginScreen; else
	if ((mState == kDidWeDoAVersionCheck) && (evt == kNo)) return kSendVersionToServer; else
	if ((mState == kDidWeDoAVersionCheck) && (evt == kYes)) return kDidWeDownloadContacts; else
	if ((mState == kDidWeDownloadContacts) && (evt == kNo)) return kSendGetContactsToServer; else
	if ((mState == kDidWeDownloadContacts) && (evt == kYes)) return kDidWeDownloadGroups; else
	if ((mState == kDidWeDownloadGroups) && (evt == kNo)) return kSendGetGroupsToServer; else
	if ((mState == kDidWeDownloadGroups) && (evt == kYes)) return kSendListMessagesToServer; else
	if ((mState == kDoWeHaveAToken) && (evt == kNo)) return kClearAllDataAndReloadTable; else
	if ((mState == kDoWeHaveAToken) && (evt == kYes)) return kDidWeDoAVersionCheck; else
	if ((mState == kIdle) && (evt == kDeleteSelected)) return kSendDeleteMessageToServer; else
	if ((mState == kIdle) && (evt == kForceLogout)) return kClearAllDataAndReloadTable; else
	if ((mState == kIdle) && (evt == kItemSelected)) return kPeerPushInboxMessage; else
	if ((mState == kIdle) && (evt == kRefreshSelected)) return kDoWeHaveAToken; else
	if ((mState == kIsThisAdhocAndFirstRun) && (evt == kNo)) return kIdle; else
	if ((mState == kIsThisAdhocAndFirstRun) && (evt == kYes)) return kShowThisIsAdhoc; else
	if ((mState == kIsThisTheCorrectVersion) && (evt == kNo)) return kShowMustUpgrade; else
	if ((mState == kIsThisTheCorrectVersion) && (evt == kYes)) return kCanRegisterDevice; else
	if ((mState == kIsThisTheFirstLogin) && (evt == kNo)) return kShowYourTokenExpired; else
	if ((mState == kIsThisTheFirstLogin) && (evt == kYes)) return kWaitForLoginSuccessIdle; else
	if ((mState == kLaunchAppStore) && (evt == kNext)) return kShowMustUpgrade; else
	if ((mState == kLoadLoginNameAndToken) && (evt == kFail)) return kClearAllDataAndReloadTable; else
	if ((mState == kLoadLoginNameAndToken) && (evt == kSuccess)) return kDoWeHaveAToken; else
	if ((mState == kPeerPushInboxMessage) && (evt == kNext)) return kIdle; else
	if ((mState == kPeerPushLoginScreen) && (evt == kNext)) return kPeerSwitchToInboxTab; else
	if ((mState == kPeerReloadTable) && (evt == kNext)) return kIsThisAdhocAndFirstRun; else
	if ((mState == kPeerResetAllTabs) && (evt == kNext)) return kWasThisAManualLogout; else
	if ((mState == kPeerSwitchToInboxTab) && (evt == kNext)) return kPeerResetAllTabs; else
	if ((mState == kPlayNewMessageSound) && (evt == kNext)) return kPeerReloadTable; else
	if ((mState == kSendDeleteMessageToServer) && (evt == kFail)) return kShowErrorDeletingMessage; else
	if ((mState == kSendDeleteMessageToServer) && (evt == kSuccess)) return kWasDeleteMessageValid; else
	if ((mState == kSendForceLoginToVC) && (evt == kNext)) return kDoWeHaveAToken; else
	if ((mState == kSendForceLogoutToVC) && (evt == kNext)) return kIdle; else
	if ((mState == kSendGetContactsToServer) && (evt == kFail)) return kShowErrorLoadingContacts; else
	if ((mState == kSendGetContactsToServer) && (evt == kSuccess)) return kWasGetContactsValid; else
	if ((mState == kSendGetGroupsToServer) && (evt == kFail)) return kShowErrorLoadingGroups; else
	if ((mState == kSendGetGroupsToServer) && (evt == kSuccess)) return kWasGetGroupsValid; else
	if ((mState == kSendListMessagesToServer) && (evt == kFail)) return kShowRetryListMessages; else
	if ((mState == kSendListMessagesToServer) && (evt == kSuccess)) return kWasListMessagesValid; else
	if ((mState == kSendRegisterDeviceToServer) && (evt == kFail)) return kDidWeDownloadContacts; else
	if ((mState == kSendRegisterDeviceToServer) && (evt == kSuccess)) return kDidWeDownloadContacts; else
	if ((mState == kSendVersionToServer) && (evt == kFail)) return kShowErrorContactVersion; else
	if ((mState == kSendVersionToServer) && (evt == kSuccess)) return kWasVersionValid; else
	if ((mState == kShowErrorContactVersion) && (evt == kYes)) return kSendVersionToServer; else
	if ((mState == kShowErrorDeletingMessage) && (evt == kYes)) return kPeerReloadTable; else
	if ((mState == kShowErrorLoadingContacts) && (evt == kYes)) return kDidWeDownloadGroups; else
	if ((mState == kShowErrorLoadingGroups) && (evt == kYes)) return kSendListMessagesToServer; else
	if ((mState == kShowErrorLoadingInbox) && (evt == kYes)) return kPeerReloadTable; else
	if ((mState == kShowMustUpgrade) && (evt == kYes)) return kLaunchAppStore; else
	if ((mState == kShowRetryListMessages) && (evt == kNo)) return kPeerReloadTable; else
	if ((mState == kShowRetryListMessages) && (evt == kYes)) return kDoWeHaveAToken; else
	if ((mState == kShowThisIsAdhoc) && (evt == kYes)) return kIdle; else
	if ((mState == kShowYourTokenExpired) && (evt == kYes)) return kWaitForLoginSuccessIdle; else
	if ((mState == kSortContactsByKana) && (evt == kNext)) return kDidWeDownloadGroups; else
	if ((mState == kSortGroupsByGroupName) && (evt == kNext)) return kSendListMessagesToServer; else
	if ((mState == kSortTableByDate) && (evt == kNext)) return kAreThereNewMessages; else
	if ((mState == kStart) && (evt == kNext)) return kLoadLoginNameAndToken; else
	if ((mState == kWaitForLoginSuccessIdle) && (evt == kLoginSucceeded)) return kSendForceLoginToVC; else
	if ((mState == kWasDeleteMessageValid) && (evt == kExpired)) return kSendForceLogoutToVC; else
	if ((mState == kWasDeleteMessageValid) && (evt == kNo)) return kShowErrorDeletingMessage; else
	if ((mState == kWasDeleteMessageValid) && (evt == kYes)) return kDoWeHaveAToken; else
	if ((mState == kWasGetContactsValid) && (evt == kExpired)) return kSendForceLogoutToVC; else
	if ((mState == kWasGetContactsValid) && (evt == kNo)) return kShowErrorLoadingContacts; else
	if ((mState == kWasGetContactsValid) && (evt == kYes)) return kAddFakeContacts; else
	if ((mState == kWasGetGroupsValid) && (evt == kExpired)) return kClearAllDataAndReloadTable; else
	if ((mState == kWasGetGroupsValid) && (evt == kNo)) return kShowErrorLoadingGroups; else
	if ((mState == kWasGetGroupsValid) && (evt == kYes)) return kSortGroupsByGroupName; else
	if ((mState == kWasListMessagesValid) && (evt == kExpired)) return kSendForceLogoutToVC; else
	if ((mState == kWasListMessagesValid) && (evt == kNo)) return kShowErrorLoadingInbox; else
	if ((mState == kWasListMessagesValid) && (evt == kYes)) return kSortTableByDate; else
	if ((mState == kWasThisAManualLogout) && (evt == kNo)) return kIsThisTheFirstLogin; else
	if ((mState == kWasThisAManualLogout) && (evt == kYes)) return kWaitForLoginSuccessIdle; else
	if ((mState == kWasVersionValid) && (evt == kNo)) return kShowErrorContactVersion; else
	if ((mState == kWasVersionValid) && (evt == kYes)) return kIsThisTheCorrectVersion;

	return kInvalidState;
}

bool InboxScreen::HasEdgeNamedNext() const
{
	switch(mState)
	{
		case kAddFakeContacts:
		case kClearAllDataAndReloadTable:
		case kLaunchAppStore:
		case kPeerPushInboxMessage:
		case kPeerPushLoginScreen:
		case kPeerReloadTable:
		case kPeerResetAllTabs:
		case kPeerSwitchToInboxTab:
		case kPlayNewMessageSound:
		case kSendForceLoginToVC:
		case kSendForceLogoutToVC:
		case kSortContactsByKana:
		case kSortGroupsByGroupName:
		case kSortTableByDate:
		case kStart:
			return true;
		default: break;
	}
	return false;
}

#pragma mark Messages
void InboxScreen::update(const InboxScreenMessage& msg)
{
    switch (msg.mEvent)
    {
        case kLoginSucceeded:   GoogleAnalytics::getInstance()->trackEvent(kScreenName,  "kLoginSucceeded"); break;
        case kForceLogout:      GoogleAnalytics::getInstance()->trackEvent(kScreenName,  "kForceLogout"); break;
        case kDeleteSelected:   GoogleAnalytics::getInstance()->trackButton(kScreenName, "kDeleteSelected"); break;
        case kRefreshSelected:  GoogleAnalytics::getInstance()->trackEvent(kScreenName,  "kRefreshSelected"); break;
        case kItemSelected:     GoogleAnalytics::getInstance()->trackButton(kScreenName, "kItemSelected"); break;
        default: break;
    }

    switch (msg.mEvent)
    {
        case kYes:
            GoogleAnalytics::getInstance()->trackConfirmYes(kScreenName, "showRetryListMessagesEntry");
            break;
        case kNo:
            GoogleAnalytics::getInstance()->trackConfirmNo(kScreenName, "showRetryListMessagesEntry");
            break;

        default:
            break;
    }

	process(msg.mEvent);
}

void InboxScreen::update(const URLLoaderEvent& msg)
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
                    case kSendGetContactsToServer:
                        mGetContactsJSON = JSONUtil::extract(msg.mString);
                        break;

                    case kSendGetGroupsToServer:
                        mGetGroupsJSON = JSONUtil::extract(msg.mString);
                        break;

                    case kSendListMessagesToServer:
                        mListMessagesJSON = JSONUtil::extract(msg.mString);
                        break;

                    case kSendDeleteMessageToServer:
                        mDeleteMessageJSON = JSONUtil::extract(msg.mString);
                        break;

                    case kSendVersionToServer:
                        mVersionJSON = JSONUtil::extract(msg.mString);
                        break;

                    default:
                        break;
                }
                update(kSuccess);
            }
                break;

            case URLLoaderEvent::kLoadedFile: update(kSuccess); break;

            default:
                break;
        }
    }
}

void InboxScreen::update(const GCTEvent& msg)
{
    if (msg.mEvent == GCTEvent::kLanguageChanged)
    {
        [mPeer refreshLanguage];
    }

    if (msg.mEvent == GCTEvent::kForceLogout)
    {
        mForceLogout = true;
        mManualLogout = msg.mManualLogout;
    }

    switch(getState())
    {
        case kIdle:
            switch (msg.mEvent)
            {
                case GCTEvent::kReloadInbox:        refreshPressed(); break;
                case GCTEvent::kForceLogout:        update(kForceLogout); break;

                default:
                    break;
            }
            break;

        case kWaitForLoginSuccessIdle:
            if (msg.mEvent == GCTEvent::kLoginSucceeded)
            {
                mFirstLogin = false;
                update(kLoginSucceeded);
            }
            break;

        case kShowErrorDeletingMessage:
        case kShowErrorLoadingInbox:
        case kShowErrorLoadingContacts:
        case kShowErrorLoadingGroups:
        case kShowRetryListMessages:
        case kShowThisIsAdhoc:
        case kShowYourTokenExpired:
        case kShowErrorContactVersion:
        case kShowMustUpgrade:
            switch(msg.mEvent)
            {
                case GCTEvent::kOKYesAlertPressed:  update(kYes); break;
                case GCTEvent::kNoAlertPressed:     update(kNo); break;

                default:
                    break;
            }
            break;
    }
}

void InboxScreen::update(const tTimerEvent& msg)
{
    switch (msg.mEvent)
    {
        case tTimer::kTimerTick:
            if (msg.mTimer == mRefreshTimer)
            {
                if (getState() == kIdle)
                {
                    refreshPressed();
                }
            }
            break;

        default:
            break;
    }
}
