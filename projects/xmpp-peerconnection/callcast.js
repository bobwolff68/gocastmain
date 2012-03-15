/**
 * Callcast - protocol utilizing general xmpp as well as disco and MUC.
 *
 * Copyright 2012 GoCast - www.GoCast.it
 * Author: Robert Wolff - rwolff@gocast.it / bob.wolff68@gmail.com
 *
 * Purpose: Use a more robust server signalling protocol than the current example peerconnection*
 *   version in webrtc/libjingle examples. The TCP connection in peerconnection is not very
 *   robust against dropped TCP connections and isn't a 'standard' either. Utilizing a standard
 *   XMPP server with a BOSH connection, we can envision a more flexible and further reaching
 *   approach which gives us a more natural call/session control, group controls, and built-in
 *   instant messaging as well as other flexible mechanisms for add-on features.
 *
 * See callcast.html for a very simple (poor UI) sample of this signalling.
 *
 * TODO: a) Remove the rest of the UI from the Callcast object. Currently .Makecall() utilizes
 *          jqueryUI dialogs as does the reception of an incoming call.
 *       b) Change code to be a Strophe plugin which will help in (a) above making the calling
 *          application cope with all UI items.
 *       c) Update use of PeerConnection from rev 1080 of webrtc to ROAP/JSEP model when appropriate.
 *       d) Remove the custom OnMessage() message modification in the plugin today. Currently,
 *          the offer message is prepended with the jid of the user to which it belongs + '~'
 *       e) Use DISCO to determine if a jid is capable of handling an invite. Otherwise, possibly
 *          send them a link to the plugin or to a webrtc resource.
 *
 * How it is done:
 *  General Theory:
 *    Use MUC chat rooms for session engagement, presence, and signalling between peers for call
 *    setup. Use directed chat for invitations to join an existing/new room/session outside of
 *    MUC. And once a person joins the MUC room, they have at that point said "accept" to the
 *    call and as such, when they enter the room, it is their responsibility to make a new
 *    PeerConnection with each of the existing members of the call. So, the new person sends
 *    an 'initiate' with their signalling info to each existing entity and anyone who is already
 *    in the room will automatically respond with their information by making a Peerconnection
 *    with the new person.
 *
 *  Joining an existing MUC room:
 *    If a user joins a MUC room and they are Callcast enabled, they take the inbound presence
 *    list given to them upon entry and they send a directed "chat" message with a stanza inside it
 *    of <initiating >Signalling message offer from PeerConnection</initiating>. This stanza
 *    is sent to each of the existing members of the room. Upon reception of an <initiating>,
 *    the message body is used to complete the call via peer_connection.processSignalingMessage().
 *
 *  Inviting a new person to a call:
 *    Using the chat message, we simply formulate an invitation with our namespace. When a Callcast
 *    enabled peer receives such a message, they can choose to prompt the user to accept the
 *    incoming call and if they do accept it, the invitation had the MUC room to join as part of
 *    the invitation. The new entrant then joins the room and the flow of events is the same
 *    as above (Joining an existing MUC room:)
 *
 *
 *  Customization to existing PeerConnection.onsignallingmessage()
 *    It is necessary for us to know which Peerconnection message belongs with which peer, and
 *    the onsignallingmessage(message) does not contain any identification natively. So, we
 *    decided to prepend "jid~" to the exisitng message so that we can properly identify which
 *    jid is being signaled. Each PeerConnection keeps track of which jid they belong to via
 *    the change to Init() below.
 *  Customization to existing PeerConnection.init()
 *    In order to keep track and 'pair' each PeerConnection to a particular jid, init() is used
 *    to make that pairing so that when onsignallingmessage is called, it is called with the
 *    identifying jid prepended to the signalling message.
 *
 */

var Callcast = {
	NOANSWER_TIMEOUT_MS: 6000,
	CALLCAST_XMPPSERVER: "video.gocast.it",
	CALLCAST_ROOMS: "gocastconference.video.gocast.it",
	AT_CALLCAST_ROOMS: "@gocastconference.video.gocast.it",
	NS_CALLCAST: "urn:xmpp:callcast",
    connection: null,
    participants: {},
    room: "",
    roomlist: {},
    nick: "",
    joined: false,
    keepAliveTimer: null,

    CallStates: {
    	NONE: 0,
    	AWAITING_RESPONSE: 1,
    	CONNECTED: 2
    },
    
    keepAlive: function() {
    	this.keepAliveTimer = setInterval(function() {
    		if (Callcast.connection)
			{
	    		Callcast.connection.sendIQ($iq({to: Callcast.CALLCAST_XMPPSERVER, from: Callcast.connection.jid, type: 'get', id: 'ping1'})
	    						.c('ping', {xmlns: 'urn:xmpp:ping'}), 
	    		null, // No action for a successful 'pong' 
	    		function() { 
	    			alert("Ping failed. Lost connection with server?"); 
	    		});
			}
    		else
    			alert("Server connection failed.");
		}, 10000);
    },
    
    onErrorStanza: function(err) {
    	alert("Error Stanza: " + $(err).children('error').children('text').text());
    	return true;
    },
    
    DropAllParticipants: function() {
		for (k in Callcast.participants) {
			Callcast.participants[k].DropCall();
			delete Callcast.participants[k];
		}

		Callcast.participants = {};
    },

    Callee: function(nickname, room) {
    	// Ojbect for participants in the call or being called (in progress)
    	this.jid = room + "/" + nickname;
    	this.non_muc_jid = "";
    	this.CallState = Callcast.CallStates.NONE;
    	// TODO - FIX - Need a truly UNIQUE adder here - not nick which can change and be replaced during the lifetime of the call.
    	$("#rtcobjects").append('<li id="li_WebrtcPeerConnection'+nickname+'"><object id="WebrtcPeerConnection'+nickname+'" type="application/x-webrtcpeerconnection" width="0" height="0"></object></li>');
    	
    	this.peer_connection = $('#WebrtcPeerConnection'+nickname).get(0);
    	if (!this.peer_connection)
    		alert("Peer connection object not found in DOM. Plugin problem?");
    	
    	self = this;
    	
//    	this.onSignalingMessage = function(message) {
//        	if (this.jid === null)
//                console.log("ERROR - message to be sent - but no recipient yet.");
//        	else
//            {
//                    var offer = $msg({to: this.jid, type: "chat"}).c('initiating', {xmlns: Callcast.NS_CALLCAST}).t(message);
//	                console.log("Sending message to peer..." + this.jid);
//                    Callcast.connection.send(offer);
//                    this.CallState = Callcast.CallStates.AWAITING_RESPONSE;
//            }
//    	};
    	
    	if (this.peer_connection === null)
    		console.log("FAILED to create peer connection object.");
    	else
    	{
	        this.peer_connection.onlogmessage = Callcast.log;
            this.peer_connection.onaddstream = function(streamId, bVideo) {
                var logMessage = 'Remote peer added ' + (bVideo? 'video ': 'audio ') + 'stream: ' + streamId;
                console.log(logMessage);
	        };
	        
	        this.peer_connection.onremovestream = function(streamId, bVideo) {
	                var logMessage = 'Remote peer removed ' + (bVideo? 'video ': 'audio ') + 'stream: ' + streamId;
	                console.log(logMessage);
	        };
	        
//	        this.peer_connection.onsignalingmessage = this.onSignalingMessage;
	        this.peer_connection.onsignalingmessage = function(message) {
	        	// If message does *NOT* start with "{", then we have our special message.
	        	// Special message is of the form JID~message
	        	var callback_jid = "";
	        	var callback_msg = "";
	        	
	        	if (message[0] !== "{")
	        	{
	        		var msgsplit = message.split("~");
	        		callback_jid = msgsplit[0];
	        		callback_msg = msgsplit[1];
	        	}
	        	else
	        	{
	        		callback_jid = self.jid;
	        		callback_msg = message;
	        	}
	        	
	        	if (!callback_jid || callback_jid == "")
                    console.log("ERROR - message to be sent - but no recipient yet.");
	        	else
                    {
                            var offer = $msg({to: callback_jid, type: "chat"}).c('initiating', {xmlns: Callcast.NS_CALLCAST}).t(callback_msg);
        	                console.log("Sending message to peer...");
                            Callcast.connection.send(offer);
                            Callcast.participants[Strophe.getResourceFromJid(callback_jid)].CallState = Callcast.CallStates.AWAITING_RESPONSE;
                    }

	        };

    	};

        this.peer_connection.init(this.jid);

    	this.InitiateCall = function() {
	        //
	        // Now that we're ready, bring the peer_connection online and kick it off.
	        //
	        var calltype = " - Audio Only.";
	        var bVideo = $('#video_enabled') && $('#video_enabled').is(':checked');
	        
	        if (bVideo)
	        	calltype = " - Audio+Video.";
	        	
	        console.log("Commencing to call " + this.jid + calltype);
	        
	        this.peer_connection.addStream('audio', bVideo);
	        this.peer_connection.connect();
    	};

    	this.CompleteCall = function(inbound) {
    		console.log("Completing call...");
    		this.peer_connection.processSignalingMessage(inbound);
    		this.CallState = Callcast.CallStates.CONNECTED;
    	};
    	
    	this.DropCall = function() {
    		console.log("Dropping call for "+this.jid);
    		if (this.peer_connection)
    		{
    			this.peer_connection.close();
    			this.peer_connection = null;
    			// Now remove object from div
    			$("#li_WebrtcPeerConnection" + Strophe.getResourceFromJid(this.jid)).remove();
    		}
    		else
    			console.log("Dropping FAILED. Cant find peer_connection (or self)");
    	};
    },
    
    escapeit: function(msg) {
   	    return msg.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    },
    
    log: function (msg) {
 //    	$('#log').append(this.escapeit(msg) + "<br>");
 
    	// This version is required for peer_connection.onlogmessage -- console.log doesn't work and escaped <br> version doesnt work.
    	$('#log').append("<p>" + msg + "</p>");
    },

    accepted: function(iq) {
    	Callcast.log("Got an accepted call.");
    },
    
    rejected: function(iq) {
    	Callcast.log("Call was rejected.");
    },
    
    initCallError: function(iq) {
    	Callcast.log("Initiating call resulted in an error.");
    },
    
    ///
    /// Grab the room list from the server, and put it in an array of .roomlist[jid] = roomname
    /// Then trigger 'roomlist_updated' for the UI portion to react.
    ///
    RefreshRooms: function(ui_element) {
    	 Callcast.connection.muc.listRooms(Callcast.CALLCAST_ROOMS, function(thelist) {
    		 Callcast.roomlist = {};	// Remove all entries from the rooms list.
    		 
    	     $(thelist).find("item").each(function () {
    	    	 Callcast.roomlist[$(this).attr('jid')] = $(this).attr('name');
    	     }) ;
    	     
    	     $(document).trigger('roomlist_updated');
    	 });
    },
    
    CallMsgHandler: function(msg) {
    	var res_nick = Strophe.getResourceFromJid($(msg).attr('from'));
    	

    	// Inbound call - initiating
       	if ($(msg).find('initiating').length > 0)
    	{
	    	console.log("Got inbound call-message from " + $(msg).attr('from'));
	  
	    	if (!Callcast.participants[res_nick])
	    	{
	    		console.log("ERROR: Participant for nick=" + res_nick + " not found. Who is this guy?");
	    		return true;
	    	}
	
	    	// 
	    	// Otherwise, we already know this guy - so complete the call.
	    	//
	    	var inbound = $(msg).children('initiating').text().replace(/&quot;/g, '"');
	    	
	    	Callcast.participants[res_nick].CompleteCall(inbound);
    	}
    	
    	if ($(msg).find('x').length > 0)
    	{
    		console.log("Got inbound INVITATION to join a session.");
    		var invite = $(msg).find('x');
    		var from = $(msg).attr('from');
    		var roomjid = $(invite).attr('jid');
    		var password = $(invite).attr('password');
    		var reason = $(invite).attr('reason');
    		
    		// Put up an approval dialog and work from there to join or not join the call.
    		
    		$('#approval_dialog').append('<p>Ring Ring: Call from ' + Strophe.getBareJidFromJid(from) + ". Ring Ring...</p>");
    		if (reason)
        		$('#approval_dialog').append('<p>' + reason + "</p>");
    			
    	    $('#approval_dialog').dialog({
    	        autoOpen: true,
    	        draggable: false,
    	        modal: true,
    	        title: 'Incoming Call From ' + Strophe.getBareJidFromJid(from),
    	        buttons: {
    	            "Answer": function () {
    	            	Callcast.JoinSession(Strophe.getNodeFromJid(roomjid), roomjid);
    	                $(this).dialog('close');
    	            },
    	    		"Ignore": function() {
    	    			$(this).dialog('close');
    	    			alert("Incoming call request was ignored.");
    	    		}
    	        }
    	    });
    		
    		
    	}
    	
    	return true;
    },
    
    MsgHandler: function(msg) {
//    	console.log("STANDARD MESSAGE:");
//    	console.log(msg);
    	return true;
    },
    
    PresHandler: function(presence) {
            var from = $(presence).attr('from');
            var room = Strophe.getBareJidFromJid(from);

        	console.log(presence);
        	console.log("From-NICK: " + $(presence).attr('from'));
//        	return true;
            // make sure this presence is for the right room
            if (room === Callcast.room) {
                var nick = Strophe.getResourceFromJid(from);

                if ($(presence).attr('type') === 'error' &&
                    !Callcast.joined) {
                    // error joining room; reset app
                	alert("Error joining room. Disconnecting.");
                    Callcast.disconnect();
                } else if (!Callcast.participants[nick] && $(presence).attr('type') !== 'unavailable') {
                    // add to participant list
                	// Make sure we ONLY add **OTHERS** to the participants list.
                	// Otherwise we'll wind up calling ourselves.
                    var user_jid = $(presence).find('item').attr('jid');

                    // 
                    // No matter what, we need to add this participant to the room/call.
                    // (Except when the new participant is ourselves. :-)
                    //
                    if (nick !== Callcast.nick)
                    {
	                    Callcast.participants[nick] = new Callcast.Callee(nick, room);
	                    if (user_jid)
	                    	Callcast.participants[nick].non_muc_jid = user_jid;

	                    // Now, if we are new to the session (not fully joined ye) then it's our job to call everyone.
	                    if (!Callcast.joined)
                        	Callcast.participants[nick].InitiateCall();
                    }

                    //
                    // Inform the UI that we have a new user
                    //
                    // Have an odd case where we get re-informed that WE are in the room.
                    // So, if we are already 'joined' and we see ourselves, then don't add to list.
                    //
                    if (!Callcast.joined || (nick !== Callcast.nick))
	                    $(document).trigger('user_joined', nick);

                    //
                    // Handle our own join in the room which completes the session-join.
                    //
                    if (!Callcast.joined && nick === Callcast.nick)
                    {
                		Callcast.joined = true;
                        $(Callcast).trigger('my_join_complete', nick);
                    }
                    
                } else if (Callcast.participants[nick] && $(presence).attr('type') === 'unavailable') {

                    console.log("Caller '" + nick + "' has dropped. Destroying connection.");
                    Callcast.participants[nick].DropCall();
                    delete Callcast.participants[nick];
                    
                    $(document).trigger('user_left', nick);
                }

                if ($(presence).attr('type') !== 'error' &&
                    !Callcast.joined) {
                    // check for status 110 to see if it's our own presence
                    if ($(presence).find("status[code='110']").length > 0) {
                        // check if server changed our nick
                        if ($(presence).find("status[code='210']").length > 0) {
                            Callcast.nick = Strophe.getResourceFromJid(from);
                        }

                        // room join complete
                        $(document).trigger("joined_session");
                    }
                }
            }

            return true;
        },

    JoinSession: function(roomname, roomjid) {
    	Callcast.room = roomjid.toLowerCase();
    	Callcast.nick = Strophe.getNodeFromJid(this.connection.jid);
    	Callcast.joined = false;

    	Callcast.DropAllParticipants();

		 if (roomname == "" || roomjid == "")
		 {
			 alert("Room and RoomJid must be given to join a session.");
			 return false;
		 }
		 else if (Callcast.joined)
		 {
			 alert("Already in a session. Must leave session first.");
			 return false;
		 }
		 else
	     	 this.connection.muc.join(roomjid, Callcast.nick, Callcast.MsgHandler, Callcast.PresHandler); //, null);

         $(document).trigger('joined_session');
    	// Handle all webrtc-based chat messages within a MUC room session
    	// Also to handle all INVITATIONS to join a session which are sent directly to the jid and not within the MUC
// Already registered globally on connect        Callcast.connection.addHandler(Callcast.CallMsgHandler, Callcast.NS_CALLCAST, "message", "chat");
        return true;
    },

    LeaveSession: function() {
    	if (Callcast.room === null || Callcast.room === "")
		{
//    		alert("Not currently in a session.");
    		return;
		}
    	else
    	{
    		this.connection.muc.leave(Callcast.room, Callcast.nick, null);
    		
    		Callcast.DropAllParticipants();
    		
    		Callcast.joined = false;
    		Callcast.room = "";
            $(document).trigger('left_session');
    	}
    },

    MakeCall: function(to_whom, room, reason)
    {
    	// Ensure we plug this in as lower-case to avoid troubles when recognizing against presence information coming back.
	 room = room.toLowerCase();

	 if (!to_whom)
		 alert("'Call-To' is missing. Must give a full JID/resource to call to.");
	 else
	 {
		 Callcast.JoinSession(room, room + Callcast.AT_CALLCAST_ROOMS);
		 
		 // Now we need to wait until we've actually joined prior to sending the invite.

		 $(Callcast).bind('my_join_complete', function(event) {
			 Callcast.connection.sendIQ($iq({to: room + Callcast.AT_CALLCAST_ROOMS, type: "set"}).c("query", {xmlns: "http://jabber.org/protocol/muc#owner"}).c("x", {xmlns: "jabber:x:data", type: "submit"}),
				function() {
					 // IQ received without error.
					 Callcast.RefreshRooms();
					 
					 // Formulate an invitation to 
					 var invite = $msg({from: Callcast.connection.jid, to: to_whom, type: 'chat'})
					 				.c('x', {xmlns: Callcast.NS_CALLCAST, jid: room + Callcast.AT_CALLCAST_ROOMS, reason: reason});
					 Callcast.connection.send(invite);
	
			    	    //  Wait for "x" seconds of timeout - if no one else in the room, then we quit the room. No answer.
					 var no_answer = setTimeout(function() {
							// No one answered.
							 
							 // Our "ringing/calling" dialog should be closed if we timeout.
							 $('#calling_dialog').dialog('close');
							 alert("No Answer.");
					 }, Callcast.NOANSWER_TIMEOUT_MS);

					 // Now open up the "calling" dialog box until the timer goes off or the user hits 'hangup'
		    		$('#calling_dialog').append('<p>Ringing other party...</p>');
		    			
		    		var isAnswered = false;
		    	    $('#calling_dialog').dialog({
		    	        autoOpen: true,
		    	        draggable: false,
		    	        modal: true,
		    	        closeOnEscape: false,
		    	        open: function() {
		    	        	// If someone joins the session while we're calling, then we have an answer - hurray.
				    	    $(document).bind('user_joined', function(event) {
				    	    	// TODO really need to enusre the 'user_joined' is the person invited and not just another person joining at the same time.
				    	    	clearTimeout(no_answer);
				    	    	$(this).unbind();
				    	    	
				    	    	// This time - close the dialog but we're successful!
				    	    	isAnswered = true;
				    	    	$('#calling_dialog').dialog('close');	// Closing because we're on the call.
				    	    });
		    	        },
		    	        close: function() { 
		    	        	if (isAnswered) return;
		    	        	
	    	            	// Cancel the timer for the ringing / hangup / destroy
		    	             clearTimeout(no_answer);

		   					 Callcast.LeaveSession();
		    	        },
		    	        title: 'Calling ' + to_whom,
		    	        buttons: {
		    	            "End Call": function () {
//		    	            	alert("Hung up.");
		    	            	// TODO - drop from call - leave room and possibly destroy room if no one else is in it. Right action?
		    	            	// Currently we're just closing the dialog which will in turn have us leave the room.
		    	            	$('#calling_dialog').dialog('close');
		    	            }
		    	        }
		    	    });

			 },
			 function() {
				 // IQ error. Room config must not have worked??
				 alert("Session configuration error. Config-save possibly failed.");
			 });
			 
			 $(this).unbind(event);
		 });

	 }
	
    },
    
    handle_ping: function(iq) {
    	console.log("PING Received:");
    	console.log(iq);
    	this.connection.send($iq({to: $(iq).attr('from'), id: $(iq).attr('id'), type: 'result'}));
//    	this.connection.send($iq({from: this.connection.jid, to: $(iq).attr('from'), id: $(iq).attr('id'), type: 'result'}));
    },
    
    disconnect: function() {
    	clearInterval(this.keepAliveTimer);
    	
		this.DropAllParticipants();
		
		this.connection.sync = true;
		this.connection.flush();
		this.connection.disconnect();

    	// remove dead connection object
		this.connection = null;
		this.joined = false;
		this.room = "";
		this.nick = "";
		
		$(document).trigger('disconnected');
    },

    ///
    /// connect using this JID and password -- and optionally use this URL for the BOSH connection.
    ///
    connect: function(id, pw, url) {
    	var boshconn = "/xmpp-httpbind";
    	if (url)
    		boshconn = url;
    	
    	if (this.connection)
    		this.disconnect();
    	
    	this.connection = new Strophe.Connection(boshconn);
    	this.connection.reset();

    	this.connection.connect(id, pw, function (status) {
	         if (status === Strophe.Status.CONNECTED) {
	        	 Callcast.finalizeConnect();
	             $(document).trigger('connected');
	         } else if (status === Strophe.Status.DISCONNECTED) {
	        	 Callcast.disconnect();
	             $(document).trigger('disconnected');
	        } else if (status === Strophe.Status.AUTHFAIL) {
	        	 Callcast.disconnect();
	             $(document).trigger('disconnected');
	             alert("Authentication failed. Bad password or username.");
	         }
    	 });

    },
    
    finalizeConnect: function() {
    	this.connection.send($pres());
    	this.keepAlive();

    	// Handle inbound signaling messages
    	//Callcast.connection.addHandler(Callcast.handle_webrtc_message, null, "message", "webrtc-message");
    	this.connection.addHandler(Callcast.handle_ping, "urn:xmpp:ping", "iq", "get");
	 
		// handle all INVITATIONS to join a session which are sent directly to the jid and not within the MUC
    	this.connection.addHandler(Callcast.CallMsgHandler, Callcast.NS_CALLCAST, "message", "chat");
	    
	    // handle any inbound error stanzas (for now) via an alert message.
    	this.connection.addHandler(Callcast.onErrorStanza, null, null, 'error');

	    // Kick things off by refreshing the rooms list.
    	this.RefreshRooms();
    },
 };

//
//Grab the url arguments and process/parse them into an array.
//
//Thanks to http://jquery-howto.blogspot.com/2009/09/get-url-parameters-values-with-jquery.html for this.
//
$.extend({
getUrlVars: function(){
 var vars = [], hash;
 var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
 for(var i = 0; i < hashes.length; i++)
 {
   hash = hashes[i].split('=');
   vars.push(hash[0]);
   vars[hash[0]] = hash[1];
 }
 return vars;
},
getUrlVar: function(name){
 return $.getUrlVars()[name];
}
});

$(document).ready(function () {
	var jid = "";
	var password = "";
	
	if ($.getUrlVar('jid'))
		jid = $.getUrlVar('jid');
	if ($.getUrlVar('password'))
		password = $.getUrlVar('password');

	///
	/// Handle the login via URL which got passed or via dialog box.
	///
	if (jid != "" && password != "")
		Callcast.connect(jid, password);
	else
	{
	    $('#login_dialog').dialog({
	        autoOpen: true,
	        draggable: false,
	        modal: true,
	        title: 'Connect to XMPP',
	        buttons: {
	            "Connect": function () {
	            	Callcast.connect($('#jid').val(), $('#password').val());
	                
	                $('#password').val('');
	                $(this).dialog('close');
	            }
	        }
	    });
	}
 
	 $('#join_button').click(function () {
		 var sel =  $("#rooms option:selected");

		 if (sel !== "")
		 {
			 $('#participant-list').empty();
	    	 Callcast.JoinSession($(sel).text(), $(sel).attr('jid'));
		 }

	 });

	 $('#leave_button').click(function () {
		 if (!Callcast.joined)
			 alert("Not currently in session. Nothing to leave.");
		 else
		 {
			Callcast.LeaveSession();
		 	$('#participant-list').empty();
		 }
	 });

	 $('#get_roster_button').click(function () {
	 	Callcast.log("**NO_CODE_HERE** Getting user's roster...");
	 	
	 });
	
	 $('#subscribe_button').click(function () {
	 	Callcast.log("Subscription requested to " + $('#input').val() + "...");
	 	
	 	Callcast.connection.roster.subscribe($('#input').val());
	 });
	
	 $('#test_button').click(function() {
	 });
	 
	 $('#call_button').click(function () {
	
		 var to_whom = $('#to_whom').val();
		 var reason = $('#reason').val();
		 var room = $('#roomname').val().toLowerCase();
	
		 $('#participant-list').empty();
	
		 Callcast.MakeCall(to_whom, room, reason);
		 
	 });

});	// document ready

$(document).bind('joined_session', function () {
	 $('#leave_button').removeAttr('disabled');
	 $("#join_button").attr('disabled', 'disabled');
	 $("#rooms select").attr('disabled', 'disabled');
});

$(document).bind('left_session', function () {
	 $('#participant-list').empty();
	 $('#participant-list').append('<p>[None Yet]</p>');
	 
	 $("#leave_button").attr('disabled', 'disabled');
	 $('#join_button').removeAttr('disabled');
	 $('#rooms select').removeAttr('disabled');
});

$(document).bind('roomlist_updated', function () {
	 $('#rooms select').empty();
	 var room_added = false;
	 
	 for (k in Callcast.roomlist)
	 {
		 var optionline = '<option jid=' + k + ' room=' + Strophe.getNodeFromJid(k);
		 //
		 // If the room we're adding here is the same room we're already *IN*, then select it in the list.
		 //
		 if (Callcast.room === k)
			 optionline += ' selected=selected';
		 
		 optionline += '>' + Callcast.roomlist[k] + '</option>';
	
		 $('#rooms select').append(optionline);
		 room_added = true;
	 }
	 
	 if (!room_added)
		 $('#rooms select').append("<option>[None Yet]</option>");
});

$(document).bind('user_joined', function (ev, nick) {
	$('#participant-list').append('<li>' + nick + '</li>');
});

$(document).bind('user_left', function (ev, nick) {
    // remove from participants list
    $('#participant-list li').each(function () {
        if (nick === $(this).text()) {
            $(this).remove();
        }
    });
});

$(document).bind('connected', function () {

	$('.button').removeAttr('disabled');
	$('#rooms select').removeAttr('disabled');
	
    Callcast.connection.xmlInput = function(data) {
        console.log("XML-IN:", $(data).children()[0]);
    };
    
    Callcast.connection.xmlOutput = function(data) {
        console.log("XML-OUT:", $(data).children()[0]);
    };

	// Set "who am i" at the top
	$("#myjid").text("My JID: " + Callcast.connection.jid);
	
});

$(document).bind('disconnected', function () {
 Callcast.log("Connection terminated.");

 $("#rooms select").empty();
 $("#rooms select").append("<li>[None Yet]</li>");
 $("#participant-list").empty();
 
 $("#leave_button").attr('disabled', 'disabled');
 $('#join_button').removeAttr('disabled');
 $('#rooms select').removeAttr('disabled');
 $('#myjid').html("<b>[Disconnected]</b>");

});

$(window).unload(function() {
	  Callcast.disconnect();
	});
