#!/bin/bash

# Initialize args array
ARGS=()

# Map Environment Variables to CLI Flags
[[ -n "$CH_LOG_LEVEL" ]]      && ARGS+=(--logLevel "$CH_LOG_LEVEL")
[[ -n "$CH_NAME" ]]           && ARGS+=(--name "$CH_NAME")
[[ -n "$CH_PORT" ]]           && ARGS+=(--port "$CH_PORT")
[[ -n "$CH_INSTANCE_COUNT" ]] && ARGS+=(--instanceCount "$CH_INSTANCE_COUNT")
[[ -n "$CH_PORTRANGE" ]]      && ARGS+=(--portRange "$CH_PORTRANGE")
[[ -n "$CH_ADDRESS" ]]        && ARGS+=(--address "$CH_ADDRESS")
[[ -n "$CH_PASSWORD" ]]       && ARGS+=(--password "$CH_PASSWORD")

# Boolean/Flag checks
[[ "$CH_NO_PASS" == "true" ]]     && ARGS+=(--nopass)
[[ "$CH_ALLOW_RESET" == "true" ]] && ARGS+=(--allowreset)
[[ "$CH_USE_DEFAULTS" == "true" ]] && ARGS+=(--defaults)

# Execute the server
exec ./Server "${ARGS[@]}"