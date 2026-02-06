#!/bin/bash
# ============================================================
# File: dump_waves.sh
# Description: 波形 dump 脚本
# Author: UVM Verification Platform
# Created: 2026-02-06
# ============================================================

set -e

# 默认参数
WAVE_TYPE=${WAVE_TYPE:-vcd}
DUMP_FILE=${DUMP_FILE:-waves.vcd}
DUMP_SCOPE=${DUMP_SCOPE:-tb_top}

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

show_help() {
    cat << EOF
用法: $(basename $0) [选项]

选项:
    -h, --help          显示帮助
    -t, --type <type>   波形类型 (vcd, fsdb, vpd) 默认: vcd
    -f, --file <file>   输出文件名 默认: waves.vcd
    -s, --scope <scope> Dump 范围 默认: tb_top
    --start             开始 dump 时间
    --stop              停止 dump 时间

示例:
    $(basename $0)                      # 默认 VCD
    $(basename $0) -t fsdb              # FSDB 格式
    $(basename $0) -t vpd -f sim.vpd    # VPD 格式

支持的仿真器:
    - VCS: 支持 VCD, FSDB, VPD
    - NCsim: 支持 VCD, FSDB
    - Xcelium: 支持 VCD, FSDB

EOF
    exit 0
}

# 生成 dump 代码
generate_dump_code() {
    local type=$1
    local file=$2
    local scope=$3
    
    case $type in
        vcd)
            cat << VCD
// VCD 波形 dump
\$dumpfile("$file");
\$dumpvars(0, "$scope");
\$dumpflush;
VCD
            ;;
        fsdb)
            cat << FSDB
// FSDB 波形 dump (需要 Verdi)
initial begin
    \$fsdbDumpfile("$file");
    \$fsdbDumpvars(0, "$scope");
    \$fsdbDumpflush;
end
FSDB
            ;;
        vpd)
            cat << VPD
// VPD 波形 dump (需要 VCS)
initial begin
    \$vcdplusfile("$file");
end
VPD
            ;;
        *)
            echo "错误: 不支持的格式: $type"
            exit 1
            ;;
    esac
}

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

main() {
    log_info "波形 Dump 脚本"
    log_info "=============="
    echo ""
    
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
    fi
    
    log_info "类型: $WAVE_TYPE"
    log_info "文件: $DUMP_FILE"
    log_info "范围: $DUMP_SCOPE"
    echo ""
    
    generate_dump_code "$WAVE_TYPE" "$DUMP_FILE" "$DUMP_SCOPE"
    
    echo ""
    log_info "使用方法:"
    log_info "1. 将生成的代码添加到 testbench 中"
    log_info "2. 编译并运行仿真"
    log_info "3. 用 Verdi/DVE 查看波形"
}

main "$@"
