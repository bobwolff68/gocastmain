#pragma once

@class ChangeRegisteredNameVC;

class ChangeRegisteredNameScreenMessage;

class ChangeRegisteredNameScreen
:   public tMealy,
    public tObserver<const ChangeRegisteredNameScreenMessage&>,
    public tObserver<const URLLoaderEvent&>,
    public tObserver<const GCTEvent&>
{
protected:
    ChangeRegisteredNameVC* mPeer;
    JSONObject              mInitObject;
    JSONObject              mSetContactsJSON;

public:
	ChangeRegisteredNameScreen(ChangeRegisteredNameVC* newVC, const JSONObject& initObject);
	~ChangeRegisteredNameScreen();

    void savePressed(const JSONObject& initObject);

protected:
	void startEntry();
	void endEntry();
	void invalidStateEntry();

	void idleEntry();
	void peerPopSelfEntry();
	void sendForceLogoutToVCEntry();
	void sendReloadInboxToVCEntry();
	void sendSetContactsToServerEntry();
	void setWaitForSetContactsEntry();
	void showErrorWithSetContactsEntry();
	void updateGlobalContactsEntry();
	void wasSetContactsSuccessfulEntry();

public:
	enum EventType
	{
		kInvalidEvent = -2,
		kNext = -1,
		kExpired,
		kFail,
		kNo,
		kSaveSelected,
		kSuccess,
		kYes,
	};

	enum StateType
	{
		kInvalidState = 0,
		kStart = 1,
		kEnd,
		kIdle,
		kPeerPopSelf,
		kSendForceLogoutToVC,
		kSendReloadInboxToVC,
		kSendSetContactsToServer,
		kSetWaitForSetContacts,
		kShowErrorWithSetContacts,
		kUpdateGlobalContacts,
		kWasSetContactsSuccessful,
	};

protected:
	void CallEntry();
	void CallExit();
	int  StateTransitionFunction(const int evt) const;
	bool HasEdgeNamedNext() const;

	void update(const ChangeRegisteredNameScreenMessage& msg);
    void update(const URLLoaderEvent& msg);
    void update(const GCTEvent& msg);
};

class ChangeRegisteredNameScreenMessage
{
public:
	ChangeRegisteredNameScreen::EventType				mEvent;
	tSubject<const ChangeRegisteredNameScreenMessage&>*	mSource;

public:
	ChangeRegisteredNameScreenMessage(ChangeRegisteredNameScreen::EventType newEvent, tSubject<const ChangeRegisteredNameScreenMessage&>* newSource = NULL)
	: mEvent(newEvent), mSource(newSource) { }
};

