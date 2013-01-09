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

var settings = require('./settings');   // Our GoCast settings JS
if (!settings) {
    settings = {};
}
if (!settings.roommanager) {
    settings.roommanager = {};
}

var sys = require('util');
var evt = require('events');

var eventManager = new evt.EventEmitter();
var argv = process.argv;

'use strict';