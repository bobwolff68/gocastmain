/**********************************************************\

  Auto-generated GCPAPI.cpp

\**********************************************************/

#include "JSObject.h"
#include "variant_list.h"
#include "DOM/Document.h"
#include "global/config.h"

#include "GCPAPI.h"

///////////////////////////////////////////////////////////////////////////////
/// @fn FB::variant GCPAPI::echo(const FB::variant& msg)
///
/// @brief  Echos whatever is passed from Javascript.
///         Go ahead and change it. See what happens!
///////////////////////////////////////////////////////////////////////////////
FB::variant GCPAPI::echo(const FB::variant& msg)
{
    static int n(0);
    fire_echo("So far, you clicked this many times: ", n++);

    // return "foobar";
    return msg;
}

///////////////////////////////////////////////////////////////////////////////
/// @fn GCPPtr GCPAPI::getPlugin()
///
/// @brief  Gets a reference to the plugin that was passed in when the object
///         was created.  If the plugin has already been released then this
///         will throw a FB::script_error that will be translated into a
///         javascript exception in the page.
///////////////////////////////////////////////////////////////////////////////
GCPPtr GCPAPI::getPlugin()
{
    GCPPtr plugin(m_plugin.lock());
    if (!plugin) {
        throw FB::script_error("The plugin is invalid");
    }
    return plugin;
}

// Read/Write property testString
std::string GCPAPI::get_testString()
{
    return m_testString;
}

void GCPAPI::set_testString(const std::string& val)
{
    m_testString = val;
}

// Read-only property version
std::string GCPAPI::get_version()
{
    return FBSTRING_PLUGIN_VERSION;
}

void GCPAPI::testEvent()
{
    fire_test();
}

FB::variant GCPAPI::InitLocalResources(const std::string& stunIP,
                                       const int stunPort,
                                       FB::JSObjectPtr pSuccCallback,
                                       FB::JSObjectPtr pFailCallback)
{
    boost::mutex::scoped_lock lock_(GCP::deqMutex);
    
    if(true == (GCP::bLocalResourceMgrAssigned))
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("deInitLocalResources() not available"));
        return false;        
    }
    
    m_bLocal = true;
    GCP::bLocalResourceMgrAssigned = true;
    GCP::stunIP = stunIP;
    GCP::stunPort = stunPort;
    GCP::successCallback = pSuccCallback;
    GCP::failureCallback = pFailCallback;
    GCP::pLocalRenderer = getPlugin()->Renderer();
    (GCP::wrtInstructions).push_back(WEBRTC_RESOURCES_INIT);
    return true;
}

FB::variant GCPAPI::DeinitLocalResources()
{
    if(false == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("deInitLocalResources() not available"));
        return false;
    }
    
    boost::mutex::scoped_lock lock_(GCP::deqMutex);
    (GCP::wrtInstructions).push_back(WEBRTC_RESOURCES_DEINIT);
    
    return true;
}

FB::variant GCPAPI::StartLocalVideo()
{
    if(false == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("startLocalVideo() not available"));
        return false;
    }
    
    boost::mutex::scoped_lock lock_(GCP::deqMutex);
    (GCP::wrtInstructions).push_back(START_LOCAL_VIDEO);
    return true;
}

FB::variant GCPAPI::StopLocalVideo()
{
    if(false == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("stopLocalVideo() not available"));
        return false;
    }
    
    boost::mutex::scoped_lock lock_(GCP::deqMutex);
    (GCP::wrtInstructions).push_back(STOP_LOCAL_VIDEO);
    return true;
}

void GCPAPI::OnAddStream(const std::string& streamId, bool bVideo)
{
    m_jsCallbackOnAddStream->InvokeAsync("", FB::variant_list_of(streamId)(bVideo));
    
    if(true == bVideo)
    {
        std::string logMsg = "SetVideoRenderer(";
        logMsg += (streamId + ", Renderer): ==> ");
        FB::variant ret = m_pWebrtcPeerConn->SetVideoRenderer(streamId, getPlugin()->Renderer());
        logMsg += (ret.convert_cast<bool>()?"successful":"failed");
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
    }
}

void GCPAPI::OnRemoveStream(const std::string& streamId, bool bVideo)
{
    m_jsCallbackOnRemoveStream->InvokeAsync("", FB::variant_list_of(streamId)(bVideo));
    
    if(true == bVideo)
    {
        std::string logMsg = "SetVideoRenderer(";
        logMsg += (streamId + ", NULL): ==> ");
        FB::variant ret = m_pWebrtcPeerConn->SetVideoRenderer(streamId, NULL);
        logMsg += (ret.convert_cast<bool>()?"successful":"failed");
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
    }
}

void GCPAPI::OnSignalingMessage(const std::string& message)
{
    std::string finalMessage = m_destJid + (m_destJid != ""? "~": "");
    finalMessage += message;
    m_jsCallbackOnSignalingMessage->InvokeAsync("", FB::variant_list_of(finalMessage));
}

FB::variant GCPAPI::AddStream(const std::string& streamId, bool bVideo)
{
    if(true == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("addStream() not available"));
        return false;
    }
    
    FB::variant ret = m_pWebrtcPeerConn->AddStream(streamId, bVideo);
    std::string logMsg = "AddStream(";
    logMsg += streamId;
    logMsg += ",";
    logMsg += (bVideo?"true":"false");
    logMsg += "): ==> ";
    logMsg += (ret.convert_cast<bool>()?"successful":"failed"); 
    m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
    
    return ret;
}

FB::variant GCPAPI::RemoveStream(const std::string& streamId)
{
    if(true == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("removeStream() not available"));
        return false;
    }
    
    FB::variant ret = m_pWebrtcPeerConn->RemoveStream(streamId);    
    std::string logMsg = "RemoveStream(";
    logMsg += streamId;
    logMsg += "): ==> ";
    logMsg += (ret.convert_cast<bool>()?"successful":"failed"); 
    m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
    
    return ret;
}

FB::variant GCPAPI::ProcessSignalingMessage(const std::string& message)
{
    if(true == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("processSignalingMessage() not available"));
        return false;
    }
    
    FB::variant ret = m_pWebrtcPeerConn->SignalingMessage(message);    
    std::string logMsg = "ProcessSignalingMessage(message): ==> ";
    logMsg += (ret.convert_cast<bool>()?"successful":"failed"); 
    m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
    
    return ret;
}

FB::variant GCPAPI::Close()
{
    if(true == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("close() not available"));
        return false;
    }
    
    FB::variant ret = m_pWebrtcPeerConn->Close();
    std::string logMsg = "Close(): ==> ";
    logMsg += (ret.convert_cast<bool>()?"successful":"failed"); 
    m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
    
    return ret;
}

FB::variant GCPAPI::Init(const std::string& destJid)
{
    if(true == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("init() not available"));
        return false;
    }
    
    FB::variant ret = true;
    std::string logMsg = "Init(): ==> ";
    
    m_destJid = destJid;
    
    if(NULL != m_pWebrtcPeerConn.get())
    {
        logMsg += "successful(peerconnection already init'ed)";
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
        return ret;
    }
    
    m_pWebrtcPeerConn.reset((GCP::pWebrtcPeerConnFactory)->CreatePeerConnection((GCP::pJingleWorkerThread).get()));
    if(NULL == m_pWebrtcPeerConn.get())
    {
        ret = false;
        logMsg += "failed(couldn't create peerconnection object)";
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
        return ret;
    }
    
    m_pWebrtcPeerConn->RegisterObserver(this);
    
    if(false == m_pWebrtcPeerConn->SetAudioDevice("", "", GOCAST_AUDIO_OPTS))
    {
        m_pWebrtcPeerConn.reset();
        ret = false;
        logMsg += "failed(couldn't set audio device)";
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
        return ret;
    }
    
    logMsg += "successful";
    m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
    
    return ret;
}

FB::variant GCPAPI::Connect()
{
    if(true == m_bLocal)
    {
        m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of("connect() not available"));
        return false;
    }
    
    FB::variant ret = m_pWebrtcPeerConn->Connect();
    std::string logMsg = "Connect(): ==> ";
    logMsg += (ret.convert_cast<bool>()?"successful":"failed"); 
    m_jsCallbackOnLogMessage->InvokeAsync("", FB::variant_list_of(logMsg));
    
    return ret;
}

//logCallback
FB::JSObjectPtr GCPAPI::get_logCallback()
{
    return m_jsCallbackOnLogMessage;
}

void GCPAPI::set_logCallback(const FB::JSObjectPtr& pJSCallback)
{
    m_jsCallbackOnLogMessage = pJSCallback;
}

//onAddStreamCallback
FB::JSObjectPtr GCPAPI::get_onAddStreamCallback()
{
    return m_jsCallbackOnAddStream;
}

void GCPAPI::set_onAddStreamCallback(const FB::JSObjectPtr& pJSCallback)
{
    m_jsCallbackOnAddStream = pJSCallback;
}

//onRemoveStreamCallback
FB::JSObjectPtr GCPAPI::get_onRemoveStreamCallback()
{
    return m_jsCallbackOnRemoveStream;
}
void GCPAPI::set_onRemoveStreamCallback(const FB::JSObjectPtr& pJSCallback)
{
    m_jsCallbackOnRemoveStream = pJSCallback;
}

//onSignalingMessageCallback
FB::JSObjectPtr GCPAPI::get_onSignalingMessageCallback()
{
    return m_jsCallbackOnSignalingMessage;
}

void GCPAPI::set_onSignalingMessageCallback(const FB::JSObjectPtr& pJSCallback)
{
    m_jsCallbackOnSignalingMessage = pJSCallback;
}

