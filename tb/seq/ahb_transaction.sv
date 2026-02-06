// ============================================================
// File: ahb_transaction.sv
// Description: AHB 事务定义
// Author: UVM Verification Platform
// Created: 2026-02-07
// ============================================================

`ifndef AHB_TRANSACTION_SV
`define AHB_TRANSACTION_SV

// AHB 命令类型
typedef enum bit [1:0] {
    AHB_IDLE   = 2'b00,
    AHB_BUSY   = 2'b01,
    AHB_NONSEQ = 2'b10,
    AHB_SEQ    = 2'b11
} ahb_cmd_t;

// AHB 响应类型
typedef enum bit [1:0] {
    AHB_OKAY   = 2'b00,
    AHB_ERROR  = 2'b01,
    AHB_RETRY  = 2'b10,
    AHB_SPLIT  = 2'b11
} ahb_resp_t;

// AHB 传输类型
typedef enum bit [2:0] {
    AHB_SINGLE = 3'b000,
    AHB_INCR   = 3'b001,
    AHB_WRAP4  = 3'b010,
    AHB_INCR4  = 3'b011,
    AHB_WRAP8  = 3'b100,
    AHB_INCR8  = 3'b101,
    AHB_WRAP16 = 3'b110,
    AHB_INCR16 = 3'b111
} ahb_burst_t;

// AHB 事务类
class ahb_transaction extends uvm_sequence_item;
    
    // -----------------------------------------------
    // 字段
    // -----------------------------------------------
    rand bit [31:0]  haddr;      // 地址
    rand bit [31:0]  hwdata[];  // 写数据数组
    rand bit [31:0]  hrdata[];  // 读数据数组
    rand bit [7:0]   hsize;     // 数据大小 (0-7)
    rand bit [2:0]   hburst;    // 突发类型
    rand bit [1:0]   hprot;     // 保护信号
    rand bit         hwrite;    // 读/写 (1=write)
    rand bit [1:0]   htrans;    // 传输类型
    rand bit         hmastlock; // 主机锁定
    rand ahb_resp_t  hresp;     // 响应
    
    // 控制字段
    rand int         delay;     // 延迟周期
    rand bit         ready;     // 就绪信号
    
    // 约束
    constraint valid_size {
        hsize inside {[0:3]};  // 1,2,4,8 字节
    }
    
    constraint valid_burst {
        hburst inside {[0:7]};
    }
    
    constraint valid_trans {
        htrans inside {[0:3]};
    }
    
    constraint data_size {
        hwdata.size() == (1 << hsize);
        hrdata.size() == (1 << hsize);
    }
    
    constraint delay_range {
        delay inside {[0:10]};
    }
    
    // -----------------------------------------------
    // 注册
    // -----------------------------------------------
    `uvm_object_utils_begin(ahb_transaction)
        `uvm_field_int(haddr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_array_int(hwdata, UVM_ALL_ON | UVM_HEX)
        `uvm_field_array_int(hrdata, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(hsize, UVM_ALL_ON)
        `uvm_field_int(hburst, UVM_ALL_ON)
        `uvm_field_int(hprot, UVM_ALL_ON)
        `uvm_field_int(hwrite, UVM_ALL_ON)
        `uvm_field_int(htrans, UVM_ALL_ON)
        `uvm_field_int(hmastlock, UVM_ALL_ON)
        `uvm_field_enum(ahb_resp_t, hresp, UVM_ALL_ON)
        `uvm_field_int(delay, UVM_ALL_ON)
    `uvm_object_utils_end
    
    // -----------------------------------------------
    // 构造函数
    // -----------------------------------------------
    function new(string name = "ahb_transaction");
        super.new(name);
        
        // 初始化数组
        hwdata = new[1];
        hrdata = new[1];
        
        // 默认值
        haddr = 32'h0;
        hsize = 2;  // 4 字节
        hburst = AHB_SINGLE;
        hwrite = 1'b1;
        htrans = AHB_NONSEQ;
        hresp = AHB_OKAY;
        delay = 0;
    endfunction
    
    // -----------------------------------------------
    // 方法
    // -----------------------------------------------
    
    // 打印函数
    function void do_print(uvm_printer printer);
        super.do_print(printer);
        
        printer.print_field("haddr", haddr, 32, UVM_HEX);
        printer.print_field("hsize", hsize, 8);
        printer.print_field("hburst", hburst, 3);
        printer.print_field("hwrite", hwrite, 1);
        printer.print_field("htrans", htrans, 2);
        printer.print_field("hresp", hresp, 2);
    endfunction
    
    // 转换为字符串
    function string convert2string();
        string s;
        s = $sformatf("AHB: addr=0x%08h, size=%0d, burst=%0d, write=%0d, trans=%0d",
            haddr, hsize, hburst, hwrite, htrans);
        return s;
    endfunction
    
    // 复制函数
    function void do_copy(uvm_object rhs);
        ahb_transaction tr;
        super.do_copy(rhs);
        
        if (!$cast(tr, rhs)) return;
        
        haddr = tr.haddr;
        hsize = tr.hsize;
        hburst = tr.hburst;
        hwrite = tr.hwrite;
        htrans = tr.htrans;
        hresp = tr.hresp;
        delay = tr.delay;
    endfunction
    
endclass : ahb_transaction

`endif // AHB_TRANSACTION_SV
