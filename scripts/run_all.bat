@echo off
chcp 65001 >nul
setlocal

REM =================================================================================
REM KỊCH BẢN CHẠY NHANH TOÀN BỘ FILE SQL TRÊN WINDOWS (GỌI POWERSHELL RUNNER)
REM Cách dùng:
REM   scripts\run_all.bat
REM   scripts\run_all.bat "localhost\SQLEXPRESS"
REM =================================================================================

set "SERVER_INSTANCE=%~1"
if "%SERVER_INSTANCE%"=="" set "SERVER_INSTANCE=localhost\SQLEXPRESS"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_all.ps1" -ServerInstance "%SERVER_INSTANCE%"
exit /b %ERRORLEVEL%
