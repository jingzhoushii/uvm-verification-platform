// ============================================================
// File: axi_seq_lib.sv
// Description: AXI 完整序列库
// Author: UVM Verification Platform
// Created: 2026-02-06
// ============================================================

`ifndef AXI_SEQ_LIB_SV
`define AXI_SEQ_LIB_SV

// ============================================================
// Class: axi_single_seq
// Description: AXI 单次传输序列 (无突发)
// ============================================================
class axi_single_seq extends uvm_sequence#(axi_transaction);
  
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit [2:0] size = 3'd2;  // 默认32位
  
  `uvm_object_utils(axi_single_seq)
  
  function new(string name = "axi_single_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    axi_transaction req;
    
    `uvm_info(get_type_name(), $sformatf("单次传输: addr=0x%08h, data=0x%08h", 
      addr, data), UVM_LOW)
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize() with {
      cmd == WRITE;
      local::addr == addr;
      len == 0;  // 单次传输
      local::size == size;
      burst == 0;  // FIXED
    }) begin `uvm_error(get_type_name(), "随机化失败") end
    
    req.data = '{data};
    finish_item(req);
  endtask
  
endclass : axi_single_seq

// ============================================================
// Class: axi_burst_seq
// Description: AXI 突发传输序列
// ============================================================
class axi_burst_seq extends uvm_sequence#(axi_transaction);
  
  rand bit [31:0] addr;
  rand bit [7:0] len = 8'd4;    // 默认4次传输
  rand bit [2:0] size = 3'd2;   // 默认32位
  rand bit [1:0] burst = 2'd1;   // 默认INCR
  
  constraint valid_burst {
    len inside {[1:16]};
    size inside {[0:3]};
    burst inside {[0:2]};
  }
  
  `uvm_object_utils(axi_burst_seq)
  
  function new(string name = "axi_burst_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    int i;
    axi_transaction req;
    
    `uvm_info(get_type_name(), $sformatf("突发传输: addr=0x%08h, len=%0d, burst=%0d", 
      addr, len, burst), UVM_LOW)
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize() with {
      cmd == WRITE;
      local::addr == addr;
      local::len == len;
      local::size == size;
      local::burst == burst;
    }) begin `uvm_error(get_type_name(), "随机化失败") end
    
    // 生成递增数据
    for (i = 0; i <= len; i++) begin
      req.data[i] = data + i;
    end
    
    finish_item(req);
  endtask
  
endclass : axi_burst_seq

// ============================================================
// Class: axi_reg_seq
// Description: AXI 寄存器读写序列
// ============================================================
class axi_reg_seq extends uvm_sequence#(axi_transaction);
  
  typedef enum {READ, WRITE} reg_op_t;
  rand reg_op_t op;
  rand bit [7:0] reg_addr;  // 寄存器地址 (byte地址)
  rand bit [31:0] reg_data;
  rand bit [3:0] wstrb = 4'hF;  // 字节使能
  
  constraint valid_reg_addr {
    reg_addr inside {[8'h00:8'h14]};
  }
  
  `uvm_object_utils(axi_reg_seq)
  
  function new(string name = "axi_reg_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    axi_transaction req;
    bit [31:0] actual_addr = {24'h0, reg_addr};
    
    `uvm_info(get_type_name(), $sformatf("寄存器操作: %s, addr=0x%02x, data=0x%08h", 
      op.name(), reg_addr, reg_data), UVM_LOW)
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize() with {
      cmd == local::op;
      local::addr == actual_addr;
      len == 0;
      size == 3'd2;
      burst == 0;
    }) begin `uvm_error(get_type_name(), "随机化失败") end
    
    if (op == WRITE) begin
      req.data = '{reg_data};
    end
    
    finish_item(req);
  endtask
  
endclass : axi_reg_seq

// ============================================================
// Class: axi_incr_seq
// Description: AXI INCR 突发序列 (递增地址)
// ============================================================
class axi_incr_seq extends uvm_sequence#(axi_transaction);
  
  rand bit [31:0] start_addr;
  rand bit [7:0] len = 8'd8;
  rand bit [2:0] size = 3'd2;
  
  constraint valid_incr {
    len inside {[1:16]};
  }
  
  `uvm_object_utils(axi_incr_seq)
  
  function new(string name = "axi_incr_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    int i;
    axi_transaction req;
    
    `uvm_info(get_type_name(), $sformatf("INCR突发: addr=0x%08h, len=%0d", 
      start_addr, len), UVM_LOW)
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize() with {
      cmd == WRITE;
      local::addr == start_addr;
      local::len == len;
      local::size == size;
      burst == 1;  // INCR
    }) begin `uvm_error(get_type_name(), "随机化失败") end
    
    // 生成地址递增数据
    for (i = 0; i <= len; i++) begin
      req.data[i] = start_addr + (i << size);
    end
    
    finish_item(req);
  endtask
  
endclass : axi_incr_seq

// ============================================================
// Class: axi_wrap_seq
// Description: AXI WRAP 突发序列 (回环地址)
// ============================================================
class axi_wrap_seq extends uvm_sequence#(axi_transaction);
  
  rand bit [31:0] start_addr;
  rand bit [7:0] len = 8'd4;
  rand bit [2:0] size = 3'd2;  // 必须是2^n
  
  constraint valid_wrap {
    len inside {[2, 4, 8, 16]};
    size inside {[2, 3]};  // 4或8字节
    (start_addr[size-1:0] == 0);  // 地址对齐
  }
  
  `uvm_object_utils(axi_wrap_seq)
  
  function new(string name = "axi_wrap_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    int i;
    axi_transaction req;
    
    `uvm_info(get_type_name(), $sformatf("WRAP突发: addr=0x%08h, len=%0d", 
      start_addr, len), UVM_LOW)
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize() with {
      cmd == WRITE;
      local::addr == start_addr;
      local::len == len;
      local::size == size;
      burst == 2;  // WRAP
    }) begin `uvm_error(get_type_name(), "随机化失败") end
    
    for (i = 0; i <= len; i++) begin
      req.data[i] = start_addr + (i << size);
    end
    
    finish_item(req);
  endtask
  
endclass : axi_wrap_seq

// ============================================================
// Class: axi_mem_seq
// Description: AXI 内存读写序列
// ============================================================
class axi_mem_seq extends uvm_sequence#(axi_transaction);
  
  typedef enum {READ, WRITE} mem_op_t;
  rand mem_op_t op;
  rand bit [31:0] addr;
  rand bit [15:0] len = 16'd16;  // 默认16次传输
  rand bit [2:0] size = 3'd2;
  bit [31:0] pattern_data = 32'hDEADBEEF;  // 测试数据
  
  `uvm_object_utils(axi_mem_seq)
  
  function new(string name = "axi_mem_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    int i;
    axi_transaction req;
    
    `uvm_info(get_type_name(), $sformatf("内存操作: %s, addr=0x%08h, len=%0d", 
      op.name(), addr, len), UVM_LOW)
    
    req = axi_transaction::type_id::create("req");
    start_item(req);
    
    if (!req.randomize() with {
      cmd == local::op;
      local::addr == addr;
      local::len == len;
      local::size == size;
      burst == 1;  // INCR
    }) begin `uvm_error(get_type_name(), "随机化失败") end
    
    if (op == WRITE) begin
      for (i = 0; i <= len; i++) begin
        req.data[i] = pattern_data + i;
      end
    end
    
    finish_item(req);
  endtask
  
endclass : axi_mem_seq

// ============================================================
// Class: axi_repeat_seq
// Description: AXI 重复读写序列
// ============================================================
class axi_repeat_seq extends uvm_sequence#(axi_transaction);
  
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand int repeat_count = 10;  // 重复次数
  
  constraint valid_repeat {
    repeat_count inside {[1:100]};
  }
  
  `uvm_object_utils(axi_repeat_seq)
  
  function new(string name = "axi_repeat_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    int i;
    axi_transaction req;
    
    `uvm_info(get_type_name(), $sformatf("重复读写: addr=0x%08h, count=%0d", 
      addr, repeat_count), UVM_LOW)
    
    for (i = 0; i < repeat_count; i++) begin
      // 写
      req = axi_transaction::type_id::create($sformatf("write_%0d", i));
      start_item(req);
      
      if (!req.randomize() with {
        cmd == WRITE;
        local::addr == addr;
        len == 0;
        size == 3'd2;
      }) begin `uvm_error(get_type_name(), "随机化失败") end
      
      req.data = '{data + i};
      finish_item(req);
      
      // 读
      req = axi_transaction::type_id::create($sformatf("read_%0d", i));
      start_item(req);
      
      if (!req.randomize() with {
        cmd == READ;
        local::addr == addr;
        len == 0;
        size == 3'd2;
      }) begin `uvm_error(get_type_name(), "随机化失败") end
      
      finish_item(req);
    end
  endtask
  
endclass : axi_repeat_seq

`endif // AXI_SEQ_LIB_SV
