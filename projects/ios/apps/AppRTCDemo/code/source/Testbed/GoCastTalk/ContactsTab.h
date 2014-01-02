#pragma once

#include <queue>

class ContactsTabMessage;
class GCTEvent;

class ContactsTab
:   public tMealy,
    public Tab,
    public tObserver<const ContactsTabMessage&>,
    public tObserver<const GCTEvent&>
{
protected:
    tUInt8  mStackSize;
    bool    mCameFromMessageHistory;

public:
	ContactsTab();
	~ContactsTab();

protected:
	void startEntry();
	void endEntry();
	void invalidStateEntry();

	void changeRegisteredNameIdleEntry();
	void contactDetailsIdleEntry();
	void contactsIdleEntry();
	void didWeComeFromMessageHistoryEntry();
	void editContactsIdleEntry();
	void messageHistoryIdleEntry();
	void popTo0Entry();
	void pushChangeRegisteredNameEntry();
	void pushContactDetailsEntry();
	void pushEditContactsEntry();
	void pushMessageHistoryEntry();
	void pushRecordMessageEntry();
	void recordMessageIdleEntry();

public:
	enum EventType
	{
		kInvalidEvent = -2,
		kNext = -1,
		kEditPressed,
		kHistoryPressed,
		kItemSelected,
		kNo,
		kPopHappened,
		kReplyPressed,
		kYes,
	};

	enum StateType
	{
		kInvalidState = 0,
		kStart = 1,
		kChangeRegisteredNameIdle,
		kContactDetailsIdle,
		kContactsIdle,
		kDidWeComeFromMessageHistory,
		kEditContactsIdle,
		kEnd,
		kMessageHistoryIdle,
		kPopTo0,
		kPushChangeRegisteredName,
		kPushContactDetails,
		kPushEditContacts,
		kPushMessageHistory,
		kPushRecordMessage,
		kRecordMessageIdle,
	};

protected:
	void CallEntry();
	void CallExit();
	int  StateTransitionFunction(const int evt) const;
	bool HasEdgeNamedNext() const;

	void update(const ContactsTabMessage& msg);
    void update(const GCTEvent& msg);
};

class ContactsTabMessage
{
public:
	ContactsTab::EventType				mEvent;
	tSubject<const ContactsTabMessage&>*	mSource;

public:
	ContactsTabMessage(ContactsTab::EventType newEvent, tSubject<const ContactsTabMessage&>* newSource = NULL)
	: mEvent(newEvent), mSource(newSource) { }
};

