@echo off
setlocal enabledelayedexpansion

REM 生成所有proto文件的Go代码
REM 使用方法:
REM   generate.bat                    # 生成所有项目
REM   generate.bat task              # 只生成task项目
REM   generate.bat task flow         # 生成指定的多个项目

set "projects="
set "clean_mode=false"

REM 解析参数
:parse_args
if "%~1"=="" goto :check_deps
if "%~1"=="--clean" (
    set "clean_mode=true"
    shift
    goto :parse_args
)
if "%~1"=="--help" (
    goto :show_help
)
if "%~1"=="-h" (
    goto :show_help
)
set "projects=!projects! %~1"
shift
goto :parse_args

:show_help
echo Proto代码生成脚本
echo.
echo 用法:
echo   %~nx0 [options] [projects...]
echo.
echo 选项:
echo   -h, --help     显示帮助信息
echo   --clean        清理生成的文件
echo.
echo 示例:
echo   %~nx0                    # 生成所有项目
echo   %~nx0 task              # 只生成task项目
echo   %~nx0 task flow         # 生成task和flow项目
echo   %~nx0 --clean           # 清理生成的文件
goto :eof

:check_deps
REM 检查protoc是否安装
where protoc >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] protoc 未安装，请先安装 Protocol Buffers 编译器
    echo [INFO] 下载地址: https://github.com/protocolbuffers/protobuf/releases
    exit /b 1
)

REM 检查go插件是否安装
where protoc-gen-go >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] protoc-gen-go 未安装
    echo [INFO] 安装方法: go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    exit /b 1
)

where protoc-gen-go-grpc >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] protoc-gen-go-grpc 未安装
    echo [INFO] 安装方法: go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    exit /b 1
)

REM 清理模式
if "%clean_mode%"=="true" (
    echo [INFO] 清理生成的文件
    for /r %%f in (*.pb.go) do del "%%f"
    for /r %%f in (*_grpc.pb.go) do del "%%f"
    echo [INFO] 清理完成
    goto :eof
)

echo [INFO] 开始生成proto代码

REM 生成通用模块
echo [INFO] 生成通用模块

REM 生成common模块
if exist "common" (
    for /r common %%f in (*.proto) do (
        echo [INFO] 生成 %%f
        protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative --proto_path=. "%%f"
    )
)

REM 如果没有指定项目，生成所有项目
if "%projects%"=="" (
    for /d %%d in (*) do (
        if not "%%d"=="common" (
            if exist "%%d\*.proto" (
                set "projects=!projects! %%d"
            ) else (
                for /r "%%d" %%f in (*.proto) do (
                    set "projects=!projects! %%d"
                    goto :next_dir
                )
                :next_dir
            )
        )
    )
)

REM 生成指定的项目
for %%p in (%projects%) do (
    if exist "%%p" (
        echo [INFO] 生成项目: %%p
        for /r "%%p" %%f in (*.proto) do (
            echo [INFO] 生成 %%f
            protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative --proto_path=. "%%f"
        )
        echo [INFO] 项目 %%p 生成完成
    ) else (
        echo [WARN] 项目目录 %%p 不存在，跳过
    )
)

echo [INFO] 所有proto代码生成完成