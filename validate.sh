#!/bin/bash

# Proto文件依赖关系验证脚本
# 检查所有proto文件的语法和依赖关系是否正确

echo "开始验证proto文件..."

# 验证函数
validate_proto() {
    local proto_file=$1
    echo "验证: $proto_file"
    
    # 检查文件是否存在
    if [ ! -f "$proto_file" ]; then
        echo "❌ 文件不存在: $proto_file"
        return 1
    fi
    
    # 检查语法
    if command -v protoc >/dev/null 2>&1; then
        if protoc --proto_path=. --descriptor_set_out=/dev/null "$proto_file" 2>/dev/null; then
            echo "✅ 语法正确: $proto_file"
        else
            echo "❌ 语法错误: $proto_file"
            protoc --proto_path=. --descriptor_set_out=/dev/null "$proto_file"
            return 1
        fi
    else
        echo "⚠️  protoc未安装，跳过语法检查: $proto_file"
    fi
    
    return 0
}

# 验证所有proto文件
error_count=0

# 验证common模块
echo -e "\n=== 验证common模块 ==="
validate_proto "common/base.proto" || ((error_count++))
validate_proto "common/types.proto" || ((error_count++))
validate_proto "common/error.proto" || ((error_count++))
validate_proto "common/pagination.proto" || ((error_count++))
validate_proto "common/auth.proto" || ((error_count++))

# 验证task模块
echo -e "\n=== 验证task模块 ==="
validate_proto "task/v1/model.proto" || ((error_count++))
validate_proto "task/v1/service.proto" || ((error_count++))
validate_proto "task/task.proto" || ((error_count++))

# 验证flow模块
echo -e "\n=== 验证flow模块 ==="
validate_proto "flow/v1/model.proto" || ((error_count++))
validate_proto "flow/v1/service.proto" || ((error_count++))
validate_proto "flow/flow.proto" || ((error_count++))

echo -e "\n=== 验证结果 ==="
if [ $error_count -eq 0 ]; then
    echo "🎉 所有proto文件验证通过！"
    exit 0
else
    echo "❌ 发现 $error_count 个错误"
    exit 1
fi