#pragma once

#include "JSONUtil.h"

class GCTEvent
{
public:
    enum EventType
    {
        kAppDelegateInit,

        kInboxTabPressed,
        kNewMemoTabPressed,
        kContactsTabPressed,
        kSettingsTabPressed,

//--
        kOKYesAlertPressed,
        kNoAlertPressed,
//--
        kTranscriptFinished,
        kReloadInbox,
        kAppendNewContact,
        kAppendNewGroup,

        kNewMessageToGroup,

        kLoginSucceeded,
        kForceLogout,
        kForceLogin,

        kLanguageChanged,
    };

    EventType   mEvent;
    JSONArray   mGroup;
    std::string mTranscription;
    std::string mContact;
    tUInt32     mItemSelected;
    void*       mIdentifier;
    bool        mManualLogout;

    GCTEvent(EventType evt)
    : mEvent(evt), mManualLogout(false) { }
    GCTEvent(EventType evt, tUInt32 newItemSelected)
    : mEvent(evt), mItemSelected(newItemSelected) { }
    GCTEvent(EventType evt, const std::string& newTranscription)
    : mEvent(evt), mTranscription(newTranscription), mContact(newTranscription), mManualLogout(newTranscription == "true") { }
    GCTEvent(EventType evt, const std::string& newTranscription, void* newIdentifier)
    : mEvent(evt), mContact(newTranscription), mIdentifier(newIdentifier) { }
    GCTEvent(EventType evt, const JSONArray& newGroup, void* newIdentifier)
    : mEvent(evt), mGroup(newGroup), mIdentifier(newIdentifier) { }
};
