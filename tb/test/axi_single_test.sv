// ============================================================
// File: axi_single_test.sv
// Description: AXI 单次传输测试
// Author: UVM Verification Platform
// Created: 2026-02-06
// ============================================================

`ifndef AXI_SINGLE_TEST_SV
`define AXI_SINGLE_TEST_SV

// -----------------------------------------------
// Class: axi_single_test
// -----------------------------------------------
class axi_single_test extends base_test;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(axi_single_test)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_single_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "构建 axi_single_test", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i;
    `uvm_info(get_type_name(), "开始 axi_single_test", UVM_LOW)
    
    phase.raise_objection(this);
    
    // 等待复位完成
    wait(env.rst_done);
    #100ns;
    
    // -----------------------------------------------
    // 单次写测试 (10次)
    // -----------------------------------------------
    `uvm_info(get_type_name(), "=== 单次写测试 ===", UVM_LOW)
    for (i = 0; i < 10; i++) begin
      axi_write_seq write_seq;
      write_seq = axi_write_seq::type_id::create("write_seq");
      
      if (!write_seq.randomize() with {
        addr inside {[32'h0000_0000:32'h0FFF_FFFF]};
        len == 0;  // 单次传输
        size == 4;  // 32位
        burst == 1;  // INCR
      }) begin
        `uvm_error(get_type_name(), "随机化失败")
      end
      
      `uvm_info(get_type_name(), $sformatf("写测试 [%0d]: addr=0x%0h", 
        i, write_seq.addr), UVM_LOW)
      
      write_seq.start(env.axi_env.axi_agnt.sequencer);
      write_seq.wait_for_sequence(UVM_ALL_DONE);
      
      #50ns;
    end
    
    // -----------------------------------------------
    // 单次读测试 (10次)
    // -----------------------------------------------
    `uvm_info(get_type_name(), "=== 单次读测试 ===", UVM_LOW)
    for (i = 0; i < 10; i++) begin
      axi_read_seq read_seq;
      read_seq = axi_read_seq::type_id::create("read_seq");
      
      if (!read_seq.randomize() with {
        addr inside {[32'h0000_0000:32'h0FFF_FFFF]};
        len == 0;
        size == 4;
        burst == 1;
      }) begin
        `uvm_error(get_type_name(), "随机化失败")
      end
      
      `uvm_info(get_type_name(), $sformatf("读测试 [%0d]: addr=0x%0h", 
        i, read_seq.addr), UVM_LOW)
      
      read_seq.start(env.axi_env.axi_agnt.sequencer);
      read_seq.wait_for_sequence(UVM_ALL_DONE);
      
      #50ns;
    end
    
    // 等待检查完成
    #100ns;
    
    // 设置完成标志
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
      `uvm_info("TEST_RESULT", "  axi_single_test: PASSED  ✓", UVM_LOW)
      `uvm_info("TEST_RESULT", "================================", UVM_LOW)
    end else begin
      `uvm_error("TEST_RESULT", "================================")
      `uvm_error("TEST_RESULT", "  axi_single_test: FAILED  ✗")
      `uvm_error("TEST_RESULT", "================================")
    end
  endfunction
  
endclass : axi_single_test

`endif // AXI_SINGLE_TEST_SV
