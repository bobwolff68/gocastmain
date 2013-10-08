function ManjeshClient(doc, path, params, E) {
	var uname = params.split('_')[0] || prompt('Screen name: '), room = null,
		roomid = params.split('_')[1] || '',
		localstream = E.Stream({audio: true, video: true, attributes: {name: uname}}),

		requestToken = function(uname, role, roomid, onresponse)
		{
			var req = new XMLHttpRequest(),
				body = JSON.stringify({'uname': uname, 'role': role, 'roomid': roomid});

			req.onreadystatechange = function() {
				if (4 === req.readyState)
				{
					onresponse(JSON.parse(req.responseText));
				}
			}

			console.log('requestToken(): Request body: ' + body);
			req.open('POST', 'http://relay.gocast.it/relaymgr/reqroomtoken/', true);
			req.setRequestHeader('Content-Type', 'application/json');
			req.send(body);
		},
		showStream = function(stream, type, id) {
			if ('remote' === type) {
				var div = doc.createElement('div');
				div.setAttribute('style', 'width: 320px; height: 240px;');
				div.setAttribute('id', type + (id||''));
				doc.body.appendChild(div);
				
				var v = doc.createElement('video');
				v.src = webkitURL.createObjectURL(stream.stream);
				v.autoplay = 'autoplay';
				v.width = 1;
				v.height = 1;
				div.appendChild(v);

				var entry = doc.querySelector('h4.participant').cloneNode();
				entry.id = stream.getAttributes().name;
				entry.innerHTML = entry.id;
				entry.style.display = '';
				doc.querySelector('div.screen').appendChild(entry);
			}
		}, stopShowingStream = function(stream, type, id) {
			doc.body.removeChild(doc.getElementById(type + (id||'')));
			doc.querySelector('div.screen').removeChild(doc.getElementById(stream.getAttributes().name));
		};

	localstream.addEventListener('access-accepted', function() {
		console.log('Local Stream: ', localstream);
		// After obtaining permission to access local media from the browser,
		// request a token for your desired room or a new room
		console.log('Requesting token to enter room...');
		requestToken(uname, 'role', roomid, function(response)
		{
			var token = response.token || '';
			if ('' === token) {
				console.log('requestToken(): Error: ' + JSON.stringify(response));
			} else {
				console.log('requestToken(): Token: ' + token);
				if ('' === roomid)
				{
					roomid = response.roomid;

					if (isChrome == 0)
					{
				        cordova.exec(function(winParam) {}, function(error) {}, "GCICallcast", "setRoomID", [ roomid.toString() ]);
					}

					history.replaceState(null, null, path + '?' + uname + '_' + roomid);
				}
				// After obtaining the token, use it to create the room object
				// through which you can connect to the room, publish your
				// local stream and subscribe remote streams
				room = E.Room({'token': token});

				room.addEventListener('room-connected', function(e) {
					// After connecting to the room, publish your stream
					// and subscribe to all available remote streams
					console.log('room.connect(): Successful, publishing local stream: ', localstream);
					room.publish(localstream);
					for (var i in e.streams) {
						if (e.streams.hasOwnProperty(i) &&
							localstream.getID() !== e.streams[i].getID()) {
							console.log('room.connect(): Subscribing to remote stream: ',
										e.streams[i].getID());
							room.subscribe(e.streams[i]);
						}
					}
				});

				room.addEventListener('stream-subscribed', function(e) {
					// After subscribing to a stream, show it
					console.log('room.subscribed(): Subscribed to remote stream: ',
								e.stream.getAttributes().name);
					showStream(e.stream, 'remote', e.stream.getID());
				});

				room.addEventListener('stream-added', function(e) {
					// After a new stream has been added,
					// if it's remote, subscribe to it
					if (localstream.getID() !== e.stream.getID()) {
						console.log('room.added(): Subscribing to added remote stream: ',
									e.stream.getAttributes().name);
						room.subscribe(e.stream);
					} else {
						localstream.stream.getVideoTracks()[0].enabled = false;
						console.log('ENABLED: ', localstream.stream.getVideoTracks()[0].enabled);
					}
				});

				room.addEventListener('stream-removed', function(e) {
					// After a remote stream has been removed,
					// stop showing it
					console.log('room.removed(): Unsubscribing from remote stream: ',
								e.stream.getID());
					stopShowingStream(e.stream, 'remote', e.stream.getID());
				});

				// Show local stream
				console.log('Displaying local stream: ', localstream.getID());
				showStream(localstream, 'local', localstream.getID());
				// Connect to the room
				console.log('Connecting to room: ', roomid);
				room.connect();
			}
		});
	});

	// Ask for permission from the browser to access local media
	console.log('Initializing local media...');
	localstream.init();

}