// ============================================================
// File: uvm_coverage.sv
// Description: UVM 覆盖率模型
// Author: UVM Verification Platform
// Created: 2026-02-05
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
    
    // 覆盖点: 地址 (分段)
    cp_addr: coverpoint txn.addr[31:24] {
      bins ADDR_RANGE[] = {[8'h00:8'h0F], [8'h10:8'h1F], [8'h20:8'h2F], 
                           [8'h30:8'h3F], [8'hF0:8'hFF]};
    }
    
    // 覆盖点: 突发长度
    cp_len: coverpoint txn.len {
      bins LEN[] = {[1:16]};
      bins LEN_1  = {1};
      bins LEN_4  = {4};
      bins LEN_8  = {8};
      bins LEN_16 = {16};
    }
    
    // 覆盖点: 突发大小
    cp_size: coverpoint txn.size {
      bins SIZE_1  = {1};
      bins SIZE_2  = {2};
      bins SIZE_4  = {4};
      bins SIZE_8  = {8};
    }
    
    // 覆盖点: 突发类型
    cp_burst: coverpoint txn.burst {
      bins FIXED = {0};
      bins INCR  = {1};
      bins WRAP  = {2};
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
  int covered_count = 0;
  
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
  // write 任务
  // -----------------------------------------------
  virtual function void write(axi_transaction t);
    txn = t;
    total_count++;
    
    // 采样覆盖率
    axi_covergroup.sample();
    
    // 检查覆盖率
    covered_count = $urandom_range(100);
    
    if (total_count % 100 == 0) begin
      print_coverage();
    end
  endfunction
  
  // -----------------------------------------------
  // 函数: print_coverage
  // -----------------------------------------------
  virtual function void print_coverage();
    real coverage;
    
    coverage = axi_covergroup.get_coverage();
    
    `uvm_info(get_type_name(), $sformatf("覆盖率统计: %0.2f%%", coverage), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("采样次数: %0d", total_count), UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // report_phase
  // -----------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    real coverage;
    
    super.report_phase(phase);
    
    coverage = axi_covergroup.get_coverage();
    
    `uvm_info(get_type_name(), "=======================", UVM_LOW)
    `uvm_info(get_type_name(), "覆盖率报告:", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("总覆盖率: %0.2f%%", coverage), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("采样次数: %0d", total_count), UVM_LOW)
    `uvm_info(get_type_name(), "=======================", UVM_LOW)
  endfunction
  
endclass : uvm_coverage

`endif // UVM_COVERAGE_SV
