# Proto代码生成Makefile

.PHONY: help generate clean install-deps check-deps generate-all generate-common generate-task generate-flow

# 默认目标
help:
	@echo "Proto代码生成工具"
	@echo ""
	@echo "可用目标:"
	@echo "  generate        - 生成所有proto代码"
	@echo "  generate-all    - 生成所有proto代码（同generate）"
	@echo "  generate-common - 只生成通用模块(common)"
	@echo "  generate-task   - 只生成task项目"
	@echo "  generate-flow   - 只生成flow项目"
	@echo "  clean          - 清理生成的文件"
	@echo "  install-deps   - 安装依赖工具"
	@echo "  check-deps     - 检查依赖工具"
	@echo "  help           - 显示此帮助信息"

# 检查依赖
check-deps:
	@echo "检查依赖工具..."
	@command -v protoc >/dev/null 2>&1 || { echo "错误: protoc 未安装"; exit 1; }
	@command -v protoc-gen-go >/dev/null 2>&1 || { echo "错误: protoc-gen-go 未安装"; exit 1; }
	@command -v protoc-gen-go-grpc >/dev/null 2>&1 || { echo "错误: protoc-gen-go-grpc 未安装"; exit 1; }
	@echo "所有依赖工具已安装"

# 安装依赖工具
install-deps:
	@echo "安装Go插件..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	@echo "Go插件安装完成"
	@echo "请确保protoc已安装:"
	@echo "  macOS: brew install protobuf"
	@echo "  Ubuntu: sudo apt-get install protobuf-compiler"
	@echo "  Windows: 下载 https://github.com/protocolbuffers/protobuf/releases"

# 清理生成的文件
clean:
	@echo "清理生成的文件..."
	@find . -name "*.pb.go" -delete 2>/dev/null || true
	@find . -name "*_grpc.pb.go" -delete 2>/dev/null || true
	@echo "清理完成"

# 生成通用模块
generate-common: check-deps
	@echo "生成通用模块..."
	@find common -name "*.proto" -exec protoc \
		--go_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_out=. \
		--go-grpc_opt=paths=source_relative \
		--proto_path=. \
		{} \; 2>/dev/null || true
	@echo "通用模块生成完成"

# 生成task项目
generate-task: check-deps generate-common
	@echo "生成task项目..."
	@find task -name "*.proto" -exec protoc \
		--go_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_out=. \
		--go-grpc_opt=paths=source_relative \
		--proto_path=. \
		{} \;
	@echo "task项目生成完成"

# 生成flow项目
generate-flow: check-deps generate-common
	@echo "生成flow项目..."
	@find flow -name "*.proto" -exec protoc \
		--go_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_out=. \
		--go-grpc_opt=paths=source_relative \
		--proto_path=. \
		{} \;
	@echo "flow项目生成完成"

# 生成所有项目
generate: generate-all

generate-all: check-deps generate-common generate-task generate-flow
	@echo "所有proto代码生成完成"

# 快速生成（跳过依赖检查）
quick-generate:
	@echo "快速生成所有proto代码..."
	@find . -name "*.proto" -exec protoc \
		--go_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_out=. \
		--go-grpc_opt=paths=source_relative \
		--proto_path=. \
		{} \;
	@echo "快速生成完成"