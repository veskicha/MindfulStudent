#!/bin/bash

ENDPOINT="http://127.0.0.1:54321/auth/v1/token"
ANON_KEY=""

if [[ $# -lt 2 ]]; then
    echo "Error: need to specify email + password!"
    exit 1
fi

EMAIL=$1
PASSWORD=$2

data="{\"email\": \"${EMAIL}\", \"password\": \"${PASSWORD}\"}"
resp=$(curl -s "$ENDPOINT?grant_type=password" \
    -H "apikey: $ANON_KEY" \
    -H "Content-Type: application/json" \
    -d "$data")

echo $resp | jq -r '.access_token'
