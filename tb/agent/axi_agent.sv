// ============================================================
// File: axi_agent.sv
// Description: AXI Agent (完整实现 Driver + Monitor + Sequencer)
// Author: UVM Verification Platform
// Created: 2026-02-05
// Updated: 2026-02-06 - 完整实现
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
// Class: axi_driver (完整实现)
// ============================================================
class axi_driver extends uvm_driver#(axi_transaction);
  
  virtual axi4l_intf vif;
  
  // 超时参数
  int drive_timeout = 1000;
  
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
  
  // ================================================
  // 任务: drive_transaction
  // 描述: 完整的 AXI4-Lite 驱动逻辑
  // ================================================
  virtual protected task drive_transaction(axi_transaction tr);
    `uvm_info(get_type_name(), $sformatf("驱动事务: cmd=%s, addr=0x%0h, len=%0d", 
      tr.cmd.name(), tr.addr, tr.len), UVM_LOW)
    
    case (tr.cmd)
      WRITE: drive_write(tr);
      READ:  drive_read(tr);
      default: `uvm_error(get_type_name(), "未知的命令类型")
    endcase
  endtask
  
  // ================================================
  // 任务: drive_write
  // 描述: AXI4-Lite 写传输
  // ================================================
  virtual protected task drive_write(axi_transaction tr);
    int i;
    
    // 1. 驱动 Write Address Channel
    `uvm_info(get_type_name(), "开始写传输 - AW Channel", UVM_LOW)
    
    // 驱动地址和控制信号
    vif.drv_cb.awvalid <= 1'b0;
    vif.drv_cb.awaddr  <= tr.addr;
    vif.drv_cb.awprot  <= 3'b000;  // 非特权模式，安全访问
    vif.drv_cb.awvalid <= 1'b1;
    
    // 等待 AWREADY
    fork
      begin
        wait(vif.drv_cb.awready === 1'b1 || drive_timeout == 0);
        if (drive_timeout > 0) begin
          `uvm_info(get_type_name(), "AW Handshake 完成", UVM_LOW)
        end else begin
          `uvm_error(get_type_name(), "AW Handshake 超时")
        end
      end
      begin
        #(drive_timeout * 1ns);
        `uvm_error(get_type_name(), "AW Handshake 超时")
      end
    join
    
    // 完成地址传输
    vif.drv_cb.awvalid <= 1'b0;
    
    // 2. 驱动 Write Data Channel
    `uvm_info(get_type_name(), "开始写传输 - W Channel", UVM_LOW)
    
    for (i = 0; i <= tr.len; i++) begin
      // 驱动数据和字节使能
      vif.drv_cb.wvalid <= 1'b0;
      vif.drv_cb.wdata  <= (tr.data.size() > i) ? tr.data[i] : 32'h0;
      vif.drv_cb.wstrb  <= 4'b1111;  // 全字节使能
      vif.drv_cb.wvalid <= 1'b1;
      
      // 等待 WREADY
      wait(vif.drv_cb.wready === 1'b1);
      `uvm_info(get_type_name(), $sformatf("W Data[%0d] Handshake 完成", i), UVM_LOW)
    end
    
    // 完成数据传输
    vif.drv_cb.wvalid <= 1'b0;
    
    // 3. 驱动 Write Response Channel
    `uvm_info(get_type_name(), "等待写响应 - B Channel", UVM_LOW)
    
    vif.drv_cb.bready <= 1'b1;
    
    // 等待 BVALID
    wait(vif.drv_cb.bvalid === 1'b1);
    
    // 检查响应
    case (vif.drv_cb.bresp)
      2'b00: `uvm_info(get_type_name(), "写响应: OKAY", UVM_LOW)
      2'b01: `uvm_warning(get_type_name(), "写响应: EXOKAY")
      2'b10: `uvm_error(get_type_name(), "写响应: SLVERR")
      2'b11: `uvm_error(get_type_name(), "写响应: DECERR")
    endcase
    
    vif.drv_cb.bready <= 1'b0;
    
    `uvm_info(get_type_name(), "写传输完成", UVM_LOW)
  endtask
  
  // ================================================
  // 任务: drive_read
  // 描述: AXI4-Lite 读传输
  // ================================================
  virtual protected task drive_read(axi_transaction tr);
    int i;
    
    // 1. 驱动 Read Address Channel
    `uvm_info(get_type_name(), "开始读传输 - AR Channel", UVM_LOW)
    
    // 驱动地址和控制信号
    vif.drv_cb.arvalid <= 1'b0;
    vif.drv_cb.araddr  <= tr.addr;
    vif.drv_cb.arprot  <= 3'b000;  // 非特权模式，安全访问
    vif.drv_cb.arvalid <= 1'b1;
    
    // 等待 ARREADY
    fork
      begin
        wait(vif.drv_cb.arready === 1'b1 || drive_timeout == 0);
        if (drive_timeout > 0) begin
          `uvm_info(get_type_name(), "AR Handshake 完成", UVM_LOW)
        end else begin
          `uvm_error(get_type_name(), "AR Handshake 超时")
        end
      end
      begin
        #(drive_timeout * 1ns);
        `uvm_error(get_type_name(), "AR Handshake 超时")
      end
    join
    
    // 完成地址传输
    vif.drv_cb.arvalid <= 1'b0;
    
    // 2. 驱动 Read Response Channel
    `uvm_info(get_type_name(), "等待读数据 - R Channel", UVM_LOW)
    
    vif.drv_cb.rready <= 1'b1;
    
    // 分配 rdata 数组
    tr.rdata = new[tr.len + 1];
    
    for (i = 0; i <= tr.len; i++) begin
      // 等待 RVALID
      wait(vif.drv_cb.rvalid === 1'b1);
      
      // 采样数据
      tr.rdata[i] = vif.drv_cb.rdata;
      
      // 检查响应
      case (vif.drv_cb.rresp)
        2'b00: `uvm_info(get_type_name(), $sformatf("R Data[%0d]: 0x%0h OKAY", i, tr.rdata[i]), UVM_LOW)
        2'b01: `uvm_warning(get_type_name(), $sformatf("R Data[%0d]: 0x%0h EXOKAY", i, tr.rdata[i]))
        2'b10: `uvm_error(get_type_name(), $sformatf("R Data[%0d]: 0x%0h SLVERR", i, tr.rdata[i]))
        2'b11: `uvm_error(get_type_name(), $sformatf("R Data[%0d]: 0x%0h DECERR", i, tr.rdata[i]))
      endcase
    end
    
    vif.drv_cb.rready <= 1'b0;
    
    `uvm_info(get_type_name(), "读传输完成", UVM_LOW)
  endtask
  
endclass : axi_driver

// ============================================================
// Class: axi_monitor (完整实现)
// ============================================================
class axi_monitor extends uvm_monitor;
  
  virtual axi4l_intf vif;
  uvm_analysis_port#(axi_transaction) ap;
  
  // 采样的事务
  axi_transaction  sampled_tr;
  
  // 状态
  typedef enum {IDLE, WRITE_ADDR, WRITE_DATA, WRITE_RESP, READ_ADDR, READ_DATA} monitor_state_t;
  monitor_state_t state;
  
  `uvm_component_utils(axi_monitor)
  
  function new(string name = "axi_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
    state = IDLE;
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
      monitor_interface();
    end
  endtask
  
  // ================================================
  // 任务: monitor_interface
  // 描述: 监控 AXI4-Lite 接口
  // ================================================
  virtual protected task monitor_interface();
    
    // 监控 Write Address Channel
    if (vif.mon_cb.awvalid && vif.mon_cb.awready) begin
      `uvm_info(get_type_name(), $sformatf("Monitor: AW VALID&READY - addr=0x%0h", 
        vif.mon_cb.awaddr), UVM_LOW)
    end
    
    // 监控 Write Data Channel
    if (vif.mon_cb.wvalid && vif.mon_cb.wready) begin
      `uvm_info(get_type_name(), $sformatf("Monitor: W VALID&READY - data=0x%0h", 
        vif.mon_cb.wdata), UVM_LOW)
    end
    
    // 监控 Write Response Channel
    if (vif.mon_cb.bvalid && vif.mon_cb.bready) begin
      `uvm_info(get_type_name(), $sformatf("Monitor: B VALID&READY - resp=%0d", 
        vif.mon_cb.bresp), UVM_LOW)
    end
    
    // 监控 Read Address Channel
    if (vif.mon_cb.arvalid && vif.mon_cb.arready) begin
      `uvm_info(get_type_name(), $sformatf("Monitor: AR VALID&READY - addr=0x%0h", 
        vif.mon_cb.araddr), UVM_LOW)
    end
    
    // 监控 Read Data Channel
    if (vif.mon_cb.rvalid && vif.mon_cb.rready) begin
      `uvm_info(get_type_name(), $sformatf("Monitor: R VALID&READY - data=0x%0h, resp=%0d", 
        vif.mon_cb.rdata, vif.mon_cb.rresp), UVM_LOW)
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
