// ============================================================
// File: ahb_single_test.sv
// Description: AHB 单次传输测试
// Author: UVM Verification Platform
// Created: 2026-02-07
// ============================================================

`ifndef AHB_SINGLE_TEST_SV
`define AHB_SINGLE_TEST_SV

class ahb_single_test extends base_test;
    
    `uvm_component_utils(ahb_single_test)
    
    function new(string name = "ahb_single_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        int i;
        ahb_single_seq seq;
        
        `uvm_info(get_type_name(), "开始 AHB 单次传输测试", UVM_LOW)
        
        phase.raise_objection(this);
        
        for (i = 0; i < 10; i++) begin
            seq = ahb_single_seq::type_id::create("seq");
            seq.addr = 32'h1000 + (i * 4);
            seq.data = 32'hA5A5_A5A0 + i;
            
            `uvm_info(get_type_name(), $sformatf("传输 %0d: addr=0x%08h, data=0x%08h", 
                i, seq.addr, seq.data), UVM_LOW)
            
            seq.start(env.ahb_agnt.sequencer);
        end
        
        phase.drop_objection(this);
        
        `uvm_info(get_type_name(), "AHB 单次传输测试完成", UVM_LOW)
    endtask
    
endclass : ahb_single_test

// -----------------------------------------------
// Class: ahb_single_seq
// -----------------------------------------------
class ahb_single_seq extends uvm_sequence#(ahb_transaction);
    
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [2:0] size = 3'd2;  // 4 字节
    
    `uvm_object_utils(ahb_single_seq)
    
    function new(string name = "ahb_single_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        ahb_transaction req;
        
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        
        if (!req.randomize() with {
            haddr == local::addr;
            hsize == local::size;
            hburst == AHB_SINGLE;
            hwrite == 1'b1;
            htrans == AHB_NONSEQ;
        }) begin `uvm_error(get_type_name(), "随机化失败") end
        
        req.hwdata = '{data};
        
        finish_item(req);
        
        `uvm_info(get_type_name(), $sformatf("单次写: addr=0x%08h, data=0x%08h", addr, data), UVM_LOW)
    endtask
    
endclass : ahb_single_seq

`endif // AHB_SINGLE_TEST_SV
