
- 该仓库为 rpc proto 文件，用于生成 golang 代码。
- 使用该项目需要通过 git submodule 引入该项目。
- 该项目需要使用 protoc 生成代码，具体生成命令如下：
```bash
protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative *.proto