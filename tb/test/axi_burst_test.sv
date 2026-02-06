// ============================================================
// File: axi_burst_test.sv
// Description: AXI 突发传输测试
// Author: UVM Verification Platform
// Created: 2026-02-06
// ============================================================

`ifndef AXI_BURST_TEST_SV
`define AXI_BURST_TEST_SV

// -----------------------------------------------
// Class: axi_burst_test
// -----------------------------------------------
class axi_burst_test extends base_test;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(axi_burst_test)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_burst_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "构建 axi_burst_test", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i, j;
    `uvm_info(get_type_name(), "开始 axi_burst_test", UVM_LOW)
    
    phase.raise_objection(this);
    
    // 等待复位完成
    wait(env.rst_done);
    #100ns;
    
    // -----------------------------------------------
    // 测试不同突发长度
    // -----------------------------------------------
    for (i = 1; i <= 16; i++) begin  // len = 1~16
      axi_write_seq write_seq;
      axi_read_seq read_seq;
      
      write_seq = axi_write_seq::type_id::create($sformatf("write_seq_len%0d", i));
      
      if (!write_seq.randomize() with {
        addr inside {[32'h0000_0000:32'h00FF_FFFF]};
        len == i;
        size == 4;
        burst == 1;  // INCR
      }) begin
        `uvm_error(get_type_name(), "随机化失败")
      end
      
      `uvm_info(get_type_name(), $sformatf("突发写测试 [len=%0d]: addr=0x%0h", 
        i, write_seq.addr), UVM_LOW)
      
      write_seq.start(env.axi_env.axi_agnt.sequencer);
      write_seq.wait_for_sequence(UVM_ALL_DONE);
      
      // 读回验证
      read_seq = axi_read_seq::type_id::create($sformatf("read_seq_len%0d", i));
      read_seq.addr = write_seq.addr;
      read_seq.len = write_seq.len;
      read_seq.size = write_seq.size;
      read_seq.burst = write_seq.burst;
      
      read_seq.start(env.axi_env.axi_agnt.sequencer);
      read_seq.wait_for_sequence(UVM_ALL_DONE);
      
      #50ns;
    end
    
    // -----------------------------------------------
    // 测试不同突发大小
    // -----------------------------------------------
    begin
      axi_write_seq write_seq;
      
      write_seq = axi_write_seq::type_id::create("write_seq_size8");
      
      if (!write_seq.randomize() with {
        addr inside {[32'h0000_0000:32'h00FF_FFFF]};
        len == 4;
        size == 8;  // 64位
        burst == 1;
      }) begin
        `uvm_error(get_type_name(), "随机化失败")
      end
      
      `uvm_info(get_type_name(), $sformatf("突发写测试 [size=8]: addr=0x%0h", 
        write_seq.addr), UVM_LOW)
      
      write_seq.start(env.axi_env.axi_agnt.sequencer);
      write_seq.wait_for_sequence(UVM_ALL_DONE);
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
      `uvm_info("TEST_RESULT", "  axi_burst_test: PASSED  ✓", UVM_LOW)
      `uvm_info("TEST_RESULT", "================================", UVM_LOW)
    end else begin
      `uvm_error("TEST_RESULT", "================================")
      `uvm_error("TEST_RESULT", "  axi_burst_test: FAILED  ✗")
      `uvm_error("TEST_RESULT", "================================")
    end
  endfunction
  
endclass : axi_burst_test

`endif // AXI_BURST_TEST_SV
