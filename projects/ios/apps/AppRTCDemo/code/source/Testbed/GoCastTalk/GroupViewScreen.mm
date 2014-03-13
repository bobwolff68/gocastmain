#include "Base/package.h"
#include "Io/package.h"
#include "Audio/package.h"

#include "package.h"

#include "GroupViewVC.h"

#pragma mark Constructor / Destructor
GroupViewScreen::GroupViewScreen(GroupViewVC* newVC, const JSONObject& initObject)
:   mPeer(newVC),
    mInitObject(initObject)
{
	ConstructMachine();
}

GroupViewScreen::~GroupViewScreen()
{
	DestructMachine();
}

#pragma mark Start / End / Invalid
void GroupViewScreen::startEntry()
{
}

void GroupViewScreen::endEntry()
{
}

void GroupViewScreen::invalidStateEntry()
{
	assert("Event is invalid for this state" && 0);
}

#pragma mark Public methods

void GroupViewScreen::pressSendMessage()
{
    process(kSendMessagePressed);
}

#pragma mark Idling
void GroupViewScreen::idleEntry()
{
}

#pragma mark Peer communication
void GroupViewScreen::peerPushRecordMessageEntry()
{
    JSONObject toAddresses;

    toAddresses["to"] = JSONArray();

    toAddresses["to"].mArray = mInitObject["emails"].mArray;

    [mPeer pushRecordMessage:toAddresses];
}

#pragma mark State wiring
void GroupViewScreen::CallEntry()
{
	switch(mState)
	{
		case kEnd: EndEntryHelper(); break;
		case kIdle: idleEntry(); break;
		case kInvalidState: invalidStateEntry(); break;
		case kPeerPushRecordMessage: peerPushRecordMessageEntry(); break;
		case kStart: startEntry(); break;
		default: break;
	}
}

void GroupViewScreen::CallExit()
{
}

int  GroupViewScreen::StateTransitionFunction(const int evt) const
{
	if ((mState == kIdle) && (evt == kSendMessagePressed)) return kPeerPushRecordMessage; else
	if ((mState == kPeerPushRecordMessage) && (evt == kNext)) return kIdle; else
	if ((mState == kStart) && (evt == kNext)) return kIdle;

	return kInvalidState;
}

bool GroupViewScreen::HasEdgeNamedNext() const
{
	switch(mState)
	{
		case kPeerPushRecordMessage:
		case kStart:
			return true;
		default: break;
	}
	return false;
}

#pragma mark Messages
void GroupViewScreen::update(const GroupViewScreenMessage& msg)
{
	process(msg.mEvent);
}
