#pragma once

#include <queue>

class RecordAudioScreenMessage;
class MemoEvent;

class RecordAudioScreen
:   public tMealy,
    public tObserver<const RecordAudioScreenMessage&>,
    public tObserver<const MemoEvent&>,
    public Screen
{
protected:
    std::string mResultFilename;
    std::string mTranscription;

public:
	RecordAudioScreen();
	~RecordAudioScreen();

protected:
	void startEntry();
	void endEntry();
	void invalidStateEntry();

	void idleEntry();
	void recordedIdleEntry();
	void recordingIdleEntry();
	void saveTranscriptionEntry();
	void sendGoInboxToVCEntry();
	void sendGoPlayToVCEntry();
	void sendGoSendGroupToVCEntry();
	void setStatusIdleEntry();
	void setStatusRecordedEntry();
	void setStatusRecordingEntry();
	void setStatusStoppingEntry();
	void showCouldntSaveEntry();
	void startRecordingAudioEntry();
	void stopRecordingAudioEntry();

public:
	enum EventType
	{
		kInvalidEvent = -2,
		kNext = -1,
		kCancel,
		kFail,
		kSave,
		kSend,
		kStartRecording,
		kStopRecording,
		kSuccess,
		kTranscriptionReady,
	};

	enum StateType
	{
		kInvalidState = 0,
		kStart = 1,
		kEnd,
		kIdle,
		kRecordedIdle,
		kRecordingIdle,
		kSaveTranscription,
		kSendGoInboxToVC,
		kSendGoPlayToVC,
		kSendGoSendGroupToVC,
		kSetStatusIdle,
		kSetStatusRecorded,
		kSetStatusRecording,
		kSetStatusStopping,
		kShowCouldntSave,
		kStartRecordingAudio,
		kStopRecordingAudio,
	};

protected:
	void CallEntry();
	void CallExit();
	int  StateTransitionFunction(const int evt) const;
	bool HasEdgeNamedNext() const;

	void update(const MemoEvent& msg);
	void update(const RecordAudioScreenMessage& msg);
};

class RecordAudioScreenMessage
{
public:
	RecordAudioScreen::EventType				mEvent;
	tSubject<const RecordAudioScreenMessage&>*	mSource;

public:
	RecordAudioScreenMessage(RecordAudioScreen::EventType newEvent, tSubject<const RecordAudioScreenMessage&>* newSource = NULL)
	: mEvent(newEvent), mSource(newSource) { }
};


