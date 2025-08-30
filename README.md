# Proto仓库

一个用于管理多项目RPC接口定义的通用Proto仓库。该仓库包含了多个项目的gRPC服务定义，支持通过git submodule方式集成到其他项目中。

## 📁 目录结构

```
protos/
├── common/                 # 🔄 通用模块（所有项目共享）
│   ├── base.proto          # 基础请求/响应结构、状态码
│   ├── types.proto         # 通用数据类型（过滤、排序等）
│   ├── error.proto         # 业务错误码定义
│   ├── pagination.proto    # 分页相关定义
│   └── auth.proto          # 认证相关定义
├── task/                   # 📋 任务管理项目
│   ├── v1/                 # 版本化API
│   │   ├── model.proto     # 任务数据模型
│   │   └── service.proto   # 任务服务定义
│   └── task.proto          # 项目入口文件
├── flow/                   # 🔄 工作流项目
│   ├── v1/                 # 版本化API
│   │   ├── model.proto     # 工作流数据模型
│   │   └── service.proto   # 工作流服务定义
│   └── flow.proto          # 项目入口文件
├── generate.sh             # 🔨 Linux/macOS代码生成脚本
├── generate.bat            # 🔨 Windows代码生成脚本
├── Makefile               # 🔨 Make构建文件
├── proto.toml             # ⚙️ Proto配置文件
└── README.md              # 📖 项目文档
```

## 🚀 快速开始

### 环境要求

- **protoc**: Protocol Buffers编译器 (≥ v3.10)
- **protoc-gen-go**: Go语言protobuf插件 (≥ v1.27)
- **protoc-gen-go-grpc**: Go语言gRPC插件 (≥ v1.2)

### 安装依赖

#### macOS
```bash
# 安装protoc
brew install protobuf

# 安装Go插件
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

#### Ubuntu/Debian
```bash
# 安装protoc
sudo apt-get install protobuf-compiler

# 安装Go插件
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

#### Windows
1. 从 [Protobuf Releases](https://github.com/protocolbuffers/protobuf/releases) 下载并安装protoc
2. 安装Go插件：
```cmd
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

### 代码生成

#### 方式1: 使用脚本（推荐）

**Linux/macOS:**
```bash
# 生成所有项目
./generate.sh

# 生成指定项目
./generate.sh task
./generate.sh task flow

# 清理生成的文件
./generate.sh --clean
```

**Windows:**
```cmd
# 生成所有项目
generate.bat

# 生成指定项目
generate.bat task
generate.bat task flow

# 清理生成的文件
generate.bat --clean
```

#### 方式2: 使用Makefile

```bash
# 查看帮助
make help

# 安装依赖
make install-deps

# 生成所有代码
make generate

# 生成指定项目
make generate-task
make generate-flow

# 清理生成文件
make clean
```

#### 方式3: 手动执行

```bash
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       --proto_path=. \
       *.proto
```

## 📦 在其他项目中使用

### 作为Git Submodule

1. **添加submodule**：
```bash
cd your-project
git submodule add https://github.com/your-org/protos.git proto
```

2. **初始化和更新**：
```bash
git submodule update --init --recursive
```

3. **生成代码**：
```bash
cd proto
./generate.sh
```

4. **在Go项目中使用**：
```go
import (
    "your-project/proto/common"
    "your-project/proto/task/v1"
    "your-project/proto/flow/v1"
)
```

### 示例代码

```go
// 创建任务客户端
conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
if err != nil {
    log.Fatal(err)
}
defer conn.Close()

client := taskv1.NewTaskServiceClient(conn)

// 创建任务
resp, err := client.CreateTask(context.Background(), &taskv1.CreateTaskRequest{
    Base: &common.BaseRequest{
        RequestId: "req-123",
        Timestamp: timestamppb.Now(),
    },
    Type:     "data-processing",
    Priority: 5,
})
```

## 🏗️ 模块说明

### Common模块
`common/` 包含所有项目共享的通用定义：
- **base.proto**: 基础请求/响应结构、状态码、认证信息
- **types.proto**: 通用数据类型（过滤条件、排序条件等）
- **error.proto**: 业务错误码和错误详情
- **pagination.proto**: 分页请求和响应（支持页码分页和游标分页）
- **auth.proto**: 权限检查、API密钥

### Task模块（任务管理）
任务管理系统的完整gRPC服务定义：
- 任务创建、查询、更新、列表、取消、暂停、恢复、删除
- 支持优先级、重试、回调
- 完整的任务状态管理（10个状态覆盖完整生命周期）

### Flow模块（工作流）
工作流引擎的gRPC服务定义：
- 工作流定义管理
- 工作流实例执行
- 工作流步骤控制
- 支持暂停、恢复、取消