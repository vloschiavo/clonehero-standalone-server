@echo off
setlocal enabledelayedexpansion

:: Build arguments array from environment variables

set ARGS=

:: Logging level
if defined CH_LOG_LEVEL (
    set ARGS=!ARGS! --logLevel %CH_LOG_LEVEL%
)

:: Server name
if defined CH_NAME (
    set ARGS=!ARGS! --name "%CH_NAME%"
)

:: Port
if defined CH_PORT (
    set ARGS=!ARGS! --port %CH_PORT%
)

:: Instance count
if defined CH_INSTANCE_COUNT (
    set ARGS=!ARGS! --instanceCount %CH_INSTANCE_COUNT%
)

:: Port range
if defined CH_PORTRANGE (
    set ARGS=!ARGS! --portRange %CH_PORTRANGE%
)

:: Binding address
if defined CH_ADDRESS (
    set ARGS=!ARGS! --address %CH_ADDRESS%
)

:: Password (only if CH_NO_PASS is not true)
if /i "%CH_NO_PASS%"=="true" (
    set ARGS=!ARGS! --nopass
) else (
    if defined CH_PASSWORD (
        set ARGS=!ARGS! --password "%CH_PASSWORD%"
    )
)

:: Allow reset when server is empty
if /i "%CH_ALLOW_RESET%"=="true" (
    set ARGS=!ARGS! --allowreset
)

:: Skip address/port setup and use defaults
if /i "%CH_USE_DEFAULTS%"=="true" (
    set ARGS=!ARGS! --defaults
)

:: Execute the server
echo Starting Clone Hero Standalone Server...
echo Args:%ARGS%

Server.exe !ARGS!
