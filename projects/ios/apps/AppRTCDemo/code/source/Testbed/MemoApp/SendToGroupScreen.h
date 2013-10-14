#pragma once

class SendToGroupScreenMessage;
class MemoEvent;

class SendToGroupScreen
:   public tMealy,
    public tObserver<const SendToGroupScreenMessage&>,
    public tObserver<const MemoEvent&>,
    public tObserver<const URLLoaderEvent&>,
    public Screen
{
protected:
    std::vector<std::string> mUserListTable;
    std::string mUserListJSON;

public:
	SendToGroupScreen();
	~SendToGroupScreen();

protected:
	void startEntry();
	void endEntry();
	void invalidStateEntry();

	void idleEntry();
	void isUserListValidEntry();
	void sendGoInboxToVCEntry();
	void sendPostGroupToServerEntry();
	void sendUserListToServerEntry();
	void serverErrorIdleEntry();
	void showPostGroupFailedEntry();
	void showPostGroupSuccessEntry();
	void showReallySendEntry();
	void showRetryPostGroupEntry();
	void showRetryUserListEntry();
	void showServerErrorEntry();
	void showUserListEmptyEntry();
	void updateLocalUserListEntry();
	void wasPostGroupSuccessfulEntry();

public:
	enum EventType
	{
		kInvalidEvent = -2,
		kNext = -1,
		kCancel,
		kFail,
		kNo,
		kSend,
		kSuccess,
		kYes,
	};

	enum StateType
	{
		kInvalidState = 0,
		kStart = 1,
		kEnd,
		kIdle,
		kIsUserListValid,
		kSendGoInboxToVC,
		kSendPostGroupToServer,
		kSendUserListToServer,
		kServerErrorIdle,
		kShowPostGroupFailed,
		kShowPostGroupSuccess,
		kShowReallySend,
		kShowRetryPostGroup,
		kShowRetryUserList,
		kShowServerError,
		kShowUserListEmpty,
		kUpdateLocalUserList,
		kWasPostGroupSuccessful,
	};

protected:
	void CallEntry();
	void CallExit();
	int  StateTransitionFunction(const int evt) const;
	bool HasEdgeNamedNext() const;

	void update(const SendToGroupScreenMessage& msg);
	void update(const MemoEvent& msg);
	void update(const URLLoaderEvent& msg);
};

class SendToGroupScreenMessage
{
public:
	SendToGroupScreen::EventType				mEvent;
	tSubject<const SendToGroupScreenMessage&>*	mSource;

public:
	SendToGroupScreenMessage(SendToGroupScreen::EventType newEvent, tSubject<const SendToGroupScreenMessage&>* newSource = NULL)
	: mEvent(newEvent), mSource(newSource) { }
};


