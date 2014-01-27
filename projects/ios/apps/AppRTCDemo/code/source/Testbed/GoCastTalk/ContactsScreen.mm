#include "Base/package.h"
#include "Io/package.h"
#include "Audio/package.h"

#include "package.h"

#include "ContactsVC.h"

#pragma mark Constructor / Destructor
ContactsScreen::ContactsScreen(ContactsVC* newVC)
: mPeer(newVC)
{
	ConstructMachine();
}

ContactsScreen::~ContactsScreen()
{
	DestructMachine();
}

void ContactsScreen::itemPressed(const size_t& i)
{
    if (getState() == kIdle)
    {
        mItemSelected = i;
        process(kItemSelected);
    }
}

void ContactsScreen::editPressed()
{
    if (getState() == kIdle)
    {
        process(kHelpPressed);
    }
}

void ContactsScreen::refreshPressed()
{
    if (getState() == kIdle)
    {
        process(kRefreshSelected);
    }
}

#pragma mark Start / End / Invalid
void ContactsScreen::startEntry()
{
    GCTEventManager::getInstance()->attach(this);
}

void ContactsScreen::endEntry()
{
}

void ContactsScreen::invalidStateEntry()
{
	assert("Event is invalid for this state" && 0);
}

#pragma mark Idling
void ContactsScreen::idleEntry()
{
}

#pragma mark Peer communication
void ContactsScreen::peerPushContactDetailsEntry()
{
    [mPeer pushContactDetails:InboxScreen::mContacts[mItemSelected].mObject];
}

void ContactsScreen::peerPushEditContactsEntry()
{
    [mPeer pushEditContacts];
}

void ContactsScreen::peerReloadTableEntry()
{
    [mPeer reloadTable];
}

#pragma mark State wiring
void ContactsScreen::CallEntry()
{
	switch(mState)
	{
		case kEnd: EndEntryHelper(); break;
		case kIdle: idleEntry(); break;
		case kInvalidState: invalidStateEntry(); break;
		case kPeerPushContactDetails: peerPushContactDetailsEntry(); break;
		case kPeerPushEditContacts: peerPushEditContactsEntry(); break;
		case kPeerReloadTable: peerReloadTableEntry(); break;
		case kStart: startEntry(); break;
		default: break;
	}
}

void ContactsScreen::CallExit()
{
}

int  ContactsScreen::StateTransitionFunction(const int evt) const
{
	if ((mState == kIdle) && (evt == kHelpPressed)) return kPeerPushEditContacts; else
	if ((mState == kIdle) && (evt == kItemSelected)) return kPeerPushContactDetails; else
	if ((mState == kIdle) && (evt == kRefreshSelected)) return kPeerReloadTable; else
	if ((mState == kPeerPushContactDetails) && (evt == kNext)) return kIdle; else
	if ((mState == kPeerPushEditContacts) && (evt == kNext)) return kIdle; else
	if ((mState == kPeerReloadTable) && (evt == kNext)) return kIdle; else
	if ((mState == kStart) && (evt == kNext)) return kIdle;

	return kInvalidState;
}

bool ContactsScreen::HasEdgeNamedNext() const
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
void ContactsScreen::update(const ContactsScreenMessage& msg)
{
	process(msg.mEvent);
}

void ContactsScreen::update(const GCTEvent& msg)
{
    switch(getState())
    {
        case kIdle:
            switch (msg.mEvent)
            {
                case GCTEvent::kReloadInbox:        refreshPressed(); break;

                default:
                    break;
            }
            break;
    }
}

