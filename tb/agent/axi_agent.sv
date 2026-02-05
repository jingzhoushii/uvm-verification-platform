// ============================================================
// File: axi_agent.sv
// Description: AXI Agent (Driver + Monitor + Sequencer)
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef AXI_AGENT_SV
`define AXI_AGENT_SV

// -----------------------------------------------
// Class: axi_agent
// -----------------------------------------------
class axi_agent extends uvm_agent;
  
  // -----------------------------------------------
  // 组件声明
  // -----------------------------------------------
  axi_driver        driver;
  axi_monitor      monitor;
  axi_sequencer    sequencer;
  uvm_analysis_port#(axi_transaction) ap;
  
  // 虚接口
  virtual axi4l_intf  vif;
  
  // is_active 开关
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(axi_agent)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // 获取虚接口
    if (!uvm_config_db#(virtual axi4l_intf)::get(this, "", "axi4l_vif", vif)) begin
      `uvm_fatal("NO_VIF", "无法获取 axi4l_vif")
    end
    
    // 获取 is_active 配置
    if (uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active)) begin
      `uvm_info(get_type_name(), $sformatf("is_active = %s", is_active.name()), UVM_LOW)
    end
    
    // 创建子组件
    monitor = axi_monitor::type_id::create("monitor", this);
    ap = new("ap", this);
    
    if (is_active == UVM_ACTIVE) begin
      driver = axi_driver::type_id::create("driver", this);
      sequencer = axi_sequencer::type_id::create("sequencer", this);
    end
    
    `uvm_info(get_type_name(), "AXI Agent 构建完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // connect_phase
  // -----------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // 连接 driver 到 sequencer
    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    // 连接 monitor 到 analysis port
    monitor.ap.connect(ap);
    
    `uvm_info(get_type_name(), "AXI Agent 连接完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "AXI Agent 运行中", UVM_LOW)
  endtask
  
endclass : axi_agent

// ============================================================
// Class: axi_driver
// ============================================================
class axi_driver extends uvm_driver#(axi_transaction);
  
  virtual axi4l_intf vif;
  
  `uvm_component_utils(axi_driver)
  
  function new(string name = "axi_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4l_intf)::get(this, "", "axi4l_vif", vif)) begin
      `uvm_fatal("NO_VIF", "无法获取 axi4l_vif")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      seq_item_port.get_next_item(req);
      drive_transaction(req);
      seq_item_port.item_done();
    end
  endtask
  
  virtual protected task drive_transaction(axi_transaction tr);
    // TODO: 实现驱动逻辑
    `uvm_info(get_type_name(), $sformatf("驱动事务: addr=0x%0h, data=0x%0h", 
      tr.addr, tr.data), UVM_LOW)
  endtask
  
endclass : axi_driver

// ============================================================
// Class: axi_monitor
// ============================================================
class axi_monitor extends uvm_monitor;
  
  virtual axi4l_intf vif;
  uvm_analysis_port#(axi_transaction) ap;
  
  `uvm_component_utils(axi_monitor)
  
  function new(string name = "axi_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4l_intf)::get(this, "", "axi4l_vif", vif)) begin
      `uvm_fatal("NO_VIF", "无法获取 axi4l_vif")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      @(vif.mon_cb);
      // TODO: 实现监控逻辑
    end
  endtask
  
endclass : axi_monitor

// ============================================================
// Class: axi_sequencer
// ============================================================
class axi_sequencer extends uvm_sequencer#(axi_transaction);
  
  `uvm_component_utils(axi_sequencer)
  
  function new(string name = "axi_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass : axi_sequencer

`endif // AXI_AGENT_SV
