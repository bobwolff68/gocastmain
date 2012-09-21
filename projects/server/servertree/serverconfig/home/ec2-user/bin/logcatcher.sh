#!/bin/sh
echo Killing any existing log catcher
echo Current server PID is `pgrep -f "logcatcher.js --debugcommands"`
pkill -f "logcatcher.js --debugcommands"
echo Starting server...
node ~/logcatcher.js --debugcommands >>~/logcatcher.log 2>&1 &
echo New server PID is `pgrep -f "logcatcher.js --debugcommands"`
echo Server started.