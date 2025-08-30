#!/bin/bash

# 生成所有proto文件的Go代码
# 使用方法:
#   ./generate.sh                    # 生成所有项目
#   ./generate.sh task              # 只生成task项目
#   ./generate.sh task flow         # 生成指定的多个项目

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查protoc是否安装
check_protoc() {
    if ! command -v protoc &> /dev/null; then
        log_error "protoc 未安装，请先安装 Protocol Buffers 编译器"
        log_info "安装方法:"
        log_info "  macOS: brew install protobuf"
        log_info "  Ubuntu: sudo apt-get install protobuf-compiler"
        log_info "  Windows: 下载 https://github.com/protocolbuffers/protobuf/releases"
        exit 1
    fi
}

# 检查go插件是否安装
check_go_plugins() {
    if ! command -v protoc-gen-go &> /dev/null; then
        log_error "protoc-gen-go 未安装"
        log_info "安装方法: go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
        exit 1
    fi

    if ! command -v protoc-gen-go-grpc &> /dev/null; then
        log_error "protoc-gen-go-grpc 未安装"
        log_info "安装方法: go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
        exit 1
    fi
}

# 生成单个proto文件
generate_proto() {
    local proto_file=$1
    local output_dir=${2:-"."}
    
    log_info "生成 $proto_file"
    
    protoc \
        --go_out="$output_dir" \
        --go_opt=paths=source_relative \
        --go-grpc_out="$output_dir" \
        --go-grpc_opt=paths=source_relative \
        --proto_path=. \
        "$proto_file"
}

# 生成项目所有proto文件
generate_project() {
    local project=$1
    local project_dir="$project"
    
    if [ ! -d "$project_dir" ]; then
        log_warn "项目目录 $project_dir 不存在，跳过"
        return
    fi
    
    log_info "生成项目: $project"
    
    # 查找所有proto文件
    local proto_files=$(find "$project_dir" -name "*.proto" | sort)
    
    if [ -z "$proto_files" ]; then
        log_warn "项目 $project 中没有找到proto文件"
        return
    fi
    
    # 生成每个proto文件
    for proto_file in $proto_files; do
        generate_proto "$proto_file"
    done
    
    log_info "项目 $project 生成完成"
}

# 生成通用模块
generate_common() {
    log_info "生成通用模块"
    
    # 生成common模块
    if [ -d "common" ]; then
        local common_files=$(find common -name "*.proto")
        for proto_file in $common_files; do
            generate_proto "$proto_file"
        done
    fi
}

# 清理生成的文件
clean() {
    log_info "清理生成的文件"
    find . -name "*.pb.go" -delete
    find . -name "*_grpc.pb.go" -delete
    log_info "清理完成"
}

# 显示帮助信息
show_help() {
    echo "Proto代码生成脚本"
    echo ""
    echo "用法:"
    echo "  $0 [options] [projects...]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -c, --clean    清理生成的文件"
    echo "  -v, --verbose  详细输出"
    echo ""
    echo "示例:"
    echo "  $0                    # 生成所有项目"
    echo "  $0 task              # 只生成task项目"
    echo "  $0 task flow         # 生成task和flow项目"
    echo "  $0 --clean           # 清理生成的文件"
}

# 主函数
main() {
    local projects=()
    local clean_mode=false
    local verbose=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--clean)
                clean_mode=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                set -x
                shift
                ;;
            -*)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                projects+=("$1")
                shift
                ;;
        esac
    done
    
    # 清理模式
    if [ "$clean_mode" = true ]; then
        clean
        exit 0
    fi
    
    # 检查依赖
    check_protoc
    check_go_plugins
    
    log_info "开始生成proto代码"
    
    # 首先生成通用模块
    generate_common
    
    # 如果没有指定项目，生成所有项目
    if [ ${#projects[@]} -eq 0 ]; then
        # 自动发现所有项目目录
        for dir in */; do
            dir=${dir%/}  # 移除末尾的斜杠
            # 跳过通用模块和非项目目录
            if [[ "$dir" != "common" && -d "$dir" ]]; then
                # 检查是否包含proto文件
                if find "$dir" -name "*.proto" | grep -q .; then
                    projects+=("$dir")
                fi
            fi
        done
    fi
    
    # 生成指定的项目
    for project in "${projects[@]}"; do
        generate_project "$project"
    done
    
    log_info "所有proto代码生成完成"
}

# 运行主函数
main "$@"