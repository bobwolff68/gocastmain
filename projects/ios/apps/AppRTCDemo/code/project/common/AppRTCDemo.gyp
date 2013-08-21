{
	'includes': [
		'common.gypi',
	], # includes

	'targets': [{

		'target_name': 'AppRTCDemo',
		'type': 'executable',
		'product_name': 'AppRTCDemo',
		'mac_bundle': 1,

		'sources': [
			'../../source/Testbed/AppRTCDemo/APPRTCAppClient.h',
			'../../source/Testbed/AppRTCDemo/APPRTCAppClient.m',
			'../../source/Testbed/AppRTCDemo/APPRTCAppDelegate.h',
			'../../source/Testbed/AppRTCDemo/APPRTCAppDelegate.m',
			'../../source/Testbed/AppRTCDemo/APPRTCViewController.h',
			'../../source/Testbed/AppRTCDemo/APPRTCViewController.m',
			'../../source/Testbed/AppRTCDemo/AppRTCDemo-Prefix.pch',
			'../../source/Testbed/AppRTCDemo/GAEChannelClient.h',
			'../../source/Testbed/AppRTCDemo/GAEChannelClient.m',
			'../../source/Testbed/AppRTCDemo/main.m',
		],

		'include_dirs': [
			'../../third-party/webrtc/include/objc',
			'../../third-party/webrtc/include/objc/public',
		],

		'mac_bundle_resources': [
			'../../rsrc/Testbed/AppRTCDemo/<@(OS)/ResourceRules.plist',
			'../../rsrc/Testbed/AppRTCDemo/<@(OS)/en.lproj/APPRTCViewController.xib',
			'../../rsrc/Testbed/AppRTCDemo/<@(OS)/ios_channel.html',
			'../../rsrc/Testbed/AppRTCDemo/<@(OS)/Icon.png',
			'../../rsrc/Testbed/AppRTCDemo/<@(OS)/Default.png',
			'../../rsrc/Testbed/AppRTCDemo/<@(OS)/Default-568h@2x.png',
		],

		'xcode_settings': {
            'CLANG_ENABLE_OBJC_ARC': 'YES',
			'INFOPLIST_FILE': '../../rsrc/Testbed/AppRTCDemo/<@(OS)/Info.plist',
		},	# xcode_settings

		'link_settings': {
			'libraries': [
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libCNG.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libG711.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libG722.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libNetEq.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libPCM16B.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libaudio_coding_module.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libaudio_conference_mixer.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libaudio_device.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libaudio_processing.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libaudio_processing_sse2.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libbitrate_controller.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libcommon_audio.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libcommon_audio_sse2.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libcommon_video.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libcrnspr.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libcrnss.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libcrnssckbi.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libcrssl.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libexpat.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libiLBC.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libiSAC.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libiSACFix.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libicudata.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libicui18n.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libicuuc.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libjingle.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libjingle_media.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libjingle_p2p.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libjingle_peerconnection.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libjingle_peerconnection_objc.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libjingle_sound.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libjsoncpp.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libmedia_file.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libnss_static.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libopus.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libpaced_sender.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/librbe_components.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libremote_bitrate_estimator.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/librtp_rtcp.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libsqlite_regexp.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libsrtp.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libsystem_wrappers.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvideo_capture_module.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvideo_coding_utility.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvideo_engine_core.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvideo_processing.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvideo_processing_sse2.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvideo_render_module.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvoice_engine.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvpx.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvpx_asm_offsets_vp8.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvpx_intrinsics_mmx.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvpx_intrinsics_sse2.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libvpx_intrinsics_ssse3.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libwebrtc_i420.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libwebrtc_opus.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libwebrtc_utility.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libwebrtc_video_coding.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libwebrtc_vp8.a',
				'../../third-party/webrtc/lib/$(CURRENT_ARCH)/$(CONFIGURATION)/libyuv.a',

				'libstdc++.dylib',
				'libsqlite3.dylib',

				'$(SDKROOT)/System/Library/Frameworks/UIKit.framework',
				'$(SDKROOT)/System/Library/Frameworks/Foundation.framework',
				'$(SDKROOT)/System/Library/Frameworks/AudioToolbox.framework',
				'$(SDKROOT)/System/Library/Frameworks/CoreAudio.framework',
			],	# libraries
		},	# link_settings

	}],  # targets
}
