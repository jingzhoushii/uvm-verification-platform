# ============================================================
# File: run.sh
# Description: VCS 运行脚本
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
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 默认参数
TEST_NAME=${uvm_testname:-smoke_test}
SEED=${ntb_random_seed:-12345}
SIM_TIME=${SIM_TIME:-1000ns}
COVERAGE=${COVERAGE:-0}

print_info "运行 UVM 测试..."
print_info "测试名称: $TEST_NAME"
print_info "随机种子: $SEED"
print_info "仿真时长: $SIM_TIME"

# 检查可执行文件
if [ ! -f "./simv" ]; then
    print_error "找不到 simv 可执行文件，请先编译"
    print_info "运行: make compile"
    exit 1
fi

# 运行仿真
print_info "开始仿真..."

./simv \
    +uvm_testname=$TEST_NAME \
    +ntb_random_seed=$SEED \
    +ntb_random_seed_type=$RANDOM_SEED_TYPE \
    -l run.log \
    $@

# 检查运行结果
if [ $? -eq 0 ]; then
    print_info "仿真完成！"
    print_info "日志文件: run.log"
else
    print_error "仿真失败！"
    print_error "请查看 run.log 获取详细信息"
    exit 1
fi

# 覆盖率处理
if [ "$COVERAGE" == "1" ]; then
    print_info "生成覆盖率报告..."
    urg -dir *.vdb -report coverage_report
fi

print_info "运行完成"
