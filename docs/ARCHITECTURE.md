# 架构文档

## 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                   Testbench 顶层 (tb_top.sv)           │
│  ┌─────────────────────────────────────────────────┐  │
│  │              DUT: axi_reg_file                  │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │ 4x 32-bit 通用寄存器                   │  │  │
│  │  │ 1x 状态寄存器                          │  │  │
│  │  │ 1x 控制寄存器                          │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ axi4l_intf
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 UVM Environment (uvm_env.sv)             │
│  ┌─────────────────────────────────────────────────┐  │
│  │              axi_env (axi_env.sv)               │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │     axi_agent (axi_agent.sv)          │  │  │
│  │  │  ┌─────────┬─────────┬─────────────┐ │  │  │
│  │  │  │ Sequencer│ Driver  │ Monitor    │ │  │  │
│  │  │  └─────────┴─────────┴─────────────┘ │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────┘  │
│  ┌───────────────────┐  ┌───────────────────────┐    │
│  │   Scoreboard     │  │      Coverage        │    │
│  │   (uvm_scoreboard)│  │  (uvm_coverage)    │    │
│  └───────────────────┘  └───────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## 文件结构

```
tb/
├── config/              # 配置文件
├── component/           # 组件
│   ├── uvm_coverage.sv  # 覆盖率模型
│   └── uvm_scoreboard.sv # 记分板
├── env/                 # 环境
│   └── uvm_env.sv       # 顶层环境
├── agent/               # 代理
│   └── axi_agent.sv     # AXI 代理
├── seq/                 # 序列库
│   ├── axi_transaction.sv # 事务定义
│   ├── base_seq.sv       # 基础序列
│   └── axi_seq_lib.sv    # 扩展序列库
└── test/                # 测试用例
    ├── base_test.sv       # 基础测试类
    └── *_test.sv          # 具体测试
```

## 数据流

### 写操作流程

```
Test
  │
  ▼
Sequence (axi_write_seq)
  │
  ▼
Sequencer
  │
  ▼
Driver ──axi4l_intf──► DUT (axi_reg_file)
  │                          │
  │◄────────────────────────┘
  │       (响应)
  ▼
Monitor
  │
  ▼
Analysis Port
  │
  ├────► Scoreboard (比较期望值和实际值)
  │
  └────► Coverage (收集覆盖率)
```

### 读操作流程

```
Test
  │
  ▼
Sequence (axi_read_seq)
  │
  ▼
Sequencer
  │
  ▼
Driver ──axi4l_intf──► DUT (axi_reg_file)
  │                          │
  │◄────────────────────────┘
  │       (数据 + 响应)
  ▼
Monitor
  │
  ▼
Analysis Port
  │
  ├────► Scoreboard (比较读回数据)
  │
  └────► Coverage (收集覆盖率)
```

## AXI4-Lite 接口信号

### Write Address Channel
| 信号 | 方向 | 描述 |
|------|------|------|
| awaddr | Master→Slave | 写地址 |
| awprot | Master→Slave | 保护类型 |
| awvalid | Master→Slave | 地址有效 |
| awready | Slave→Master | 地址就绪 |

### Write Data Channel
| 信号 | 方向 | 描述 |
|------|------|------|
| wdata | Master→Slave | 写数据 |
| wstrb | Master→Slave | 字节使能 |
| wvalid | Master→Slave | 数据有效 |
| wready | Slave→Master | 数据就绪 |

### Write Response Channel
| 信号 | 方向 | 描述 |
|------|------|------|
| bresp | Slave→Master | 响应 (OKAY/SLVERR/DECERR) |
| bvalid | Slave→Master | 响应有效 |
| bready | Master→Slave | 响应就绪 |

### Read Address Channel
| 信号 | 方向 | 描述 |
|------|------|------|
| araddr | Master→Slave | 读地址 |
| arprot | Master→Slave | 保护类型 |
| arvalid | Master→Slave | 地址有效 |
| arready | Slave→Master | 地址就绪 |

### Read Data Channel
| 信号 | 方向 | 描述 |
|------|------|------|
| rdata | Slave→Master | 读数据 |
| rresp | Slave→Master | 响应 |
| rvalid | Slave→Master | 数据有效 |
| rready | Master→Slave | 数据就绪 |

## 关键时序

### 写传输时序

```
         ┌─────┐     ┌─────┐     ┌─────┐
AWVALID ─┘     └─────┘     └───┐ └───
                        ┌───┘
AWREADY ────────────────────┘     (地址握手)

         ┌─────┐     ┌─────┐     ┌─────┐
WVALID  ─┘     └─────┘     └───┐ └───
                        ┌───┘
WREADY  ────────────────────┘     (数据握手)

                        ┌───┐
BRESP   ────────────────────────┐ │
BVALID  ────────────────────────┘ └───
                              ┌───┘
BREADY  ────────────────────────────┘ (响应握手)
```

### 读传输时序

```
         ┌─────┐     ┌─────┐     ┌─────┐
ARVALID ─┘     └─────┘     └───┐ └───
                        ┌───┘
ARREADY ────────────────────┘     (地址握手)

                        ┌───┐ ┌─────┐ ┌─────┐
RDATA   ────────────────────────┐ │  │  │   │ └───┐
                         ┌───┘ └───┘     └───┘
RVALID  ────────────────────────────────┘     (数据握手)

RREADY  ────────────────────────────────────┘
```

## UVM Phase 执行顺序

```
build_phase      ─► 构建组件
connect_phase    ─► 连接组件
run_phase       ─► 执行测试
  ├─ pre_reset_phase
  ├─ reset_phase
  ├─ pre_configure_phase
  ├─ configure_phase
  ├─ pre_main_phase
  ├─ main_phase     ◄── 主要测试在这里执行
  ├─ post_main_phase
  ├─ shutdown_phase
extract_phase    ─► 提取数据
check_phase       ─► 检查结果
report_phase     ─► 打印报告
final_phase      ─► 清理
```

## 配置选项

### 环境配置
```systemverilog
// 通过 uvm_config_db 配置
uvm_config_db#(int)::set(null, "*", "recording_detail", 0);
uvm_config_db#(bit)::set(null, "*", "check_enable", 1);
uvm_config_db#(bit)::set(null, "*", "coverage_enable", 1);
```

### Driver 配置
```systemverilog
uvm_config_db#(uvm_active_passive_enum)::set(this, "axi_agnt", "is_active", UVM_ACTIVE);
```

### Scoreboard 配置
```systemverilog
uvm_config_db#(bit)::set(null, "env.scoreboard", "check_enable", 1);
```

## 覆盖率模型

### 覆盖点 (Coverage Points)

| 覆盖点 | 描述 | Bins |
|--------|------|------|
| cp_cmd | 命令类型 | READ, WRITE |
| cp_addr | 地址范围 | REG_0~3, REG_S, OTHER |
| cp_len | 突发长度 | 1, 2, 4, 8, 16, OTHER |
| cp_size | 数据大小 | 1, 2, 4, 8 |
| cp_burst | 突发类型 | FIXED, INCR, WRAP |

### 交叉覆盖

| 交叉覆盖 | 描述 |
|----------|------|
| cmd_x_burst | 命令 × 突发类型 |
| len_x_size | 长度 × 大小 |
| addr_x_cmd | 地址 × 命令 |
