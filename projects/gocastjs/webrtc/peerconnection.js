var GoCastJS = ("undefined" !== typeof(GoCastJS))? GoCastJS: {};
GoCastJS = (null !== GoCastJS)? GoCastJS: {};

//!
//! constructor: GoCastJS.Exception(pluginId, message)
//!
//! members:
//!		pluginId <string> : unique id of plugin instance generating the exception
//!		message	 <string> : description of the exception
//!
GoCastJS.Exception = function(pluginId, message) {
	this.pluginId = pluginId;
	this.message = message;
};

GoCastJS.Exception.prototype.toString = function() {
	return ("[" + this.pluginId + "]: " + this.message);
};

//!
//! function: GoCastJS.CheckBrowserSupport()
//! 
//! returns: 'true' if browser supported, 'false' if not.
//!
GoCastJS.CheckBrowserSupport = function() {
	return (null === navigator.userAgent.toLowerCase().match("msie"));
};

//!
//! function: GoCastJS.CheckGoCastPlayer()
//! 
//! returns: 'true' if "GoCastPlayer" detected, 'false' if not.
//!
GoCastJS.CheckGoCastPlayer = function() {
	for(i in navigator.plugins) {
		if("GoCastPlayer" === navigator.plugins[i].name) {
			return true;
		}
	}
	return false;
};

//!
//! constructor: GoCastJS.UserMediaOptions(mediaHints,
//!										   width,
//!										   height,
//!										   videoId,
//!										   containerId)
//!
//! arguments/members:
//!		mediaHints  <obj>    : {audio: <bool>, video: <bool>}
//!		width       <int>    : width of plugin window
//!		height      <int>    : height of plugin window
//!		videoId     <string> : unique id of plugin object
//!		containerId <string> : unique id of div element that contains 'videoId'
//!
GoCastJS.UserMediaOptions = function(mediaHints, width, height, videoId, containerId) {
	this.mediaHints = mediaHints;
	this.width = width;
	this.height = height;
	this.videoId = videoId;
	this.containerId = containerId;
};

//!
//! function: GoCastJS.getUserMedia(options, success, failure)
//!
//! arguments:
//!		options <GoCastJS.UserMediaOptions>	: options for obtaining user media
//!		success <function(stream)>			: success callback with stream object
//!		failure <function(message)>			: failure callback with message
//!
GoCastJS.getUserMedia = function(options, success, failure) {
	if(false === this.CheckBrowserSupport()) {
		if("undefined" !== typeof(failure) && null !== failure) {
			failure("GoCastJS.getUserMedia(): This browser not supported yet.");
		}		
	} else if(false === this.CheckGoCastPlayer()) {
		if("undefined" !== typeof(failure) && null !== failure) {
			failure("GoCastJS.getUserMedia(): GoCastPlayer not detected.");
		}
	} else {
		var container = document.getElementById(options.containerId);
		var player = document.createElement("object");
		
		player.id = options.videoId;
		player.type = "application/x-gocastplayer";
		player.width = options.width;
		player.height = options.height;
		container.appendChild(player);
		
		player.getUserMedia(
			options.mediaHints,
			function(stream) {					
				if(false === player.init("localPlayer",
										 "STUN stun.l.google.com:19302",
										 null)) {
					throw new GoCastJS.Exception(player.id, "init() failed.");
				}
				
				if(false === player.addStream(stream)) {
					throw new GoCastJS.Exception(player.id, "addStream() failed.");
				}
				
				player.setLocalDescription(
					"OFFER",
					player.createOffer({audio: true, video: true}),
					function() { player.source = stream; },
					function(message) {
						console.log("localPlayer.setLocalDescription(): ", message);
					}
				);
				
				if("undefined" !== typeof(success) && null !== success) {
					success(stream);
				}
			},
			function(message) {
				if("undefined" !== typeof(failure) && null !== success) {
					failure(message);
				}
			}
		);
	}
};

//!
//! constructor: GoCastJS.PeerConnectionOptions(iceConfig,
//!												onIceMessage,
//!												onAddStream,
//!												onRemoveStream,
//!												onReadyStateChange,
//!												width,
//!												height,
//!												videoId,
//!												containerId)
//!
//! arguments/members:
//!		iceConfig   <string> : "STUN <ip>:<port>"
//!		width       <int>    : width of plugin window
//!		height      <int>    : height of plugin window
//!		videoId     <string> : unique id of plugin object
//!		containerId <string> : unique id of div element that contains 'videoId'
//!		onIceMessage       <function(candidateSdp, moreComing)> : new ice candidate
//!		onAddStream        <function(stream)>                   : new remote stream added
//!		onRemoveStream     <function(stream)>                   : remote stream removed
//!		onReadyStateChange <function()>                         : ready state changed
//!
GoCastJS.PeerConnectionOptions = function(iceConfig,
										  onIceMessage,
										  onAddStream,
										  onRemoveStream,
										  onReadyStateChange,
										  width, 
										  height, 
										  videoId, 
										  containerId) {
	this.iceConfig = iceConfig;
	this.onIceMessage = onIceMessage;
	this.onAddStream = onAddStream;
	this.onRemoveStream = onRemoveStream;
	this.onReadyStateChange = onReadyStateChange;
	this.width = width;
	this.height = height;
	this.videoId = videoId;
	this.containerId = containerId;
};

//!
//! constructor: GoCastJS.PeerConnection(options)
//!
//! arguments:
//!		options <GoCastJS.PeerConnectionOptions> : options for creating peerconnection
//!
//! members:
//!		peerConn <HtmlObject> : 'GoCastPlayer' instance for this peerconnection
//!
GoCastJS.PeerConnection = function(options) {
	if(false === GoCastJS.CheckBrowserSupport()) {
		throw new GoCastJS.Exception(this.peerConn.id, "This browser not supported.");
	} else if(false === GoCastJS.CheckGoCastPlayer()) {
		throw new GoCastJS.Exception(this.peerConn.id, "GoCastPlayer not detected.");
	} else {
		var container = document.getElementById(options.containerId);
		this.peerConn = document.createElement("object");
		this.peerConn.id = options.videoId;
		this.peerConn.type = "application/x-gocastplayer";
		this.peerConn.width = options.width;
		this.peerConn.height = options.height;
		
		//At this point the plugin instance is loaded because of appendChild()
		container.appendChild(this.peerConn);
		
		var peerConnRef = this.peerConn;
		this.peerConn.onaddstream = function(stream) {
			peerConnRef.source = stream;
			if("undefined" !== typeof(options.onAddStream) &&
			   null !== options.onAddStream) {
				options.onAddStream(stream);
			} 
		};
		
		this.peerConn.onremovestream = function(stream) {
			if("undefined" !== typeof(options.onRemoveStream) &&
			   null !== options.onRemoveStream) {
				options.onRemoveStream(stream);
			}
		};
		
		this.peerConn.onreadystatechange = function() {
			if("undefined" !== typeof(options.onReadyStateChange) &&
			   null !== options.onReadyStateChange) {
				options.onReadyStateChange();
			}
		};
		
		if(false === this.peerConn.init(options.videoId,
										options.iceConfig,
										options.onIceMessage)) {
			throw new GoCastJS.Exception(this.peerConn.id, "init() failed.");
		}
	}
};

//!
//! function: GoCastJS.PeerConnection.AddStream(stream)
//!
//! arguments:
//!		stream <obj> : stream to be added (returned by GetUserMedia's success callback)
//!
GoCastJS.PeerConnection.prototype.AddStream = function(stream) {
	if(false === this.peerConn.addStream(stream)) {
		throw new GoCastJS.Exception(this.peerConn.id, "addStream() failed.");
	}
};

//!
//! function: GoCastJS.PeerConnection.RemoveStream(stream)
//!
//! arguments:
//!		stream <obj> : stream to be removed (returned by GetUserMedia's success callback)
//!
GoCastJS.PeerConnection.prototype.RemoveStream = function(stream) {
	if(false === this.peerConn.removeStream(stream)) {
		throw new GoCastJS.Exception(this.peerConn.id, "removeStream() failed.");		
	}
};

//!
//! function: GoCastJS.PeerConnection.CreateOffer(mediaHints)
//!
//! arguments:
//!		mediaHints <obj> : see GoCastJS.GetUserMedia()
//!
//! returns: sdp <string>
//!
GoCastJS.PeerConnection.prototype.CreateOffer = function(mediaHints) {
	var offer = this.peerConn.createOffer(mediaHints);
	if("" === offer) {
		throw new GoCastJS.Exception(this.peerConn.id, "createOffer() failed.");
	}
	return offer;
};

//!
//! function: GoCastJS.PeerConnection.CreateAnswer(offer, mediaHints)
//!
//! arguments:
//! 	offer      <string> : sdp offer of remote peer
//!		mediaHints <obj>    : see GoCastJS.GetUserMedia()
//!
//! returns: sdp <string>
//!
GoCastJS.PeerConnection.prototype.CreateAnswer = function(offer, mediaHints) {
	var answer = this.peerConn.createAnswer(offer, mediaHints);
	if("" === answer) {
		throw new GoCastJS.Exception(this.peerConn.id, "createAnswer() failed.");
	}
	return answer;
};

//!
//! function: GoCastJS.PeerConnection.SetLocalDescription(action, sdp, success, failure)
//!
//! arguments:
//!		action <string> : "OFFER" (if sdp is an offer) or "ANSWER" (if sdp is an answer) 
//!		sdp    <string> : sdp to be used as local peer's description
//!		success <function()>        : success callback
//!		failure <function(message)> : failure callback with message 
//!
GoCastJS.PeerConnection.prototype.SetLocalDescription = function(action,
																 sdp,
																 success,
																 failure) {
	this.peerConn.setLocalDescription(
		action,
		sdp,
		function() {
			if("undefined" !== typeof(success) && null !== success) {
				success();
			}
		}, 
		function(message) {
			if("undefined" !== typeof(failure) && null !== failure) {
				failure(message);
			}
		}
	);
};

//!
//! function: GoCastJS.PeerConnection.SetRemoteDescription(action, sdp)
//!
//! arguments:
//!		action <string> : "OFFER" (if sdp is an offer) or "ANSWER" (if sdp is an answer) 
//!		sdp    <string> : sdp to be used as remote peer's description
//!
GoCastJS.PeerConnection.prototype.SetRemoteDescription = function(action, sdp) {
	if(false === this.peerConn.setRemoteDescription(action, sdp)) {
		throw new GoCastJS.Exception(this.peerConn.id, "setRemoteDescription() failed.");
	}
};

//!
//! function: GoCastJS.PeerConnection.ProcessIceMessage(sdp)
//!
//! arguments:
//!		sdp <string> : sdp of remote peer's ice candidate
//!
GoCastJS.PeerConnection.prototype.ProcessIceMessage = function(sdp) {
	if(false === this.peerConn.processIceMessage(sdp)) {
		throw new GoCastJS.Exception(this.peerConn.id, "processIceMessage() failed.");
	}
};

//!
//! function: GoCastJS.PeerConnection.StartIce()
//!
//! NOTE: should be called after GoCastJS.PeerConnection.SetLocalDescription()
//!
GoCastJS.PeerConnection.prototype.StartIce = function() {
	if(false === this.peerConn.startIce()) {
		throw new GoCastJS.Exception(this.peerConn.id, "startIce() failed.");
	}
};

//!
//! function: GoCastJS.PeerConnection.ReadyState()
//!
//! returns: ["INVALID" | "PRENEW" | "NEW" | "NEGOTIATING" | 
//!			  "ACTIVE" | "CLOSING" | "CLOSED"];
//!
GoCastJS.PeerConnection.prototype.ReadyState = function() {
	return this.peerConn.readyState;
};

//!
//! function: GoCast.PeerConnection.Width([width])
//!
//! arguments:
//!		width <int> (optional) : new width value for the plugin instance
//!
//! returns:
//!		current width value of the plugin instance
//!
GoCastJS.PeerConnection.prototype.Width = function(width) {
	if("undefined" !== typeof(width) && null !== width) {
		this.peerConn.width = width;
	}
	return this.peerConn.width;
};

//!
//! function: GoCast.PeerConnection.Height([height])
//!
//! arguments:
//!		height <int> (optional) : new height value for the plugin instance
//!
//! returns:
//!		current height value of the plugin instance
//!
GoCastJS.PeerConnection.prototype.Height = function(height) {
	if("undefined" !== typeof(height) && null !== height) {
		this.peerConn.height = height;
	}
	return this.peerConn.height;
};