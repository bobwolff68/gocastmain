#pragma once

@class RecordMessageVC;

class RecordMessageScreenMessage;

class RecordMessageScreen
:   public tMealy,
    public tObserver<const RecordMessageScreenMessage&>,
    public tObserver<const tSoundEvent&>,
    public tObserver<const URLLoaderEvent&>,
    public tObserver<const GCTEvent&>,
    public tObserver<const tTimerEvent&>
{
protected:
    RecordMessageVC*    mPeer;
    JSONObject          mInitObject;
    JSONObject          mMessageJSON;
    JSONObject          mPostAudioJSON;
    JSONObject          mPostTranscriptJSON;
    JSONObject          mPostMessageJSON;
    JSONObject          mValidUsersJSON;
    JSONObject          mTranscription;
    JSONArray           mNewMessageRecipients;
    tSound*             mSound;
    tSound*             mBeginRecordingIndicator;
    tSound*             mEndRecordingIndicator;
    tTimer*             mTenMinuteTimer;
    tTimer*             mSliderUpdateTimer;
    tTimer*             mRecordTimer;
    size_t              mRecrodSeconds;
    int32_t             mStartTimeMS;
    int32_t             mAlreadyPlayedTimeMS;
    bool                mDidRecord;
    bool                mGotTranscriptionEvent;
    bool                mForceLogout;

public:
    RecordMessageScreen(RecordMessageVC* newVC, const JSONObject& initObject);
	~RecordMessageScreen();

    void recordPressed();
    void readPressed();
    void composePressed();

protected:
	void startEntry();
	void endEntry();
	void invalidStateEntry();

	void idleComposeMessageEntry();
	void idleEntry();
	void idleReadMessageEntry();
	void idleRecordVoiceCommandEntry();

public:
	enum EventType
	{
		kInvalidEvent = -2,
		kNext = -1,
		kComposeButtonPressed,
		kReadButtonPressed,
		kRecordButtonPressed,
	};

	enum StateType
	{
		kInvalidState = 0,
		kStart = 1,
		kEnd,
		kIdle,
		kIdleComposeMessage,
		kIdleReadMessage,
		kIdleRecordVoiceCommand,
	};

protected:
	void CallEntry();
	void CallExit();
	int  StateTransitionFunction(const int evt) const;
	bool HasEdgeNamedNext() const;

	void update(const RecordMessageScreenMessage& msg);
	void update(const tSoundEvent& msg);
	void update(const URLLoaderEvent& msg);
	void update(const GCTEvent& msg);
	void update(const tTimerEvent& msg);
};

class RecordMessageScreenMessage
{
public:
	RecordMessageScreen::EventType				mEvent;
	tSubject<const RecordMessageScreenMessage&>*	mSource;

public:
	RecordMessageScreenMessage(RecordMessageScreen::EventType newEvent, tSubject<const RecordMessageScreenMessage&>* newSource = NULL)
	: mEvent(newEvent), mSource(newSource) { }
};


