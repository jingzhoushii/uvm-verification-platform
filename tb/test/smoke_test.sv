// ============================================================
// File: smoke_test.sv
// Description: UVM 冒烟测试
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef SMOKE_TEST_SV
`define SMOKE_TEST_SV

// -----------------------------------------------
// Class: smoke_test
// -----------------------------------------------
class smoke_test extends base_test;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(smoke_test)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "smoke_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "构建冒烟测试", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    `uvm_info(get_type_name(), "开始冒烟测试", UVM_LOW)
    
    phase.raise_objection(this);
    
    // -----------------------------------------------
    // 冒烟测试序列
    // -----------------------------------------------
    
    // 1. 等待复位完成
    `uvm_info(get_type_name(), "等待复位释放...", UVM_LOW)
    wait(env.rst_done);
    
    // 2. 简单写读测试
    `uvm_info(get_type_name(), "执行简单写读测试", UVM_LOW)
    begin
      axi_write_seq write_seq;
      axi_read_seq  read_seq;
      
      write_seq = axi_write_seq::type_id::create("write_seq");
      write_seq.addr = 32'h1000;
      write_seq.data = '{32'h0000_0001, 32'h0000_0002, 32'h0000_0003, 32'h0000_0004};
      write_seq.len = 4;
      write_seq.size = 2;
      write_seq.burst = 2;  // INCR
      
      write_seq.start(env.axi_env.axi_agnt.sequencer);
      write_seq.wait_for_sequence(UVM_ALL_DONE);
      
      read_seq = axi_read_seq::type_id::create("read_seq");
      read_seq.addr = 32'h1000;
      read_seq.len = 4;
      read_seq.size = 2;
      read_seq.burst = 2;
      
      read_seq.start(env.axi_env.axi_agnt.sequencer);
      read_seq.wait_for_sequence(UVM_ALL_DONE);
    end
    
    // 3. 随机测试
    `uvm_info(get_type_name(), "执行随机测试", UVM_LOW)
    repeat(5) begin
      axi_random_seq rand_seq;
      rand_seq = axi_random_seq::type_id::create("rand_seq");
      rand_seq.start(env.axi_env.axi_agnt.sequencer);
      rand_seq.wait_for_sequence(UVM_ALL_DONE);
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
      `uvm_info("TEST_RESULT", "=======================", UVM_LOW)
      `uvm_info("TEST_RESULT", "  smoke_test: PASSED  ✓", UVM_LOW)
      `uvm_info("TEST_RESULT", "=======================", UVM_LOW)
    end else begin
      `uvm_error("TEST_RESULT", "=======================")
      `uvm_error("TEST_RESULT", "  smoke_test: FAILED  ✗")
      `uvm_error("TEST_RESULT", "=======================")
    end
  endfunction
  
endclass : smoke_test

`endif // SMOKE_TEST_SV
