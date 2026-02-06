// ============================================================
// File: apb_single_test.sv
// Description: APB 单次传输测试
// Author: UVM Verification Platform
// Created: 2026-02-07
// ============================================================

`ifndef APB_SINGLE_TEST_SV
`define APB_SINGLE_TEST_SV

class apb_single_test extends base_test;
    
    `uvm_component_utils(apb_single_test)
    
    function new(string name = "apb_single_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        int i;
        apb_single_seq seq;
        
        `uvm_info(get_type_name(), "开始 APB 单次传输测试", UVM_LOW)
        
        phase.raise_objection(this);
        
        // 写测试
        for (i = 0; i < 5; i++) begin
            seq = apb_single_seq::type_id::create("seq");
            seq.pwrite = 1'b1;
            seq.paddr = 32'h4000_0000 + (i * 4);
            seq.pwdata = 32'h5A5A_5A00 + i;
            
            `uvm_info(get_type_name(), $sformatf("APB 写 %0d: addr=0x%08h, data=0x%08h", 
                i, seq.paddr, seq.pwdata), UVM_LOW)
            
            seq.start(env.apb_agnt.sequencer);
        end
        
        // 读测试
        for (i = 0; i < 5; i++) begin
            seq = apb_single_seq::type_id::create("seq");
            seq.pwrite = 1'b0;
            seq.paddr = 32'h4000_0000 + (i * 4);
            
            `uvm_info(get_type_name(), $sformatf("APB 读 %0d: addr=0x%08h", 
                i, seq.paddr), UVM_LOW)
            
            seq.start(env.apb_agnt.sequencer);
        end
        
        phase.drop_objectition(this);
        
        `uvm_info(get_type_name(), "APB 单次传输测试完成", UVM_LOW)
    endtask
    
endclass : apb_single_test

// -----------------------------------------------
// Class: apb_single_seq
// -----------------------------------------------
class apb_single_seq extends uvm_sequence#(apb_transaction);
    
    rand bit [31:0] paddr;
    rand bit [31:0] pwdata;
    rand bit pwrite = 1'b1;
    rand bit [3:0] pstrb = 4'hF;
    
    `uvm_object_utils(apb_single_seq)
    
    function new(string name = "apb_single_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        apb_transaction req;
        
        req = apb_transaction::type_id::create("req");
        start_item(req);
        
        if (!req.randomize() with {
            paddr == local::paddr;
            pwdata == local::pwdata;
            pwrite == local::pwrite;
            pstrb == local::pstrb;
        }) begin `uvm_error(get_type_name(), "随机化失败") end
        
        finish_item(req);
    endtask
    
endclass : apb_single_seq

`endif // APB_SINGLE_TEST_SV
