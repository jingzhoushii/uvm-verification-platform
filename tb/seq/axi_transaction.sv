// ============================================================
// File: axi_transaction.sv
// Description: AXI 事务基类
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef AXI_TRANSACTION_SV
`define AXI_TRANSACTION_SV

// -----------------------------------------------
// Class: axi_transaction
// -----------------------------------------------
class axi_transaction extends uvm_sequence_item;
  
  // -----------------------------------------------
  // 字段定义
  // -----------------------------------------------
  rand axi_cmd_enum   cmd;      // READ/WRITE
  rand bit [31:0]     addr;     // 地址
  rand bit [31:0]     data[];   // 数据数组
  rand bit [7:0]      len;      // 突发长度 (1-16)
  rand bit [2:0]      size;     // 突发大小 (1,2,4,8 bytes)
  rand bit [1:0]      burst;    // 突发类型 (FIXED, INCR, WRAP)
  
  // 响应
  bit [31:0]          rdata[];  // 读数据
  bit [1:0]           resp;     // 响应状态
  
  // 约束
  constraint valid_len {
    len inside {[1:16]};
  }
  
  constraint valid_size {
    size inside {1, 2, 4, 8};
  }
  
  constraint valid_burst {
    burst inside {0, 1, 2};  // FIXED, INCR, WRAP
  }
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_object_utils_begin(axi_transaction)
    `uvm_field_enum (axi_cmd_enum, cmd,   UVM_ALL_ON)
    `uvm_field_int  (addr,              UVM_ALL_ON)
    `uvm_field_array_int(data,          UVM_ALL_ON)
    `uvm_field_int  (len,               UVM_ALL_ON)
    `uvm_field_int  (size,              UVM_ALL_ON)
    `uvm_field_int  (burst,             UVM_ALL_ON)
    `uvm_field_array_int(rdata,         UVM_ALL_ON)
    `uvm_field_int  (resp,              UVM_ALL_ON)
  `uvm_object_utils_end
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_transaction");
    super.new(name);
  endfunction
  
  // -----------------------------------------------
  // 函数: do_print
  // -----------------------------------------------
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_string("cmd", cmd.name());
    printer.print_field("addr", addr, 32, UVM_HEX);
    printer.print_field("len", len, 8, UVM_DEC);
    printer.print_field("size", size, 3, UVM_DEC);
    printer.print_field("burst", burst, 2, UVM_DEC);
  endfunction
  
  // -----------------------------------------------
  // 函数: do_copy
  // -----------------------------------------------
  virtual function void do_copy(uvm_object rhs);
    axi_transaction rhs_;
    super.do_copy(rhs);
    $cast(rhs_, rhs);
    cmd   = rhs_.cmd;
    addr  = rhs_.addr;
    data  = rhs_.data;
    len   = rhs_.len;
    size  = rhs_.size;
    burst = rhs_.burst;
    rdata = rhs_.rdata;
    resp  = rhs_.resp;
  endfunction
  
  // -----------------------------------------------
  // 函数: do_compare
  // -----------------------------------------------
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    axi_transaction rhs_;
    do_compare = super.do_compare(rhs, comparer);
    $cast(rhs_, rhs);
    do_compare &= (cmd == rhs_.cmd);
    do_compare &= (addr == rhs_.addr);
    do_compare &= (len == rhs_.len);
  endfunction
  
endclass : axi_transaction

// -----------------------------------------------
// Enum: axi_cmd_enum
// -----------------------------------------------
typedef enum bit {READ = 0, WRITE = 1} axi_cmd_enum;

`endif // AXI_TRANSACTION_SV
