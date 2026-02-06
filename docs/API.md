# API 文档

## 序列库 (Sequence Library)

### 基础序列 (base_seq.sv)

#### axi_base_seq
基类序列，所有自定义序列的父类。

```systemverilog
class axi_base_seq extends uvm_sequence#(axi_transaction);
```

#### axi_write_seq
写传输序列。

```systemverilog
class axi_write_seq extends uvm_sequence#(axi_transaction);

  rand bit [31:0] addr;   // 写地址
  rand bit [31:0] data[];  // 写数据数组
  rand bit [7:0] len;      // 突发长度
  rand bit [2:0] size;     // 数据大小
  rand bit [1:0] burst;    // 突发类型
```

**使用示例**：
```systemverilog
axi_write_seq seq;
seq = axi_write_seq::type_id::create("seq");
seq.addr = 32'h1000;
seq.len = 4;
seq.size = 2;
seq.burst = 1;  // INCR
seq.start(sequencer);
```

#### axi_read_seq
读传输序列。

```systemverilog
class axi_read_seq extends uvm_sequence#(axi_transaction);

  rand bit [31:0] addr;
  rand bit [7:0] len;
  rand bit [2:0] size;
  rand bit [1:0] burst;
```

#### axi_random_seq
随机事务序列。

```systemverilog
class axi_random_seq extends uvm_sequence#(axi_transaction);
```

#### axi_error_seq
错误注入序列。

```systemverilog
class axi_error_seq extends uvm_sequence#(axi_transaction);
// 访问无效地址 0xFFFF_FFFF
```

### 扩展序列 (axi_seq_lib.sv)

#### axi_single_seq
单次传输序列（无突发）。

```systemverilog
class axi_single_seq extends uvm_sequence#(axi_transaction);

  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit [2:0] size = 3'd2;
```

**使用示例**：
```systemverilog
axi_single_seq seq;
seq = axi_single_seq::type_id::create("seq");
seq.addr = 32'h0000_0100;
seq.data = 32'h1234_5678;
seq.start(sequencer);
```

#### axi_burst_seq
突发传输序列。

```systemverilog
class axi_burst_seq extends uvm_sequence#(axi_transaction);

  rand bit [31:0] addr;
  rand bit [7:0] len = 8'd4;    // 1-16次传输
  rand bit [2:0] size = 3'd2;   // 1/2/4/8字节
  rand bit [1:0] burst = 2'd1;   // 0=FIXED, 1=INCR, 2=WRAP
```

#### axi_reg_seq
寄存器读写序列。

```systemverilog
class axi_reg_seq extends uvm_sequence#(axi_transaction);

  typedef enum {READ, WRITE} reg_op_t;
  rand reg_op_t op;
  rand bit [7:0] reg_addr;   // 寄存器地址 (byte对齐)
  rand bit [31:0] reg_data;
  rand bit [3:0] wstrb = 4'hF;  // 字节使能
```

**寄存器地址映射**：
| 地址 | 寄存器 |
|------|--------|
| 0x00 | reg_file[0] |
| 0x04 | reg_file[1] |
| 0x08 | reg_file[2] |
| 0x0C | reg_file[3] |
| 0x10 | status_reg |
| 0x14 | control_reg |

#### axi_incr_seq
INCR 突发序列（地址递增）。

```systemverilog
class axi_incr_seq extends uvm_sequence#(axi_transaction);

  rand bit [31:0] start_addr;
  rand bit [7:0] len = 8'd8;
  rand bit [2:0] size = 3'd2;
```

#### axi_wrap_seq
WRAP 突发序列（回环访问）。

```systemverilog
class axi_wrap_seq extends uvm_sequence#(axi_transaction);

  rand bit [31:0] start_addr;
  rand bit [7:0] len = 8'd4;   // 必须是2/4/8/16
  rand bit [2:0] size = 3'd2;  // 必须是4/8字节
```

#### axi_mem_seq
内存读写序列。

```systemverilog
class axi_mem_seq extends uvm_sequence#(axi_transaction);

  typedef enum {READ, WRITE} mem_op_t;
  rand mem_op_t op;
  rand bit [31:0] addr;
  rand bit [15:0] len = 16'd16;
```

#### axi_repeat_seq
重复读写序列。

```systemverilog
class axi_repeat_seq extends uvm_sequence#(axi_transaction);

  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand int repeat_count = 10;  // 重复次数
```

## 组件 (Component)

### Scoreboard

```systemverilog
class uvm_scoreboard extends uvm_scoreboard;

// 配置
check_enable    // 检查使能
print_enable    // 打印使能

// 方法
clear_exp()    // 清空期望值
```

### Coverage

```systemverilog
class uvm_coverage extends uvm_subscriber#(axi_transaction);

// 配置
coverage_enable  // 覆盖率收集使能
print_enable     // 打印使能

// 方法
get_coverage()   // 获取覆盖率
```

## 环境 (Environment)

```systemverilog
class uvm_env extends uvm_env;

// 子组件
axi_env axi_env;           // AXI 环境
uvm_scoreboard scoreboard; // 记分板
uvm_coverage coverage;      // 覆盖率

// 信号
bit rst_done;              // 复位完成信号
bit done;                 // 测试完成信号
```
