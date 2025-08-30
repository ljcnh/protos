@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

echo [INFO] Starting proto file validation...

set "error_count=0"

REM Validation function (implemented via labels)
goto :validate_all

:validate_proto
set "proto_file=%~1"
echo [INFO] Validating: !proto_file!

REM Check if file exists
if not exist "!proto_file!" (
    echo [ERROR] File not found: !proto_file!
    set /a error_count+=1
    goto :eof
)

REM Check syntax
where protoc >nul 2>&1
if !errorlevel! equ 0 (
    protoc --proto_path=. --descriptor_set_out=nul "!proto_file!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [PASS] Syntax OK: !proto_file!
    ) else (
        echo [FAIL] Syntax Error: !proto_file!
        protoc --proto_path=. --descriptor_set_out=nul "!proto_file!"
        set /a error_count+=1
    )
) else (
    echo [WARN] protoc not installed, skipping syntax check: !proto_file!
)

goto :eof

:validate_all
REM Validate common module
echo.
echo ============ Validating common module ============
call :validate_proto "common\base.proto"
call :validate_proto "common\types.proto"
call :validate_proto "common\error.proto"
call :validate_proto "common\pagination.proto"
call :validate_proto "common\auth.proto"

REM Validate task module
echo.
echo ============ Validating task module ============
call :validate_proto "task\v1\model.proto"
call :validate_proto "task\v1\service.proto"
call :validate_proto "task\task.proto"

REM Validate flow module
echo.
echo ============ Validating flow module ============
call :validate_proto "flow\v1\model.proto"
call :validate_proto "flow\v1\service.proto"
call :validate_proto "flow\flow.proto"

echo.
echo ============ Validation Results ============
if !error_count! equ 0 (
    echo [SUCCESS] All proto files validation passed!
    exit /b 0
) else (
    echo [ERROR] Found !error_count! errors
    exit /b 1
)