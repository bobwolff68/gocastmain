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

    size_t getToCount();
    std::string getTo(const size_t& i);
    void deleteTo(const size_t& i);

    void donePressed();
    void cancelPressed();

    void pausePressed();
    void recordPressed();
    void playPressed();
    void stopPressed();

protected:
	void startEntry();
	void endEntry();
	void invalidStateEntry();

	void calculateMessageJSONEntry();
	void clearDataAndReloadTableEntry();
	void copyRecipientsAndReloadTableEntry();
	void didWeRecordEntry();
	void doWeHaveContactsToSendToEntry();
	void doWeHaveRecipientsOrARecordingEntry();
	void doWeNeedToWaitForTranscriptionEntry();
	void fixRecipientListEntry();
	void isThisAForcedCancelEntry();
	void letDidRecordBeFalseEntry();
	void letDidRecordBeTrueEntry();
	void pauseAudioEntry();
	void pausedIdleEntry();
	void peerPopAllInboxViewsEntry();
	void peerSendEmailToNonMembersEntry();
	void peerStartEditingTranscriptionEntry();
	void peerSwitchToInboxTabEntry();
	void peerSwitchToNewMemoTabEntry();
	void playAudioEntry();
	void playingIdleEntry();
	void recordingIdleEntry();
	void resumeAudioEntry();
	void sendForceLogoutToVCEntry();
	void sendPostAudioToServerEntry();
	void sendPostMessageToServerEntry();
	void sendPostTranscriptToServerEntry();
	void sendReloadInboxToVCEntry();
	void sendValidUsersToServerEntry();
	void showComposeNewMessageEntry();
	void showConfirmDeleteEntry();
	void showConfirmSendEntry();
	void showNoAudioToSendEntry();
	void showNoContactsToSendToEntry();
	void showPostAudioFailedEntry();
	void showThereWereNonMembersEntry();
	void showValidUsersFailedEntry();
	void startRecordingAudioEntry();
	void stopAudioEntry();
	void stopPlayingBeforePopEntry();
	void stopPlayingBeforeSendEntry();
	void stopRecordingAudioEntry();
	void waitForTranscriptionIdleEntry();
	void waitToPlayIdleEntry();
	void waitToRecordIdleEntry();
	void wasPostAudioSuccessfulEntry();
	void wasPostMessageSuccessfulEntry();
	void wasPostTranscriptSuccessfulEntry();
	void wasValidUsersSuccessfulEntry();
	void wereThereAnyNonMembersEntry();

	void recordingIdleExit();

public:
	enum EventType
	{
		kInvalidEvent = -2,
		kNext = -1,
		kCancelPressed,
		kExpired,
		kFail,
		kFinishedPlaying,
		kNewMessage,
		kNo,
		kPausePressed,
		kPlayPressed,
		kRecordPressed,
		kSendPressed,
		kStopPressed,
		kSuccess,
		kTranscriptionReady,
		kYes,
	};

	enum StateType
	{
		kInvalidState = 0,
		kStart = 1,
		kCalculateMessageJSON,
		kClearDataAndReloadTable,
		kCopyRecipientsAndReloadTable,
		kDidWeRecord,
		kDoWeHaveContactsToSendTo,
		kDoWeHaveRecipientsOrARecording,
		kDoWeNeedToWaitForTranscription,
		kEnd,
		kFixRecipientList,
		kIsThisAForcedCancel,
		kLetDidRecordBeFalse,
		kLetDidRecordBeTrue,
		kPauseAudio,
		kPausedIdle,
		kPeerPopAllInboxViews,
		kPeerSendEmailToNonMembers,
		kPeerStartEditingTranscription,
		kPeerSwitchToInboxTab,
		kPeerSwitchToNewMemoTab,
		kPlayAudio,
		kPlayingIdle,
		kRecordingIdle,
		kResumeAudio,
		kSendForceLogoutToVC,
		kSendPostAudioToServer,
		kSendPostMessageToServer,
		kSendPostTranscriptToServer,
		kSendReloadInboxToVC,
		kSendValidUsersToServer,
		kShowComposeNewMessage,
		kShowConfirmDelete,
		kShowConfirmSend,
		kShowNoAudioToSend,
		kShowNoContactsToSendTo,
		kShowPostAudioFailed,
		kShowThereWereNonMembers,
		kShowValidUsersFailed,
		kStartRecordingAudio,
		kStopAudio,
		kStopPlayingBeforePop,
		kStopPlayingBeforeSend,
		kStopRecordingAudio,
		kWaitForTranscriptionIdle,
		kWaitToPlayIdle,
		kWaitToRecordIdle,
		kWasPostAudioSuccessful,
		kWasPostMessageSuccessful,
		kWasPostTranscriptSuccessful,
		kWasValidUsersSuccessful,
		kWereThereAnyNonMembers,
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

