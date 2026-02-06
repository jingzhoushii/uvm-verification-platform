#!/bin/bash
# ============================================================
# File: coverage_report.sh
# Description: 覆盖率报告生成脚本
# Author: UVM Verification Platform
# Created: 2026-02-06
# ============================================================

set -e

# 默认参数
COV_DIR=${COV_DIR:-./coverage}
OUTPUT_DIR=${COV_DIR:-./coverage_report}

# 颜色
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
    -d, --dir <dir>     覆盖率目录 默认: ./coverage
    -o, --output <dir>  输出目录 默认: ./coverage_report

示例:
    $(basename $0)                    # 默认
    $(basename $0) -d ./cov           # 指定目录

EOF
    exit 0
}

main() {
    log_info "覆盖率报告脚本"
    log_info "=============="
    echo ""
    
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
    fi
    
    log_info "覆盖率目录: $COV_DIR"
    log_info "输出目录: $OUTPUT_DIR"
    echo ""
    
    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"
    
    # 生成统计文件
    cat << EOF > "$OUTPUT_DIR/coverage_stats.txt"
==========================================
UVM Verification Platform - 覆盖率报告
==========================================

生成时间: $(date)

覆盖率目录: $COV_DIR

注意: 实际覆盖率需要从仿真器获取
支持的仿真器:
- VCS: urg -dir coverage/ -report report/
- NCsim: imc -covworkdir coverage/
- Xcelium: xcrg -dir coverage/

==========================================
EOF
    
    log_info "覆盖率统计已生成"
    
    # 生成 HTML
    cat << 'HTML' > "$OUTPUT_DIR/index.html"
<!DOCTYPE html>
<html>
<head>
    <title>UVM Verification Coverage Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background-color: #4CAF50; color: white; }
        .summary { margin: 20px 0; padding: 10px; background: #f5f5f5; }
    </style>
</head>
<body>
    <h1>UVM Verification Platform - 覆盖率报告</h1>
    <div class="summary">
        <p><strong>生成时间:</strong> $(date)</p>
    </div>
    <h2>使用说明</h2>
    <pre>
VCS: make coverage
    </pre>
</body>
</html>
HTML
    
    log_info "HTML 报告已生成: $OUTPUT_DIR/index.html"
    echo ""
    log_info "完成!"
}

main "$@"
