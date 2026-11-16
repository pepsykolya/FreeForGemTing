@echo off
rem FFGT -- see LICENSE
setlocal EnableExtensions
title FFGT - Daler (DLR) on crypto-connection.net

rem ================================================================
rem  FFGT for Windows - EDIT THESE VALUES
rem ================================================================
rem Your Ting account (64 hex characters; Ting ID app or `ting wallet create`). REPLACE it:
set "ACCOUNT=YOUR_TING_ACCOUNT"
rem Pool HOST:PORT (a comma list = failover, the first is the primary), or your ffgt-gate HOST:PORT
set "POOL=crypto-connection.net:4073"
rem Worker (rig) name
set "WORKER=%COMPUTERNAME%"
rem Password: x for a pool, the rig's password for an ffgt-gate
set "PASSWORD=x"
rem GPUs: empty = all, or a list like 0,1
set "DEVICES="
rem Extra options, e.g. --lock-cclock 1500 --auto-uv  (clock locks and the undervolt need "Run as administrator")
set "EXTRA="
rem ================================================================

cd /d "%~dp0"
if "%ACCOUNT%"=="YOUR_TING_ACCOUNT" (
  echo Edit start.bat first: put your Ting account in ACCOUNT.
  pause
  exit /b 1
)
set "DEV="
if not "%DEVICES%"=="" set "DEV=--devices %DEVICES%"
:loop
ffgt.exe --pool %POOL% --wallet %ACCOUNT%.%WORKER% --password %PASSWORD% %DEV% %EXTRA%
echo The miner stopped (code %errorlevel%); restarting in 15 s. Close this window to stop.
timeout /t 15 /nobreak >nul
goto loop
