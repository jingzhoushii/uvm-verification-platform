#!/bin/bash
# ============================================================
# File: run_regress.sh
# Description: UVM 回归测试脚本
# Author: UVM Verification Platform
# Created: 2026-02-06
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# 默认参数
TEST_PATTERN="*_test"
TEST_DIR="./sim/vcs"
REGRESS_DIR="./regress"
RESULTS_DIR="$REGRESS_DIR/results"

# 帮助信息
show_help() {
    cat << EOF
用法: $(basename $0) [选项]

选项:
    -h, --help              显示帮助信息
    -p, --pattern <pattern> 测试用例匹配模式
    -d, --dir <dir>        测试目录
    -v, --verbose           详细输出
    --skip-smoke           跳过冒烟测试
    --skip-compile         跳过编译

EOF
    exit 0
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) show_help ;;
        -p|--pattern) TEST_PATTERN="$2"; shift 2 ;;
        -d|--dir) TEST_DIR="$2"; shift 2 ;;
        -v|--verbose) VERBOSE=1; shift ;;
        --skip-smoke) SKIP_SMOKE=1; shift ;;
        --skip-compile) SKIP_COMPILE=1; shift ;;
        *) log_error "未知参数: $1"; exit 1 ;;
    esac
done

# 检查环境
check_environment() {
    log_info "检查环境..."
    
    if [ ! -d "$TEST_DIR" ]; then
        log_error "测试目录不存在: $TEST_DIR"
        exit 1
    fi
    
    if [ ! -f "$TEST_DIR/simv" ]; then
        if [ "$SKIP_COMPILE" != "1" ]; then
            log_warn "未找到 simv，开始编译..."
            cd "$TEST_DIR"
            ./compile.sh
            cd - > /dev/null
        else
            log_error "未找到 simv，请先编译"
            exit 1
        fi
    fi
    
    mkdir -p "$RESULTS_DIR"
    log_info "环境检查完成"
}

# 运行单个测试
run_test() {
    local test_name=$1
    local test_log="$RESULTS_DIR/${test_name}.log"
    local test_start=$(date +%s)
    
    log_test "运行测试: $test_name"
    
    cd "$TEST_DIR"
    
    if [ $VERBOSE -eq 1 ]; then
        ./run.sh +uvm_testname=$test_name +ntb_random_seed=12345 2>&1 | tee "$test_log"
    else
        ./run.sh +uvm_testname=$test_name +ntb_random_seed=12345 > "$test_log" 2>&1
    fi
    
    local test_end=$(date +%s)
    local test_duration=$((test_end - test_start))
    
    if [ $? -eq 0 ]; then
        log_info "测试通过: $test_name (${test_duration}s)"
        echo "$test_name:PASS:$test_duration" >> "$RESULTS_DIR/summary.log"
        return 0
    else
        log_error "测试失败: $test_name (${test_duration}s)"
        echo "$test_name:FAIL:$test_duration" >> "$RESULTS_DIR/summary.log"
        return 1
    fi
}

# 主函数
main() {
    local start_time=$(date +%s)
    
    echo ""
    log_info "=========================================="
    log_info "   UVM Verification Platform - 回归测试   "
    log_info "=========================================="
    echo ""
    
    check_environment
    
    log_info "开始回归测试..."
    log_info "测试模式: $TEST_PATTERN"
    
    mkdir -p "$RESULTS_DIR"
    rm -f "$RESULTS_DIR/summary.log"
    touch "$RESULTS_DIR/summary.log"
    
    local passed=0
    local failed=0
    
    # 获取测试列表
    cd "$TEST_DIR"
    local tests=($(find . -name "${TEST_PATTERN}.sv" -o -name "$TEST_PATTERN" 2>/dev/null | sed 's|.*/||' | sed 's/\.sv$//' | sort -u))
    
    log_info "找到 ${#tests[@]} 个测试用例"
    
    for test in "${tests[@]}"; do
        if run_test "$test"; then
            ((passed++))
        else
            ((failed++))
        fi
    done
    
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    
    echo ""
    log_info "=========================================="
    log_info "回归测试完成"
    log_info "=========================================="
    log_info "总测试数: ${#tests[@]}"
    log_info "通过: $passed"
    log_info "失败: $failed"
    log_info "总耗时: ${total_time}s"
    log_info "=========================================="
    
    if [ $failed -gt 0 ]; then
        log_error "$failed 个测试失败!"
        exit 1
    else
        log_info "所有测试通过!"
        exit 0
    fi
}

main
