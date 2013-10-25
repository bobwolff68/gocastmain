#pragma once

#ifdef ADHOC
#define kMemoAppServerURL "http://terencejgrant.com/memoappserver/"
#else
#define kMemoAppServerURL "http://127.0.0.1:8888/"
#endif

#include <string>
#include <map>
#include <set>

#include "libjson.h"

#include "JSONUtil.h"
#include "URLLoader.h"

#include "Screen.h"
#include "RecordAudioScreen.h"
#include "PlayAudioScreen.h"
#include "SettingsScreen.h"
#include "StartScreen.h"
#include "SendToGroupScreen.h"
#include "MyInboxScreen.h"
#include "VersionCheckScreen.h"

#include "MemoApp.h"

#include "MemoEvent.h"
#include "MemoEventManager.h"

#include "ios/AppDelegate.h"

extern AppDelegate* gAppDelegateInstance;
