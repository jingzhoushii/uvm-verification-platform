# ============================================================
# File: compile.sh
# Description: VCS 编译脚本
# Author: UVM Verification Platform
# Created: 2026-02-05
# ============================================================

#!/bin/bash

# 设置错误处理
set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 清理函数
cleanup() {
    print_info "清理编译文件..."
    rm -rf csrc simv* *.o
}

# 编译开始
print_info "开始编译 UVM 测试平台..."
print_info "使用仿真工具: VCS"

# 检查 UVM_HOME
if [ -z "$UVM_HOME" ]; then
    print_error "请设置 UVM_HOME 环境变量"
    exit 1
fi

# 检查 VCS_HOME
if [ -z "$VCS_HOME" ]; then
    print_error "请设置 VCS_HOME 环境变量"
    exit 1
fi

# 设置编译选项
COMPILE_OPTS="-sverilog \
    -ntb_opts uvm-1.2 \
    -debug_access+all \
    -lca \
    +v2k \
    +acc+b"

# 包含目录
INCDIR="-I$UVM_HOME/src \
    -I../src \
    -I../tb"

# 定义
DEFINE="+define+UVM_NO_DEPRECATED \
    +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR"

# 文件列表
FILELIST="../filelist.f"

# 执行编译
print_info "执行 VCS 编译..."

vcs $COMPILE_OPTS \
    $INCDIR \
    $DEFINE \
    -f $FILELIST \
    -o simv \
    -l compile.log

# 检查编译结果
if [ $? -eq 0 ]; then
    print_info "编译成功！"
    print_info "生成的可执行文件: ./simv"
else
    print_error "编译失败！"
    print_error "请查看 compile.log 获取详细信息"
    exit 1
fi

print_info "编译完成"
