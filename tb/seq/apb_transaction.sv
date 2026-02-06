// ============================================================
// File: apb_transaction.sv
// Description: APB 事务定义
// Author: UVM Verification Platform
// Created: 2026-02-07
// ============================================================

`ifndef APB_TRANSACTION_SV
`define APB_TRANSACTION_SV

// APB 事务类
class apb_transaction extends uvm_sequence_item;
    
    // -----------------------------------------------
    // 字段
    // -----------------------------------------------
    rand bit [31:0]  paddr;      // 地址
    rand bit [31:0]  pwdata;    // 写数据
    rand bit [31:0]  prdata;     // 读数据
    rand bit         pwrite;     // 读/写 (1=write)
    rand bit [3:0]   pstrb;     // 字节使能
    rand bit [2:0]   pprot;      // 保护信号
    rand bit         penable;    // 使能信号
    rand bit         psel;       // 选择信号
    
    // 控制字段
    rand int         delay;      // 延迟周期
    
    // 约束
    constraint valid_addr {
        paddr inside {[32'h0000_0000:32'h0FFF_FFFF]};
    }
    
    constraint valid_strb {
        pstrb inside {[4'h0:4'hF]};
    }
    
    constraint delay_range {
        delay inside {[0:5]};
    }
    
    // -----------------------------------------------
    // 注册
    // -----------------------------------------------
    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_int(paddr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(pwdata, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(prdata, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(pwrite, UVM_ALL_ON)
        `uvm_field_int(pstrb, UVM_ALL_ON)
        `uvm_field_int(pprot, UVM_ALL_ON)
        `uvm_field_int(delay, UVM_ALL_ON)
    `uvm_object_utils_end
    
    // -----------------------------------------------
    // 构造函数
    // -----------------------------------------------
    function new(string name = "apb_transaction");
        super.new(name);
        
        // 默认值
        paddr = 32'h0;
        pwdata = 32'h0;
        pwrite = 1'b1;
        pstrb = 4'hF;  // 所有字节使能
        pprot = 3'b000;
        delay = 0;
    endfunction
    
    // -----------------------------------------------
    // 方法
    // -----------------------------------------------
    function void do_print(uvm_printer printer);
        super.do_print(printer);
        
        printer.print_field("paddr", paddr, 32, UVM_HEX);
        printer.print_field("pwdata", pwdata, 32, UVM_HEX);
        printer.print_field("prdata", prdata, 32, UVM_HEX);
        printer.print_field("pwrite", pwrite, 1);
        printer.print_field("pstrb", pstrb, 4);
    endfunction
    
    function string convert2string();
        string s;
        s = $sformatf("APB: addr=0x%08h, wdata=0x%08h, rdata=0x%08h, write=%0d",
            paddr, pwdata, prdata, pwrite);
        return s;
    endfunction
    
    function void do_copy(uvm_object rhs);
        apb_transaction tr;
        super.do_copy(rhs);
        
        if (!$cast(tr, rhs)) return;
        
        paddr = tr.paddr;
        pwdata = tr.pwdata;
        prdata = tr.prdata;
        pwrite = tr.pwrite;
        pstrb = tr.pstrb;
        pprot = tr.pprot;
        delay = tr.delay;
    endfunction
    
endclass : apb_transaction

`endif // APB_TRANSACTION_SV
