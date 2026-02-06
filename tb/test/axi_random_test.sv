// ============================================================
// File: axi_random_test.sv
// Description: AXI 随机传输测试
// Author: UVM Verification Platform
// Created: 2026-02-06
// ============================================================

`ifndef AXI_RANDOM_TEST_SV
`define AXI_RANDOM_TEST_SV

// -----------------------------------------------
// Class: axi_random_test
// -----------------------------------------------
class axi_random_test extends base_test;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(axi_random_test)
  
  // -----------------------------------------------
  // 配置
  // -----------------------------------------------
  int test_count = 100;  // 默认100次随机测试
  int write_count = 0;
  int read_count = 0;
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // 从命令行获取测试次数
    void'($value$plusargs("test_count=%0d", test_count));
    
    `uvm_info(get_type_name(), $sformatf("构建 axi_random_test (count=%0d)", test_count), UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i;
    `uvm_info(get_type_name(), $sformatf("开始 axi_random_test (%0d 次)", test_count), UVM_LOW)
    
    phase.raise_objection(this);
    
    // 等待复位完成
    wait(env.rst_done);
    #100ns;
    
    // -----------------------------------------------
    // 随机测试
    // -----------------------------------------------
    for (i = 0; i < test_count; i++) begin
      axi_random_seq rand_seq;
      rand_seq = axi_random_seq::type_id::create($sformatf("rand_seq_%0d", i));
      
      if (!rand_seq.randomize()) begin
        `uvm_error(get_type_name(), "随机化失败")
      end
      
      // 统计
      if (rand_seq.cmd == WRITE) begin
        write_count++;
      end else begin
        read_count++;
      end
      
      // 每10次打印进度
      if ((i + 1) % 10 == 0) begin
        `uvm_info(get_type_name(), $sformatf("进度: %0d/%0d (写=%0d, 读=%0d)", 
          i + 1, test_count, write_count, read_count), UVM_LOW)
      end
      
      rand_seq.start(env.axi_env.axi_agnt.sequencer);
      rand_seq.wait_for_sequence(UVM_ALL_DONE);
      
      #10ns;
    end
    
    `uvm_info(get_type_name(), $sformatf("随机测试完成: 写=%0d, 读=%0d", 
      write_count, read_count), UVM_LOW)
    
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
    
    `uvm_info(get_type_name(), $sformatf("测试统计: 写=%0d, 读=%0d", 
      write_count, read_count), UVM_LOW)
    
    if (uvm_report_service::get_report_count(UVM_FATAL) == 0 &&
        uvm_report_service::get_report_count(UVM_ERROR) == 0) begin
      `uvm_info("TEST_RESULT", "================================", UVM_LOW)
      `uvm_info("TEST_RESULT", $sformatf("  axi_random_test: PASSED  ✓ (%0d tests)", test_count), UVM_LOW)
      `uvm_info("TEST_RESULT", "================================", UVM_LOW)
    end else begin
      `uvm_error("TEST_RESULT", "================================")
      `uvm_error("TEST_RESULT", $sformatf("  axi_random_test: FAILED  ✗ (%0d errors)", 
        uvm_report_service::get_report_count(UVM_ERROR)), UVM_LOW)
      `uvm_error("TEST_RESULT", "================================")
    end
  endfunction
  
endclass : axi_random_test

`endif // AXI_RANDOM_TEST_SV
