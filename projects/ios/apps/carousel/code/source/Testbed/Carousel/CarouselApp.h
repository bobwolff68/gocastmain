#pragma once

#include <queue>
#include <vector>
#include <map>

#ifdef tTimer
#undef tTimer
#endif

class CarouselAppMessage;
class tSGViewEvent;
class Spot;
class WhiteboardSpot;

class CarouselApp
:   public tObserver<const CarouselAppMessage&>,
    public tObserver<const CallcastEvent&>,
    public tObserver<const tSGViewEvent&>,
    public tObserver<const tTimerEvent&>,
    public tObserver<const tTouchEvent&>
{
protected:

    std::string             mJSONStrings;

    std::vector<tPoint2f>   mWhiteBoardVerts;
    std::vector<tPoint2f>   mWhiteBoardTexCoords;
    tProgram*               mSpriteProgram;
    tTexture*               mWhiteboardTexture;

    std::string                         mNickname;
    std::string                         mRoomname;
    std::vector<Spot*>                  mSpots;
    std::map<int32_t, WhiteboardSpot*>  mMapping;
    uint32_t                            mSpotFinger;

    tTimer*                 mInputTimer;
    tTimer*                 mJSONTimer;

    tPoint2f                mStartTouch;
    tPoint2f                mEndTouch;
    tPoint2f                mLastPolledPt;
    tColor4b                mSendPenColor;
    float                   mSendPenSize;

    bool                    mInitialized;
    bool                    mShouldCapture;

protected:
    void createResources();
    void configureNodes();

    void UpdateLeftRightSpots();

public:
    CarouselApp();
    ~CarouselApp();

    void onInitView();
    void onResizeView(const tDimension2f& newSize);
    void onRedrawView(float time);

    void refresh(const int32_t& newID);

    void onAddSpot(const std::string& newType, const int32_t& newID);
    void onRemoveSpot(const int32_t& newID);
    void onOkayButton();
    void onPrevButton();
    void onNextButton();
    void onPenSizeChange(const float& newSize);
    void onPenColorChange(const tColor4b& newColor);

    void onAnimationLeft();
    void onAnimationRight();
//    void onAnimationEnd();

    void onNewButton();
    void onDeleteButton();

    void queueLine(const int32_t& newID, const tColor4b& newColor, const int32_t& newPenSize, const tPoint2f& newSt, const tPoint2f& newEn);
    void sendStrings();

    void onMouseDown(const tPoint2f& newPt);
    void onMouseDrag(const tPoint2f& newPt);
    void onMouseUp(const tPoint2f& newPt);

    void onTimerTick(const tTimer* newTimer);

protected:
    void endEntry();
    void showBlankSpotEntry();
    void showLoggingInViewEntry();
    void showLoginViewEntry();
    void showNetworkErrorEntry();
    void showNicknameInUseEntry();
    void showWebLoadingViewEntry();
    void showWhiteboardSpotEntry();
    void startEntry();
    void waitAnimThenShowBlankEntry();
    void waitAnimThenShowWBEntry();

    void endExit();
    void showBlankSpotExit();
    void showLoggingInViewExit();
    void showLoginViewExit();
    void showNetworkErrorExit();
    void showNicknameInUseExit();
    void showWebLoadingViewExit();
    void showWhiteboardSpotExit();
    void startExit();
    void waitAnimThenShowBlankExit();
    void waitAnimThenShowWBExit();

    void invalidStateEntry() { assert("Attempted to enter an invalid state." && 0); }
    void invalidStateExit()  { assert("Attempted to exit an invalid state." && 0); }

public:
	enum EventType
	{
		kInvalidEvent = 0,
		kEndAnimation,
		kLoginPressed,
		kLoginSuccess,
		kNetworkError,
		kNext,
		kNickInUse,
		kOkay,
		kQuit,
		kShowBlank,
		kShowWhiteboard,
		kStartAnimation,
		kWebViewLoaded,
	};

	enum StateType
	{
		kInvalidState = 0,
		kEnd,
		kShowBlankSpot,
		kShowLoggingInView,
		kShowLoginView,
		kShowNetworkError,
		kShowNicknameInUse,
		kShowWebLoadingView,
		kShowWhiteboardSpot,
		kStart,
		kWaitAnimThenShowBlank,
		kWaitAnimThenShowWB,
	};

	static const StateType kInitialState = kStart;

#if DEBUG
	static const char* NameForEvent(const EventType evt)
	{
		static const char* names[] =
		{
			"**invalidEvent**",
			"endAnimation",
			"loginPressed",
			"loginSuccess",
			"networkError",
			"next",
			"nickInUse",
			"okay",
			"quit",
			"showBlank",
			"showWhiteboard",
			"startAnimation",
			"webViewLoaded",
		};
		return names[(evt < 0) ? kInvalidEvent : (evt > (sizeof(names) / sizeof(const char*))) ? kInvalidEvent : evt];
	};

	static const char* NameForState(const StateType node)
	{
		static const char* names[] =
		{
			"**invalidState**",
			"end",
			"showBlankSpot",
			"showLoggingInView",
			"showLoginView",
			"showNetworkError",
			"showNicknameInUse",
			"showWebLoadingView",
			"showWhiteboardSpot",
			"start",
			"waitAnimThenShowBlank",
			"waitAnimThenShowWB",
		};
		return names[(node < 0) ? kInvalidState : (node > (sizeof(names) / sizeof(const char*))) ? kInvalidState : node];
	};
#endif

protected:
	typedef void (CarouselApp::*callfn) ();

	void CallEntry()
	{
		static const callfn fns[] =
		{
			&CarouselApp::invalidStateEntry,
			&CarouselApp::endEntry,
			&CarouselApp::showBlankSpotEntry,
			&CarouselApp::showLoggingInViewEntry,
			&CarouselApp::showLoginViewEntry,
			&CarouselApp::showNetworkErrorEntry,
			&CarouselApp::showNicknameInUseEntry,
			&CarouselApp::showWebLoadingViewEntry,
			&CarouselApp::showWhiteboardSpotEntry,
			&CarouselApp::startEntry,
			&CarouselApp::waitAnimThenShowBlankEntry,
			&CarouselApp::waitAnimThenShowWBEntry,
		};

		(this->*fns[(mState < 0) ? kInvalidState : (mState > (sizeof(fns) / sizeof(callfn))) ? kInvalidState : mState])();
	}
	void CallExit()
	{
		static const callfn fns[] =
		{
			&CarouselApp::invalidStateExit,
			&CarouselApp::endExit,
			&CarouselApp::showBlankSpotExit,
			&CarouselApp::showLoggingInViewExit,
			&CarouselApp::showLoginViewExit,
			&CarouselApp::showNetworkErrorExit,
			&CarouselApp::showNicknameInUseExit,
			&CarouselApp::showWebLoadingViewExit,
			&CarouselApp::showWhiteboardSpotExit,
			&CarouselApp::startExit,
			&CarouselApp::waitAnimThenShowBlankExit,
			&CarouselApp::waitAnimThenShowWBExit,
		};

		(this->*fns[(mState < 0) ? kInvalidState : (mState > (sizeof(fns) / sizeof(callfn))) ? kInvalidState : mState])();
	}

	StateType StateTransitionFunction(const EventType evt) const
	{
		if ((mState == kShowBlankSpot) && (evt == kNetworkError)) return kShowNetworkError;
		if ((mState == kShowBlankSpot) && (evt == kNickInUse)) return kShowNicknameInUse;
		if ((mState == kShowBlankSpot) && (evt == kQuit)) return kEnd;
		if ((mState == kShowBlankSpot) && (evt == kShowBlank)) return kShowBlankSpot;
		if ((mState == kShowBlankSpot) && (evt == kShowWhiteboard)) return kShowWhiteboardSpot;
		if ((mState == kShowBlankSpot) && (evt == kStartAnimation)) return kWaitAnimThenShowBlank;
		if ((mState == kShowLoggingInView) && (evt == kLoginSuccess)) return kShowBlankSpot;
		if ((mState == kShowLoggingInView) && (evt == kNetworkError)) return kShowNetworkError;
		if ((mState == kShowLoggingInView) && (evt == kNickInUse)) return kShowNicknameInUse;
		if ((mState == kShowLoggingInView) && (evt == kQuit)) return kEnd;
		if ((mState == kShowLoginView) && (evt == kLoginPressed)) return kShowLoggingInView;
		if ((mState == kShowLoginView) && (evt == kNetworkError)) return kShowNetworkError;
		if ((mState == kShowLoginView) && (evt == kQuit)) return kEnd;
		if ((mState == kShowNetworkError) && (evt == kQuit)) return kEnd;
		if ((mState == kShowNicknameInUse) && (evt == kNetworkError)) return kShowNetworkError;
		if ((mState == kShowNicknameInUse) && (evt == kOkay)) return kShowLoginView;
		if ((mState == kShowNicknameInUse) && (evt == kQuit)) return kEnd;
		if ((mState == kShowWebLoadingView) && (evt == kNetworkError)) return kShowNetworkError;
		if ((mState == kShowWebLoadingView) && (evt == kQuit)) return kEnd;
		if ((mState == kShowWebLoadingView) && (evt == kWebViewLoaded)) return kShowLoginView;
		if ((mState == kShowWhiteboardSpot) && (evt == kNetworkError)) return kShowNetworkError;
		if ((mState == kShowWhiteboardSpot) && (evt == kNickInUse)) return kShowNicknameInUse;
		if ((mState == kShowWhiteboardSpot) && (evt == kQuit)) return kEnd;
		if ((mState == kShowWhiteboardSpot) && (evt == kShowBlank)) return kShowBlankSpot;
		if ((mState == kShowWhiteboardSpot) && (evt == kShowWhiteboard)) return kShowWhiteboardSpot;
		if ((mState == kShowWhiteboardSpot) && (evt == kStartAnimation)) return kWaitAnimThenShowWB;
		if ((mState == kStart) && (evt == kNext)) return kShowWebLoadingView;
		if ((mState == kWaitAnimThenShowBlank) && (evt == kEndAnimation)) return kShowBlankSpot;
		if ((mState == kWaitAnimThenShowBlank) && (evt == kNetworkError)) return kShowNetworkError;
		if ((mState == kWaitAnimThenShowBlank) && (evt == kQuit)) return kEnd;
		if ((mState == kWaitAnimThenShowBlank) && (evt == kShowBlank)) return kWaitAnimThenShowBlank;
		if ((mState == kWaitAnimThenShowBlank) && (evt == kShowWhiteboard)) return kWaitAnimThenShowWB;
		if ((mState == kWaitAnimThenShowBlank) && (evt == kStartAnimation)) return kWaitAnimThenShowBlank;
		if ((mState == kWaitAnimThenShowWB) && (evt == kEndAnimation)) return kShowWhiteboardSpot;
		if ((mState == kWaitAnimThenShowWB) && (evt == kNetworkError)) return kShowNetworkError;
		if ((mState == kWaitAnimThenShowWB) && (evt == kQuit)) return kEnd;
		if ((mState == kWaitAnimThenShowWB) && (evt == kShowBlank)) return kWaitAnimThenShowBlank;
		if ((mState == kWaitAnimThenShowWB) && (evt == kShowWhiteboard)) return kWaitAnimThenShowWB;
		if ((mState == kWaitAnimThenShowWB) && (evt == kStartAnimation)) return kWaitAnimThenShowWB;

		assert("Event is invalid for this state" && 0);

		return kInvalidState;
	}

	bool HasEdgeNamedNext() const
	{
		switch (mState)
		{
			case kStart:
				return true;

			default: break;
		}
		return false;
	}

protected:
    std::queue<EventType>   mReentrantQueue;
    StateType               mState;
    EventType               mImmediateEvent;
    bool                    mHasImmediateEvent;
    bool*                   mMachineDestroyedPtr;

protected:
    void ConstructMachine()
    {
        mState = CarouselApp::kInitialState;
        mHasImmediateEvent = false;
        mMachineDestroyedPtr = NULL;

        CallEntry();

        if (HasEdgeNamedNext())
        {
            RunEvent(CarouselApp::kNext);
        }
    }

    void DestructMachine()
    {
        if (mMachineDestroyedPtr)
        {
            *mMachineDestroyedPtr = true;
        }
        else
        {
            process(CarouselApp::kQuit);
        }
    }

    bool RunEvent(const EventType& evt)
    {
        bool machineDestroyed = false;
        mMachineDestroyedPtr = &machineDestroyed;

        setImmediateEvent(evt);

        while (mHasImmediateEvent)
        {
            mHasImmediateEvent = false;

            CallExit();

            if (machineDestroyed) { return true; }
#if DEBUG && 1
            StateType newState = StateTransitionFunction(mImmediateEvent);
            printf("%s[%p]: %s X %s -> %s\n", "CarouselApp", this, CarouselApp::NameForState(mState), CarouselApp::NameForEvent(mImmediateEvent), CarouselApp::NameForState(newState));
            mState = newState;
#else
            mState = StateTransitionFunction(mImmediateEvent);
#endif
            assert(mState != kInvalidState);
            CallEntry();

            if (machineDestroyed) { return true; }

            if (HasEdgeNamedNext())
            {
                setImmediateEvent(kNext);
            }
        }

        mMachineDestroyedPtr = NULL;

        return false;
    }

public:
    StateType getState() const { return mState; }

    void setImmediateEvent(const EventType evt)
    {
        assert(!mHasImmediateEvent);

        mHasImmediateEvent = true;
        mImmediateEvent = evt;
    }

    void process(const EventType evt)
    {
        bool empty = mReentrantQueue.empty();

        mReentrantQueue.push(evt);

        if (empty)
        {
            while (!mReentrantQueue.empty())
            {
                bool machineDestroyed = RunEvent(mReentrantQueue.front());
                if (machineDestroyed) { return; }
                mReentrantQueue.pop();
            }
        }
    }

    void update(const CarouselAppMessage& msg);
    void update(const CallcastEvent& msg);
    void update(const tSGViewEvent& msg);
    void update(const tTimerEvent& msg);
    void update(const tTouchEvent& msg);

//void CarouselApp::update(const CarouselAppMessage& msg)
//{
//    process(msg.event);
//}
};

class CarouselAppMessage
{
public:
    CarouselApp::EventType                event;
    tSubject<const CarouselAppMessage&>*   source;

public:
    CarouselAppMessage(CarouselApp::EventType evt, tSubject<const CarouselAppMessage&>* src = NULL) : event(evt), source(src) { }
};
