// ============================================================
// File: axi_reg_test.sv
// Description: AXI 寄存器读写测试
// Author: UVM Verification Platform
// Created: 2026-02-06
// ============================================================

`ifndef AXI_REG_TEST_SV
`define AXI_REG_TEST_SV

// -----------------------------------------------
// Class: axi_reg_test
// -----------------------------------------------
class axi_reg_test extends base_test;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(axi_reg_test)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_reg_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "构建 axi_reg_test", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i;
    bit [31:0] test_data;
    `uvm_info(get_type_name(), "开始 axi_reg_test", UVM_LOW)
    
    phase.raise_objection(this);
    
    // 等待复位完成
    wait(env.rst_done);
    #100ns;
    
    // -----------------------------------------------
    // 测试所有寄存器
    // -----------------------------------------------
    `uvm_info(get_type_name(), "=== 测试通用寄存器 0-3 ===", UVM_LOW)
    for (i = 0; i < 4; i++) begin
      axi_write_seq write_seq;
      axi_read_seq read_seq;
      bit [31:0] addr;
      
      addr = {28'h0, i[1:0], 2'b00};  // 0x00, 0x04, 0x08, 0x0C
      
      // 写测试数据
      test_data = 32'hABCD_0000 | i[7:0];
      write_seq = axi_write_seq::type_id::create($sformatf("write_reg%0d", i));
      write_seq.addr = addr;
      write_seq.data = '{test_data};
      write_seq.len = 0;
      write_seq.size = 4;
      write_seq.burst = 0;  // FIXED
      
      `uvm_info(get_type_name(), $sformatf("写寄存器 [%0d]: addr=0x%08h, data=0x%08h", 
        i, addr, test_data), UVM_LOW)
      
      write_seq.start(env.axi_env.axi_agnt.sequencer);
      write_seq.wait_for_sequence(UVM_ALL_DONE);
      
      #20ns;
      
      // 读回验证
      read_seq = axi_read_seq::type_id::create($sformatf("read_reg%0d", i));
      read_seq.addr = addr;
      read_seq.len = 0;
      read_seq.size = 4;
      read_seq.burst = 0;
      
      `uvm_info(get_type_name(), $sformatf("读寄存器 [%0d]: addr=0x%08h", 
        i, addr), UVM_LOW)
      
      read_seq.start(env.axi_env.axi_agnt.sequencer);
      read_seq.wait_for_sequence(UVM_ALL_DONE);
      
      #20ns;
    end
    
    // -----------------------------------------------
    // 测试状态寄存器
    // -----------------------------------------------
    `uvm_info(get_type_name(), "=== 测试状态寄存器 ===", UVM_LOW)
    begin
      axi_read_seq read_seq;
      
      read_seq = axi_read_seq::type_id::create("read_status");
      read_seq.addr = 32'h10;  // status_reg
      read_seq.len = 0;
      read_seq.size = 4;
      read_seq.burst = 0;
      
      `uvm_info(get_type_name(), "读状态寄存器: 0x10", UVM_LOW)
      read_seq.start(env.axi_env.axi_agnt.sequencer);
      read_seq.wait_for_sequence(UVM_ALL_DONE);
    end
    
    // -----------------------------------------------
    // 测试控制寄存器
    // -----------------------------------------------
    `uvm_info(get_type_name(), "=== 测试控制寄存器 ===", UVM_LOW)
    begin
      axi_write_seq write_seq;
      
      write_seq = axi_write_seq::type_id::create("write_ctrl");
      write_seq.addr = 32'h14;  // control_reg
      write_seq.data = '{32'h0000_00FF};
      write_seq.len = 0;
      write_seq.size = 4;
      write_seq.burst = 0;
      
      `uvm_info(get_type_name(), "写控制寄存器: 0x14, data=0x0000_00FF", UVM_LOW)
      write_seq.start(env.axi_env.axi_agnt.sequencer);
      write_seq.wait_for_sequence(UVM_ALL_DONE);
      
      #20ns;
      
      // 读回验证
      begin
        axi_read_seq read_seq;
        read_seq = axi_read_seq::type_id::create("read_ctrl");
        read_seq.addr = 32'h14;
        read_seq.len = 0;
        read_seq.size = 4;
        read_seq.burst = 0;
        
        `uvm_info(get_type_name(), "读控制寄存器: 0x14", UVM_LOW)
        read_seq.start(env.axi_env.axi_agnt.sequencer);
        read_seq.wait_for_sequence(UVM_ALL_DONE);
      end
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
      `uvm_info("TEST_RESULT", "  axi_reg_test: PASSED  ✓", UVM_LOW)
      `uvm_info("TEST_RESULT", "================================", UVM_LOW)
    end else begin
      `uvm_error("TEST_RESULT", "================================")
      `uvm_error("TEST_RESULT", "  axi_reg_test: FAILED  ✗", UVM_LOW)
      `uvm_error("TEST_RESULT", "================================")
    end
  endfunction
  
endclass : axi_reg_test

`endif // AXI_REG_TEST_SV
