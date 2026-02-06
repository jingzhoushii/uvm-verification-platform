// ============================================================
// File: apb_agent.sv
// Description: APB Agent
// Author: UVM Verification Platform
// Created: 2026-02-07
// ============================================================

`ifndef APB_AGENT_SV
`define APB_AGENT_SV

// -----------------------------------------------
// Class: apb_driver
// -----------------------------------------------
class apb_driver extends uvm_driver#(apb_transaction);
    
    virtual apb_if.vif vif;
    apb_config cfg;
    
    `uvm_component_utils_begin(apb_driver)
    `uvm_component_utils_end
    
    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(virtual apb_if.vif)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "未找到 APB 虚拟接口")
        end
        
        if (!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg)) begin
            cfg = apb_config::type_id::create("cfg");
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive(apb_transaction tr);
        // 等待复位
        wait (vif.presetn === 1'b1);
        
        // 等待一个周期
        @(posedge vif.pclk);
        
        // 阶段 1: 设置地址和控制
        vif.paddr   <= tr.paddr;
        vif.pwdata  <= tr.pwdata;
        vif.pwrite <= tr.pwrite;
        vif.pstrb  <= tr.pstrb;
        vif.pprot  <= tr.pprot;
        vif.psel   <= 1'b1;
        vif.penable <= 1'b0;
        
        // 阶段 2: 使能
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        
        // 等待响应
        wait (vif.pready === 1'b1);
        
        // 采样读数据
        if (!tr.pwrite) begin
            tr.prdata = vif.prdata;
            `uvm_info(get_type_name(), $sformatf("APB 读: addr=0x%08h, data=0x%08h", 
                tr.paddr, tr.prdata), UVM_LOW)
        end else begin
            `uvm_info(get_type_name(), $sformatf("APB 写: addr=0x%08h, data=0x%08h", 
                tr.paddr, tr.pwdata), UVM_LOW)
        end
        
        // 结束传输
        @(posedge vif.pclk);
        vif.psel   <= 1'b0;
        vif.penable <= 1'b0;
    endtask
    
endclass : apb_driver

// -----------------------------------------------
// Class: apb_monitor
// -----------------------------------------------
class apb_monitor extends uvm_monitor;
    
    virtual apb_if.vif vif;
    uvm_analysis_port#(apb_transaction) ap;
    apb_config cfg;
    
    `uvm_component_utils_begin(apb_monitor)
    `uvm_component_utils_end
    
    function new(string name = "apb_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(virtual apb_if.vif)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "未找到 APB 虚拟接口")
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            monitor_transfer();
        end
    endtask
    
    virtual task monitor_transfer();
        apb_transaction tr;
        tr = apb_transaction::type_id::create("tr");
        
        // 等待传输开始
        wait (vif.psel === 1'b1 && vif.penable === 1'b0);
        
        // 采样地址和控制
        tr.paddr = vif.paddr;
        tr.pwrite = vif.pwrite;
        tr.pstrb = vif.pstrb;
        tr.pprot = vif.pprot;
        
        // 等待数据阶段
        wait (vif.penable === 1'b1 && vif.pready === 1'b1);
        
        // 采样数据
        if (tr.pwrite) begin
            tr.pwdata = vif.pwdata;
        end else begin
            tr.prdata = vif.prdata;
        end
        
        `uvm_info(get_type_name(), tr.convert2string(), UVM_LOW)
        
        ap.write(tr);
    endtask
    
endclass : apb_monitor

// -----------------------------------------------
// Class: apb_sequencer
// -----------------------------------------------
class apb_sequencer extends uvm_sequencer#(apb_transaction);
    
    `uvm_component_utils_begin(apb_sequencer)
    `uvm_component_utils_end
    
    function new(string name = "apb_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass : apb_sequencer

// -----------------------------------------------
// Class: apb_agent
// -----------------------------------------------
class apb_agent extends uvm_agent;
    
    apb_driver       driver;
    apb_monitor      monitor;
    apb_sequencer    sequencer;
    apb_config       cfg;
    virtual apb_if.vif vif;
    
    `uvm_component_utils_begin(apb_agent)
    `uvm_component_utils_end
    
    function new(string name = "apb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(apb_config)::get(this, "", "cfg", cfg)) begin
            cfg = apb_config::type_id::create("cfg");
        end
        
        if (!uvm_config_db#(virtual apb_if.vif)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "未找到 APB 虚拟接口")
        end
        
        if (cfg.is_active == UVM_ACTIVE) begin
            driver = apb_driver::type_id::create("driver", this);
            sequencer = apb_sequencer::type_id::create("sequencer", this);
        end
        
        monitor = apb_monitor::type_id::create("monitor", this);
        
        uvm_config_db#(virtual apb_if.vif)::set(this, "*", "vif", vif);
        uvm_config_db#(apb_config)::set(this, "*", "cfg", cfg);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if (cfg.is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
    
endclass : apb_agent

`endif // APB_AGENT_SV
