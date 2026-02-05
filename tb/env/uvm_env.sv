// ============================================================
// File: uvm_env.sv
// Description: UVM 顶层 Environment
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef UVM_ENV_SV
`define UVM_ENV_SV

// -----------------------------------------------
// Class: uvm_env
// -----------------------------------------------
class uvm_env extends uvm_env;
  
  // -----------------------------------------------
  // 组件声明
  // -----------------------------------------------
  axi_env          axi_env;
  uvm_scoreboard   scoreboard;
  uvm_coverage     coverage;
  
  // 虚接口
  virtual axi4l_intf  axi_vif;
  
  // 信号
  bit rst_done = 0;
  bit done = 0;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(uvm_env)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "uvm_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // 获取虚接口
    if (!uvm_config_db#(virtual axi4l_intf)::get(this, "", "axi4l_vif", axi_vif)) begin
      `uvm_fatal("NO_VIF", "无法获取 axi4l_vif")
    end
    
    // 配置虚接口到 db
    uvm_config_db#(virtual axi4l_intf)::set(this, "*", "axi4l_vif", axi_vif);
    
    // 创建组件
    axi_env      = axi_env::type_id::create("axi_env", this);
    scoreboard   = uvm_scoreboard::type_id::create("scoreboard", this);
    coverage     = uvm_coverage::type_id::create("coverage", this);
    
    `uvm_info(get_type_name(), "UVM 环境构建完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // connect_phase
  // -----------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // 连接 agent 到 scoreboard
    axi_env.axi_agnt.monitor.ap.connect(scoreboard.axi_export);
    
    // 连接 agent 到 coverage
    axi_env.axi_agnt.monitor.ap.connect(coverage.axi_export);
    
    // 连接 scoreboard 到 coverage
    // scoreboard.ap.connect(coverage sb_export);
    
    `uvm_info(get_type_name(), "连接完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    // 监控复位
    fork
      monitor_reset(phase);
    join_none
    
    // 监控仿真结束
    fork
      monitor_simulation_end(phase);
    join_none
  endtask
  
  // -----------------------------------------------
  // 任务: monitor_reset
  // -----------------------------------------------
  virtual task monitor_reset(uvm_phase phase);
    wait(axi_vif.rst_n === 1'b1);
    rst_done = 1;
    `uvm_info(get_type_name(), "复位释放", UVM_LOW)
  endtask
  
  // -----------------------------------------------
  // 任务: monitor_simulation_end
  // -----------------------------------------------
  virtual task monitor_simulation_end(uvm_phase phase);
    // 等待测试完成信号
    wait(done === 1'b1);
    phase.drop_objection(this);
  endtask
  
endclass : uvm_env

`endif // UVM_ENV_SV

// ============================================================
// File: axi_env.sv
// Description: AXI Environment
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef AXI_ENV_SV
`define AXI_ENV_SV

class axi_env extends uvm_env;
  
  // -----------------------------------------------
  // 组件声明
  // -----------------------------------------------
  axi_agent        axi_agnt;
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(axi_env)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "axi_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // 创建 agent
    axi_agnt = axi_agent::type_id::create("axi_agnt", this);
    
    // 配置 is_active
    uvm_config_db#(int)::set(this, "axi_agnt", "is_active", UVM_ACTIVE);
    
    `uvm_info(get_type_name(), "AXI 环境构建完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // connect_phase
  // -----------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
endclass : axi_env

`endif // AXI_ENV_SV
