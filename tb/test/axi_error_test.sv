// ============================================================
// File: axi_error_test.sv
// Description: AXI 错误注入测试
// Author: UVM Verification Platform
// Created: 2026-02-06
// ============================================================

`ifndef AXI_ERROR_TEST_SV
`define AXI_ERROR_TEST_SV

// -----------------------------------------------
// Class: axi_error_test
// -----------------------------------------------
class axi_error_test extends base_test;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(axi_error_test)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_error_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "构建 axi_error_test", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i;
    `uvm_info(get_type_name(), "开始 axi_error_test", UVM_LOW)
    
    phase.raise_objection(this);
    
    // 等待复位完成
    wait(env.rst_done);
    #100ns;
    
    // -----------------------------------------------
    // 正常读写测试（基线）
    // -----------------------------------------------
    `uvm_info(get_type_name(), "=== 基线测试 (正常读写) ===", UVM_LOW)
    for (i = 0; i < 5; i++) begin
      axi_write_seq write_seq;
      axi_read_seq read_seq;
      
      write_seq = axi_write_seq::type_id::create($sformatf("write_seq_%0d", i));
      if (!write_seq.randomize() with {
        addr inside {[32'h0000_0000:32'h00FF_FFFF]};
        len == 0;
        size == 4;
      }) begin `uvm_error(get_type_name(), "随机化失败") end
      
      write_seq.start(env.axi_env.axi_agnt.sequencer);
      write_seq.wait_for_sequence(UVM_ALL_DONE);
      
      read_seq = axi_read_seq::type_id::create($sformatf("read_seq_%0d", i));
      read_seq.addr = write_seq.addr;
      read_seq.len = write_seq.len;
      read_seq.size = write_seq.size;
      
      read_seq.start(env.axi_env.axi_agnt.sequencer);
      read_seq.wait_for_sequence(UVM_ALL_DONE);
      
      #50ns;
    end
    
    // -----------------------------------------------
    // 测试保留地址
    // -----------------------------------------------
    `uvm_info(get_type_name(), "=== 保留地址测试 ===", UVM_LOW)
    begin
      axi_read_seq read_seq;
      read_seq = axi_read_seq::type_id::create("read_reserved");
      read_seq.addr = 32'hFFFF_FFF0;  // 保留地址
      read_seq.len = 0;
      read_seq.size = 4;
      read_seq.burst = 1;
      
      `uvm_info(get_type_name(), "读保留地址: 0xFFFF_FFF0", UVM_LOW)
      read_seq.start(env.axi_env.axi_agnt.sequencer);
      read_seq.wait_for_sequence(UVM_ALL_DONE);
    end
    
    // -----------------------------------------------
    // 测试无效长度
    // -----------------------------------------------
    `uvm_info(get_type_name(), "=== 随机测试 ===", UVM_LOW)
    repeat(10) begin
      axi_random_seq rand_seq;
      rand_seq = axi_random_seq::type_id::create("rand_seq");
      if (!rand_seq.randomize()) begin `uvm_error(get_type_name(), "随机化失败") end
      rand_seq.start(env.axi_env.axi_agnt.sequencer);
      rand_seq.wait_for_sequence(UVM_ALL_DONE);
      #10ns;
    end
    
    // 等待检查完成
    #100ns;
    env.done = 1;
    
    phase.drop_objection(this);
  endtask
  
  // -----------------------------------------------
  // report_phase
  // -----------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    if (uvm_report_service::get_report_count(UVM_FATAL) == 0 &&
        uvm_report_service::get_report_count(UVM_ERROR) == 0) begin
      `uvm_info("TEST_RESULT", "================================", UVM_LOW)
      `uvm_info("TEST_RESULT", "  axi_error_test: PASSED  ✓", UVM_LOW)
      `uvm_info("TEST_RESULT", "================================", UVM_LOW)
    end else begin
      `uvm_error("TEST_RESULT", "================================")
      `uvm_error("TEST_RESULT", "  axi_error_test: FAILED  ✗", UVM_LOW)
      `uvm_error("TEST_RESULT", "================================")
    end
  endfunction
  
endclass : axi_error_test

`endif // AXI_ERROR_TEST_SV
