#pragma once

class MemoEvent
{
public:
    enum EventType
    {
        kAppDelegateInit,

        kSignInPressed,

        kInboxTabPressed,
        kMemosTabPressed,
        kNewMemoTabPressed,
        kSettingsTabPressed,

        kStartRecordingPressed,
        kStopRecordingPressed,
        kCancelRecordingPressed,

        kPlayAudioPressed,
        kStopAudioPressed,
        kDeleteAudioPressed,
        kSendAudioPressed,
        kCancelAudioPressed,

        kChangePasswordPressed,
        kLogOutPressed,

        kOKYesAlertPressed,
        kNoAlertPressed,

        kTableItemSelected,
    };

    EventType   mEvent;
    tUInt32     mItemSelected;

    MemoEvent(EventType evt)
    : mEvent(evt) { }
    MemoEvent(EventType evt, tUInt32 newItemSelected)
    : mEvent(evt), mItemSelected(newItemSelected) { }
};
