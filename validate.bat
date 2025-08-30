@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

echo [INFO] 开始验证proto文件...

set "error_count=0"

REM 验证函数（通过标签实现）
goto :validate_all

:validate_proto
set "proto_file=%~1"
echo [INFO] 验证: !proto_file!

REM 检查文件是否存在
if not exist "!proto_file!" (
    echo [ERROR] 文件不存在: !proto_file!
    set /a error_count+=1
    goto :eof
)

REM 检查语法
where protoc >nul 2>&1
if !errorlevel! equ 0 (
    protoc --proto_path=. --descriptor_set_out=nul "!proto_file!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [PASS] 语法正确: !proto_file!
    ) else (
        echo [FAIL] 语法错误: !proto_file!
        protoc --proto_path=. --descriptor_set_out=nul "!proto_file!"
        set /a error_count+=1
    )
) else (
    echo [WARN] protoc未安装，跳过语法检查: !proto_file!
)

goto :eof

:validate_all
REM 验证common模块
echo.
echo ============ 验证common模块 ============
call :validate_proto "common\base.proto"
call :validate_proto "common\types.proto"
call :validate_proto "common\error.proto"
call :validate_proto "common\pagination.proto"
call :validate_proto "common\auth.proto"

REM 验证task模块
echo.
echo ============ 验证task模块 ============
call :validate_proto "task\v1\model.proto"
call :validate_proto "task\v1\service.proto"
call :validate_proto "task\task.proto"

REM 验证flow模块
echo.
echo ============ 验证flow模块 ============
call :validate_proto "flow\v1\model.proto"
call :validate_proto "flow\v1\service.proto"
call :validate_proto "flow\flow.proto"

echo.
echo ============ 验证结果 ============
if !error_count! equ 0 (
    echo [SUCCESS] 所有proto文件验证通过！
    exit /b 0
) else (
    echo [ERROR] 发现 !error_count! 个错误
    exit /b 1
)