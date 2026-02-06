// ============================================================
// File: axi_boundary_test.sv
// Description: AXI 边界测试
// Author: UVM Verification Platform
// Created: 2026-02-06
// ============================================================

`ifndef AXI_BOUNDARY_TEST_SV
`define AXI_BOUNDARY_TEST_SV

class axi_boundary_test extends base_test;
  
  `uvm_component_utils(axi_boundary_test)
  
  function new(string name = "axi_boundary_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "开始边界测试", UVM_LOW)
    
    phase.raise_objection(this);
    
    // 测试 1: 地址边界对齐
    test_address_alignment();
    
    // 测试 2: 最大传输
    test_max_transfer();
    
    // 测试 3: 最小传输
    test_min_transfer();
    
    // 测试 4: 跨边界传输
    test_cross_boundary();
    
    // 测试 5: 保留地址
    test_reserved_address();
    
    phase.drop_objection(this);
    
    `uvm_info(get_type_name(), "边界测试完成", UVM_LOW)
  endtask
  
  // 测试地址对齐
  virtual task test_address_alignment();
    int i;
    axi_single_seq seq;
    
    `uvm_info(get_type_name(), "测试地址对齐", UVM_LOW)
    
    for (i = 0; i < 4; i++) begin
      seq = axi_single_seq::type_id::create("seq");
      
      case (i)
        0: seq.size = 3'd0;  // 1 字节对齐
        1: seq.size = 3'd1;  // 2 字节对齐
        2: seq.size = 3'd2;  // 4 字节对齐
        3: seq.size = 3'd3;  // 8 字节对齐
      endcase
      
      seq.addr = 32'h0000_0000 + (i * (1 << seq.size));
      seq.data = 32'hA5A5_A5A5 + i;
      
      seq.start(env.axi_agnt.sequencer);
    end
    
    `uvm_info(get_type_name(), "地址对齐测试完成", UVM_LOW)
  endtask
  
  // 测试最大传输
  virtual task test_max_transfer();
    axi_burst_seq seq;
    
    `uvm_info(get_type_name(), "测试最大传输", UVM_LOW)
    
    seq = axi_burst_seq::type_id::create("seq");
    seq.addr = 32'h0000_1000;
    seq.len = 8'd16;  // 最大突发长度
    seq.size = 3'd2;  // 4 字节
    seq.burst = 2'd1;  // INCR
    
    seq.start(env.axi_agnt.sequencer);
    
    `uvm_info(get_type_name(), "最大传输测试完成", UVM_LOW)
  endtask
  
  // 测试最小传输
  virtual task test_min_transfer();
    axi_single_seq seq;
    
    `uvm_info(get_type_name(), "测试最小传输", UVM_LOW)
    
    // 单字节传输
    seq = axi_single_seq::type_id::create("seq");
    seq.addr = 32'h0000_0000;
    seq.data = 32'h12;
    seq.size = 3'd0;  // 1 字节
    
    seq.start(env.axi_agnt.sequencer);
    
    `uvm_info(get_type_name(), "最小传输测试完成", UVM_LOW)
  endtask
  
  // 测试跨 4KB 边界
  virtual task test_cross_boundary();
    axi_burst_seq seq;
    
    `uvm_info(get_type_name(), "测试跨 4KB 边界", UVM_LOW)
    
    seq = axi_burst_seq::type_id::create("seq");
    seq.addr = 32'h0000_F000;  // 接近 4KB 边界
    seq.len = 8'd8;
    seq.size = 3'd2;
    seq.burst = 2'd1;
    
    seq.start(env.axi_agnt.sequencer);
    
    `uvm_info(get_type_name(), "跨边界测试完成", UVM_LOW)
  endtask
  
  // 测试保留地址
  virtual task test_reserved_address();
    axi_single_seq seq;
    
    `uvm_info(get_type_name(), "测试保留地址", UVM_LOW)
    
    seq = axi_single_seq::type_id::create("seq");
    seq.addr = 32'hFFFF_FFF0;  // 保留地址
    seq.data = 32'hDEAD_BEEF;
    seq.size = 3'd2;
    
    // 预期会收到错误响应
    seq.start(env.axi_agnt.sequencer);
    
    `uvm_info(get_type_name(), "保留地址测试完成", UVM_LOW)
  endtask
  
endclass : axi_boundary_test

`endif // AXI_BOUNDARY_TEST_SV
