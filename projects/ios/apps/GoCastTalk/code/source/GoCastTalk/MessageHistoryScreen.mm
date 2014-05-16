#include "Base/package.h"
#include "Io/package.h"
#include "Audio/package.h"

#include "package.h"

#include "MessageHistoryVC.h"

#define kScreenName "MessageHistory"

#pragma mark Constructor / Destructor
MessageHistoryScreen::MessageHistoryScreen(MessageHistoryVC* newVC, const JSONObject& initObject)
:   mPeer(newVC),
    mInitObject(initObject)
{
	ConstructMachine();
}

MessageHistoryScreen::~MessageHistoryScreen()
{
	DestructMachine();
}

#pragma mark Public methods

void MessageHistoryScreen::replyPressed()
{
    update(kReplySelected);
}

void MessageHistoryScreen::selectItem(const size_t& i)
{
    mItemSelected = i;

    update(MessageHistoryScreenMessage(MessageHistoryScreen::kItemSelected));
}

size_t  MessageHistoryScreen::getInboxSize()
{
    return mHistory.size();
}

std::string MessageHistoryScreen::getFrom(const size_t& i)
{
#pragma unused(i)
    std::string email   = mHistory[i].mObject["from"].mString;
    std::string result  = InboxScreen::nameFromEmail(email);

    if (result.empty())
    {
        result = email;
    }

    return result;
}

std::string MessageHistoryScreen::getDate(const size_t& i)
{
#pragma unused(i)
    std::string date = InboxScreen::gmtToLocal(mHistory[i].mObject["date"].mString);

    std::string result = "xx/xx xx:xx";

    if (date.size() == 16)
    {
        result = date.substr(4,2) + "/" + date.substr(6,2) + " " + date.substr(8,2) + ":" + date.substr(10,2);
    }

    return result;
}

std::string MessageHistoryScreen::getTranscription(const size_t& i)
{
#pragma unused(i)
    return mHistory[i].mObject["transcription"].mObject["ja"].mString;
}

bool        MessageHistoryScreen::getIsReceive(const size_t& i)
{
#pragma unused(i)
    return mHistory[i].mObject["from"].mString != InboxScreen::mEmailAddress;
}

bool        MessageHistoryScreen::getIsGroup(const size_t& i)
{
#pragma unused(i)
    return false;
}

#pragma mark Peer communication
void MessageHistoryScreen::peerPushInboxMessageEntry()
{
    [mPeer pushInboxMessage:mHistory[mItemSelected].mObject];
}

//void MessageHistoryScreen::peerPushRecordMessageEntry()
//{
//    [mPeer pushRecordMessage:mInitObject];
//}

#pragma mark Start / End / Invalid
void MessageHistoryScreen::startEntry()
{
    GoogleAnalytics::getInstance()->trackScreenEntry(kScreenName);
}

void MessageHistoryScreen::endEntry()
{
}

void MessageHistoryScreen::invalidStateEntry()
{
	assert("Event is invalid for this state" && 0);
}

#pragma mark Idling
void MessageHistoryScreen::idleEntry()
{
}

#pragma mark Actions
void MessageHistoryScreen::buildMessageHistoryEntry()
{
    mHistory.clear();

    mHistory.push_back(mInitObject);

    std::string item    = mInitObject["in-reply-to"].mString;
    bool found          = true;

    while (found)
    {
        found = false;
        for (size_t i = 0; i < InboxScreen::mInbox.size(); i++)
        {
            if (InboxScreen::mInbox[i].mObject["audio"].mString == item)
            {
                mHistory.push_back(InboxScreen::mInbox[i].mObject);
                item = InboxScreen::mInbox[i].mObject["in-reply-to"].mString;

                //Only if not self-referencing
                found = mInitObject["in-reply-to"].mString != item;
                break;
            }
        }
    }
}

#pragma mark Sending messages to other machines
void MessageHistoryScreen::sendNewMessageToGroupToVCEntry()
{
    JSONArray arr = mInitObject["to"].mArray;
    arr.push_back(mInitObject["from"].mString);

    GCTEventManager::getInstance()->notify(GCTEvent(GCTEvent::kNewMessageToGroup, arr, NULL));
}

#pragma mark State wiring
void MessageHistoryScreen::CallEntry()
{
	switch(mState)
	{
		case kBuildMessageHistory: buildMessageHistoryEntry(); break;
		case kEnd: EndEntryHelper(); break;
		case kIdle: idleEntry(); break;
		case kInvalidState: invalidStateEntry(); break;
		case kPeerPushInboxMessage: peerPushInboxMessageEntry(); break;
		case kSendNewMessageToGroupToVC: sendNewMessageToGroupToVCEntry(); break;
		case kStart: startEntry(); break;
		default: break;
	}
}

void MessageHistoryScreen::CallExit()
{
}

int  MessageHistoryScreen::StateTransitionFunction(const int evt) const
{
	if ((mState == kBuildMessageHistory) && (evt == kNext)) return kIdle; else
	if ((mState == kIdle) && (evt == kItemSelected)) return kPeerPushInboxMessage; else
	if ((mState == kIdle) && (evt == kReplySelected)) return kSendNewMessageToGroupToVC; else
	if ((mState == kPeerPushInboxMessage) && (evt == kNext)) return kIdle; else
	if ((mState == kSendNewMessageToGroupToVC) && (evt == kNext)) return kIdle; else
	if ((mState == kStart) && (evt == kNext)) return kBuildMessageHistory;

	return kInvalidState;
}

bool MessageHistoryScreen::HasEdgeNamedNext() const
{
	switch(mState)
	{
		case kEnd:
		case kIdle:
		case kInvalidState:
			return false;
		default: break;
	}
	return true;
}

#pragma mark Messages
void MessageHistoryScreen::update(const MessageHistoryScreenMessage& msg)
{
    switch (msg.mEvent)
    {
        case kItemSelected:     GoogleAnalytics::getInstance()->trackButton(kScreenName, "kItemSelected"); break;
        case kReplySelected:    GoogleAnalytics::getInstance()->trackButton(kScreenName, "kReplySelected"); break;
        default: break;
    }

	process(msg.mEvent);
}

void MessageHistoryScreen::update(const GCTEvent& msg)
{
    if (msg.mEvent == GCTEvent::kLanguageChanged)
    {
        [mPeer refreshLanguage];
    }

    switch (getState())
    {
//        case kShowNoAudioToSend:
//        case kShowPostAudioFailed:
//            switch(msg.mEvent)
//            {
//                case GCTEvent::kOKYesAlertPressed:  update(kYes); break;
//                case GCTEvent::kNoAlertPressed:     update(kNo); break;
//
//                default:
//                    break;
//            }
//            break;

        default:
            break;
    }
}
