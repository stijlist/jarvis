#!/bin/bash

message=$1
curl https://api.zulip.com/v1/messages \
    -u $JARVIS_EMAIL_ADDRESS:$JARVIS_API_KEY \
    -d "type=stream" \
    -d "to=test-bot" \
    -d "subject=jarvis" \
    -d "content=$message"
