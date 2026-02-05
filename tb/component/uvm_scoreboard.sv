// ============================================================
// File: uvm_scoreboard.sv
// Description: UVM Scoreboard (结果检查)
// Author: UVM Verification Platform
// Created: 2026-02-05
// ============================================================

`ifndef UVM_SCOREBOARD_SV
`define UVM_SCOREBOARD_SV

// -----------------------------------------------
// Class: uvm_scoreboard
// -----------------------------------------------
class uvm_scoreboard extends uvm_scoreboard;
  
  // -----------------------------------------------
  // 组件声明
  // -----------------------------------------------
  uvm_analysis_export#(axi_transaction) axi_export;
  
  // -----------------------------------------------
  // TLM FIFO
  // -----------------------------------------------
  uvm_tlm_analysis_fifo#(axi_transaction) axi_fifo;
  
  // -----------------------------------------------
  // 计数器
  // -----------------------------------------------
  int write_count = 0;
  int read_count = 0;
  int error_count = 0;
  int pass_count = 0;
  
  // -----------------------------------------------
  // 期望值存储
  // -----------------------------------------------
  axi_transaction write_exp[$];
  
  // -----------------------------------------------
  // 注册
  // -----------------------------------------------
  `uvm_component_utils(uvm_scoreboard)
  
  // -----------------------------------------------
  // 构造函数
  // -----------------------------------------------
  function new(string name = "uvm_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // -----------------------------------------------
  // build_phase
  // -----------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    axi_export = new("axi_export", this);
    axi_fifo = new("axi_fifo", this);
    
    `uvm_info(get_type_name(), "Scoreboard 构建完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // connect_phase
  // -----------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    axi_export.connect(axi_fifo.analysis_export);
    
    `uvm_info(get_type_name(), "Scoreboard 连接完成", UVM_LOW)
  endfunction
  
  // -----------------------------------------------
  // run_phase
  // -----------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      axi_transaction tr;
      
      // 从 FIFO 获取事务
      axi_fifo.get(tr);
      
      // 处理事务
      process_transaction(tr);
    end
  endtask
  
  // -----------------------------------------------
  // 任务: process_transaction
  // -----------------------------------------------
  virtual protected task process_transaction(axi_transaction tr);
    
    case (tr.cmd)
      WRITE: begin
        write_count++;
        write_exp.push_back(tr);
        `uvm_info(get_type_name(), $sformatf("收到写事务: addr=0x%0h", tr.addr), UVM_LOW)
      end
      
      READ: begin
        read_count++;
        
        // 查找期望的写事务
        if (write_exp.size() > 0) begin
          axi_transaction exp_tr = write_exp.pop_front();
          
          // 检查数据一致性
          if (check_data_consistency(exp_tr, tr)) begin
            pass_count++;
            `uvm_info(get_type_name(), "数据一致性检查: PASS", UVM_LOW)
          end else begin
            error_count++;
            `uvm_error(get_type_name(), "数据一致性检查: FAIL")
          end
        end else begin
          error_count++;
          `uvm_warning(get_type_name(), "无期望的写事务匹配")
        end
        
        `uvm_info(get_type_name(), $sformatf("收到读事务: addr=0x%0h, data=0x%0h", 
          tr.addr, tr.rdata[0]), UVM_LOW)
      end
    endcase
  endtask
  
  // -----------------------------------------------
  // 函数: check_data_consistency
  // -----------------------------------------------
  virtual protected function bit check_data_consistency(axi_transaction write_tr, 
                                                         axi_transaction read_tr);
    // 简化版检查
    if (write_tr.addr != read_tr.addr) begin
      `uvm_error(get_type_name(), "地址不匹配")
      return 0;
    end
    
    if (write_tr.len != read_tr.len) begin
      `uvm_error(get_type_name(), "长度不匹配")
      return 0;
    end
    
    // 实际数据检查需要在 monitor 中填充 rdata
    return 1;
  endfunction
  
  // -----------------------------------------------
  // report_phase
  // -----------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info(get_type_name(), "=======================", UVM_LOW)
    `uvm_info(get_type_name(), "Scoreboard 统计:", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("写事务: %0d", write_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("读事务: %0d", read_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("通过: %0d", pass_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("错误: %0d", error_count), UVM_LOW)
    `uvm_info(get_type_name(), "=======================", UVM_LOW)
  endfunction
  
endclass : uvm_scoreboard

`endif // UVM_SCOREBOARD_SV
