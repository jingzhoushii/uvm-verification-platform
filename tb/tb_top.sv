// ============================================================
// File: tb_top.sv
// Description: UVM Testbench 顶层模块 + 示例 DUT
// Author: UVM Verification Platform
// Created: 2026-02-05
// Updated: 2026-02-06 - 完善 DUT
// ============================================================

`timescale 1ns/1ps

// -----------------------------------------------
// 时钟生成
// -----------------------------------------------
parameter CLK_PERIOD = 10;  // 100MHz 时钟

initial begin
  tb_clk = 0;
  forever #(CLK_PERIOD/2) tb_clk = ~tb_clk;
end

// -----------------------------------------------
// 复位生成
// -----------------------------------------------
initial begin
  tb_rst_n = 0;
  #100 tb_rst_n = 1;
end

// -----------------------------------------------
// DUT 实例化
// -----------------------------------------------
axi_reg_file u_dut (
  .clk      (tb_clk),
  .rst_n    (tb_rst_n),
  .s_awaddr (axi4l_if.awaddr),
  .s_awprot (axi4l_if.awprot),
  .s_awvalid(axi4l_if.awvalid),
  .s_awready(axi4l_if.awready),
  .s_wdata  (axi4l_if.wdata),
  .s_wstrb  (axi4l_if.wstrb),
  .s_wvalid (axi4l_if.wvalid),
  .s_wready (axi4l_if.wready),
  .s_bresp  (axi4l_if.bresp),
  .s_bvalid (axi4l_if.bvalid),
  .s_bready (axi4l_if.bready),
  .s_araddr (axi4l_if.araddr),
  .s_arprot (axi4l_if.arprot),
  .s_arvalid(axi4l_if.arvalid),
  .s_arready(axi4l_if.arready),
  .s_rdata  (axi4l_if.rdata),
  .s_rresp  (axi4l_if.rresp),
  .s_rvalid (axi4l_if.rvalid),
  .s_rready (axi4l_if.rready)
);

// ============================================================
// Module: axi_reg_file
// Description: 简单的 AXI4-Lite 寄存器文件
// 功能: 
//   - 4个32位通用寄存器
//   - 1个状态寄存器
//   - 1个控制寄存器
// ============================================================
module axi_reg_file (
  input  wire        clk,
  input  wire        rst_n,
  
  // AXI4-Lite Slave 接口
  input  wire [31:0] s_awaddr,
  input  wire [2:0]  s_awprot,
  input  wire        s_awvalid,
  output wire        s_awready,
  
  input  wire [31:0] s_wdata,
  input  wire [3:0]  s_wstrb,
  input  wire        s_wvalid,
  output wire        s_wready,
  
  output wire [1:0]  s_bresp,
  output wire        s_bvalid,
  input  wire        s_bready,
  
  input  wire [31:0] s_araddr,
  input  wire [2:0]  s_arprot,
  input  wire        s_arvalid,
  output wire        s_arready,
  
  output wire [31:0] s_rdata,
  output wire [1:0]  s_rresp,
  output wire        s_rvalid,
  input  wire        s_rready
);
  
  // -----------------------------------------------
  // 参数定义
  // -----------------------------------------------
  parameter NUM_REGS = 4;  // 通用寄存器数量
  
  // -----------------------------------------------
  // 寄存器定义
  // -----------------------------------------------
  reg [31:0] reg_file [0:NUM_REGS-1];  // 通用寄存器
  reg [31:0] status_reg;               // 状态寄存器
  reg [31:0] control_reg;              // 控制寄存器
  
  // -----------------------------------------------
  // Write Address Channel 握手
  // -----------------------------------------------
  reg [31:0] awaddr_reg;
  reg         awvalid_reg;
  
  assign s_awready = 1'b1;  // 始终就绪
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      awaddr_reg <= 32'h0;
      awvalid_reg <= 1'b0;
    end else begin
      if (s_awvalid && s_awready) begin
        awaddr_reg <= s_awaddr;
        awvalid_reg <= 1'b1;
      end else if (awvalid_reg && s_wvalid && s_wready) begin
        awvalid_reg <= 1'b0;
      end
    end
  end
  
  // -----------------------------------------------
  // Write Data Channel 握手
  // -----------------------------------------------
  reg [31:0] wdata_reg;
  reg [3:0]   wstrb_reg;
  reg         wvalid_reg;
  
  assign s_wready = 1'b1;  // 始终就绪
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wdata_reg <= 32'h0;
      wstrb_reg <= 4'h0;
      wvalid_reg <= 1'b0;
    end else begin
      if (s_wvalid && s_wready) begin
        wdata_reg <= s_wdata;
        wstrb_reg <= s_wstrb;
        wvalid_reg <= 1'b1;
      end else if (awvalid_reg && wvalid_reg) begin
        wvalid_reg <= 1'b0;
      end
    end
  end
  
  // -----------------------------------------------
  // Write Response Channel
  // -----------------------------------------------
  reg [1:0]  bresp_reg;
  reg        bvalid_reg;
  
  assign s_bresp = bresp_reg;
  assign s_bvalid = bvalid_reg;
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bresp_reg <= 2'b00;
      bvalid_reg <= 1'b0;
    end else begin
      if (awvalid_reg && wvalid_reg && s_bready) begin
        // 写操作完成
        bresp_reg <= 2'b00;  // OKAY
        bvalid_reg <= 1'b1;
      end else if (s_bready) begin
        bvalid_reg <= 1'b0;
      end
    end
  end
  
  // -----------------------------------------------
  // Read Address Channel 握手
  // -----------------------------------------------
  reg [31:0] araddr_reg;
  reg         arvalid_reg;
  
  assign s_arready = 1'b1;  // 始终就绪
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      araddr_reg <= 32'h0;
      arvalid_reg <= 1'b0;
    end else begin
      if (s_arvalid && s_arready) begin
        araddr_reg <= s_araddr;
        arvalid_reg <= 1'b1;
      end else if (arvalid_reg && s_rvalid && s_rready) begin
        arvalid_reg <= 1'b0;
      end
    end
  end
  
  // -----------------------------------------------
  // Read Data Channel
  // -----------------------------------------------
  reg [31:0] rdata_reg;
  reg [1:0]   rresp_reg;
  reg         rvalid_reg;
  
  assign s_rdata = rdata_reg;
  assign s_rresp = rresp_reg;
  assign s_rvalid = rvalid_reg;
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rdata_reg <= 32'h0;
      rresp_reg <= 2'b00;
      rvalid_reg <= 1'b0;
    end else begin
      if (arvalid_reg && s_rready) begin
        // 读操作
        case (araddr_reg[7:0])
          8'h00: rdata_reg = reg_file[0];
          8'h04: rdata_reg = reg_file[1];
          8'h08: rdata_reg = reg_file[2];
          8'h0C: rdata_reg = reg_file[3];
          8'h10: rdata_reg = status_reg;
          8'h14: rdata_reg = control_reg;
          default: rdata_reg = 32'h0;
        endcase
        rresp_reg = 2'b00;  // OKAY
        rvalid_reg = 1'b1;
      end else begin
        rvalid_reg = 1'b0;
      end
    end
  end
  
  // -----------------------------------------------
  // 寄存器写操作
  // -----------------------------------------------
  integer i;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < NUM_REGS; i++) begin
        reg_file[i] <= 32'h0;
      end
      status_reg <= 32'h0;
      control_reg <= 32'h0;
    end else begin
      if (awvalid_reg && wvalid_reg && s_bready) begin
        // 写寄存器
        case (awaddr_reg[7:0])
          8'h00: begin
            if (wstrb_reg[0]) reg_file[0][7:0]   <= wdata_reg[7:0];
            if (wstrb_reg[1]) reg_file[0][15:8]  <= wdata_reg[15:8];
            if (wstrb_reg[2]) reg_file[0][23:16] <= wdata_reg[23:16];
            if (wstrb_reg[3]) reg_file[0][31:24] <= wdata_reg[31:24];
          end
          8'h04: begin
            if (wstrb_reg[0]) reg_file[1][7:0]   <= wdata_reg[7:0];
            if (wstrb_reg[1]) reg_file[1][15:8]  <= wdata_reg[15:8];
            if (wstrb_reg[2]) reg_file[1][23:16] <= wdata_reg[23:16];
            if (wstrb_reg[3]) reg_file[1][31:24] <= wdata_reg[31:24];
          end
          8'h08: begin
            if (wstrb_reg[0]) reg_file[2][7:0]   <= wdata_reg[7:0];
            if (wstrb_reg[1]) reg_file[2][15:8]  <= wdata_reg[15:8];
            if (wstrb_reg[2]) reg_file[2][23:16] <= wdata_reg[23:16];
            if (wstrb_reg[3]) reg_file[2][31:24] <= wdata_reg[31:24];
          end
          8'h0C: begin
            if (wstrb_reg[0]) reg_file[3][7:0]   <= wdata_reg[7:0];
            if (wstrb_reg[1]) reg_file[3][15:8]  <= wdata_reg[15:8];
            if (wstrb_reg[2]) reg_file[3][23:16] <= wdata_reg[23:16];
            if (wstrb_reg[3]) reg_file[3][31:24] <= wdata_reg[31:24];
          end
          8'h14: begin
            // 控制寄存器 (只写某些位)
            if (wstrb_reg[0]) control_reg[7:0]   <= wdata_reg[7:0];
            if (wstrb_reg[1]) control_reg[15:8]  <= wdata_reg[15:8];
            if (wstrb_reg[2]) control_reg[23:16] <= wdata_reg[23:16];
            if (wstrb_reg[3]) control_reg[31:24] <= wdata_reg[31:24];
          end
        endcase
      end
    end
  end
  
  // -----------------------------------------------
  // 状态寄存器更新
  // -----------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      status_reg <= 32'h0;
    end else begin
      // Bit 0: 复位状态
      status_reg[0] <= ~rst_n;
      // Bit 1: 写完成标志
      status_reg[1] <= (awvalid_reg && wvalid_reg) ? 1'b1 : 1'b0;
      // Bit 2: 读完成标志
      status_reg[2] <= (arvalid_reg) ? 1'b1 : 1'b0;
      // 其他位保留
      status_reg[31:3] <= 32'h0;
    end
  end
  
endmodule : axi_reg_file

// ============================================================
// File: axi4l_intf.sv
// Description: AXI4-Lite 接口定义
// ============================================================

interface axi4l_intf (
  input clk,
  input rst_n
);
  
  // Write Address Channel
  wire [31:0] awaddr;
  wire [2:0]  awprot;
  wire        awvalid;
  wire        awready;
  
  // Write Data Channel
  wire [31:0] wdata;
  wire [3:0]  wstrb;
  wire        wvalid;
  wire        wready;
  
  // Write Response Channel
  wire [1:0]  bresp;
  wire        bvalid;
  wire        bready;
  
  // Read Address Channel
  wire [31:0] araddr;
  wire [2:0]  arprot;
  wire        arvalid;
  wire        arready;
  
  // Read Data Channel
  wire [31:0] rdata;
  wire [1:0]  rresp;
  wire        rvalid;
  wire        rready;
  
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

// ============================================================
// File: tb_top.sv (旧版本 - 已废弃)
// 此文件已更新，现在包含完整的 DUT 和接口定义
// ============================================================
