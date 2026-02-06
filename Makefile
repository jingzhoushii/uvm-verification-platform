# ============================================================
# File: Makefile
# Description: UVM 验证平台顶层 Makefile
# Author: UVM Verification Platform
# Created: 2026-02-05
# ============================================================

# 包含编译选项定义
-include Makefile.defs

# 默认目标
.PHONY: help
help:
	@echo ""
	@echo "UVM Verification Platform - Makefile"
	@echo "======================================"
	@echo ""
	@echo "使用方法: make <目标> [参数]"
	@echo ""
	@echo "编译目标:"
	@echo "  compile          - 编译整个测试平台"
	@echo "  compile_vcs       - 使用 VCS 编译"
	@echo "  compile_ncsim     - 使用 NCsim 编译"
	@echo ""
	@echo "运行目标:"
	@echo "  run [TEST=name]  - 运行指定测试"
	@echo "  seed=[num]       - 指定随机种子"
	@echo ""
	@echo "回归测试:"
	@echo "  regress          - 运行所有回归测试"
	@echo "  smoke            - 运行冒烟测试"
	@echo ""
	@echo "覆盖率:"
	@echo "  coverage         - 生成覆盖率报告"
	@echo "  view_wave        - 查看波形"
	@echo ""
	@echo "清理:"
	@echo "  clean            - 清理仿真文件"
	@echo "  distclean        - 清理所有生成文件"
	@echo ""
	@echo "示例:"
	@echo "  make run TEST=smoke_test"
	@echo "  make run TEST=demo_test SEED=12345"
	@echo "  make compile TOOL=vcs"
	@echo ""

# ============================================================
# 编译目标
# ============================================================

.PHONY: compile
compile: $(BUILD_DIR)
	@echo "开始编译..."
	@echo "仿真工具: $(SIM_TOOL)"
	@echo "UVM 版本: $(UVM_HOME)"
	$(MAKE) -C $(SIM_DIR)/$(SIM_TOOL) compile.sh

.PHONY: compile_vcs
compile_vcs:
	$(MAKE) compile SIM_TOOL=vcs

.PHONY: compile_ncsim
compile_ncsim:
	$(MAKE) compile SIM_TOOL=ncsim

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# ============================================================
# 运行目标
# ============================================================

.PHONY: run
run: compile
	@echo "运行测试: $(TEST)"
	@echo "随机种子: $(SEED)"
	$(SIM_DIR)/$(SIM_TOOL)/run.sh +uvm_testname=$(TEST) +ntb_random_seed=$(SEED)

.PHONY: smoke
smoke:
	$(MAKE) run TEST=smoke_test

.PHONY: demo
demo:
	$(MAKE) run TEST=demo_test

# ============================================================
# 回归测试
# ============================================================

.PHONY: regress
regress:
	@echo "运行回归测试..."
	@echo "测试列表: $(REGRESS_DIR)/testlist.yaml"
	$(REGRESS_DIR)/run_regress.sh

# ============================================================
# 覆盖率
# ============================================================

.PHONY: coverage
coverage:
	@echo "生成覆盖率报告..."
	$(SCRIPTS_DIR)/gen_coverage_report.sh

.PHONY: view_wave
view_wave:
	@echo "打开波形查看器..."
	@echo "波形文件: $(BUILD_DIR)/waves.vcd"
ifeq ($(SIM_TOOL),vcs)
	@echo "使用 DVE 查看: dve -vpd waves.vcd &"
else ifeq ($(SIM_TOOL),ncsim)
	@echo "使用 IMC 查看覆盖率"
endif

# ============================================================
# 清理
# ============================================================

.PHONY: clean
clean:
	@echo "清理仿真文件..."
	rm -rf $(BUILD_DIR)
	rm -f *.log
	rm -f *.vcd
	rm -f *.fsdb
	rm -f *.vpd
	rm -fnovas*
	rm -f work*.db
	rm -f csrc
	rm -f simv*
	rm -f ucli.key
	rm -f vc_hdrs.h

.PHONY: distclean
distclean: clean
	@echo "清理所有生成文件..."
	rm -rf $(REGRESS_DIR)/results
	rm -f $(COVERAGE_DIR)/*

# ============================================================
# 测试列表 (2026-02-06 新增)
# ============================================================

TEST_LIST = \
    smoke_test \
    base_test \
    demo_test \
    axi_single_test \
    axi_burst_test \
    axi_random_test \
    axi_error_test \
    axi_reg_test

# 运行所有测试
.PHONY: all_tests
all_tests: $(TEST_LIST:%=run_%)
	@echo ""
	@echo "所有测试完成!"

# 分别运行每个测试
.PHONY: $(TEST_LIST)
$(TEST_LIST):
	@echo ""
	@echo "运行测试: $@"
	$(MAKE) run TEST=$@

# 快速测试 (只运行 P0 和 P1)
.PHONY: quick_test
quick_test: smoke_test base_test demo_test axi_single_test axi_burst_test axi_reg_test
	@echo ""
	@echo "快速测试完成!"

# 压力测试
.PHONY: stress_test
stress_test:
	$(MAKE) run TEST=axi_random_test SEED=54321

# 测试覆盖率
.PHONY: coverage_test
coverage_test: compile
	@echo "运行覆盖率测试..."
	$(MAKE) regress VERBOSE=1



# ============================================================
# CI/CD 检查 (2026-02-06 新增)
# ============================================================

.PHONY: ci-check ci-lint ci-doc ci-stats

ci-check: ci-lint ci-doc ci-stats
	@echo ""
	@echo "=========================================="
	@echo "CI 检查完成!"
	@echo "=========================================="

ci-lint:
	@echo ""
	@echo "=========================================="
	@echo "  CI Lint 检查"
	@echo "=========================================="
	@echo ""
	@echo "文件结构:"
	@ls -la | head -5
	@echo ""
	@echo "Testbench 文件:"
	@find tb -name "*.sv" 2>/dev/null | wc -l | xargs echo "  .sv 文件:"
	@find tb -name "*.sv" 2>/dev/null | head -10
	@echo ""
	@echo "测试文件:"
	@find tb/test -name "*_test.sv" 2>/dev/null | xargs echo "  "
	@find tb/test -name "*_test.sv" 2>/dev/null
	@echo ""
	@echo "序列文件:"
	@find tb/seq -name "*.sv" 2>/dev/null

ci-doc:
	@echo ""
	@echo "=========================================="
	@echo "  CI 文档检查"
	@echo "=========================================="
	@echo ""
	@echo "README.md:       $(shell [ -f README.md ] && echo '✓' || echo '✗')"
	@echo "ROADMAP.md:      $(shell [ -f ROADMAP.md ] && echo '✓' || echo '✗')"
	@echo "CHANGELOG.md:    $(shell [ -f CHANGELOG.md ] && echo '✓' || echo '✗')"
	@echo "filelist.f:      $(shell [ -f filelist.f ] && echo '✓' || echo '✗')"
	@echo "regress/:        $(shell [ -d regress ] && echo '✓' || echo '✗')"
	@echo "testlist.yaml:   $(shell [ -f regress/testlist.yaml ] && echo '✓' || echo '✗')"
	@echo "docs/:           $(shell [ -d docs ] && echo '✓' || echo '✗')"

ci-stats:
	@echo ""
	@echo "=========================================="
	@echo "  CI 代码统计"
	@echo "=========================================="
	@echo ""
	@echo "代码行数统计:"
	@find . -name "*.sv" -o -name "*.v" | grep -v ".git" | xargs wc -l 2>/dev/null | tail -1 | xargs echo "  总计 .sv/.v:"
	@echo ""
	@echo "文件分类:"
	@echo "  Testbench:  $$(find tb -name "*.sv" 2>/dev/null | wc -l | xargs) 个"
	@echo "  测试用例:   $$(find tb/test -name "*_test.sv" 2>/dev/null | wc -l | xargs) 个"
	@echo "  序列:       $$(find tb/seq -name "*.sv" 2>/dev/null | wc -l | xargs) 个"
	@echo "  组件:       $$(find tb/component -name "*.sv" 2>/dev/null | wc -l | xargs) 个"
	@echo "  Agent:      $$(find tb/agent -name "*.sv" 2>/dev/null | wc -l | xargs) 个"
	@echo "  文档:       $$(find docs -name "*.md" 2>/dev/null | wc -l | xargs) 个"
	@echo ""
	@echo "Git 提交统计:"
	@git log --oneline 2>/dev/null | wc -l | xargs echo "  总提交数:"



# ============================================================
# 边界测试 (2026-02-06 新增)
# ============================================================

.PHONY: boundary_test
boundary_test:
	@echo ""
	@echo "运行边界测试..."
	$(MAKE) run TEST=axi_boundary_test

.PHONY: all_tests_boundary
all_tests_boundary: smoke_test base_test demo_test axi_single_test axi_burst_test axi_random_test axi_error_test axi_reg_test boundary_test
	@echo ""
	@echo "所有测试完成 (含边界测试)!"

# ============================================================
# Docker (2026-02-06 新增)
# ============================================================

.PHONY: docker-build docker-run docker-stop

docker-build:
	@echo "构建 Docker 镜像..."
	docker build -t uvm-platform .

docker-run:
	@echo "运行 Docker 容器..."
	docker-compose up -d

docker-stop:
	@echo "停止 Docker 容器..."
	docker-compose down

docker-bash:
	@echo "进入 Docker 容器..."
	docker-compose exec uvm-platform bash

# ============================================================
# 覆盖率报告 (2026-02-06 新增)
# ============================================================

.PHONY: coverage coverage-report

coverage: compile
	@echo "运行覆盖率测试..."
	$(SIM_DIR)/$(SIM_TOOL)/run.sh +uvm_testname=smoke_test $(COV_FLAGS)

coverage-report:
	@echo "生成覆盖率报告..."
	$(SCRIPTS_DIR)/coverage_report.sh -d ./coverage -o ./coverage_report

# ============================================================
# 波形查看 (2026-02-06 新增)
# ============================================================

.PHONY: wave-dump

wave-dump:
	@echo "生成波形 dump 代码..."
	$(SCRIPTS_DIR)/wave/dump_waves.sh

wave-view:
	@echo "打开波形查看器..."
ifeq ($(SIM_TOOL),vcs)
	@echo "使用 DVE: dve -vpd waves.vpd &"
else ifeq ($(SIM_TOOL),ncsim)
	@echo "使用 IMC 查看覆盖率"
endif

# ============================================================
# 帮助 (2026-02-06 更新)
# ============================================================

.PHONY: help
help:
	@echo ""
	@echo "UVM Verification Platform - Makefile"
	@echo "======================================"
	@echo ""
	@echo "使用方法: make <目标> [参数]"
	@echo ""
	@echo "编译目标:"
	@echo "  compile          - 编译整个测试平台"
	@echo "  compile_vcs      - 使用 VCS 编译"
	@echo "  compile_ncsim    - 使用 NCsim 编译"
	@echo ""
	@echo "运行目标:"
	@echo "  run [TEST=name]  - 运行指定测试"
	@echo "  seed=[num]       - 指定随机种子"
	@echo ""
	@echo "测试目标:"
	@echo "  smoke            - 运行冒烟测试"
	@echo "  demo             - 运行演示测试"
	@echo "  boundary_test    - 运行边界测试"
	@echo "  all_tests        - 运行所有测试"
	@echo "  all_tests_boundary - 运行所有测试 (含边界)"
	@echo "  quick_test       - 快速测试 (P0 + P1)"
	@echo "  stress_test      - 压力测试"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build      - 构建 Docker 镜像"
	@echo "  docker-run       - 运行 Docker 容器"
	@echo "  docker-stop      - 停止 Docker 容器"
	@echo "  docker-bash      - 进入容器 bash"
	@echo ""
	@echo "覆盖率:"
	@echo "  coverage         - 生成覆盖率"
	@echo "  coverage-report  - 生成覆盖率报告"
	@echo ""
	@echo "波形:"
	@echo "  wave-dump        - 生成波形 dump 代码"
	@echo "  wave-view        - 查看波形"
	@echo ""
	@echo "回归测试:"
	@echo "  regress          - 运行回归测试"
	@echo ""
	@echo "清理:"
	@echo "  clean            - 清理仿真文件"
	@echo "  distclean        - 清理所有生成文件"
	@echo ""
	@echo "示例:"
	@echo "  make run TEST=smoke_test"
	@echo "  make run TEST=demo_test SEED=12345"
	@echo "  make boundary_test"
	@echo "  make docker-build"
	@echo ""



# ============================================================
# 工具脚本 (2026-02-06 新增)
# ============================================================

.PHONY: parse-log gen-report

parse-log:
	@echo "解析仿真日志..."
	python3 $(SCRIPTS_DIR)/parse_log.py sim/vcs/simv.log

parse-log-custom:
	@echo "解析自定义日志..."
	python3 $(SCRIPTS_DIR)/parse_log.py $(LOG_FILE)

gen-report:
	@echo "生成 HTML 回归报告..."
	python3 $(REGRESS_DIR)/gen_html_report.py regress/results regress/report.html
	@echo "报告位置: regress/report.html"

# ============================================================
# 帮助 (2026-02-06 更新)
# ============================================================

.PHONY: help
help:
	@echo ""
	@echo "UVM Verification Platform - Makefile"
	@echo "======================================"
	@echo ""
	@echo "使用方法: make <目标> [参数]"
	@echo ""
	@echo "文档:"
	@echo "  docs/zh/README.md  - 中文文档"
	@echo "  docs/FAQ.md       - 常见问题"
	@echo "  CONTRIBUTING.md    - 贡献指南"
	@echo ""
	@echo "测试:"
	@echo "  make smoke              - 冒烟测试"
	@echo "  make regress            - 回归测试"
	@echo "  make boundary_test      - 边界测试"
	@echo ""
	@echo "工具:"
	@echo "  make parse-log          - 解析日志"
	@echo "  make gen-report         - 生成 HTML 报告"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build       - 构建镜像"
	@echo "  make docker-run         - 运行容器"
	@echo ""
	@echo "完整列表请查看 README.md"
	@echo ""


