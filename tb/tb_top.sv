// ============================================================
// File: tb_top.sv
// Description: UVM Testbench 顶层模块
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`timescale 1ns/1ps

// 顶层模块
module tb_top;

  // -----------------------------------------------
  // 参数定义
  // -----------------------------------------------
  parameter CLK_PERIOD = 10;  // 100MHz 时钟
  parameter RST_DELAY  = 100;  // 复位延迟
  
  // -----------------------------------------------
  // 接口声明
  // -----------------------------------------------
  logic clk;
  logic rst_n;
  
  // AXI4-Lite 接口
  axi4l_intf  axi4l_if (.clk(clk), .rst_n(rst_n));
  
  // DUT 接口
  logic [31:0] dut_input;
  logic [31:0] dut_output;
  logic        dut_valid;
  
  // -----------------------------------------------
  // 时钟生成
  // -----------------------------------------------
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end
  
  // -----------------------------------------------
  // 复位生成
  // -----------------------------------------------
  initial begin
    rst_n = 0;
    #RST_DELAY rst_n = 1;
  end
  
  // -----------------------------------------------
  // DUT 实例化
  // -----------------------------------------------
  my_dut u_dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .input    (dut_input),
    .output   (dut_output),
    .valid    (dut_valid)
  );
  
  // -----------------------------------------------
  // 接口连接
  // -----------------------------------------------
  assign axi4l_if.awvalid = 1'b0;
  assign axi4l_if.arvalid = 1'b0;
  assign dut_input        = 32'h0;
  
  // -----------------------------------------------
  // UVM 初始化
  // -----------------------------------------------
  initial begin
    // 设置虚接口
    uvm_config_db#(virtual axi4l_intf)::set(null, "uvm_test_top", "axi4l_vif", axi4l_if);
    
    // 设置全局超时
    uvm_root::set_timeout(1000ms);
    
    // 运行测试
    run_test();
  end
  
  // -----------------------------------------------
  // 仿真结束处理
  // -----------------------------------------------
  initial begin
    // 等待仿真完成
    wait(uvm_report_service::get_report_count(UVM_FATAL) > 0);
    $finish;
  end
  
  // -----------------------------------------------
  // VCD 波形dump
  // -----------------------------------------------
  `ifdef DUMP_WAVES
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb_top);
  end
  `endif
  
endmodule : tb_top

// ============================================================
// File: my_dut.v
// Description: 示例 DUT (待验证的设计)
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

module my_dut (
  input  wire        clk,
  input  wire        rst_n,
  input  wire [31:0] input_data,
  output wire [31:0] output_data,
  output wire        valid
);
  
  // -----------------------------------------------
  // 寄存器定义
  // -----------------------------------------------
  reg [31:0] data_reg;
  reg [7:0]  counter;
  
  // -----------------------------------------------
  // 组合逻辑
  // -----------------------------------------------
  assign output_data = data_reg;
  assign valid       = counter[7];
  
  // -----------------------------------------------
  // 时序逻辑
  // -----------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_reg <= 32'h0;
      counter  <= 8'h0;
    end else begin
      data_reg <= input_data + 32'h1;
      counter  <= counter + 8'h1;
    end
  end
  
endmodule : my_dut

// ============================================================
// File: axi4l_intf.sv
// Description: AXI4-Lite 接口定义
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

interface axi4l_intf (
  input clk,
  input rst_n
);
  
  // Write Address Channel
  logic [31:0] awaddr;
  logic [2:0]  awprot;
  logic        awvalid;
  logic        awready;
  
  // Write Data Channel
  logic [31:0] wdata;
  logic [3:0]  wstrb;
  logic        wvalid;
  logic        wready;
  
  // Write Response Channel
  logic [1:0]  bresp;
  logic        bvalid;
  logic        bready;
  
  // Read Address Channel
  logic [31:0] araddr;
  logic [2:0]  arprot;
  logic        arvalid;
  logic        arready;
  
  // Read Data Channel
  logic [31:0] rdata;
  logic [1:0]  rresp;
  logic        rvalid;
  logic        rready;
  
  // 时钟块 - 用于驱动
  clocking drv_cb @(posedge clk);
    output awaddr, awprot, awvalid;
    input  awready;
    output wdata, wstrb, wvalid;
    input  wready;
    input  bresp, bvalid;
    output bready;
    output araddr, arprot, arvalid;
    input  arready;
    input  rdata, rresp, rvalid;
    output rready;
  endclocking
  
  // 时钟块 - 用于监控
  clocking mon_cb @(posedge clk);
    input  awaddr, awprot, awvalid, awready;
    input  wdata, wstrb, wvalid, wready;
    input  bresp, bvalid, bready;
    input  araddr, arprot, arvalid, arready;
    input  rdata, rresp, rvalid, rready;
  endclocking
  
  // Modport 定义
  modport DRV (clocking drv_cb);
  modport MON (clocking mon_cb);
  
endinterface : axi4l_intf
