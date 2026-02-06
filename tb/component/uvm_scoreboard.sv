// ============================================================
// File: uvm_scoreboard.sv
// Description: UVM Scoreboard (完整实现)
// Author: UVM Verification Platform
// Created: 2026-02-05
// Updated: 2026-02-06 - 完整实现
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
  int total_count = 0;
  
  // -----------------------------------------------
  // 期望值存储 (按地址索引)
  // -----------------------------------------------
  axi_transaction write_exp[bit[31:0]];
  
  // -----------------------------------------------
  // 配置
  // -----------------------------------------------
  bit check_enable = 1'b1;
  bit print_enable = 1'b1;
  
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
    
    // 获取配置
    if (uvm_config_db#(bit)::get(this, "", "check_enable", check_enable)) begin
      `uvm_info(get_type_name(), $sformatf("check_enable = %0b", check_enable), UVM_LOW)
    end
    
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
    
    fork
      forever begin
        axi_transaction tr;
        
        // 从 FIFO 获取事务
        axi_fifo.get(tr);
        
        // 处理事务
        process_transaction(tr);
      end
    join_none
  endtask
  
  // -----------------------------------------------
  // 任务: process_transaction
  // -----------------------------------------------
  virtual protected task process_transaction(axi_transaction tr);
    total_count++;
    
    `uvm_info(get_type_name(), $sformatf("处理事务: cmd=%s, addr=0x%0h, len=%0d", 
      tr.cmd.name(), tr.addr, tr.len), UVM_MEDIUM)
    
    case (tr.cmd)
      WRITE: process_write(tr);
      READ:  process_read(tr);
      default: `uvm_error(get_type_name(), "未知的命令类型")
    endcase
  endtask
  
  // -----------------------------------------------
  // 任务: process_write
  // -----------------------------------------------
  virtual protected task process_write(axi_transaction tr);
    write_count++;
    
    // 存储期望值
    write_exp[tr.addr] = tr;
    
    `uvm_info(get_type_name(), $sformatf("写事务存储: addr=0x%0h, data[0]=0x%0h", 
      tr.addr, (tr.data.size() > 0) ? tr.data[0] : 32'h0), UVM_LOW)
    
    if (print_enable) begin
      print_write_exp();
    end
  endtask
  
  // -----------------------------------------------
  // 任务: process_read
  // -----------------------------------------------
  virtual protected task process_read(axi_transaction tr);
    int i;
    bit check_result;
    
    read_count++;
    
    // 检查是否有期望的写事务
    if (write_exp.exists(tr.addr)) begin
      axi_transaction exp_tr = write_exp[tr.addr];
      
      // 执行数据比较
      check_result = check_data_consistency(exp_tr, tr);
      
      if (check_result) begin
        pass_count++;
        `uvm_info(get_type_name(), $sformatf("读事务验证 PASS: addr=0x%0h", tr.addr), UVM_LOW)
      end else begin
        error_count++;
        `uvm_error(get_type_name(), $sformatf("读事务验证 FAIL: addr=0x%0h", tr.addr))
        
        // 打印详细信息
        print_mismatch(exp_tr, tr);
      end
      
      // 可选：清除已验证的期望值
      // write_exp.delete(tr.addr);
    end else begin
      // 没有期望值，只打印读到的数据
      `uvm_info(get_type_name(), $sformatf("读事务 (无期望): addr=0x%0h", tr.addr), UVM_MEDIUM)
      
      if (tr.rdata.size() > 0) begin
        `uvm_info(get_type_name(), $sformatf("读到的数据: "), UVM_NONE)
        for (i = 0; i < tr.rdata.size(); i++) begin
          `uvm_info(get_type_name(), $sformatf("  [%0d]: 0x%0h", i, tr.rdata[i]), UVM_NONE)
        end
      end
    end
  endtask
  
  // -----------------------------------------------
  // 函数: check_data_consistency
  // -----------------------------------------------
  virtual protected function bit check_data_consistency(axi_transaction write_tr, 
                                                         axi_transaction read_tr);
    int i;
    bit result = 1'b1;
    
    // 检查地址
    if (write_tr.addr != read_tr.addr) begin
      `uvm_error(get_type_name(), $sformatf("地址不匹配: expected=0x%0h, actual=0x%0h", 
        write_tr.addr, read_tr.addr), UVM_LOW)
      result = 1'b0;
    end
    
    // 检查长度
    if (write_tr.len != read_tr.len) begin
      `uvm_error(get_type_name(), $sformatf("长度不匹配: expected=%0d, actual=%0d", 
        write_tr.len, read_tr.len), UVM_LOW)
      result = 1'b0;
    end
    
    // 检查数据
    if (write_tr.data.size() != read_tr.rdata.size()) begin
      `uvm_error(get_type_name(), $sformatf("数据大小不匹配: expected=%0d, actual=%0d", 
        write_tr.data.size(), read_tr.rdata.size()), UVM_LOW)
      result = 1'b0;
    end else begin
      for (i = 0; i < write_tr.data.size(); i++) begin
        if (i < read_tr.rdata.size()) begin
          if (write_tr.data[i] != read_tr.rdata[i]) begin
            `uvm_error(get_type_name(), $sformatf("数据不匹配 [%0d]: expected=0x%0h, actual=0x%0h", 
              i, write_tr.data[i], read_tr.rdata[i]), UVM_LOW)
            result = 1'b0;
          end
        end
      end
    end
    
    // 检查响应
    if (read_tr.resp != 2'b00) begin
      `uvm_warning(get_type_name(), $sformatf("响应非 OKAY: resp=%0d", read_tr.resp))
    end
    
    return result;
  endfunction
  
  // -----------------------------------------------
  // 任务: print_write_exp
  // -----------------------------------------------
  virtual protected task print_write_exp();
    int i;
    string s;
    bit [31:0] addrs[$];
    
    // 获取所有地址
    addrs = write_exp.keys();
    
    if (addrs.size() > 0) begin
      `uvm_info(get_type_name(), "========== 期望值队列 ==========", UVM_LOW)
      foreach (addrs[i]) begin
        s = $sformatf("Addr=0x%08h: ", addrs[i]);
        if (write_exp[addrs[i]].data.size() > 0) begin
          s = $sformatf("%sData[0]=0x%08h", s, write_exp[addrs[i]].data[0]);
        end else begin
          s = $sformatf("%s<无数据>", s);
        end
        `uvm_info(get_type_name(), s, UVM_LOW)
      end
      `uvm_info(get_type_name(), "================================", UVM_LOW)
    end
  endtask
  
  // -----------------------------------------------
  // 任务: print_mismatch
  // -----------------------------------------------
  virtual protected task print_mismatch(axi_transaction exp_tr, axi_transaction act_tr);
    int i;
    
    `uvm_error(get_type_name(), "========== 数据不匹配详情 ==========", UVM_LOW)
    `uvm_error(get_type_name(), $sformatf("地址: expected=0x%0h, actual=0x%0h", 
      exp_tr.addr, act_tr.addr), UVM_LOW)
    `uvm_error(get_type_name(), $sformatf("长度: expected=%0d, actual=%0d", 
      exp_tr.len, act_tr.len), UVM_LOW)
    
    `uvm_error(get_type_name(), "期望数据:", UVM_LOW)
    for (i = 0; i < exp_tr.data.size(); i++) begin
      `uvm_error(get_type_name(), $sformatf("  [%0d]: 0x%0h", i, exp_tr.data[i]), UVM_LOW)
    end
    
    `uvm_error(get_type_name(), "实际数据:", UVM_LOW)
    for (i = 0; i < act_tr.rdata.size(); i++) begin
      `uvm_error(get_type_name(), $sformatf("  [%0d]: 0x%0h", i, act_tr.rdata[i]), UVM_LOW)
    end
    
    `uvm_error(get_type_name(), "====================================", UVM_LOW)
  endtask
  
  // -----------------------------------------------
  // 任务: clear_exp
  // -----------------------------------------------
  virtual task clear_exp();
    write_exp.delete();
    `uvm_info(get_type_name(), "期望值队列已清空", UVM_LOW)
  endtask
  
  // -----------------------------------------------
  // report_phase
  // -----------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info(get_type_name(), "====================== Scoreboard 统计 ======================", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("总事务数: %0d", total_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("写事务: %0d", write_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("读事务: %0d", read_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("通过: %0d", pass_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("错误: %0d", error_count), UVM_LOW)
    
    if (total_count > 0) begin
      `uvm_info(get_type_name(), $sformatf("通过率: %0.2f%%", 
        real'(pass_count) * 100.0 / real'(total_count)), UVM_LOW)
    end
    
    if (error_count == 0) begin
      `uvm_info("SCOREBOARD_PASS", "============================================================", UVM_LOW)
      `uvm_info("SCOREBOARD_PASS", "                    Scoreboard: ALL TESTS PASSED                    ", UVM_LOW)
      `uvm_info("SCOREBOARD_PASS", "============================================================", UVM_LOW)
    end else begin
      `uvm_error("SCOREBOARD_FAIL", "============================================================")
      `uvm_error("SCOREBOARD_FAIL", $sformatf("                    Scoreboard: %0d ERRORS DETECTED                    ", error_count))
      `uvm_error("SCOREBOARD_FAIL", "============================================================")
    end
  endfunction
  
endclass : uvm_scoreboard

`endif // UVM_SCOREBOARD_SV
