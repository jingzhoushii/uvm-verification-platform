// ============================================================
// File: base_seq.sv
// Description: AXI 基类序列
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef BASE_SEQ_SV
`define BASE_SEQ_SV

// -----------------------------------------------
// Class: axi_base_seq
// -----------------------------------------------
class axi_base_seq extends uvm_sequence#(axi_transaction);
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_object_utils(axi_base_seq)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_base_seq");
    super.new(name);
  endfunction
  
  // -----------------------------------------------
  // body 任务
  // -----------------------------------------------
  virtual task body();
    `uvm_info(get_type_name(), "执行基类序列", UVM_LOW)
  endtask
  
endclass : axi_base_seq

// ============================================================
// Class: axi_write_seq
// ============================================================
class axi_write_seq extends uvm_sequence#(axi_transaction);
  
  // -----------------------------------------------
  // 字段
  // -----------------------------------------------
  rand bit [31:0]  addr;
  rand bit [31:0]  data[];
  rand bit [7:0]   len;
  rand bit [2:0]   size;
  rand bit [1:0]   burst;
  
  constraint valid_data {
    data.size() == len + 1;
    foreach (data[i]) data[i] == 32'h0;  // 默认值
  }
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_object_utils(axi_write_seq)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_write_seq");
    super.new(name);
  endfunction
  
  // -----------------------------------------------
  // body 任务
  // -----------------------------------------------
  virtual task body();
    axi_transaction req;
    
    `uvm_info(get_type_name(), $sformatf("执行写序列: addr=0x%0h, len=%0d", 
      addr, len), UVM_LOW)
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize() with {
      cmd == WRITE;
      local::addr  inside {[32'h0000_0000:32'h0FFF_FFFF]};
      local::len   == len;
      local::size  == size;
      local::burst == burst;
    }) begin
      `uvm_error(get_type_name(), "随机化失败")
    end
    
    req.addr = addr;
    req.data = data;
    
    finish_item(req);
    
    `uvm_info(get_type_name(), "写序列完成", UVM_LOW)
  endtask
  
endclass : axi_write_seq

// ============================================================
// Class: axi_read_seq
// ============================================================
class axi_read_seq extends uvm_sequence#(axi_transaction);
  
  // -----------------------------------------------
  // 字段
  // -----------------------------------------------
  rand bit [31:0]  addr;
  rand bit [7:0]   len;
  rand bit [2:0]   size;
  rand bit [1:0]   burst;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_object_utils(axi_read_seq)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_read_seq");
    super.new(name);
  endfunction
  
  // -----------------------------------------------
  // body 任务
  // -----------------------------------------------
  virtual task body();
    axi_transaction req;
    
    `uvm_info(get_type_name(), $sformatf("执行读序列: addr=0x%0h, len=%0d", 
      addr, len), UVM_LOW)
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize() with {
      cmd == READ;
      local::addr inside {[32'h0000_0000:32'h0FFF_FFFF]};
      local::len  == len;
      local::size == size;
      local::burst == burst;
    }) begin
      `uvm_error(get_type_name(), "随机化失败")
    end
    
    req.addr = addr;
    finish_item(req);
    
    `uvm_info(get_type_name(), "读序列完成", UVM_LOW)
  endtask
  
endclass : axi_read_seq

// ============================================================
// Class: axi_random_seq
// ============================================================
class axi_random_seq extends uvm_sequence#(axi_transaction);
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_object_utils(axi_random_seq)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_random_seq");
    super.new(name);
  endfunction
  
  // -----------------------------------------------
  // body 任务
  // -----------------------------------------------
  virtual task body();
    axi_transaction req;
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize()) begin
      `uvm_error(get_type_name(), "随机化失败")
    end
    
    `uvm_info(get_type_name(), $sformatf("随机事务: cmd=%s, addr=0x%0h", 
      req.cmd.name(), req.addr), UVM_LOW)
    
    finish_item(req);
  endtask
  
endclass : axi_random_seq

// ============================================================
// Class: axi_error_seq
// ============================================================
class axi_error_seq extends uvm_sequence#(axi_transaction);
  
  `uvm_object_utils(axi_error_seq)
  
  function new(string name = "axi_error_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    axi_transaction req;
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    // 错误注入：无效地址
    if (!req.randomize() with {
      cmd == READ;
      addr == 32'hFFFF_FFFF;  // 无效地址
    }) begin
      `uvm_error(get_type_name(), "随机化失败")
    end
    
    `uvm_info(get_type_name(), "错误注入: 访问无效地址", UVM_LOW)
    
    finish_item(req);
  endtask
  
endclass : axi_error_seq

`endif // BASE_SEQ_SV
