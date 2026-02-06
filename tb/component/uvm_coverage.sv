// ============================================================
// File: uvm_coverage.sv
// Description: UVM 覆盖率模型 (完整实现)
// Author: UVM Verification Platform
// Created: 2026-02-05
// Updated: 2026-02-06 - 完整实现
// ============================================================

`ifndef UVM_COVERAGE_SV
`define UVM_COVERAGE_SV

// -----------------------------------------------
// Class: uvm_coverage
// -----------------------------------------------
class uvm_coverage extends uvm_subscriber#(axi_transaction);
  
  // -----------------------------------------------
  // 覆盖率组
  // -----------------------------------------------
  covergroup axi_covergroup;
    
    // 覆盖点: 命令
    cp_cmd: coverpoint txn.cmd {
      bins READ  = {READ};
      bins WRITE = {WRITE};
    }
    
    // 覆盖点: 地址 (按功能区域)
    cp_addr: coverpoint txn.addr[7:0] {
      bins REG_0  = {8'h00};
      bins REG_1  = {8'h04};
      bins REG_2  = {8'h08};
      bins REG_3  = {8'h0C};
      bins REG_S  = {8'h10, 8'h14};
      bins OTHER  = default;
    }
    
    // 覆盖点: 突发长度
    cp_len: coverpoint txn.len {
      bins LEN_1  = {1};
      bins LEN_2  = {2};
      bins LEN_4  = {4};
      bins LEN_8  = {8};
      bins LEN_16 = {16};
      bins OTHER  = {[2:15]};
    }
    
    // 覆盖点: 突发大小
    cp_size: coverpoint txn.size {
      bins SIZE_1 = {1};
      bins SIZE_2 = {2};
      bins SIZE_4 = {4};
      bins SIZE_8 = {8};
    }
    
    // 覆盖点: 突发类型
    cp_burst: coverpoint txn.burst {
      bins FIXED = {0};
      bins INCR  = {1};
      bins WRAP  = {2};
    }
    
    // 覆盖点: 字节使能 (部分写)
    cp_wstrb: coverpoint txn.wstrb {
      bins ALL_BYTE  = {4'b1111};
      bins LOW_BYTE  = {4'b0001};
      bins HIGH_BYTE = {4'b1000};
      bins LOW_WORD  = {4'b0011};
      bins HIGH_WORD = {4'b1100};
      bins OTHER     = default;
    }
    
    // 交叉覆盖: 命令 x 突发类型
    cmd_x_burst: cross cp_cmd, cp_burst;
    
    // 交叉覆盖: 长度 x 大小
    len_x_size: cross cp_len, cp_size;
    
    // 交叉覆盖: 地址 x 命令
    addr_x_cmd: cross cp_addr, cp_cmd;
    
  endgroup : axi_covergroup
  
  // -----------------------------------------------
  // 字段
  // -----------------------------------------------
  axi_transaction txn;
  int total_count = 0;
  int sample_count = 0;
  
  // -----------------------------------------------
  // 配置
  // -----------------------------------------------
  bit print_enable = 1'b1;
  bit coverage_enable = 1'b1;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(uvm_coverage)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "uvm_coverage", uvm_component parent = null);
    super.new(name, parent);
    axi_covergroup = new();
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (uvm_config_db#(bit)::get(this, "", "coverage_enable", coverage_enable)) begin
      `uvm_info(get_type_name(), $sformatf("coverage_enable = %0b", coverage_enable), UVM_LOW)
    end
  endfunction
  
  // -----------------------------------------------
  // write 任务
  // -----------------------------------------------
  virtual function void write(axi_transaction t);
    if (!coverage_enable) return;
    
    txn = t;
    total_count++;
    
    // 采样覆盖率
    axi_covergroup.sample();
    sample_count++;
    
    // 定期打印
    if (print_enable && (total_count % 100 == 0)) begin
      print_coverage();
    end
  endfunction
  
  // -----------------------------------------------
  // 任务: sample
  // -----------------------------------------------
  virtual function void sample(axi_transaction t);
    txn = t;
    axi_covergroup.sample();
  endfunction
  
  // -----------------------------------------------
  // 函数: get_coverage
  // -----------------------------------------------
  virtual function real get_coverage();
    return axi_covergroup.get_coverage();
  endfunction
  
  // -----------------------------------------------
  // 函数: print_coverage
  // -----------------------------------------------
  virtual function void print_coverage();
    real coverage;
    real addr_coverage;
    real cmd_coverage;
    real burst_coverage;
    
    coverage = axi_covergroup.get_coverage();
    
    // 获取各部分覆盖率
    addr_coverage = axi_covergroup.cp_addr.get_coverage();
    cmd_coverage = axi_covergroup.cp_cmd.get_coverage();
    burst_coverage = axi_covergroup.cp_burst.get_coverage();
    
    `uvm_info(get_type_name(), "================== 覆盖率统计 ==================", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("总覆盖率: %0.2f%%", coverage), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("地址覆盖率: %0.2f%%", addr_coverage), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("命令覆盖率: %0.2f%%", cmd_coverage), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("突发覆盖率: %0.2f%%", burst_coverage), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("采样次数: %0d", sample_count), UVM_LOW)
    `uvm_info(get_type_name(), "================================================", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // 函数: get_covered_bins
  // -----------------------------------------------
  virtual function void get_covered_bins(output int bins_array[$]);
    bins_array = axi_covergroup.get_covered_bins();
  endfunction
  
  // -----------------------------------------------
  // report_phase
  // -----------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    real coverage;
    
    super.report_phase(phase);
    
    coverage = axi_covergroup.get_coverage();
    
    `uvm_info(get_type_name(), "======================= 覆盖率报告 =======================", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("覆盖率: %0.2f%% (%0d samples)", 
      coverage, sample_count), UVM_LOW)
    `uvm_info(get_type_name(), "====================================================", UVM_LOW)
    
    // 覆盖率检查
    if (coverage >= 90.0) begin
      `uvm_info("COVERAGE_PASS", "覆盖率目标已达成!", UVM_LOW)
    end else if (coverage >= 70.0) begin
      `uvm_warning(get_type_name(), "覆盖率未达标，请增加测试")
    end else begin
      `uvm_error(get_type_name(), "覆盖率太低，请增加更多测试")
    end
  endfunction
  
endclass : uvm_coverage

`endif // UVM_COVERAGE_SV
