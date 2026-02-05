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
