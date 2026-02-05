// ============================================================
// File: base_test.sv
// Description: UVM 基础测试类
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef BASE_TEST_SV
`define BASE_TEST_SV

// -----------------------------------------------
// Class: base_test
// -----------------------------------------------
class base_test extends uvm_test;
  
  // -----------------------------------------------
  // 组件声明
  // -----------------------------------------------
  uvm_env         env;
  uvm_config_db#(int)          :: set(null, "*", "recording_detail", 0);
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // 创建 env
    env = uvm_env::type_id::create("env", this);
    
    // 配置打印策略
    uvm_printer = uvm_default_printer;
    
    // 设置超时
    uvm_root::set_timeout(1000ms);
    
    `uvm_info(get_type_name(), "build_phase 完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // connect_phase
  // -----------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "connect_phase 完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), "开始运行测试", UVM_LOW)
    
    // 等待仿真完成
    @(posedge env.done);
    
    phase.drop_objection(this);
  endtask
  
  // -----------------------------------------------
  // report_phase
  // -----------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    // 打印测试结果摘要
    if (uvm_report_service::get_report_count(UVM_FATAL) == 0) begin
      `uvm_info("TEST_PASS", "测试通过 ✓", UVM_LOW)
    end else begin
      `uvm_error("TEST_FAIL", "测试失败 ✗")
    end
    
    // 打印统计信息
    `uvm_info(get_type_name(), $sformatf("UVM_ERROR 数量: %0d", 
      uvm_report_service::get_report_count(UVM_ERROR)), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("UVM_WARNING 数量: %0d", 
      uvm_report_service::get_report_count(UVM_WARNING)), UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // final_phase
  // -----------------------------------------------
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    
    // 打印总结
    `uvm_info(get_type_name(), "测试结束", UVM_LOW)
  endfunction
  
endclass : base_test

`endif // BASE_TEST_SV
