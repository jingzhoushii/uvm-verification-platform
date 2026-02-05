// ============================================================
// File: demo_test.sv
// Description: UVM 示例测试类
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef DEMO_TEST_SV
`define DEMO_TEST_SV

// -----------------------------------------------
// Class: demo_test
// -----------------------------------------------
class demo_test extends base_test;
  
  // -----------------------------------------------
  // 组件声明
  // -----------------------------------------------
  axi_base_seq      base_seq;
  axi_write_seq     write_seq;
  axi_read_seq      read_seq;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(demo_test)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "demo_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info(get_type_name(), "构建 demo_test", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    `uvm_info(get_type_name(), "开始 demo_test", UVM_LOW)
    
    phase.raise_objection(this);
    
    // -----------------------------------------------
    // 测试序列
    // -----------------------------------------------
    
    // 1. 复位序列
    `uvm_info(get_type_name(), "执行复位序列", UVM_LOW)
    base_seq = axi_base_seq::type_id::create("base_seq");
    wait(env.rst_done);
    
    // 2. 写数据序列
    `uvm_info(get_type_name(), "执行写数据序列", UVM_LOW)
    write_seq = axi_write_seq::type_id::create("write_seq");
    write_seq.addr  = 32'h1000;
    write_seq.data  = 32'hABCD_EF01;
    write_seq.len   = 4;
    write_seq.size  = 2;  // 4 bytes
    write_seq.burst = 2;  // INCR
    write_seq.start(env.axi_env.axi_agnt.sequencer);
    write_seq.wait_for_sequence(UVM_ALL_DONE);
    
    // 3. 读数据序列
    `uvm_info(get_type_name(), "执行读数据序列", UVM_LOW)
    read_seq = axi_read_seq::type_id::create("read_seq");
    read_seq.addr  = 32'h1000;
    read_seq.len   = 4;
    read_seq.size  = 2;
    read_seq.burst = 2;
    read_seq.start(env.axi_env.axi_agnt.sequencer);
    read_seq.wait_for_sequence(UVM_ALL_DONE);
    
    // 4. 随机测试序列
    `uvm_info(get_type_name(), "执行随机测试序列", UVM_LOW)
    repeat(10) begin
      axi_random_seq rand_seq = axi_random_seq::type_id::create("rand_seq");
      rand_seq.start(env.axi_env.axi_agnt.sequencer);
      rand_seq.wait_for_sequence(UVM_ALL_DONE);
    end
    
    // 5. 错误注入测试
    `uvm_info(get_type_name(), "执行错误注入测试", UVM_LOW)
    axi_error_seq err_seq = axi_error_seq::type_id::create("err_seq");
    err_seq.start(env.axi_env.axi_agnt.sequencer);
    err_seq.wait_for_sequence(UVM_ALL_DONE);
    
    // 等待结果检查完成
    #100ns;
    
    phase.drop_objection(this);
  endtask
  
  // -----------------------------------------------
  // report_phase
  // -----------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    // 检查覆盖率
    `uvm_info(get_type_name(), "覆盖率检查:", UVM_LOW)
    
    // 打印测试结果
    if (uvm_report_service::get_report_count(UVM_FATAL) == 0 &&
        uvm_report_service::get_report_count(UVM_ERROR) == 0) begin
      `uvm_info("TEST_RESULT", "=======================", UVM_LOW)
      `uvm_info("TEST_RESULT", "  demo_test: PASSED  ✓", UVM_LOW)
      `uvm_info("TEST_RESULT", "=======================", UVM_LOW)
    end else begin
      `uvm_error("TEST_RESULT", "=======================")
      `uvm_error("TEST_RESULT", "  demo_test: FAILED  ✗")
      `uvm_error("TEST_RESULT", "=======================")
    end
  endfunction
  
endclass : demo_test

`endif // DEMO_TEST_SV
