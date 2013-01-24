/**
 * accounts_service - A port-listener which takes web-based account commands
 *
 * The web server will give us certain action-requests as URLs here:
 * - New account
 * - Validate account
 * - Delete account
 * - Update Password to account
 *
 **/

/*jslint node: true, nomen: true, white: true */
/*global test, exec */

var settings;

try {
    settings = require('./settings');   // Our GoCast settings JS
} catch(e) {
    settings = require('../../settings');   // Look relative ... for developers on desktops.
}

if (!settings) {
    settings = {};
}
if (!settings.accounts) {
    settings.accounts = {};
}

var sys = require('util');
var evt = require('events');

var gcutil = require('./gcutil_node');

var eventManager = new evt.EventEmitter();
var argv = process.argv;

var api = require('./accounts_api');

'use strict';

var express = require('express');
var app = express();

// -------------- INCLUDED EXPRESS LIBRARIES -----------------

app.use(express.bodyParser());

// -------------- ACCT SERVICE REQUEST HANDLERS --------------

app.post('/register', function(req, res) {
    var firstRoomName = req.body.desired_roomname;

    if (req.body && req.body.baseurl && req.body.email && req.body.password && req.body.name) {
//        gcutil.log('accounts_service [/register][info]: FormData = ', req.body);
        api.NewAccount(req.body.baseurl, req.body.email, req.body.password, req.body.name, firstRoomName, function() {
            res.send('{"result": "success"}');
        }, function(err) {
            gcutil.log('accounts_service [/register][error]: ', err);
            if ('apiNewAccount: Failed - account already in use.' === err) {
                res.send('{"result": "inuse"}');
            } else {
                res.send('{"result": "error"}');
            }
        });
    }
    else {
        gcutil.log('accounts_service [/register][error]: FormData problem in req.body: ', req.body);

        if (!req.body.name) {
            res.send('{"result": "no name"}');
        }
        else if (!req.body.email) {
            res.send('{"result": "no email"}');
        }
        else if (!req.body.password) {
            res.send('{"result": "no password"}');
        }
        else {
            res.send('{"result": "error"}');
        }
    }
});

app.post('/createroom', function(req, res) {
    var roomName = req.body.desired_roomname;

    if (req.body && req.body.email && roomName) {
        gcutil.log('accounts_service [/createroom][info]: FormData = ', req.body);
        api.NewRoom(req.body.email, roomName, function() {
            res.send('{"result": "success"}');
        }, function(err) {
            if (err && err.code === 'ConditionalCheckFailedException') {
                // This is just a 'room name already exists' error. Let it go.
                res.send('{"result": "success"}');
            }
            else {
                gcutil.log('accounts_service [/createroom][error]: ', err);
                res.send('{"result": "error"}');
            }
        });
    }
    else {
        gcutil.log('accounts_service [/createroom][error]: FormData problem in req.body: ', req.body);

        if (!req.body.email) {
            res.send('{"result": "no email"}');
        }
        else if (!req.body.desired_roomname) {
            res.send('{"result": "no roomname"}');
        }
        else {
            res.send('{"result": "error"}');
        }
    }
});

app.post('/listrooms', function(req, res) {

    if (req.body && req.body.email) {
        gcutil.log('accounts_service [/listrooms][info]: FormData = ', req.body);
        api.ListRooms(req.body.email, function(data) {
            res.send('{"result": "success", "data": ' + JSON.stringify(data) + '}');
        }, function(err) {
            gcutil.log('accounts_service [/listrooms][error]: ', err);
            res.send('{"result": "error"}');
        });
    }
    else {
        gcutil.log('accounts_service [/listrooms][error]: FormData problem in req.body: ', req.body);

        if (!req.body.email) {
            res.send('{"result": "no email"}');
        }
        else {
            res.send('{"result": "error"}');
        }
    }
});

app.post('/activate', function(req, res) {
    if (req.body && req.body.email && req.body.activation_code) {
//        gcutil.log('accounts_service [/activate][info]: FormData = ', req.body);
        api.ValidateAccount(req.body.email, req.body.activation_code, function() {
            res.send('{"result": "success"}');
        }, function(err) {
            gcutil.log('accounts_service [/activate][error]: ', err);
            if (('apiValidateAccount: Incorrect activation code for ' + req.body.email) === err) {
                res.send('{"result": "incorrect"}');
            } else if (('apiValidateAccount: Bad activation code. No account found for: ' + req.body.email) === err) {
                res.send('{"result": "noaccount"}');
            } else if ('apiValidateAccount: Activation already used or expired.' === err ||
                       'apiValidateAccount: Activation already used or expired - and enable failed.' === err) {
                res.send('{"result": "usedorexpired"}');
            } else {
                res.send('{"result": "error"}');
            }
        });
    }
    else {
        gcutil.log('accounts_service [/activate][error]: FormData problem in req.body: ', req.body);

        if (!req.body.email) {
            res.send('{"result": "no email"}');
        }
        else if (!req.body.activation_code) {
            res.send('{"result": "no activationcode"}');
        }
        else {
            res.send('{"result": "error"}');
        }
    }
});

app.post('/changepwd', function(req, res) {
    if (req.body && req.body.email && req.body.new_password) {
        gcutil.log('accounts_service [/changepwd][info]: FormData = ', req.body);
        api.ChangePassword(req.body.email, req.body.new_password, function() {
            res.send('{"result": "success"}');
        }, function(err) {
            gcutil.log('accounts_service [/changepwd][error]: ', err);
            res.send('{"result": "error"}');
        });
    }
    else {
        gcutil.log('accounts_service [/changepwd][error]: FormData problem in req.body: ', req.body);

        if (!req.body.email) {
            res.send('{"result": "no email"}');
        }
        else if (!req.body.new_password) {
            res.send('{"result": "no password"}');
        }
        else {
            res.send('{"result": "error"}');
        }
    }
});

app.post('/visitorseen', function(req, res) {
    if (req.body && req.body.email) {
        gcutil.log('accounts_service [/visitorseen][info]: FormData = ', req.body);
        api.VisitorSeen(req.body.email, req.body.nickname, function() {
            res.send('{"result": "success"}');
        }, function(err) {
            gcutil.log('accounts_service [/visitorseen][error]: ', err);
            res.send('{"result": "error"}');
        });
    }
    else {
        gcutil.log('accounts_service [/createroom][error]: FormData problem in req.body: ', req.body);

        if (!req.body.email) {
            res.send('{"result": "no email"}');
        }
        else {
            res.send('{"result": "error"}');
        }
    }
});

app.listen(settings.accounts.serviceport || 8083);
