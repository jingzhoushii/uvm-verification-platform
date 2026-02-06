// filelist.f

$(SRC_DIR)/bus_if.sv
$(SRC_DIR)/bus_if.sv
$(TB_DIR)/tb_top.sv
// Other contents of the file remain the same...
# ============================================================
# 测试文件 (2026-02-06 新增)
# ============================================================
$(TB_DIR)/test/axi_single_test.sv
$(TB_DIR)/test/axi_burst_test.sv
$(TB_DIR)/test/axi_random_test.sv
$(TB_DIR)/test/axi_error_test.sv
$(TB_DIR)/test/axi_reg_test.sv

# ============================================================
# 序列库 (2026-02-06 新增)
# ============================================================
$(TB_DIR)/seq/axi_seq_lib.sv

# ============================================================
# 边界测试和工具脚本 (2026-02-06 新增)
# ============================================================
$(TB_DIR)/test/axi_boundary_test.sv
$(SCRIPTS_DIR)/wave/dump_waves.sh
$(SCRIPTS_DIR)/coverage_report.sh

# ============================================================
# 工具脚本 (2026-02-06 新增)
# ============================================================
$(SCRIPTS_DIR)/parse_log.py
$(REGRESS_DIR)/gen_html_report.py
