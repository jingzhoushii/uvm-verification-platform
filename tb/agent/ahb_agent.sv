// ============================================================
// File: ahb_agent.sv
// Description: AHB Agent
// Author: UVM Verification Platform
// Created: 2026-02-07
// ============================================================

`ifndef AHB_AGENT_SV
`define AHB_AGENT_SV

// -----------------------------------------------
// Class: ahb_driver
// -----------------------------------------------
class ahb_driver extends uvm_driver#(ahb_transaction);
    
    // 虚拟接口
    virtual ahb_if.vif vif;
    
    // 配置
    ahb_config cfg;
    
    // 日志
    `uvm_component_utils_begin(ahb_driver)
    `uvm_component_utils_end
    
    function new(string name = "ahb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(virtual ahb_if.vif)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "未找到 AHB 虚拟接口")
        end
        
        if (!uvm_config_db#(ahb_config)::get(this, "", "cfg", cfg)) begin
            cfg = ahb_config::type_id::create("cfg");
        end
    endfunction
    
    // run_phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end
    endtask
    
    // drive 任务
    virtual task drive(ahb_transaction tr);
        // 等待复位
        wait (vif.hresetn === 1'b1);
        
        // 驱动地址和控制信号
        @(posedge vif.hclk);
        
        // 驱动传输
        if (tr.hwrite) begin
            drive_write(tr);
        end else begin
            drive_read(tr);
        end
    endtask
    
    // 写传输
    virtual task drive_write(ahb_transaction tr);
        // 地址相位
        vif.haddr    <= tr.haddr;
        vif.hsize    <= tr.hsize;
        vif.hburst   <= tr.hburst;
        vif.hwrite   <= 1'b1;
        vif.htrans   <= tr.htrans;
        vif.hmastlock <= tr.hmastlock;
        vif.hprot    <= tr.hprot;
        
        // 等待 hready
        wait (vif.hready === 1'b1);
        
        // 驱动数据
        for (int i = 0; i < (1 << tr.hsize); i++) begin
            vif.hwdata[i*8 +: 8] <= tr.hwdata[i];
        end
        
        `uvm_info(get_type_name(), $sformatf("写传输: addr=0x%08h", tr.haddr), UVM_LOW)
    endtask
    
    // 读传输
    virtual task drive_read(ahb_transaction tr);
        // 地址相位
        vif.haddr    <= tr.haddr;
        vif.hsize    <= tr.hsize;
        vif.hburst   <= tr.hburst;
        vif.hwrite   <= 1'b0;
        vif.htrans   <= tr.htrans;
        vif.hmastlock <= tr.hmastlock;
        vif.hprot    <= tr.hprot;
        
        // 等待 hready
        wait (vif.hready === 1'b1);
        
        // 采样数据
        for (int i = 0; i < (1 << tr.hsize); i++) begin
            tr.hrdata[i] = vif.hrdata[i*8 +: 8];
        end
        
        `uvm_info(get_type_name(), $sformatf("读传输: addr=0x%08h, data=0x%08h", 
            tr.haddr, tr.hrdata[0]), UVM_LOW)
    endtask
    
endclass : ahb_driver

// -----------------------------------------------
// Class: ahb_monitor
// -----------------------------------------------
class ahb_monitor extends uvm_monitor;
    
    // 虚拟接口
    virtual ahb_if.vif vif;
    
    // 分析端口
    uvm_analysis_port#(ahb_transaction) ap;
    
    // 配置
    ahb_config cfg;
    
    // 日志
    `uvm_component_utils_begin(ahb_monitor)
    `uvm_component_utils_end
    
    function new(string name = "ahb_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    // build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        if (!uvm_config_db#(virtual ahb_if.vif)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "未找到 AHB 虚拟接口")
        end
        
        if (!uvm_config_db#(ahb_config)::get(this, "", "cfg", cfg)) begin
            cfg = ahb_config::type_id::create("cfg");
        end
    endfunction
    
    // run_phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            monitor_transfer();
        end
    endtask
    
    // monitor 任务
    virtual task monitor_transfer();
        ahb_transaction tr;
        tr = ahb_transaction::type_id::create("tr");
        
        // 等待传输开始
        wait (vif.htrans != AHB_IDLE && vif.hready === 1'b1);
        
        // 采样地址和控制
        tr.haddr = vif.haddr;
        tr.hsize = vif.hsize;
        tr.hburst = vif.hburst;
        tr.hwrite = vif.hwrite;
        tr.htrans = vif.htrans;
        tr.hmastlock = vif.hmastlock;
        tr.hprot = vif.hprot;
        
        // 采样数据
        if (tr.hwrite) begin
            for (int i = 0; i < (1 << tr.hsize); i++) begin
                tr.hwdata[i] = vif.hwdata[i*8 +: 8];
            end
            `uvm_info(get_type_name(), $sformatf("监控写: addr=0x%08h", tr.haddr), UVM_LOW)
        end else begin
            for (int i = 0; i < (1 << tr.hsize); i++) begin
                tr.hrdata[i] = vif.hrdata[i*8 +: 8];
            end
            `uvm_info(get_type_name(), $sformatf("监控读: addr=0x%08h, data=0x%08h", 
                tr.haddr, tr.hrdata[0]), UVM_LOW)
        end
        
        // 发送到 scoreboard
        ap.write(tr);
    endtask
    
endclass : ahb_monitor

// -----------------------------------------------
// Class: ahb_sequencer
// -----------------------------------------------
class ahb_sequencer extends uvm_sequencer#(ahb_transaction);
    
    `uvm_component_utils_begin(ahb_sequencer)
    `uvm_component_utils_end
    
    function new(string name = "ahb_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass : ahb_sequencer

// -----------------------------------------------
// Class: ahb_agent
// -----------------------------------------------
class ahb_agent extends uvm_agent;
    
    // 子组件
    ahb_driver       driver;
    ahb_monitor      monitor;
    ahb_sequencer    sequencer;
    
    // 配置
    ahb_config cfg;
    
    // 虚拟接口
    virtual ahb_if.vif vif;
    
    // 日志
    `uvm_component_utils_begin(ahb_agent)
    `uvm_component_utils_end
    
    function new(string name = "ahb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // 获取配置
        if (!uvm_config_db#(ahb_config)::get(this, "", "cfg", cfg)) begin
            cfg = ahb_config::type_id::create("cfg");
        end
        
        // 获取接口
        if (!uvm_config_db#(virtual ahb_if.vif)::get(this, "", "vif", vif)) begin
            `uvm_error(get_type_name(), "未找到 AHB 虚拟接口")
        end
        
        // 创建子组件
        if (cfg.is_active == UVM_ACTIVE) begin
            driver = ahb_driver::type_id::create("driver", this);
            sequencer = ahb_sequencer::type_id::create("sequencer", this);
        end
        
        monitor = ahb_monitor::type_id::create("monitor", this);
        
        // 配置虚拟接口
        uvm_config_db#(virtual ahb_if.vif)::set(this, "*", "vif", vif);
        uvm_config_db#(ahb_config)::set(this, "*", "cfg", cfg);
    endfunction
    
    // connect_phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if (cfg.is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
        
        monitor.ap.connect(env.ahb_sb.ap);
    endfunction
    
endclass : ahb_agent

`endif // AHB_AGENT_SV
